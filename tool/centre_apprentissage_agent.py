#!/usr/bin/env python3
"""Sentinel CI — autonomous Centre d'Apprentissage content agent.

Default: audit only.
With OPENAI_API_KEY: generate missing chapters in batches and write them to the
dedicated _catalogueAgent block. Firestore publication is deliberately outside
this agent: generated resources remain drafts until a human publishes them.
"""

import json, os, re, sys, urllib.request
from pathlib import Path

PROGRAMME = Path("lib/centre_apprentissage/donnees/programme_officiel.dart")
CONTENU = Path("lib/centre_apprentissage/donnees/contenu_officiel.dart")
REPORT = Path("tool/centre_apprentissage_agent_report.json")
MODEL = os.getenv("CENTRE_AGENT_MODEL", "gpt-5.6-luna")
BATCH_SIZE = int(os.getenv("CENTRE_AGENT_BATCH_SIZE", "3"))
GENERATE = "--generate" in sys.argv and bool(os.getenv("OPENAI_API_KEY"))

def parse_programmes(text):
    out = {}
    entry = re.compile(r"""['"]([^'"]+)['"]\s*:\s*\[([\s\S]*?)\n\s*\],""")
    chapter = re.compile(r"""ChapitreOfficiel\(\s*(\d+)\s*,\s*['"]([^'"]+)['"]\s*,\s*['"]([^'"]*)['"]""")
    for m in entry.finditer(text):
        rows = []
        for c in chapter.finditer(m.group(2)):
            rows.append({"order": int(c.group(1)), "title": c.group(2), "description": c.group(3)})
        if rows:
            out[m.group(1)] = rows
    return out

def parse_content_keys(text):
    return set(re.findall(r"""['"]([^'"]+_ch\d+)['"]\s*:""", text))

def chapter_id(programme_key, order):
    return f"{programme_key}_ch{order:02d}"

def extract_output_text(data):
    if isinstance(data, dict):
        if data.get("output_text") and isinstance(data["output_text"], str):
            return data["output_text"]
        for value in data.values():
            found = extract_output_text(value)
            if found:
                return found
    elif isinstance(data, list):
        for value in data:
            found = extract_output_text(value)
            if found:
                return found
    return ""

def call_model(chapters):
    schema = {
        "type": "object",
        "properties": {
            "entries": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "chapter_id": {"type": "string"},
                        "dart_expression": {"type": "string"}
                    },
                    "required": ["chapter_id", "dart_expression"],
                    "additionalProperties": False
                }
            }
        },
        "required": ["entries"],
        "additionalProperties": False
    }

    prompt = """Tu es l'agent pédagogique de Sentinel CI.
Génère du contenu scolaire en français pour les chapitres fournis.
Le programme officiel donne les titres et descriptions : respecte-les strictement.
Le contenu produit est une création pédagogique Sentinel CI, pas un texte présenté
comme une citation officielle.

Pour CHAQUE chapitre, retourne exactement une expression Dart List<RessourceOfficielle>
avec 6 ressources :
1 cours, 1 renforcement, 2 exercices (facile puis moyen), 1 fiche, 1 quiz.
Le quiz doit avoir 3 questions avec choix et bonnesReponses.
Utilise uniquement les API visibles dans ce projet :
TypeRessource.cours, renforcement, exercice, fiche, quiz ;
Difficulte.facile et Difficulte.moyen ;
RessourceOfficielle(...) et QuestionQuiz(...).
N'inclus jamais de clé de map, import, classe, commentaire ou markdown.
Le résultat doit être directement insérable après :
'chapter_id': <expression>,
Chaque exercice doit avoir un énoncé et une solution cohérente.
Évite les formulations génériques et adapte réellement les exercices au chapitre.

Chapitres :
""" + json.dumps(chapters, ensure_ascii=False, indent=2)

    body = {
        "model": MODEL,
        "input": prompt,
        "text": {
            "format": {
                "type": "json_schema",
                "name": "sentinel_content_batch",
                "strict": True,
                "schema": schema
            }
        }
    }
    req = urllib.request.Request(
        "https://api.openai.com/v1/responses",
        data=json.dumps(body, ensure_ascii=False).encode(),
        headers={
            "Authorization": "Bearer " + os.environ["OPENAI_API_KEY"],
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=180) as response:
        data = json.load(response)
    raw = extract_output_text(data)
    if not raw:
        raise RuntimeError("Réponse IA vide.")
    return json.loads(raw)

def validate_entry(entry, expected_id):
    key = entry["chapter_id"]
    dart = entry["dart_expression"].strip()
    if key != expected_id:
        raise ValueError(f"ID inattendu: {key} != {expected_id}")
    if not dart.startswith("[") or not dart.endswith("]"):
        raise ValueError(f"Expression Dart invalide pour {key}")
    count = len(re.findall(r"RessourceOfficielle\s*\(", dart))
    if count != 6:
        raise ValueError(f"{key}: {count} ressources au lieu de 6")
    for token in [
        "TypeRessource.cours",
        "TypeRessource.renforcement",
        "TypeRessource.exercice",
        "TypeRessource.fiche",
        "TypeRessource.quiz",
    ]:
        if token not in dart:
            raise ValueError(f"{key}: ressource manquante {token}")
    return dart

def append_entries(source, entries):
    marker = "final Map<String, List<RessourceOfficielle>> _catalogueAgent = <String, List<RessourceOfficielle>>{"
    start = source.find(marker)
    if start < 0:
        raise RuntimeError("Bloc _catalogueAgent introuvable.")
    end = source.find("\n};", start)
    if end < 0:
        raise RuntimeError("Fin du bloc _catalogueAgent introuvable.")
    block = []
    for key, dart in entries:
        block.append(f"  {key!r}: {dart},")
    insertion = "\n" + "\n".join(block) + "\n"
    return source[:end] + insertion + source[end:]

def main():
    programmes = parse_programmes(PROGRAMME.read_text(encoding="utf-8"))
    content_text = CONTENU.read_text(encoding="utf-8")
    existing = parse_content_keys(content_text)

    missing = []
    for programme_key, chapters in programmes.items():
        for chapter in chapters:
            cid = chapter_id(programme_key, chapter["order"])
            if cid not in existing:
                missing.append({
                    "chapter_id": cid,
                    "programme": programme_key,
                    **chapter,
                })

    report = {
        "annee": "2026-2027",
        "programme": "dpfc",
        "model": MODEL,
        "mode": "generate" if GENERATE else "audit",
        "programmes": len(programmes),
        "existing_content_chapters": len(existing),
        "missing_before_generation": len(missing),
        "generated": [],
        "errors": [],
        "publication": "disabled",
    }

    if not missing:
        REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print("AGENT: aucun chapitre manquant.")
        return 0

    if not GENERATE:
        report["next_action"] = "Configurer OPENAI_API_KEY puis lancer avec --generate."
        REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"AGENT: {len(missing)} chapitre(s) manquant(s). Mode audit, aucune génération.")
        return 0

    generated = []
    for i in range(0, len(missing), BATCH_SIZE):
        batch = missing[i:i+BATCH_SIZE]
        try:
            response = call_model(batch)
            by_id = {x["chapter_id"]: x for x in response.get("entries", [])}
            for chapter in batch:
                cid = chapter["chapter_id"]
                if cid not in by_id:
                    raise ValueError(f"Réponse IA incomplète: {cid}")
                dart = validate_entry(by_id[cid], cid)
                generated.append((cid, dart))
                report["generated"].append(cid)
        except Exception as exc:
            report["errors"].append({"batch": [x["chapter_id"] for x in batch], "error": str(exc)})
            break

    if generated:
        new_source = append_entries(content_text, generated)
        CONTENU.write_text(new_source, encoding="utf-8")

    report["missing_after_generation"] = len(missing) - len(generated)
    report["status"] = "partial" if report["errors"] else "generated"
    REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    if report["errors"]:
        print("AGENT: arrêt sur anomalie; les ressources générées restent en brouillon.")
        return 1
    print(f"AGENT: {len(generated)} chapitre(s) généré(s); publication automatique désactivée.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

# ============================================================
#  SENTINEL CI — Rendre le site web 100 % autonome
#  Exécuté par Codemagic APRÈS `flutter build web`.
#
#  Problème résolu : certains opérateurs (dont en Côte d'Ivoire)
#  bloquent les serveurs Google (www.gstatic.com, fonts.gstatic.com).
#  Sans ce script, le site reste bloqué sur l'écran de chargement.
#
#  Ce script :
#   1. Télécharge les briques Firebase JS et les héberge sur le site
#      (dossier /firebasejs/), puis réécrit toutes les adresses.
#   2. Télécharge les polices émojis/symboles (dossier /gfonts/)
#      et réécrit leurs adresses.
#   3. Met à jour l'empreinte de main.dart.js dans le service worker
#      pour que la mise en cache reste cohérente.
# ============================================================
import glob
import hashlib
import io
import json
import os
import re
import sys
import tarfile
import urllib.request

WEB = os.path.join("build", "web")
MAIN = os.path.join(WEB, "main.dart.js")
SW = os.path.join(WEB, "flutter_service_worker.js")

# Familles de polices Google à embarquer (émojis et symboles).
# Les autres familles de secours resteront non embarquées : elles
# échoueront vite en local (404) au lieu de bloquer sur le réseau.
FAMILLES_POLICES = (
    "notocoloremoji",
    "notoemoji",
    "notosanssymbols",
    "notosanssymbols2",
    "notosansmath",
)


def telecharger(url: str) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def principal() -> int:
    if not os.path.exists(MAIN):
        print(f"ERREUR : {MAIN} introuvable. Lancer apres 'flutter build web'.")
        return 1

    with open(MAIN, encoding="utf-8") as f:
        js = f.read()

    # ---------- 1) FIREBASE ----------
    versions = []
    m = re.search(r"gstatic\.com/firebasejs/(\d+\.\d+\.\d+)/", js)
    if m:
        versions.append(m.group(1))
        print(f"Version Firebase detectee dans main.dart.js : {m.group(1)}")
    # Toujours completer avec TOUTES les versions presentes dans le pub-cache :
    # si plusieurs cohabitent, on heberge sous chacune (aucun risque de rater
    # celle que l'application demandera au chargement).
    candidats = glob.glob(
        os.path.expanduser(
            "~/.pub-cache/hosted/*/firebase_core_web-*/lib/src/firebase_sdk_version.dart"
        )
    )
    for c in sorted(candidats, reverse=True):
        v = re.search(r"['\"](\d+\.\d+\.\d+)['\"]", open(c).read())
        if v and v.group(1) not in versions:
            versions.append(v.group(1))
            print(f"Version Firebase detectee via pub-cache : {v.group(1)}")
    version = versions[0] if versions else None
    if not version and "firebasejs" in js:
        print("ERREUR : version Firebase introuvable (ni dans le JS ni dans le pub-cache).")
        return 1

    if version:
        prefixe = f"https://www.gstatic.com/firebasejs/{version}/"
        dossier_fb = os.path.join(WEB, "firebasejs")
        os.makedirs(dossier_fb, exist_ok=True)

        # Le paquet npm 'firebase' contient exactement les memes bundles
        # navigateur que le CDN gstatic (firebase-app.js, firebase-auth.js...).
        url_npm = f"https://registry.npmjs.org/firebase/-/firebase-{version}.tgz"
        print(f"Telechargement du paquet Firebase : {url_npm}")
        archive = tarfile.open(fileobj=io.BytesIO(telecharger(url_npm)), mode="r:gz")
        bundles = {}
        for membre in archive.getmembers():
            nom = os.path.basename(membre.name)
            if (
                membre.name.startswith("package/firebase-")
                and nom.endswith(".js")
                and "/" not in membre.name[len("package/"):]
            ):
                bundles[nom] = archive.extractfile(membre).read().decode("utf-8")
        print(f"{len(bundles)} bundles disponibles dans le paquet npm.")

        # Fichiers reellement references, en partant de main.dart.js
        # puis en suivant les imports internes (ex. firestore -> pipelines).
        # On heberge TOUJOURS le jeu complet des bundles : les noms de
        # fichiers peuvent etre ecrits en morceaux dans le JS compile,
        # impossible de les deviner de facon fiable. Quelques Mo, zero risque.
        necessaires = set(bundles.keys())
        reperes = set(re.compile(r"firebase-[a-z0-9-]+\.js").findall(js))
        print(f"Bundles heberges : {len(necessaires)} (dont {len(reperes)} reperes dans le JS).")

        # Hebergement MULTIPLE : /firebasejs/fichier.js ET
        # /firebasejs/<chaque version>/fichier.js — aucune porte ne reste vide.
        dossiers = [dossier_fb]
        for v in versions:
            d = os.path.join(dossier_fb, v)
            os.makedirs(d, exist_ok=True)
            dossiers.append(d)
        for fichier in sorted(necessaires):
            contenu = bundles.get(fichier)
            if contenu is None:
                continue
            # Imports RELATIFS ("./") : chaque emplacement (racine ou versionne)
            # utilise SES propres copies. Plus jamais deux exemplaires du meme
            # moteur charges en parallele (cause du bug « Component auth has
            # not been registered yet »).
            contenu = contenu.replace(prefixe, "./")
            contenu = contenu.replace("https://www.gstatic.com/firebasejs/", "./")
            for dossier in dossiers:
                with open(os.path.join(dossier, fichier), "w", encoding="utf-8") as f:
                    f.write(contenu)
            print(f"  Heberge : /firebasejs/{fichier} (+ {len(versions)} version(s), imports relatifs)")

        js = js.replace(prefixe, "/firebasejs/")
        js = js.replace("https://www.gstatic.com/firebasejs/", "/firebasejs/")

        # GARDE-FOU : si une brique vitale manque, on FAIT ECHOUER le build
        # (build rouge dans Codemagic) plutot que de casser le site en silence.
        vitales = [
            "firebase-app.js", "firebase-auth.js", "firebase-firestore.js",
            "firebase-firestore-pipelines.js", "firebase-storage.js",
            "firebase-messaging.js",
        ]
        manquantes = [
            v for v in vitales
            if not os.path.exists(os.path.join(dossier_fb, v))
        ]
        if manquantes:
            print(f"ERREUR FATALE : briques manquantes {manquantes} — build stoppe.")
            return 1

    # ---------- 2) POLICES GOOGLE (emojis, symboles) ----------
    # Les adresses peuvent etre stockees en entier OU en morceaux
    # (base + chemin relatif assembles au chargement) : on cherche les deux.
    urls_polices = set(
        re.findall(r"https://fonts\.gstatic\.com/s/[A-Za-z0-9/._-]+", js)
    )
    chemins_relatifs = set(
        re.findall(r"[a-z0-9]+/v[0-9]+/[A-Za-z0-9._-]+?\.(?:woff2|ttf|otf)", js)
    )
    for chemin in chemins_relatifs:
        urls_polices.add("https://fonts.gstatic.com/s/" + chemin)
    embarquees, ignorees = 0, 0
    for url in sorted(urls_polices):
        chemin_relatif = url.split("fonts.gstatic.com/s/", 1)[1]
        famille = chemin_relatif.split("/", 1)[0].lower()
        if famille not in FAMILLES_POLICES:
            ignorees += 1
            continue
        destination = os.path.join(WEB, "gfonts", *chemin_relatif.split("/"))
        os.makedirs(os.path.dirname(destination), exist_ok=True)
        try:
            donnees = telecharger(url)
            # Controle d'integrite : etre sur que c'est bien une police.
            if not (
                donnees[:4] in (b"wOF2", b"wOFF", b"OTTO", b"true")
                or donnees[:4] == b"\x00\x01\x00\x00"
            ):
                raise ValueError("le fichier recu n'est pas une police valide")
            with open(destination, "wb") as f:
                f.write(donnees)
            embarquees += 1
            print(f"  Police embarquee : /gfonts/{chemin_relatif}")
        except Exception as e:  # noqa: BLE001 - on continue, c'est cosmetique
            print(f"  AVERTISSEMENT : echec police {url} : {e}")
    js = js.replace("https://fonts.gstatic.com/s/", "/gfonts/")
    print(f"BILAN POLICES : {embarquees} embarquee(s), {ignorees} famille(s) ignoree(s).")
    if embarquees == 0:
        print("ATTENTION : aucune police emoji embarquee — les emojis resteront en carres.")

    with open(MAIN, "w", encoding="utf-8") as f:
        f.write(js)
    print("main.dart.js reecrit : plus aucune adresse gstatic active.")

    # ---------- 3) SERVICE WORKER (empreinte + casse-cache) ----------
    if os.path.exists(SW):
        empreinte = hashlib.md5(js.encode("utf-8")).hexdigest()
        with open(SW, encoding="utf-8") as f:
            sw = f.read()
        sw2, n = re.subn(
            r'(["\']main\.dart\.js["\']\s*:\s*["\'])[^"\']+(["\'])',
            rf"\g<1>{empreinte}\g<2>",
            sw,
        )
        if n:
            print(f"Service worker mis a jour ({n} empreinte(s) corrigee(s)).")
        else:
            print("Empreinte main.dart.js absente du service worker (format recent).")
        # CASSE-CACHE : on modifie TOUJOURS le service worker a chaque
        # publication. Un service worker different force le navigateur a
        # reinstaller la nouvelle version du site au prochain passage —
        # fini les visiteurs bloques sur une ancienne version.
        import time as _t
        sw2 += "\n// publication sentinel " + str(int(_t.time())) + "\n"
        with open(SW, "w", encoding="utf-8") as f:
            f.write(sw2)
        print("Casse-cache ajoute : les navigateurs se mettront a jour seuls.")
    else:
        print("Pas de flutter_service_worker.js — etape ignoree.")

    # Petit rapport final
    restants = len(re.findall(r"www\.gstatic\.com/firebasejs", js))
    print(f"References gstatic Firebase restantes : {restants} (attendu : 0)")
    print("TERMINE : le site est autonome. ✔")
    return 0


if __name__ == "__main__":
    sys.exit(principal())

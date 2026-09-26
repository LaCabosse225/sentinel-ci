// SENTINEL CI — Validateur du Centre d'Apprentissage
// Exécution : dart run tool/validate_centre_apprentissage.dart

import 'dart:io';

void main() {
  final programme = File('lib/centre_apprentissage/donnees/programme_officiel.dart').readAsStringSync();
  final contenu = File('lib/centre_apprentissage/donnees/contenu_officiel.dart').readAsStringSync();

  final programmes = RegExp(r"^\s*'([^']+)':\s*\[", multiLine: true)
      .allMatches(programme)
      .map((m) => m.group(1)!)
      .toList();

  final chapters = RegExp(r'''['"]([A-Za-z0-9]+(?:_[A-Za-z0-9]+)*_math_ch\d+)['"]\s*:''')
      .allMatches(contenu)
      .map((m) => m.group(1)!)
      .toList();

  final programmeCounts = <String, int>{};
  for (final key in programmes) {
    final pattern =
        "'" + RegExp.escape(key) + r"':\s*\[([\s\S]*?)\n\s*\],";
    final match = RegExp(pattern).firstMatch(programme);
    programmeCounts[key] =
        RegExp(r'ChapitreOfficiel\(').allMatches(match?.group(1) ?? '').length;
  }

  final contentCounts = <String, int>{};
  for (final key in chapters) {
    final base = key.replaceFirst(RegExp(r'_ch\d+$'), '');
    contentCounts[base] = (contentCounts[base] ?? 0) + 1;
  }

  final duplicates = <String>[];
  final seen = <String>{};
  for (final key in chapters) {
    if (!seen.add(key)) duplicates.add(key);
  }

  final missing = <String>[];
  for (final entry in programmeCounts.entries) {
    if (contentCounts[entry.key] != entry.value) {
      missing.add(
        entry.key +
            ': programme=' +
            entry.value.toString() +
            ', contenu=' +
            (contentCounts[entry.key] ?? 0).toString(),
      );
    }
  }

  print('=== SENTINEL CI — CONTROLE DU CATALOGUE ===');
  print('Programmes : ' + programmes.length.toString());
  print('Chapitres  : ' + chapters.length.toString());
  print('Doublons   : ' + duplicates.length.toString());
  print('Anomalies  : ' + missing.length.toString());

  if (duplicates.isNotEmpty) {
    print('DOUBLONS : ' + duplicates.join(', '));
  }
  if (missing.isNotEmpty) {
    print('ANOMALIES :');
    for (final item in missing) print(' - ' + item);
  }

  if (duplicates.isNotEmpty || missing.isNotEmpty) {
    exitCode = 1;
    print('RESULTAT : ECHEC — aucune generation massive ne doit etre lancee.');
  } else {
    print('RESULTAT : OK — catalogue coherent.');
  }
}

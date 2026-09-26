// SENTINEL CI — Validateur universel du Centre d'Apprentissage
// Exécution : dart run tool/validate_centre_apprentissage.dart

import 'dart:convert';
import 'dart:io';

String read(String path) => File(path).readAsStringSync();

Map<String, List<String>> parseProgramme(String source) {
  final result = <String, List<String>>{};
  final entry = RegExp(r"""['"]([^'"]+)['"]\s*:\s*\[([\s\S]*?)\n\s*\],""");
  final chapter = RegExp(r"""ChapitreOfficiel\(\s*(\d+)\s*,\s*['"]([^'"]+)['"]""");
  for (final match in entry.allMatches(source)) {
    final key = match.group(1)!;
    final body = match.group(2)!;
    final chapters = <String>[];
    for (final c in chapter.allMatches(body)) chapters.add(c.group(2)!);
    if (chapters.isNotEmpty) result[key] = chapters;
  }
  return result;
}

Map<String, List<String>> parseContenu(String source) {
  final result = <String, List<String>>{};
  final keyPattern = RegExp(r"""['"]([^'"]+_ch\d+)['"]\s*:""");
  for (final match in keyPattern.allMatches(source)) {
    final key = match.group(1)!;
    final base = key.replaceFirst(RegExp(r'_ch\d+$'), '');
    (result[base] ??= <String>[]).add(key);
  }
  return result;
}

String normalizeContentBase(String base) {
  final sep = base.indexOf('__');
  if (sep >= 0) {
    final prefix = base.substring(0, sep).split('_');
    final suffix = base.substring(sep + 2);
    if (prefix.length >= 3) {
      final niveau = prefix[2];
      final serie = prefix.length >= 4 ? prefix[3] : '';
      return serie.isEmpty ? '${niveau}_${suffix}' : '${niveau}_${serie}_${suffix}';
    }
  }
  return base;
}

void main() {
  final programmeSource = read('lib/centre_apprentissage/donnees/programme_officiel.dart');
  final contenuSource = read('lib/centre_apprentissage/donnees/contenu_officiel.dart');
  final programmes = parseProgramme(programmeSource);
  final contenusBruts = parseContenu(contenuSource);

  final contenus = <String, List<String>>{};
  for (final entry in contenusBruts.entries) {
    final base = normalizeContentBase(entry.key);
    contenus.putIfAbsent(base, () => <String>[]).addAll(entry.value);
  }

  final duplicates = <String>[];
  for (final entry in contenusBruts.entries) {
    final seen = <String>{};
    for (final key in entry.value) {
      if (!seen.add(key)) duplicates.add(key);
    }
  }

  final anomalies = <Map<String, dynamic>>[];
  final matched = <String>{};

  for (final entry in programmes.entries) {
    final expected = entry.value.length;
    final actualKeys = contenus[entry.key] ?? const <String>[];
    if (actualKeys.length != expected) {
      anomalies.add({
        'programme': entry.key,
        'type': 'chapter_count_mismatch',
        'expected': expected,
        'actual': actualKeys.length,
      });
    }
    matched.add(entry.key);
  }

  final orphanContent = contenus.keys.where((key) => !matched.contains(key)).toList()..sort();
  for (final key in orphanContent) {
    anomalies.add({
      'programme': key,
      'type': 'orphan_content',
      'expected': 0,
      'actual': contenus[key]!.length,
    });
  }

  final report = <String, dynamic>{
    'annee': '2026-2027',
    'programme': 'dpfc',
    'programmes': programmes.length,
    'chapitresProgramme': programmes.values.fold<int>(0, (sum, e) => sum + e.length),
    'chapitresContenu': contenusBruts.values.fold<int>(0, (sum, e) => sum + e.length),
    'doublons': duplicates,
    'anomalies': anomalies,
    'orphanContent': orphanContent,
    'ok': duplicates.isEmpty && anomalies.isEmpty,
  };

  File('tool/centre_apprentissage_rapport.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(report) + '\n',
  );

  stdout.writeln('=== SENTINEL CI — CONTROLE UNIVERSEL ===');
  stdout.writeln('Programmes : ${programmes.length}');
  stdout.writeln('Chapitres programme : ${report['chapitresProgramme']}');
  stdout.writeln('Chapitres contenu : ${report['chapitresContenu']}');
  stdout.writeln('Doublons : ${duplicates.length}');
  stdout.writeln('Anomalies : ${anomalies.length}');
  stdout.writeln('Rapport : tool/centre_apprentissage_rapport.json');

  if (duplicates.isNotEmpty) stdout.writeln('DOUBLONS : ${duplicates.join(', ')}');
  if (anomalies.isNotEmpty) {
    stdout.writeln('ANOMALIES :');
    for (final anomaly in anomalies) stdout.writeln(' - $anomaly');
  }

  if (report['ok'] != true) {
    stdout.writeln('RESULTAT : ECHEC — aucune generation massive ne doit etre lancee.');
    exitCode = 1;
  } else {
    stdout.writeln('RESULTAT : OK — catalogue coherent.');
  }
}

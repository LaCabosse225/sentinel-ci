// ============================================================================
//  SENTINEL CI — MAINTENANCE
//  Detection et nettoyage des donnees orphelines
//  Fichier : lib/maintenance/menage.dart
//
//  POURQUOI CET OUTIL
//  Quand une ecole est supprimee depuis la console Firebase, ou quand elle
//  l'a ete avant la mise en place de la suppression en cascade, ses classes,
//  ses comptes et ses notes restent en base. Ils n'appartiennent plus a
//  personne : ce sont des donnees ORPHELINES. Elles polluent les listes
//  (une classe « 6eme A » sans etablissement) et faussent les comptages.
//
//  L'outil se lit en deux temps :
//   1. DIAGNOSTIC — lecture seule, il compte et n'efface rien.
//   2. NETTOYAGE — suppression par lots, apres double confirmation.
//
//  Reserve au SUPER ADMIN. Un co-administrateur ne supprime jamais de
//  donnees, conformement a la regle deja appliquee partout dans l'app.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';

// ============================================================================
//  1. RESULTAT DU DIAGNOSTIC
// ============================================================================

class OrphelinsCollection {
  final String collection;
  final int total;
  final int orphelins;
  final Set<String> ecolesFantomes;

  const OrphelinsCollection({
    required this.collection,
    required this.total,
    required this.orphelins,
    required this.ecolesFantomes,
  });
}

class Diagnostic {
  final List<OrphelinsCollection> details;
  final Set<String> ecolesExistantes;
  final Set<String> ecolesFantomes;

  const Diagnostic({
    required this.details,
    required this.ecolesExistantes,
    required this.ecolesFantomes,
  });

  int get totalOrphelins =>
      details.fold<int>(0, (s, d) => s + d.orphelins);

  List<OrphelinsCollection> get concernees =>
      details.where((d) => d.orphelins > 0).toList();
}

// ============================================================================
//  2. SERVICE
// ============================================================================

class ServiceMenage {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Toutes les collections dont les documents portent un champ 'ecoleId'.
  /// Cette liste doit rester alignee sur supprimerEcoleEtDependances.
  static const List<String> collections = [
    'classes',
    'utilisateurs',
    'notes',
    'absences',
    'devoirs',
    'lecons',
    'agenda',
    'alertes',
    'rattrapages',
    'matieres',
    'emploiDuTemps',
    // Collection historique, avec un « t » minuscule. Firestore la traite
    // comme une collection distincte : sans cette ligne, ses documents
    // orphelins resteraient invisibles au diagnostic.
    'emploiDutemps',
    'vieScolaire',
    'paiements',
    'messages',
    'ca_ressources', // contenu prive du Centre d'Apprentissage
  ];

  // --------------------------------------------------------------------------
  //  DIAGNOSTIC — lecture seule
  // --------------------------------------------------------------------------

  static Future<Diagnostic> analyser() async {
    // 1. Les ecoles qui existent reellement
    final ecolesSnap = await _db.collection('ecoles').get();
    final existantes = ecolesSnap.docs.map((d) => d.id).toSet();

    // 2. Chaque collection est passee en revue
    final details = <OrphelinsCollection>[];
    final fantomesGlobal = <String>{};

    for (final col in collections) {
      try {
        final snap = await _db.collection(col).get();
        int orphelins = 0;
        final fantomes = <String>{};
        for (final d in snap.docs) {
          final e = (d.data()['ecoleId'] ?? '').toString();
          // Un champ vide n'est PAS un orphelin : c'est le cas du contenu
          // national du Centre d'Apprentissage, qui n'appartient a aucune
          // ecole par conception.
          if (e.isEmpty) continue;
          if (!existantes.contains(e)) {
            orphelins++;
            fantomes.add(e);
          }
        }
        fantomesGlobal.addAll(fantomes);
        details.add(OrphelinsCollection(
          collection: col,
          total: snap.docs.length,
          orphelins: orphelins,
          ecolesFantomes: fantomes,
        ));
      } catch (_) {
        // Collection absente ou illisible : on l'ignore sans bloquer.
      }
    }

    return Diagnostic(
      details: details,
      ecolesExistantes: existantes,
      ecolesFantomes: fantomesGlobal,
    );
  }

  // --------------------------------------------------------------------------
  //  NETTOYAGE — suppression par lots de 400
  // --------------------------------------------------------------------------

  static Future<int> nettoyer(Set<String> ecolesValides) async {
    int total = 0;
    for (final col in collections) {
      try {
        final snap = await _db.collection(col).get();
        final aSupprimer = snap.docs.where((d) {
          final e = (d.data()['ecoleId'] ?? '').toString();
          return e.isNotEmpty && !ecolesValides.contains(e);
        }).toList();

        for (var i = 0; i < aSupprimer.length; i += 400) {
          final fin =
              (i + 400) < aSupprimer.length ? (i + 400) : aSupprimer.length;
          final batch = _db.batch();
          for (final d in aSupprimer.sublist(i, fin)) {
            batch.delete(d.reference);
          }
          await batch.commit();
          total += fin - i;
        }
      } catch (_) {}
    }
    return total;
  }
}

// ============================================================================
//  3. ECRAN
// ============================================================================

class MenagePage extends StatefulWidget {
  final AppUser user;
  const MenagePage({super.key, required this.user});
  @override
  State<MenagePage> createState() => _MenagePageState();
}

class _MenagePageState extends State<MenagePage> {
  Diagnostic? _resultat;
  bool _analyse = false;
  bool _nettoyage = false;

  Future<void> _lancerAnalyse() async {
    setState(() => _analyse = true);
    try {
      final d = await ServiceMenage.analyser();
      if (mounted) setState(() { _resultat = d; _analyse = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _analyse = false);
        showSnack(context, 'Erreur : $e', error: true);
      }
    }
  }

  Future<void> _lancerNettoyage() async {
    final d = _resultat;
    if (d == null || d.totalOrphelins == 0) return;

    final ok1 = await confirmerDialog(
        context,
        'Supprimer ${d.totalOrphelins} document(s) ?',
        'Ces donnees sont rattachees a ${d.ecolesFantomes.length} etablissement(s) '
        'qui n existent plus. Elles seront definitivement effacees. '
        'Cette action est irreversible.');
    if (!ok1 || !mounted) return;

    // Seconde confirmation : saisir le nombre exact.
    final ctrl = TextEditingController();
    final ok2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Confirmation finale'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
                'Pour confirmer, saisissez le nombre exact de documents a '
                'supprimer :\n\n${d.totalOrphelins}',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Nombre', border: OutlineInputBorder())),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                  ctx, ctrl.text.trim() == '${d.totalOrphelins}'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red, foregroundColor: Colors.white),
              child: const Text('Supprimer definitivement'),
            ),
          ],
        ),
      ),
    );
    if (ok2 != true || !mounted) return;

    setState(() => _nettoyage = true);
    try {
      final n = await ServiceMenage.nettoyer(d.ecolesExistantes);
      if (!mounted) return;
      setState(() { _nettoyage = false; _resultat = null; });
      showSnack(context, '$n document(s) supprime(s). Relancez l analyse.');
    } catch (e) {
      if (mounted) {
        setState(() => _nettoyage = false);
        showSnack(context, 'Erreur : $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.user.estSuperAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Maintenance')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Text(
                'Cet outil supprime des donnees. Il est reserve au super '
                'administrateur.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted)),
          ),
        ),
      );
    }

    final d = _resultat;

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance des donnees')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SCCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                Row(children: [
                  Icon(Icons.cleaning_services_rounded,
                      size: 20, color: AppColors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Donnees orphelines',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ]),
                SizedBox(height: 8),
                Text(
                    'Quand une ecole est supprimee directement dans la console '
                    'Firebase, ses classes, ses comptes et ses notes restent en '
                    'base sans etablissement. Cet outil les repere et permet de '
                    'les effacer.',
                    style: TextStyle(
                        fontSize: 12.5, height: 1.5, color: AppColors.textMuted)),
                SizedBox(height: 8),
                Text(
                    'L analyse est en lecture seule : elle ne supprime rien.',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green)),
              ])),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_analyse || _nettoyage) ? null : _lancerAnalyse,
              icon: _analyse
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.search_rounded, size: 18),
              label: Text(_analyse ? 'Analyse en cours...' : 'Lancer l analyse'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 18),

          if (d != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: d.totalOrphelins == 0
                      ? AppColors.greenBg
                      : AppColors.orangeBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: d.totalOrphelins == 0
                          ? AppColors.green
                          : AppColors.orange)),
              child: Row(children: [
                Icon(
                    d.totalOrphelins == 0
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    color: d.totalOrphelins == 0
                        ? AppColors.green
                        : AppColors.orange,
                    size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            d.totalOrphelins == 0
                                ? 'Base propre'
                                : '${d.totalOrphelins} document(s) orphelin(s)',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: d.totalOrphelins == 0
                                    ? AppColors.green
                                    : AppColors.orange)),
                        const SizedBox(height: 2),
                        Text(
                            d.totalOrphelins == 0
                                ? '${d.ecolesExistantes.length} ecole(s) enregistree(s), aucune donnee sans etablissement.'
                                : 'Rattaches a ${d.ecolesFantomes.length} etablissement(s) supprime(s).',
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.textMain)),
                      ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            if (d.concernees.isNotEmpty) ...[
              SectionTitle('Detail par collection'),
              SCCard(
                  child: Column(
                      children: List.generate(d.concernees.length, (i) {
                final c = d.concernees[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.collection,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                            Text('${c.total} document(s) au total',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.redBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('${c.orphelins}',
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.red)),
                    ),
                  ]),
                );
              }))),
              const SizedBox(height: 16),

              SectionTitle('Identifiants des ecoles disparues'),
              SCCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: d.ecolesFantomes
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Text(e,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textMuted)),
                              ))
                          .toList())),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _nettoyage ? null : _lancerNettoyage,
                  icon: _nettoyage
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.delete_forever_rounded, size: 18),
                  label: Text(_nettoyage
                      ? 'Suppression en cours...'
                      : 'Supprimer les donnees orphelines'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                  'Verifiez le detail ci-dessus avant de supprimer. Une double '
                  'confirmation vous sera demandee.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

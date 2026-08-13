// ============================================================================
//  SENTINEL CI — SENTINELLE INSIGHT
//  Ecran cote ECOLE : direction, super admin, professeur principal
//  Fichier : lib/insight/ecran_insight.dart
//
//  Vue de pilotage : factuelle, chiffree, sans menagement inutile.
//  Elle s'adresse a des professionnels. La vue destinee aux familles est
//  dans insight_parent.dart et emploie un tout autre registre.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'moteur_insight.dart';

// ============================================================================
//  ECRAN — TABLEAU DE BORD PAR CLASSE
// ============================================================================

class InsightPage extends StatefulWidget {
  final AppUser user;
  const InsightPage({super.key, required this.user});
  @override
  State<InsightPage> createState() => _InsightPageState();
}

class _InsightPageState extends State<InsightPage> {
  String? _classeId;
  String? _classeNom;
  Future<List<AnalyseEleve>>? _analyse;

  bool get _estStaff =>
      widget.user.role == UserRole.admin ||
      widget.user.role == UserRole.directeur;

  @override
  void initState() {
    super.initState();
    // Le professeur principal arrive directement sur sa classe.
    if (widget.user.role == UserRole.prof &&
        (widget.user.classePrincipale ?? '').isNotEmpty) {
      _classeId = widget.user.classePrincipale;
      _lancer();
    }
  }

  void _lancer() {
    if (_classeId == null) return;
    setState(() {
      _analyse = MoteurInsight.analyserClasse(
          ecoleId: widget.user.school, classeId: _classeId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reserve a la direction et aux professeurs principaux.
    final autorise = _estStaff ||
        (widget.user.role == UserRole.prof && widget.user.estPrincipal);
    if (!autorise) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
              'Sentinelle Insight est reserve a la direction et aux '
              'professeurs principaux.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ---- Bandeau ----
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF062E1A), AppColors.green]),
              image: const DecorationImage(
                  image: AssetImage('assets/images/motif.png'),
                  repeat: ImageRepeat.repeat),
              borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Sentinelle Insight',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Reperer les difficultes avant qu il ne soit trop tard',
                style: TextStyle(color: Colors.white70, fontSize: 12.5)),
          ]),
        ),
        const SizedBox(height: 18),

        // ---- Choix de la classe ----
        if (_estStaff) ...[
          SCCard(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamClasses(widget.user.school),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Text('Chargement des classes...',
                    style: TextStyle(color: AppColors.textMuted));
              }
              final classes = snap.data!.docs;
              if (classes.isEmpty) {
                return const Text('Aucune classe enregistree.',
                    style: TextStyle(color: AppColors.textMuted));
              }
              return DropdownButtonFormField<String>(
                value: _classeId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Classe a analyser'),
                hint: const Text('Choisir une classe'),
                items: classes.map((d) {
                  final m = d.data() as Map<String, dynamic>;
                  return DropdownMenuItem(
                      value: d.id, child: Text(m['nom'] ?? d.id));
                }).toList(),
                onChanged: (v) {
                  final doc = classes.firstWhere((c) => c.id == v);
                  _classeId = v;
                  _classeNom = ((doc.data() as Map)['nom'] ?? '').toString();
                  _lancer();
                },
              );
            },
          )),
          const SizedBox(height: 16),
        ],

        if (_analyse == null)
          SCCard(
              child: const Text(
                  'Choisissez une classe pour lancer l analyse.',
                  style: TextStyle(color: AppColors.textMuted)))
        else
          FutureBuilder<List<AnalyseEleve>>(
            future: _analyse,
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Analyse des resultats en cours...',
                        style: TextStyle(color: AppColors.textMuted)),
                  ]),
                );
              }
              final list = snap.data!;
              if (list.isEmpty) {
                return SCCard(
                    child: const Text('Aucun eleve dans cette classe.',
                        style: TextStyle(color: AppColors.textMuted)));
              }

              final prioritaires = list
                  .where((a) => a.niveau == NiveauAttention.prioritaire)
                  .length;
              final surveiller = list
                  .where((a) => a.niveau == NiveauAttention.surveiller)
                  .length;
              final ok =
                  list.where((a) => a.niveau == NiveauAttention.aucun).length;

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Synthese ----
                    Row(children: [
                      _pastille('🔴', '$prioritaires', 'Prioritaires',
                          AppColors.red, AppColors.redBg),
                      const SizedBox(width: 10),
                      _pastille('🟡', '$surveiller', 'A surveiller',
                          AppColors.gold, AppColors.goldBg),
                      const SizedBox(width: 10),
                      _pastille('🟢', '$ok', 'Rien a signaler',
                          AppColors.green, AppColors.greenBg),
                    ]),
                    const SizedBox(height: 18),
                    SectionTitle(_classeNom == null
                        ? 'Eleves'
                        : 'Eleves — $_classeNom'),
                    ...list.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ligneEleve(a),
                        )),
                    const SizedBox(height: 10),
                    SCCard(
                        child: Row(children: const [
                      Icon(Icons.info_outline_rounded,
                          size: 18, color: AppColors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            'Insight signale, il ne decide pas. Chaque alerte '
                            'indique sur quoi elle repose : verifiez, et faites '
                            'confiance a votre connaissance de l eleve.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ),
                    ])),
                  ]);
            },
          ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _pastille(
      String emoji, String valeur, String label, Color couleur, Color fond) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
            color: fond, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 4),
          Text(valeur,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: couleur)),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 10.5, color: AppColors.textMuted)),
        ]),
      ),
    );
  }

  Widget _ligneEleve(AnalyseEleve a) {
    final couleur = a.niveau == NiveauAttention.prioritaire
        ? AppColors.red
        : a.niveau == NiveauAttention.surveiller
            ? AppColors.gold
            : AppColors.green;

    return SCCard(
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => InsightElevePage(analyse: a))),
        child: Row(children: [
          Container(
            width: 5,
            height: 44,
            decoration: BoxDecoration(
                color: couleur, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.eleveNom,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                      a.nbNotes == 0
                          ? 'Aucune note enregistree'
                          : 'Moyenne ${a.moyenneGenerale.toStringAsFixed(2)}/20'
                              '${a.alertes.isEmpty ? '' : '  ·  ${a.alertes.length} signal(aux)'}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                  if (a.alertes.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: a.alertes.take(3).map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: couleur.withOpacity(.10),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(s.matiere ?? s.titre,
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: couleur)),
                        );
                      }).toList(),
                    ),
                  ],
                ]),
          ),
          Text(a.niveau.emoji, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ]),
      ),
    );
  }
}

// ============================================================================
//  ECRAN — DETAIL D'UN ELEVE (cote ecole)
// ============================================================================

class InsightElevePage extends StatelessWidget {
  final AnalyseEleve analyse;
  const InsightElevePage({super.key, required this.analyse});

  @override
  Widget build(BuildContext context) {
    final a = analyse;
    final couleur = a.niveau == NiveauAttention.prioritaire
        ? AppColors.red
        : a.niveau == NiveauAttention.surveiller
            ? AppColors.gold
            : AppColors.green;

    final matieres = a.moyennesParMatiere.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text(a.eleveNom)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Niveau d'attention ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: couleur.withOpacity(.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: couleur.withOpacity(.5))),
            child: Row(children: [
              Text(a.niveau.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.niveau.libelle,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: couleur)),
                      const SizedBox(height: 2),
                      Text(
                          a.nbNotes == 0
                              ? 'Aucune note enregistree pour le moment'
                              : 'Moyenne generale : ${a.moyenneGenerale.toStringAsFixed(2)}/20 '
                                  'sur ${a.nbNotes} note(s)',
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textMain)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),

          // ---- Alertes ----
          if (a.alertes.isNotEmpty) ...[
            SectionTitle('Ce qui a declenche l alerte'),
            ...a.alertes.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                              color: s.poids >= 2
                                  ? AppColors.red
                                  : AppColors.gold,
                              width: 4),
                          top: const BorderSide(color: AppColors.border),
                          right: const BorderSide(color: AppColors.border),
                          bottom: const BorderSide(color: AppColors.border),
                        )),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.titre,
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(s.explication,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: AppColors.textMuted)),
                        ]),
                  ),
                )),
            const SizedBox(height: 8),
          ],

          // ---- Encouragements ----
          if (a.encouragements.isNotEmpty) ...[
            SectionTitle('A saluer'),
            ...a.encouragements.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppColors.greenBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.green)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.trending_up_rounded,
                                size: 18, color: AppColors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(s.titre,
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.green)),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Text(s.explication,
                              style: const TextStyle(
                                  fontSize: 12.5, height: 1.45)),
                        ]),
                  ),
                )),
            const SizedBox(height: 8),
          ],

          // ---- Assiduite ----
          SectionTitle('Assiduite (30 derniers jours)'),
          SCCard(
              child: Column(children: [
            _ligne('Absences non justifiees', '${a.absencesNonJustifiees}',
                a.absencesNonJustifiees >= SeuilsInsight.absencesAlerte),
            const Divider(height: 18),
            _ligne('Retards', '${a.retards}',
                a.retards >= SeuilsInsight.retardsAlerte),
          ])),
          const SizedBox(height: 16),

          // ---- Moyennes par matiere ----
          if (matieres.isNotEmpty) ...[
            SectionTitle('Moyennes par matiere'),
            SCCard(
                child: Column(
                    children: List.generate(matieres.length, (i) {
              final m = matieres[i];
              final moy = a.moyennesParMatiere[m] ?? 0;
              final faible = moy < SeuilsInsight.matiereFragile;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  Expanded(
                      child: Text(m, style: const TextStyle(fontSize: 13))),
                  Text('${moy.toStringAsFixed(2)}/20',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: faible ? AppColors.red : AppColors.green)),
                ]),
              );
            }))),
            const SizedBox(height: 16),
          ],

          // ---- Suggestion d'action ----
          if (a.alertes.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.blueBg,
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          size: 18, color: AppColors.blue),
                      SizedBox(width: 8),
                      Text('Pistes d accompagnement',
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.blue)),
                    ]),
                    const SizedBox(height: 8),
                    if (a.matieresADeployer.isNotEmpty)
                      Text(
                          'Matieres a travailler en priorite : '
                          '${a.matieresADeployer.join(', ')}.',
                          style: const TextStyle(fontSize: 12.5, height: 1.5)),
                    const SizedBox(height: 4),
                    const Text(
                        'Le Centre d Apprentissage propose des cours de '
                        'renforcement, des exercices corriges et des quiz sur '
                        'ces chapitres.',
                        style: TextStyle(fontSize: 12.5, height: 1.5)),
                    const SizedBox(height: 4),
                    const Text(
                        'Un echange avec la famille reste le levier le plus '
                        'efficace : proposez un rendez-vous.',
                        style: TextStyle(fontSize: 12.5, height: 1.5)),
                  ]),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _ligne(String label, String valeur, bool alerte) => Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        Text(valeur,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: alerte ? AppColors.red : AppColors.textMain)),
      ]);
}

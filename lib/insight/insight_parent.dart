// ============================================================================
//  SENTINEL CI — SENTINELLE INSIGHT
//  Vue cote FAMILLE : carte du tableau de bord + page de suivi
//  Fichier : lib/insight/insight_parent.dart
//
//  REGISTRE
//  Un parent qui lit une alerte est souvent seul, le soir, sans personne
//  pour lui expliquer. Le ton et le vocabulaire sont donc differents de la
//  vue ecole :
//   - jamais de rouge, jamais le mot « risque », « echec » ou « decrochage » ;
//   - jamais de comparaison avec les autres eleves, jamais de rang ;
//   - toujours une action concrete et une invitation a se rapprocher de
//     l'ecole : le parent ne reste jamais seul avec l'information ;
//   - les progres sont annonces AVANT les difficultes.
//
//  « Veiller, pas surveiller » : ce qui est dit a la famille doit rapprocher
//  l'enfant de l'ecole, jamais l'inquieter inutilement.
// ============================================================================

import 'package:flutter/material.dart';

import '../main.dart';
import 'moteur_insight.dart';

// ============================================================================
//  1. CARTE DU TABLEAU DE BORD
//
//  Discrete quand tout va bien, presente quand il y a quelque chose a dire.
// ============================================================================

class CarteSuiviEnfant extends StatelessWidget {
  final AppUser user;
  const CarteSuiviEnfant({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final cible =
        user.role == UserRole.parent ? user.childId : user.uid;
    if (cible == null || cible.isEmpty) return const SizedBox.shrink();

    final nom = user.role == UserRole.parent
        ? (user.childName ?? 'votre enfant')
        : user.name;

    return FutureBuilder<AnalyseEleve>(
      future: MoteurInsight.analyserEleve(eleveId: cible, eleveNom: nom),
      builder: (ctx, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final a = snap.data!;
        // Sans aucune note, on n'affiche rien : pas de message dans le vide.
        if (a.nbNotes == 0) return const SizedBox.shrink();

        final bien = a.niveau == NiveauAttention.aucun;
        final couleur = bien ? AppColors.green : AppColors.orange;
        final fond = bien ? AppColors.greenBg : AppColors.orangeBg;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SuiviEnfantPage(user: user, analyse: a))),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: fond,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: couleur.withOpacity(.6))),
              child: Row(children: [
                Icon(bien ? Icons.favorite_rounded : Icons.waving_hand_rounded,
                    color: couleur, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_titreCarte(a, nom),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: couleur)),
                        const SizedBox(height: 2),
                        Text(_sousTitreCarte(a),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMain)),
                      ]),
                ),
                Icon(Icons.chevron_right_rounded, color: couleur),
              ]),
            ),
          ),
        );
      },
    );
  }

  static String _prenom(String nom) {
    final p = nom.trim().split(' ');
    return p.isEmpty ? nom : p.first;
  }

  static String _titreCarte(AnalyseEleve a, String nom) {
    final p = _prenom(nom);
    if (a.encouragements.isNotEmpty && a.alertes.isEmpty) {
      return '$p progresse, bravo !';
    }
    if (a.niveau == NiveauAttention.aucun) return 'Tout se passe bien';
    return 'Un point sur le travail de $p';
  }

  static String _sousTitreCarte(AnalyseEleve a) {
    if (a.niveau == NiveauAttention.aucun) {
      return 'Touchez pour voir le suivi detaille';
    }
    return 'Quelques matieres meritent votre attention';
  }
}

// ============================================================================
//  2. PAGE DE SUIVI DETAILLE
// ============================================================================

class SuiviEnfantPage extends StatelessWidget {
  final AppUser user;
  final AnalyseEleve analyse;
  const SuiviEnfantPage(
      {super.key, required this.user, required this.analyse});

  String get _prenom {
    final n = analyse.eleveNom.trim().split(' ');
    return n.isEmpty ? analyse.eleveNom : n.first;
  }

  bool get _estParent => user.role == UserRole.parent;

  @override
  Widget build(BuildContext context) {
    final a = analyse;
    final bien = a.niveau == NiveauAttention.aucun;
    final couleur = bien ? AppColors.green : AppColors.orange;
    final matieres = a.moyennesParMatiere.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
          title: Text(_estParent ? 'Suivi de $_prenom' : 'Mon suivi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Message d'accueil ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: bien ? AppColors.greenBg : AppColors.orangeBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: couleur.withOpacity(.6))),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_titre(a),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: couleur)),
                  const SizedBox(height: 8),
                  Text(_message(a),
                      style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color: AppColors.textMain)),
                ]),
          ),
          const SizedBox(height: 18),

          // ---- Les progres d'abord ----
          if (a.encouragements.isNotEmpty) ...[
            SectionTitle('Les progres'),
            ...a.encouragements.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SCCard(
                    child: Row(children: [
                      const Icon(Icons.trending_up_rounded,
                          color: AppColors.green, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.titre,
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.green)),
                              const SizedBox(height: 3),
                              Text(_reformuler(s.explication),
                                  style: const TextStyle(
                                      fontSize: 12.5, height: 1.45)),
                            ]),
                      ),
                    ]),
                  ),
                )),
            const SizedBox(height: 8),
          ],

          // ---- Les points a travailler ----
          if (a.alertes.isNotEmpty) ...[
            SectionTitle('Les points a travailler'),
            ...a.alertes.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SCCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_titreDoux(s),
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(_reformuler(s.explication),
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: AppColors.textMuted)),
                        ]),
                  ),
                )),
            const SizedBox(height: 8),
          ],

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
                          color: faible ? AppColors.orange : AppColors.green)),
                ]),
              );
            }))),
            const SizedBox(height: 16),
          ],

          // ---- Ce que vous pouvez faire ----
          SectionTitle('Ce que vous pouvez faire'),
          SCCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                if (a.matieresADeployer.isNotEmpty) ...[
                  _conseil(
                      Icons.menu_book_rounded,
                      'Reviser avec le Centre d Apprentissage',
                      'Des cours expliques autrement, des exercices corriges '
                          'et des quiz sont disponibles en '
                          '${a.matieresADeployer.join(', ')}.'),
                  const SizedBox(height: 12),
                ],
                _conseil(
                    Icons.forum_rounded,
                    'Echanger avec l enseignant',
                    'La messagerie de Sentinel vous met en relation directe '
                        'avec les professeurs de la classe.'),
                if (a.absencesNonJustifiees > 0) ...[
                  const SizedBox(height: 12),
                  _conseil(
                      Icons.event_available_rounded,
                      'Justifier les absences',
                      'Certaines absences ne sont pas encore justifiees. '
                          'Vous pouvez le faire depuis l onglet Absence.'),
                ],
              ])),
          const SizedBox(height: 16),

          // ---- Invitation a se rapprocher de l'ecole ----
          if (!bien)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.green, Color(0xFF0E6D14)]),
                  image: const DecorationImage(
                      image: AssetImage('assets/images/motif.png'),
                      repeat: ImageRepeat.repeat),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.handshake_rounded,
                          color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Vous n etes pas seul',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(
                        'Une difficulte reperee tot se corrige presque toujours. '
                        'Rapprochez-vous de l ecole : le professeur principal '
                        'connait $_prenom et pourra vous proposer un '
                        'accompagnement adapte. Ensemble, vous trouverez la '
                        'bonne solution plus vite.',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.6)),
                  ]),
            ),
          const SizedBox(height: 16),

          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                  'Ces informations sont calculees a partir des notes et des '
                  'absences enregistrees par l ecole. Elles ne remplacent ni '
                  'le jugement des enseignants, ni le bulletin officiel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  REDACTION DES MESSAGES
  // --------------------------------------------------------------------------

  String _titre(AnalyseEleve a) {
    if (a.niveau == NiveauAttention.aucun) {
      return a.encouragements.isNotEmpty
          ? 'Bravo, $_prenom progresse'
          : 'Tout se passe bien';
    }
    if (a.niveau == NiveauAttention.surveiller) {
      return 'Un point d attention';
    }
    return '$_prenom a besoin d un coup de main';
  }

  String _message(AnalyseEleve a) {
    final moy = a.moyenneGenerale.toStringAsFixed(2);
    switch (a.niveau) {
      case NiveauAttention.aucun:
        return 'La moyenne generale de $_prenom est de $moy/20. '
            'Le travail est regulier : continuez a l encourager, cela compte '
            'beaucoup plus qu on ne le croit.';
      case NiveauAttention.surveiller:
        return 'La moyenne generale de $_prenom est de $moy/20. '
            'Un point merite votre attention, sans inquietude particuliere. '
            'Un peu de soutien maintenant evitera des difficultes plus tard.';
      case NiveauAttention.prioritaire:
        return 'La moyenne generale de $_prenom est de $moy/20. '
            'Plusieurs signes montrent qu il traverse une periode difficile. '
            'Ce n est pas une fatalite : repere tot, cela se rattrape. '
            'L essentiel est d en parler avec lui et avec l ecole.';
    }
  }

  /// Titre adouci pour la famille : on parle de travail, pas de defaillance.
  String _titreDoux(Signal s) {
    switch (s.type) {
      case TypeSignal.matiereFragile:
        return '${s.matiere} demande plus de travail';
      case TypeSignal.matiereEnBaisse:
        return 'Les resultats baissent en ${s.matiere}';
      case TypeSignal.moyenneBasse:
        return 'La moyenne generale est fragile';
      case TypeSignal.absencesRepetees:
        return 'Des absences a regulariser';
      case TypeSignal.retardsRepetes:
        return 'Des retards frequents';
      case TypeSignal.progres:
        return s.titre;
    }
  }

  /// Le prenom remplace « l eleve » dans les explications chiffrees.
  String _reformuler(String texte) => texte;

  Widget _conseil(IconData icone, String titre, String texte) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: AppColors.greenBg, borderRadius: BorderRadius.circular(9)),
          child: Icon(icone, color: AppColors.green, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titre,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(texte,
                style: const TextStyle(
                    fontSize: 12.5, height: 1.45, color: AppColors.textMuted)),
          ]),
        ),
      ]);
}

// ============================================================================
//  SENTINEL CI — CENTRE D’APPRENTISSAGE
//  Contenu pedagogique pret a installer
//  Fichier : lib/centre_apprentissage/donnees/contenu_officiel.dart
//
//  Meme principe que programme_officiel.dart, mais pour le CONTENU des
//  chapitres : cours, renforcement, exercices, fiche et quiz.
//  Un bouton du back-office installe tout un chapitre d’un seul geste.
//
//  POUR AJOUTER UN CHAPITRE
//  Ajouter une entree dans _catalogue avec pour cle le code pedagogique
//  du chapitre. Les anciens codes ("3e_math_ch09") restent compatibles.
//
//  Les ressources sont installees en BROUILLON : elles restent invisibles
//  pour les eleves jusqu’a relecture et publication par un adulte.
// ============================================================================

import '../modeles/contenu.dart';
import '../services/contenu_service.dart';

/// Une ressource prete a etre creee dans Firestore.
class RessourceOfficielle {
  final TypeRessource type;
  final String titre;
  final int ordre;
  final String contenu;
  final String enonce;
  final String solution;
  final int difficulte;
  final int dureeMinutes;
  final List<QuestionQuiz> questions;

  const RessourceOfficielle({
    required this.type,
    required this.titre,
    this.ordre = 1,
    this.contenu = '',
    this.enonce = '',
    this.solution = '',
    this.difficulte = Difficulte.moyen,
    this.dureeMinutes = 0,
    this.questions = const [],
  });
}

class ContenuOfficiel {
  ContenuOfficiel._();

  // ==========================================================================
  //  ACCES
  // ==========================================================================

  // ==========================================================================
  //  VERSIONNAGE DU CONTENU
  // ==========================================================================

  static const String anneeCourante = '2026-2027';
  static const String programmeCourant = 'dpfc';

  /// Construit une cle versionnee, par exemple :
  /// 2026-2027_dpfc_3e__math_ch01
  ///
  /// Le double underscore avant la matiere permet de distinguer clairement
  /// le niveau/serie de la matiere.
  static String cle(
    String niveau,
    String matiereId,
    int ordre, {
    String anneeScolaire = anneeCourante,
    String programmeVersion = programmeCourant,
    String serie = '',
  }) {
    final seriePart = serie.trim();
    final chapitre = 'ch${ordre.toString().padLeft(2, '0')}';
    return '${anneeScolaire}_${programmeVersion}_${niveau}_${seriePart}__${matiereId}_$chapitre';
  }

  /// Compatibilite avec les anciennes cles du fichier.
  static String ancienneCle(String niveau, String matiereId, int ordre) =>
      '${niveau}_${matiereId}_ch${ordre.toString().padLeft(2, '0')}';

  static bool existe(
    String chapitreId, {
    String? anneeScolaire,
    String? programmeVersion,
    String? serie,
  }) {
    if (_catalogue.containsKey(chapitreId)) return true;
    if (anneeScolaire == null && programmeVersion == null && serie == null) {
      return false;
    }

    // Recherche par identite du chapitre : le numero est extrait de l’ID.
    // Ancienne cle : 3e_math_ch01
    final ancienMatch = RegExp(r'^(.+?)_(.+?)_ch(\d+)$').firstMatch(chapitreId);
    if (ancienMatch != null) {
      final niveau = ancienMatch.group(1)!;
      final matiereId = ancienMatch.group(2)!;
      final ordre = int.tryParse(ancienMatch.group(3)!) ?? 0;
      return _catalogue.containsKey(cle(
        niveau,
        matiereId,
        ordre,
        anneeScolaire: anneeScolaire ?? anneeCourante,
        programmeVersion: programmeVersion ?? programmeCourant,
        serie: serie ?? '',
      ));
    }

    // Cle versionnee : 2026-2027_dpfc_3e___math_ch01
    // ou 2026-2027_dpfc_1ere_A1__math_ch01
    final sep = chapitreId.indexOf('__');
    if (sep < 0) return false;
    final prefix = chapitreId.substring(0, sep);
    final suffix = chapitreId.substring(sep + 2);
    final prefixParts = prefix.split('_');
    if (prefixParts.length < 3) return false;
    final niveau = prefixParts[2];
    final serieVersion = prefixParts.length >= 4 ? prefixParts[3] : '';
    final matiereMatch = RegExp(r'^_?(.+?)_ch(\d+)$').firstMatch(suffix);
    if (matiereMatch == null) return false;
    final matiereId = matiereMatch.group(1)!;
    final ordre = int.tryParse(matiereMatch.group(2)!) ?? 0;
    return _catalogue.containsKey(cle(
      niveau,
      matiereId,
      ordre,
      anneeScolaire: anneeScolaire ?? prefixParts[0],
      programmeVersion: programmeVersion ?? prefixParts[1],
      serie: serie ?? serieVersion,
    )) || _catalogue.containsKey(ancienneCle(niveau, matiereId, ordre));
  }

  /// Retourne les ressources d’un chapitre.
  ///
  /// La cle historique reste prioritaire pour ne rien casser dans la base
  /// actuelle. Une cle versionnee peut ensuite etre ajoutee sans supprimer
  /// l’ancien contenu.
  static List<RessourceOfficielle> ressources(
    String chapitreId, {
    String? anneeScolaire,
    String? programmeVersion,
    String? serie,
  }) {
    final direct = _catalogue[chapitreId];
    if (direct != null) return direct;

    // Ancienne cle : 3e_math_ch01
    final ancienMatch = RegExp(r'^(.+?)_(.+?)_ch(\d+)$').firstMatch(chapitreId);
    if (ancienMatch != null) {
      final niveau = ancienMatch.group(1)!;
      final matiereId = ancienMatch.group(2)!;
      final ordre = int.tryParse(ancienMatch.group(3)!) ?? 0;
      return _catalogue[cle(
            niveau,
            matiereId,
            ordre,
            anneeScolaire: anneeScolaire ?? anneeCourante,
            programmeVersion: programmeVersion ?? programmeCourant,
            serie: serie ?? '',
          )] ??
          _catalogue[ancienneCle(niveau, matiereId, ordre)] ??
          const [];
    }

    // Cle versionnee : 2026-2027_dpfc_3e___math_ch01
    // ou 2026-2027_dpfc_1ere_A1__math_ch01
    final sep = chapitreId.indexOf('__');
    if (sep < 0) return const [];
    final prefix = chapitreId.substring(0, sep);
    final suffix = chapitreId.substring(sep + 2);
    final prefixParts = prefix.split('_');
    if (prefixParts.length < 3) return const [];
    final niveau = prefixParts[2];
    final serieVersion = prefixParts.length >= 4 ? prefixParts[3] : '';
    final matiereMatch = RegExp(r'^_?(.+?)_ch(\d+)$').firstMatch(suffix);
    if (matiereMatch == null) return const [];
    final matiereId = matiereMatch.group(1)!;
    final ordre = int.tryParse(matiereMatch.group(2)!) ?? 0;

    return _catalogue[cle(
          niveau,
          matiereId,
          ordre,
          anneeScolaire: anneeScolaire ?? prefixParts[0],
          programmeVersion: programmeVersion ?? prefixParts[1],
          serie: serie ?? serieVersion,
        )] ??
        _catalogue[ancienneCle(niveau, matiereId, ordre)] ??
        const [];
  }

  /// Indique si le catalogue contient des ressources pour le niveau/matiere.
  static bool existePour(
    String niveau,
    String matiereId, {
    String anneeScolaire = anneeCourante,
    String programmeVersion = programmeCourant,
    String serie = '',
  }) {
    final prefixe = '${anneeScolaire}_${programmeVersion}_${niveau}_${serie}__${matiereId}_';
    return _catalogue.keys.any((k) => k.startsWith(prefixe)) ||
        _catalogue.keys.any((k) => k.startsWith('${niveau}_${matiereId}_ch'));
  }

  /// Liste les chapitres du catalogue pour un niveau/matiere.
  static List<String> chapitresDisponibles(
    String niveau,
    String matiereId, {
    String anneeScolaire = anneeCourante,
    String programmeVersion = programmeCourant,
    String serie = '',
  }) {
    final prefixe = '${anneeScolaire}_${programmeVersion}_${niveau}_${serie}__${matiereId}_';
    final resultat = <String>[];

    for (final k in _catalogue.keys) {
      if (k.startsWith(prefixe)) {
        resultat.add(k);
      }
    }

    // Compatibilite avec les anciennes cles.
    if (resultat.isEmpty) {
      for (final k in _catalogue.keys) {
        if (k.startsWith('${niveau}_${matiereId}_ch')) {
          resultat.add(k);
        }
      }
    }

    resultat.sort();
    return resultat;
  }

  /// Cree toutes les ressources du chapitre, en brouillon.
  ///
  /// L’installation est idempotente : chaque ressource reçoit un identifiant
  /// stable et une ressource deja presente n’est pas ecrasee.
  ///
  /// Les ressources sont liees au chapitre Firestore, qui porte maintenant
  /// les metadonnees annee/programme/serie/theme. On ne duplique donc pas
  /// ces champs dans chaque ressource.
  ///
  /// Renvoie le nombre de ressources creees.
  static Future<int> installer(
    Chapitre chapitre,
    String auteurUid, {
    String? anneeScolaire,
    String? programmeVersion,
    String? serie,
  }) async {
    final cleChapitre = chapitre.code.isNotEmpty ? chapitre.code : chapitre.id;
    final ressourcesChapitre = ressources(
      cleChapitre,
      anneeScolaire: anneeScolaire ?? chapitre.anneeScolaire,
      programmeVersion: programmeVersion ?? chapitre.programmeVersion,
      serie: serie ?? chapitre.serie,
    );

    int crees = 0;
    for (var i = 0; i < ressourcesChapitre.length; i++) {
      final r = ressourcesChapitre[i];

      // Identifiant stable : relancer l’installation ne crée pas de doublon.
      final ressourceId =
          'ca_${chapitre.id}_r${r.type.index}_${r.ordre}_${i + 1}';

      // Si la ressource existe déjà, on la conserve telle quelle.
      // Cela protège notamment une ressource déjà relue ou publiée.
      final dejaPresente = await ContenuService.ressource(ressourceId);
      if (dejaPresente != null) continue;

      final res = await ContenuService.creerRessource(
        Ressource(
          id: ressourceId,
          type: r.type,
          titre: r.titre,
          ordre: r.ordre,
          chapitreId: chapitre.id,
          niveau: chapitre.niveau,
          matiereId: chapitre.matiereId,
          contenu: r.contenu,
          enonce: r.enonce,
          solution: r.solution,
          difficulte: r.difficulte,
          dureeMinutes: r.dureeMinutes,
          questions: r.questions,
          actif: false, // brouillon : relecture obligatoire
          auteur: auteurUid,
        ),
      );
      if (!res.startsWith('!')) crees++;
    }
    return crees;
  }

  // ==========================================================================
  //  CATALOGUE
  // ==========================================================================


  static List<RessourceOfficielle> _math5eChapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quiz1Bonne,
  }) {
    return [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → calculer → vérifier.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : appliquer une formule sans vérifier les unités et les conditions.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile,
        enonce: '''$enonce1''',
        solution: '''$solution1''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice d’application',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: '''$enonce2''',
        solution: '''$solution2''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: '$titre — quiz',
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '5e${code}q1',
            type: TypeQuestion.qcm,
            enonce: '''$quiz1''',
            choix: ['''$quiz1Bonne''', 'Une réponse sans justification', 'Une méthode qui ignore les données', 'Aucune de ces réponses'],
            bonnesReponses: [0],
            explication: 'La première proposition correspond à la règle ou propriété essentielle du chapitre.',
          ),
          QuestionQuiz(
            id: '5e${code}q2',
            type: TypeQuestion.vraiFaux,
            enonce: 'Une démarche correcte consiste à identifier les données, choisir une propriété adaptée et vérifier le résultat.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication: 'Une résolution mathématique doit être organisée et vérifiable.',
          ),
          QuestionQuiz(
            id: '5e${code}q3',
            type: TypeQuestion.qcm,
            enonce: 'Quel réflexe est le plus utile dans ce chapitre ?',
            choix: ['Écrire les étapes du raisonnement', 'Répondre sans calculer', 'Ignorer les unités', 'Ne jamais vérifier'],
            bonnesReponses: [0],
            explication: 'Écrire les étapes permet de justifier la réponse et de repérer une éventuelle erreur.',
          ),
        ],
      ),
    ];
  }


  static List<RessourceOfficielle> _math4eChapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
  }) {
    return [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → calculer → vérifier.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : oublier les signes, les conditions ou les unités.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile,
        enonce: '''$enonce1''',
        solution: '''$solution1''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice d’application',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: '''$enonce2''',
        solution: '''$solution2''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: '$titre — quiz',
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '4e${code}q1',
            type: TypeQuestion.qcm,
            enonce: 'Quelle proposition correspond à une règle essentielle de « $titre » ?',
            choix: ['Appliquer les propriétés étudiées avec les données de l\'énoncé', 'Ignorer les données', 'Changer les unités au hasard', 'Ne jamais vérifier'],
            bonnesReponses: [0],
            explication: 'La première proposition décrit la démarche mathématique attendue.',
          ),
          QuestionQuiz(
            id: '4e${code}q2',
            type: TypeQuestion.vraiFaux,
            enonce: 'Une réponse mathématique doit être justifiée par un raisonnement ou une propriété adaptée.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication: 'La justification permet de vérifier et de communiquer correctement le raisonnement.',
          ),
          QuestionQuiz(
            id: '4e${code}q3',
            type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il garder pour les exercices de ce chapitre ?',
            choix: ['Identifier les données, choisir une méthode et vérifier', 'Répondre sans calcul', 'Ignorer les unités', 'Copier uniquement le résultat'],
            bonnesReponses: [0],
            explication: 'Cette démarche structure une résolution correcte.',
          ),
        ],
      ),
    ];
  }


  static List<RessourceOfficielle> _math2ndeAChapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(type: TypeRessource.cours, titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : lire les données → choisir la propriété → calculer → vérifier.
'''),
      RessourceOfficielle(type: TypeRessource.renforcement, titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : appliquer une règle sans vérifier ses conditions.
'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile, enonce: '''$enonce1''', solution: '''$solution1'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice d’application',
        ordre: 2, difficulte: Difficulte.moyen, enonce: '''$enonce2''', solution: '''$solution2'''),
      RessourceOfficielle(type: TypeRessource.fiche, titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et vérifier le résultat.
'''),
      RessourceOfficielle(type: TypeRessource.quiz, titre: '$titre — quiz', dureeMinutes: 5,
        questions: [
          QuestionQuiz(id: '2ndeA_${code}_q1', type: TypeQuestion.qcm, enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les conditions du problème', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0], explication: 'La première proposition correspond à la notion essentielle du chapitre.'),
          QuestionQuiz(id: '2ndeA_${code}_q2', type: TypeQuestion.vraiFaux,
            enonce: 'Une résolution correcte doit présenter une démarche suffisamment claire pour être vérifiée.',
            choix: ['Vrai', 'Faux'], bonnesReponses: [0],
            explication: 'Le raisonnement et la vérification permettent de contrôler le résultat.'),
          QuestionQuiz(id: '2ndeA_${code}_q3', type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier ?',
            choix: ['Identifier les données et les conditions avant de calculer', 'Répondre sans calcul', 'Ignorer les unités ou domaines', 'Copier uniquement le résultat'],
            bonnesReponses: [0], explication: 'Les données et les conditions déterminent la méthode adaptée.'),
        ]),
    ];
  }


  static List<RessourceOfficielle> _math2ndeCChapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(type: TypeRessource.cours, titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → calculer → vérifier.
'''),
      RessourceOfficielle(type: TypeRessource.renforcement, titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : appliquer une propriété sans vérifier les hypothèses.
'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile, enonce: '''$enonce1''', solution: '''$solution1'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice d’application',
        ordre: 2, difficulte: Difficulte.moyen, enonce: '''$enonce2''', solution: '''$solution2'''),
      RessourceOfficielle(type: TypeRessource.fiche, titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et vérifier le domaine ou les conditions.
'''),
      RessourceOfficielle(type: TypeRessource.quiz, titre: '$titre — quiz', dureeMinutes: 5,
        questions: [
          QuestionQuiz(id: '2ndeC_${code}_q1', type: TypeQuestion.qcm, enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les conditions du problème', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0], explication: 'La première proposition correspond à la notion essentielle du chapitre.'),
          QuestionQuiz(id: '2ndeC_${code}_q2', type: TypeQuestion.vraiFaux,
            enonce: 'Une résolution correcte doit présenter une démarche suffisamment claire pour être vérifiée.',
            choix: ['Vrai', 'Faux'], bonnesReponses: [0],
            explication: 'Le raisonnement et la vérification permettent de contrôler le résultat.'),
          QuestionQuiz(id: '2ndeC_${code}_q3', type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier ?',
            choix: ['Identifier les données et les conditions avant de calculer', 'Répondre sans calcul', 'Ignorer les unités ou domaines', 'Copier uniquement le résultat'],
            bonnesReponses: [0], explication: 'Les données et les conditions déterminent la méthode adaptée.'),
        ]),
    ];
  }


  static List<RessourceOfficielle> _math1ereA1Chapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(type: TypeRessource.cours, titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → calculer → vérifier.
'''),
      RessourceOfficielle(type: TypeRessource.renforcement, titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : appliquer une formule sans vérifier les conditions.
'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile, enonce: '''$enonce1''', solution: '''$solution1'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice d’application',
        ordre: 2, difficulte: Difficulte.moyen, enonce: '''$enonce2''', solution: '''$solution2'''),
      RessourceOfficielle(type: TypeRessource.fiche, titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et vérifier le résultat.
'''),
      RessourceOfficielle(type: TypeRessource.quiz, titre: '$titre — quiz', dureeMinutes: 5,
        questions: [
          QuestionQuiz(id: '1ereA1_${code}_q1', type: TypeQuestion.qcm, enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les conditions', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0], explication: 'La première proposition correspond à la notion essentielle du chapitre.'),
          QuestionQuiz(id: '1ereA1_${code}_q2', type: TypeQuestion.vraiFaux,
            enonce: 'Une résolution correcte doit présenter une démarche claire et vérifiable.',
            choix: ['Vrai', 'Faux'], bonnesReponses: [0],
            explication: 'Une démarche explicite permet de contrôler le raisonnement et le résultat.'),
          QuestionQuiz(id: '1ereA1_${code}_q3', type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier ?',
            choix: ['Identifier les données et les conditions avant de calculer', 'Répondre sans calcul', 'Ignorer le domaine', 'Copier uniquement le résultat'],
            bonnesReponses: [0], explication: 'Les données et les conditions déterminent la méthode adaptée.'),
        ]),
    ];
  }


  static List<RessourceOfficielle> _math1ereA2Chapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(type: TypeRessource.cours, titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → calculer → vérifier.
'''),
      RessourceOfficielle(type: TypeRessource.renforcement, titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : appliquer une règle sans vérifier les conditions.
'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile, enonce: '''$enonce1''', solution: '''$solution1'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice d’application',
        ordre: 2, difficulte: Difficulte.moyen, enonce: '''$enonce2''', solution: '''$solution2'''),
      RessourceOfficielle(type: TypeRessource.fiche, titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et vérifier le résultat.
'''),
      RessourceOfficielle(type: TypeRessource.quiz, titre: '$titre — quiz', dureeMinutes: 5,
        questions: [
          QuestionQuiz(id: '1ereA2_${code}_q1', type: TypeQuestion.qcm, enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les conditions', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0], explication: 'La première proposition correspond à la notion essentielle du chapitre.'),
          QuestionQuiz(id: '1ereA2_${code}_q2', type: TypeQuestion.vraiFaux,
            enonce: 'Une résolution correcte doit présenter une démarche claire et vérifiable.',
            choix: ['Vrai', 'Faux'], bonnesReponses: [0],
            explication: 'Une démarche explicite permet de contrôler le raisonnement et le résultat.'),
          QuestionQuiz(id: '1ereA2_${code}_q3', type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier ?',
            choix: ['Identifier les données et les conditions avant de calculer', 'Répondre sans calcul', 'Ignorer le domaine', 'Copier uniquement le résultat'],
            bonnesReponses: [0], explication: 'Les données et les conditions déterminent la méthode adaptée.'),
        ]),
    ];
  }


  static List<RessourceOfficielle> _math1ereCChapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(type: TypeRessource.cours, titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → calculer → vérifier.
'''),
      RessourceOfficielle(type: TypeRessource.renforcement, titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : appliquer une propriété sans vérifier ses conditions.
'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile, enonce: '''$enonce1''', solution: '''$solution1'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice d’application',
        ordre: 2, difficulte: Difficulte.moyen, enonce: '''$enonce2''', solution: '''$solution2'''),
      RessourceOfficielle(type: TypeRessource.fiche, titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et vérifier le résultat.
'''),
      RessourceOfficielle(type: TypeRessource.quiz, titre: '$titre — quiz', dureeMinutes: 5,
        questions: [
          QuestionQuiz(id: '1ereC_${code}_q1', type: TypeQuestion.qcm, enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les conditions', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0], explication: 'La première proposition correspond à la notion essentielle du chapitre.'),
          QuestionQuiz(id: '1ereC_${code}_q2', type: TypeQuestion.vraiFaux,
            enonce: 'Une démonstration mathématique doit utiliser des propriétés applicables aux objets étudiés.',
            choix: ['Vrai', 'Faux'], bonnesReponses: [0],
            explication: 'Une propriété n’est utilisable que lorsque ses hypothèses sont satisfaites.'),
          QuestionQuiz(id: '1ereC_${code}_q3', type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier dans un problème ?',
            choix: ['Identifier les données, les conditions et la méthode', 'Répondre sans justification', 'Ignorer le domaine de définition', 'Utiliser une formule sans vérifier'],
            bonnesReponses: [0], explication: 'Une résolution rigoureuse commence par l’identification des données et des conditions.'
          ),
        ]),
    ];
  }


  static List<RessourceOfficielle> _math1ereDChapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(type: TypeRessource.cours, titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → calculer → vérifier.
'''),
      RessourceOfficielle(type: TypeRessource.renforcement, titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : appliquer une propriété sans vérifier ses conditions.
'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile, enonce: '''$enonce1''', solution: '''$solution1'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice d’application',
        ordre: 2, difficulte: Difficulte.moyen, enonce: '''$enonce2''', solution: '''$solution2'''),
      RessourceOfficielle(type: TypeRessource.fiche, titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et vérifier le résultat.
'''),
      RessourceOfficielle(type: TypeRessource.quiz, titre: '$titre — quiz', dureeMinutes: 5,
        questions: [
          QuestionQuiz(id: '1ereD_${code}_q1', type: TypeQuestion.qcm, enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les conditions', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0], explication: 'La première proposition correspond à la notion essentielle du chapitre.'),
          QuestionQuiz(id: '1ereD_${code}_q2', type: TypeQuestion.vraiFaux,
            enonce: 'Une résolution mathématique correcte doit respecter les conditions des propriétés utilisées.',
            choix: ['Vrai', 'Faux'], bonnesReponses: [0],
            explication: 'Les hypothèses d’une propriété doivent être vérifiées avant son application.'),
          QuestionQuiz(id: '1ereD_${code}_q3', type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier ?',
            choix: ['Identifier les données, les conditions et la méthode', 'Répondre sans justification', 'Ignorer le domaine', 'Utiliser une formule sans vérifier'],
            bonnesReponses: [0], explication: 'La rigueur commence par l’identification des données et des conditions.'
          ),
        ]),
    ];
  }


  static List<RessourceOfficielle> _mathTleA1Chapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(type: TypeRessource.cours, titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → calculer → vérifier.
'''),
      RessourceOfficielle(type: TypeRessource.renforcement, titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : appliquer une propriété sans vérifier ses conditions.
'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile, enonce: '''$enonce1''', solution: '''$solution1'''),
      RessourceOfficielle(type: TypeRessource.exercice, titre: '$titre — exercice d’application',
        ordre: 2, difficulte: Difficulte.moyen, enonce: '''$enonce2''', solution: '''$solution2'''),
      RessourceOfficielle(type: TypeRessource.fiche, titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et vérifier le résultat.
'''),
      RessourceOfficielle(type: TypeRessource.quiz, titre: '$titre — quiz', dureeMinutes: 5,
        questions: [
          QuestionQuiz(id: 'TleA1_${code}_q1', type: TypeQuestion.qcm, enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les conditions', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0], explication: 'La première proposition correspond à la notion essentielle du chapitre.'),
          QuestionQuiz(id: 'TleA1_${code}_q2', type: TypeQuestion.vraiFaux,
            enonce: 'Une résolution correcte doit respecter les conditions des propriétés utilisées.',
            choix: ['Vrai', 'Faux'], bonnesReponses: [0],
            explication: 'Les hypothèses d’une propriété doivent être vérifiées avant son application.'),
          QuestionQuiz(id: 'TleA1_${code}_q3', type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier ?',
            choix: ['Identifier les données, les conditions et la méthode', 'Répondre sans justification', 'Ignorer le domaine', 'Utiliser une formule sans vérifier'],
            bonnesReponses: [0], explication: 'La rigueur commence par l’identification des données et des conditions.'
          ),
        ]),
    ];
  }


  static List<RessourceOfficielle> _mathTleA2Chapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → calculer → vérifier.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : appliquer une propriété sans vérifier ses conditions.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile,
        enonce: '''$enonce1''',
        solution: '''$solution1''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice d’application',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: '''$enonce2''',
        solution: '''$solution2''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et vérifier le résultat.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: '$titre — quiz',
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'TleA2_' + code + '_q1',
            type: TypeQuestion.qcm,
            enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les conditions', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0],
            explication: 'La première proposition correspond à la notion essentielle du chapitre.',
          ),
          QuestionQuiz(
            id: 'TleA2_' + code + '_q2',
            type: TypeQuestion.vraiFaux,
            enonce: 'Une résolution correcte doit respecter les conditions des propriétés utilisées.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication: 'Les hypothèses d’une propriété doivent être vérifiées avant son application.',
          ),
          QuestionQuiz(
            id: 'TleA2_' + code + '_q3',
            type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier ?',
            choix: ['Identifier les données, les conditions et la méthode', 'Répondre sans justification', 'Ignorer le domaine', 'Utiliser une formule sans vérifier'],
            bonnesReponses: [0],
            explication: 'La rigueur commence par l’identification des données et des conditions.',
          ),
        ],
      ),
    ];
  }


  static List<RessourceOfficielle> _mathTleCChapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → développer le raisonnement → vérifier.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : utiliser une propriété sans vérifier ses hypothèses et son domaine d’application.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile,
        enonce: '''$enonce1''',
        solution: '''$solution1''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice d’application',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: '''$enonce2''',
        solution: '''$solution2''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et contrôler les résultats.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: '$titre — quiz',
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'TleC_' + code + '_q1',
            type: TypeQuestion.qcm,
            enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les hypothèses', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0],
            explication: 'La première proposition correspond à la notion essentielle du chapitre.',
          ),
          QuestionQuiz(
            id: 'TleC_' + code + '_q2',
            type: TypeQuestion.vraiFaux,
            enonce: 'Une démonstration correcte doit respecter les hypothèses des théorèmes et propriétés utilisés.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication: 'Les conditions d’application doivent être vérifiées avant d’utiliser un résultat.',
          ),
          QuestionQuiz(
            id: 'TleC_' + code + '_q3',
            type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier en Terminale C ?',
            choix: ['Justifier les étapes et vérifier le résultat', 'Répondre sans raisonnement', 'Ignorer le domaine', 'Utiliser une formule sans vérifier'],
            bonnesReponses: [0],
            explication: 'La rigueur du raisonnement est essentielle dans les exercices de niveau Terminale C.',
          ),
        ],
      ),
    ];
  }


  static List<RessourceOfficielle> _mathTleDChapitre({
    required String code,
    required String titre,
    required String cours,
    required String renforcement,
    required String enonce1,
    required String solution1,
    required String enonce2,
    required String solution2,
    required String motsCles,
    required String quiz1,
    required String quizBonne,
  }) {
    return [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: '$titre — cours',
        contenu: '''$cours

MÉTHODE : identifier les données → choisir la propriété → développer le raisonnement → vérifier.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: '$titre — comprendre facilement',
        contenu: '''$renforcement

PIÈGE À ÉVITER : utiliser une propriété sans vérifier ses hypothèses et son domaine d’application.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice guidé',
        difficulte: Difficulte.facile,
        enonce: '''$enonce1''',
        solution: '''$solution1''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: '$titre — exercice d’application',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: '''$enonce2''',
        solution: '''$solution2''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: '$titre — fiche de révision',
        contenu: '''MOTS-CLÉS : $motsCles

À RETENIR :
$cours

RÉFLEXE : écrire les étapes du raisonnement et contrôler les résultats.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: '$titre — quiz',
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'TleD_' + code + '_q1',
            type: TypeQuestion.qcm,
            enonce: '''$quiz1''',
            choix: ['''$quizBonne''', 'Ignorer les hypothèses', 'Choisir une formule au hasard', 'Aucune justification n’est nécessaire'],
            bonnesReponses: [0],
            explication: 'La première proposition correspond à la notion essentielle du chapitre.',
          ),
          QuestionQuiz(
            id: 'TleD_' + code + '_q2',
            type: TypeQuestion.vraiFaux,
            enonce: 'Une démarche correcte doit respecter les hypothèses des théorèmes et propriétés utilisés.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication: 'Les conditions d’application doivent être vérifiées avant d’utiliser un résultat.',
          ),
          QuestionQuiz(
            id: 'TleD_' + code + '_q3',
            type: TypeQuestion.qcm,
            enonce: 'Quel réflexe faut-il privilégier en Terminale D ?',
            choix: ['Justifier les étapes et vérifier le résultat', 'Répondre sans raisonnement', 'Ignorer le domaine', 'Utiliser une formule sans vérifier'],
            bonnesReponses: [0],
            explication: 'La rigueur du raisonnement est essentielle dans les exercices de niveau Terminale D.',
          ),
        ],
      ),
    ];
  }

  static final Map<String, List<RessourceOfficielle>> _catalogue = {
    ..._catalogueAgent,

    'Tle_D_math_ch01': _mathTleDChapitre(
      code:'ch01', titre:'Limites et continuité',
      cours:r'''Une limite décrit le comportement d’une fonction lorsque la variable se rapproche d’une valeur ou tend vers l’infini. La continuité en a signifie que la limite de f(x) quand x tend vers a est égale à f(a).''',
      renforcement:r'''Pour lever une forme indéterminée, transforme l’expression par factorisation, mise au même dénominateur ou expression conjuguée selon le cas. Vérifie aussi le domaine de définition.''',
      enonce1:r'''Calcule lim(x→2)(3x+1).''', solution1:r'''La fonction affine est continue, donc la limite vaut 7.''',
      enonce2:r'''Calcule lim(x→+∞)(5x²−1)/x².''', solution2:r'''En divisant par x², on obtient 5−1/x², donc la limite vaut 5.''',
      motsCles:'limite • continuité • voisinage • infini • forme indéterminée', quiz1:r'''Que signifie qu’une fonction f est continue en a ?''', quizBonne:r'''La limite de f(x) quand x tend vers a est égale à f(a)''',
    ),
    'Tle_D_math_ch02': _mathTleDChapitre(
      code:'ch02', titre:'Probabilité conditionnelle et variable aléatoire',
      cours:r'''La probabilité conditionnelle de A sachant B est P_B(A)=P(A∩B)/P(B), lorsque P(B)>0. Une variable aléatoire associe une valeur numérique aux issues d’une expérience aléatoire et possède une loi de probabilité.''',
      renforcement:r'''Identifie clairement l’événement conditionnant. Pour une variable aléatoire, construis la loi puis vérifie que la somme des probabilités vaut 1 avant de calculer l’espérance.''',
      enonce1:r'''P(A∩B)=0,2 et P(B)=0,5. Calcule P_B(A).''', solution1:r'''P_B(A)=0,2/0,5=0,4.''',
      enonce2:r'''Une variable X vaut 0 avec probabilité 0,3 et 2 avec probabilité 0,7. Calcule E(X).''', solution2:r'''E(X)=0×0,3+2×0,7=1,4.''',
      motsCles:'probabilité conditionnelle • variable aléatoire • loi • espérance • événement', quiz1:r'''Quelle formule définit P_B(A) ?''', quizBonne:r'''P(A∩B)/P(B)''',
    ),
    'Tle_D_math_ch03': _mathTleDChapitre(
      code:'ch03', titre:'Dérivabilité et étude de fonctions',
      cours:r'''La dérivée mesure le taux de variation local d’une fonction. Elle permet d’étudier les variations, les extrema et les tangentes. Une étude de fonction associe domaine, limites, dérivée, signe de la dérivée et tableau de variations.''',
      renforcement:r'''Détermine d’abord le domaine, calcule la dérivée puis étudie son signe. Complète l’étude avec les limites et les valeurs remarquables.''',
      enonce1:r'''Dérive f(x)=x³−3x+2.''', solution1:r'''f’(x)=3x²−3.''',
      enonce2:r'''Étudie le signe de f’(x)=2x−4.''', solution2:r'''f’(x)<0 pour x<2, f’(2)=0 et f’(x)>0 pour x>2.''',
      motsCles:'dérivée • taux de variation • tangente • extrema • variations', quiz1:r'''Que permet principalement le signe de f’(x) ?''', quizBonne:r'''D’étudier les variations de f''',
    ),
    'Tle_D_math_ch04': _mathTleDChapitre(
      code:'ch04', titre:'Primitives',
      cours:r'''Une primitive F d’une fonction f sur un intervalle vérifie F’=f. Toute autre primitive de f sur cet intervalle diffère de F par une constante.''',
      renforcement:r'''Reconnais les formes usuelles, propose une primitive puis vérifie-la systématiquement en dérivant le résultat.''',
      enonce1:r'''Donne une primitive de f(x)=4x³.''', solution1:r'''F(x)=x⁴+C.''',
      enonce2:r'''Donne une primitive de f(x)=1/x sur ]0;+∞[.''', solution2:r'''F(x)=ln(x)+C.''',
      motsCles:'primitive • dérivée • constante • intégrale • fonction', quiz1:r'''Quelle relation vérifie une primitive F de f ?''', quizBonne:r'''F’=f''',
    ),
    'Tle_D_math_ch05': _mathTleDChapitre(
      code:'ch05', titre:'Fonctions logarithmes',
      cours:r'''La fonction logarithme népérien ln est définie sur ]0;+∞[, strictement croissante et dérivable. Elle transforme les produits en sommes et permet de résoudre des équations et inéquations.''',
      renforcement:r'''Vérifie toujours que les arguments des logarithmes sont positifs. Utilise ln(ab)=ln(a)+ln(b) et ln(a/b)=ln(a)−ln(b).''',
      enonce1:r'''Calcule ln(e⁴).''', solution1:r'''ln(e⁴)=4.''',
      enonce2:r'''Résous ln(x)=3.''', solution2:r'''x=e³, avec x>0.''',
      motsCles:'ln • logarithme • domaine • croissance • équation • inéquation', quiz1:r'''Quel est le domaine de définition de ln ?''', quizBonne:r''']0;+∞[''',
    ),
    'Tle_D_math_ch06': _mathTleDChapitre(
      code:'ch06', titre:'Fonctions exponentielles et puissances',
      cours:r'''La fonction exponentielle est définie sur ℝ, positive et strictement croissante, avec e^(a+b)=e^a e^b. Les fonctions puissances sont étudiées sur leurs domaines de définition et permettent de modéliser des variations.''',
      renforcement:r'''Utilise les propriétés de l’exponentielle pour simplifier les produits et puissances. Pour une fonction puissance, commence par déterminer son domaine.''',
      enonce1:r'''Simplifie e²×e³.''', solution1:r'''e⁵.''',
      enonce2:r'''Résous e^x=7.''', solution2:r'''x=ln(7).''',
      motsCles:'exponentielle • puissance • croissance • ln • domaine', quiz1:r'''Quelle relation est vraie pour l’exponentielle ?''', quizBonne:r'''e^(a+b)=e^a×e^b''',
    ),
    'Tle_D_math_ch07': _mathTleDChapitre(
      code:'ch07', titre:'Suites numériques',
      cours:r'''Une suite est une fonction définie sur les entiers naturels. On étudie ses termes, ses variations et sa convergence. Les suites arithmétiques et géométriques constituent des modèles fondamentaux.''',
      renforcement:r'''Identifie la relation entre deux termes consécutifs. Pour une suite arithmétique, étudie la raison ; pour une suite géométrique, étudie le quotient et sa valeur absolue.''',
      enonce1:r'''Soit u_n=2n+1. Calcule u_5.''', solution1:r'''u_5=11.''',
      enonce2:r'''Une suite géométrique vérifie u_0=3 et q=2. Calcule u_4.''', solution2:r'''u_4=3×2⁴=48.''',
      motsCles:'suite • terme • arithmétique • géométrique • variation • convergence', quiz1:r'''Dans une suite géométrique, quelle grandeur est constante ?''', quizBonne:r'''Le quotient de deux termes consécutifs non nuls''',
    ),
    'Tle_D_math_ch08': _mathTleDChapitre(
      code:'ch08', titre:'Nombres complexes',
      cours:r'''Un nombre complexe s’écrit z=a+ib avec a,b réels et i²=−1. On distingue partie réelle, partie imaginaire, conjugué et module. Les formes algébrique et trigonométrique permettent de résoudre des problèmes.''',
      renforcement:r'''Regroupe séparément les parties réelle et imaginaire. Utilise le conjugué pour simplifier certains quotients et le module pour les interprétations géométriques.''',
      enonce1:r'''Calcule (2+3i)+(1−5i).''', solution1:r'''3−2i.''',
      enonce2:r'''Calcule le module de z=3+4i.''', solution2:r'''|z|=√(3²+4²)=5.''',
      motsCles:'complexe • partie réelle • partie imaginaire • conjugué • module', quiz1:r'''Que vaut i² ?''', quizBonne:r'''−1''',
    ),
    'Tle_D_math_ch09': _mathTleDChapitre(
      code:'ch09', titre:'Calcul intégral',
      cours:r'''L’intégrale définie d’une fonction f sur [a,b] peut être calculée à l’aide d’une primitive F par ∫a^b f(x)dx=F(b)−F(a). Elle intervient notamment dans le calcul d’aires algébriques.''',
      renforcement:r'''Cherche une primitive puis applique la formule aux bornes. Pour interpréter une intégrale comme une aire, vérifie le signe de la fonction sur l’intervalle.''',
      enonce1:r'''Calcule ∫₀² x dx.''', solution1:r'''Une primitive est x²/2, donc l’intégrale vaut 2.''',
      enonce2:r'''Calcule ∫₁³ 2x dx.''', solution2:r'''Une primitive est x², donc 9−1=8.''',
      motsCles:'intégrale • primitive • bornes • aire • fonction', quiz1:r'''Quelle formule permet de calculer ∫a^b f(x)dx avec une primitive F ?''', quizBonne:r'''F(b)−F(a)''',
    ),
    'Tle_D_math_ch10': _mathTleDChapitre(
      code:'ch10', titre:'Nombres complexes et géométrie du plan',
      cours:r'''Les nombres complexes permettent de représenter les points et vecteurs du plan. Le module représente une distance et l’argument décrit une direction. Les quotients de complexes permettent aussi d’étudier des rapports et angles.''',
      renforcement:r'''Associe à une affixe z son module pour la distance à l’origine et son argument pour une direction. Utilise les opérations complexes pour traduire les relations géométriques.''',
      enonce1:r'''Pour z=3+4i, que représente |z| ?''', solution1:r'''|z|=5 : c’est la distance du point d’affixe z à l’origine.''',
      enonce2:r'''Quel complexe représente le vecteur allant du point d’affixe 1+i au point d’affixe 4+3i ?''', solution2:r'''(4+3i)−(1+i)=3+2i.''',
      motsCles:'affixe • module • argument • vecteur • distance • complexe', quiz1:r'''Que représente géométriquement le module d’une affixe z ?''', quizBonne:r'''La distance du point à l’origine''',
    ),
    'Tle_D_math_ch11': _mathTleDChapitre(
      code:'ch11', titre:'Statistiques à deux variables',
      cours:r'''Une statistique à deux variables étudie des couples de valeurs observées. Le nuage de points, la covariance, le coefficient de corrélation et l’ajustement permettent de décrire une liaison entre les variables.''',
      renforcement:r'''Organise les couples puis représente-les. Observe la tendance et utilise un ajustement linéaire lorsque le nuage s’y prête. Une corrélation décrit une association linéaire.''',
      enonce1:r'''Les points (1,2), (2,4), (3,6) sont-ils alignés ?''', solution1:r'''Oui, ils vérifient tous y=2x.''',
      enonce2:r'''Que suggère une corrélation linéaire proche de 1 ?''', solution2:r'''Une liaison linéaire positive forte entre les deux variables.''',
      motsCles:'statistique • deux variables • nuage • corrélation • ajustement', quiz1:r'''Que représente chaque point d’un nuage de points ?''', quizBonne:r'''Un couple de valeurs observées''',
    ),
    'Tle_D_math_ch12': _mathTleDChapitre(
      code:'ch12', titre:'Équations différentielles',
      cours:r'''Une équation différentielle relie une fonction inconnue à ses dérivées. Pour une équation du type y’=ay, la solution générale est y=Ce^(ax). Une condition initiale permet de déterminer la constante.''',
      renforcement:r'''Identifie l’ordre et la forme de l’équation. Pour y’=ay, utilise y=Ce^(ax), puis applique la condition initiale.''',
      enonce1:r'''Résous y’=2y.''', solution1:r'''La solution générale est y=Ce^(2x), où C est une constante réelle.''',
      enonce2:r'''Résous y’=3y avec y(0)=5.''', solution2:r'''y=Ce^(3x). Comme y(0)=C=5, y=5e^(3x).''',
      motsCles:'équation différentielle • dérivée • solution générale • condition initiale • exponentielle', quiz1:r'''Quelle est la forme générale d’une solution de y’=ay ?''', quizBonne:r'''y=Ce^(ax)''',
    ),

    'Tle_A1_math_ch01': _mathTleA1Chapitre(
      code:'ch01', titre:'Étude de fonctions polynômes et de fonctions rationnelles',
      cours:r'''Les fonctions polynômes et rationnelles se définissent sur des domaines déterminés par leurs expressions. Leur étude utilise limites, dérivée, signe, variations, zéros et asymptotes. Une représentation graphique rassemble ces informations pour décrire le comportement de la fonction.''',
      renforcement:r'''Commence par déterminer le domaine de définition. Étudie ensuite les limites et la dérivée, puis le signe et les variations. Pour une fonction rationnelle, recherche les valeurs interdites et les éventuelles asymptotes.''',
      enonce1:r'''Dérive f(x)=x³−3x²+2x.''', solution1:r'''f’(x)=3x²−6x+2.''',
      enonce2:r'''Détermine le domaine de f(x)=(x+1)/(x−2).''', solution2:r'''Le dénominateur ne doit pas être nul : Df=ℝ\{2}.''',
      motsCles:'polynôme • rationnelle • domaine • dérivée • limite • asymptote • variation', quiz1:'Pour une fonction rationnelle, que faut-il vérifier avant toute étude ?', quizBonne:'Les valeurs qui annulent le dénominateur',
    ),
    'Tle_A1_math_ch02': _mathTleA1Chapitre(
      code:'ch02', titre:'Probabilité et variable aléatoire',
      cours:r'''Une variable aléatoire associe un nombre réel à chaque issue d’une expérience aléatoire. Sa loi donne les probabilités de ses valeurs. L’espérance représente une valeur moyenne théorique et la variance mesure la dispersion autour de cette moyenne.''',
      renforcement:r'''Construis d’abord la loi de probabilité en vérifiant que la somme des probabilités vaut 1. Calcule ensuite espérance et variance à partir des valeurs et de leurs probabilités.''',
      enonce1:r'''Une variable X vaut 0 avec probabilité 0,4 et 1 avec probabilité 0,6. Calcule E(X).''', solution1:r'''E(X)=0×0,4+1×0,6=0,6.''',
      enonce2:r'''Une variable X prend 1 et 3 avec probabilités 0,5 chacune. Calcule E(X).''', solution2:r'''E(X)=1×0,5+3×0,5=2.''',
      motsCles:'variable aléatoire • loi • probabilité • espérance • variance', quiz1:'Que représente l’espérance d’une variable aléatoire ?', quizBonne:'Sa valeur moyenne théorique',
    ),
    'Tle_A1_math_ch03': _mathTleA1Chapitre(
      code:'ch03', titre:'Primitives et calcul intégral',
      cours:r'''Une primitive F d’une fonction f sur un intervalle vérifie F’=f. L’intégrale d’une fonction sur un intervalle peut être calculée à partir d’une primitive. Elle permet notamment de déterminer des aires algébriques et des quantités cumulées.''',
      renforcement:r'''Pour trouver une primitive, reconnais les formes usuelles puis vérifie en dérivant le résultat. Pour une intégrale définie, applique F(b)−F(a).''',
      enonce1:r'''Donne une primitive de f(x)=3x².''', solution1:r'''F(x)=x³+C.''',
      enonce2:r'''Calcule ∫₀² x dx.''', solution2:r'''Une primitive est x²/2, donc l’intégrale vaut 2.''',
      motsCles:'primitive • intégrale • aire • dérivée • borne', quiz1:'Quelle relation doit vérifier une primitive F de f ?', quizBonne:'F’=f',
    ),
    'Tle_A1_math_ch04': _mathTleA1Chapitre(
      code:'ch04', titre:'Fonction logarithme népérien',
      cours:r'''La fonction logarithme népérien, notée ln, est définie sur ]0;+∞[ et vérifie ln(ab)=ln(a)+ln(b). Elle est strictement croissante et constitue la fonction réciproque de l’exponentielle. Les propriétés du logarithme permettent de résoudre des équations et inéquations.''',
      renforcement:r'''Vérifie toujours que les arguments des logarithmes sont strictement positifs. Utilise ln(ab)=ln(a)+ln(b), ln(a/b)=ln(a)−ln(b) et ln(a^r)=r ln(a).''',
      enonce1:r'''Calcule ln(1).''', solution1:r'''ln(1)=0.''',
      enonce2:r'''Résous ln(x)=2.''', solution2:r'''En appliquant l’exponentielle, x=e².''',
      motsCles:'ln • logarithme • domaine • exponentielle • propriétés', quiz1:'Sur quel ensemble la fonction ln est-elle définie ?', quizBonne:']0;+∞[',
    ),
    'Tle_A1_math_ch05': _mathTleA1Chapitre(
      code:'ch05', titre:'Fonction exponentielle népérienne',
      cours:r'''La fonction exponentielle, notée exp ou e^x, est définie sur ℝ. Elle vérifie exp(a+b)=exp(a)exp(b), exp(0)=1 et exp(x)>0. Sa dérivée est elle-même. Elle est strictement croissante et réciproque du logarithme népérien.''',
      renforcement:r'''Utilise les propriétés de produit et de quotient pour transformer les expressions. Pour résoudre exp(x)=k avec k>0, applique ln des deux côtés.''',
      enonce1:r'''Calcule e^0.''', solution1:r'''e^0=1.''',
      enonce2:r'''Résous e^x=5.''', solution2:r'''x=ln(5).''',
      motsCles:'exponentielle • exp • e^x • logarithme • croissance', quiz1:'Quelle est la dérivée de la fonction exponentielle ?', quizBonne:'Elle est égale à elle-même',
    ),
    'Tle_A1_math_ch06': _mathTleA1Chapitre(
      code:'ch06', titre:'Statistique à deux variables',
      cours:r'''Une série statistique à deux variables étudie deux caractères observés simultanément. Le nuage de points permet de visualiser leur relation. La covariance et le coefficient de corrélation renseignent sur le sens et l’intensité d’une liaison linéaire, tandis qu’une droite d’ajustement peut servir à estimer des valeurs.''',
      renforcement:r'''Commence par représenter les couples (x,y). Observe la tendance générale puis utilise un ajustement linéaire lorsque le modèle est pertinent. Une corrélation proche de 1 ou −1 indique une liaison linéaire forte.''',
      enonce1:r'''Un nuage de points suit approximativement une droite croissante. Que peut-on dire du coefficient de corrélation ?''', solution1:r'''Il est positif et, si la liaison est forte, proche de 1.''',
      enonce2:r'''Une droite d’ajustement est y=2x+3. Estime y pour x=5.''', solution2:r'''y=2×5+3=13.''',
      motsCles:'statistique • deux variables • nuage • corrélation • ajustement', quiz1:'Que représente un coefficient de corrélation proche de 1 ?', quizBonne:'Une forte liaison linéaire positive',
    ),
    'Tle_A1_math_ch07': _mathTleA1Chapitre(
      code:'ch07', titre:'Suites numériques',
      cours:r'''Une suite numérique peut être définie explicitement ou par récurrence. Les suites arithmétiques et géométriques possèdent des formules particulières. L’étude d’une suite peut porter sur son sens de variation, ses bornes et sa convergence.''',
      renforcement:r'''Pour étudier une suite, calcule quelques termes puis cherche une propriété générale. Pour une suite arithmétique, utilise la raison additive ; pour une suite géométrique, la raison multiplicative.''',
      enonce1:r'''Une suite arithmétique vérifie u₀=3 et r=4. Calcule u₇.''', solution1:r'''u₇=3+7×4=31.''',
      enonce2:r'''Une suite géométrique vérifie u₀=2 et q=1/2. Calcule u₃.''', solution2:r'''u₃=2×(1/2)³=1/4.''',
      motsCles:'suite • récurrence • arithmétique • géométrique • convergence', quiz1:'Dans une suite géométrique de raison q, quelle relation relie deux termes consécutifs ?', quizBonne:'uₙ₊₁=q uₙ',
    ),
    'Tle_A1_math_ch08': _mathTleA1Chapitre(
      code:'ch08', titre:'Systèmes d’équations linéaires dans ℝ × ℝ',
      cours:r'''Un système linéaire à deux inconnues recherche les couples qui satisfont simultanément deux équations. Il peut être résolu par substitution, combinaison linéaire ou interprétation graphique. Deux droites peuvent être sécantes, parallèles distinctes ou confondues, correspondant respectivement à une, aucune ou une infinité de solutions.''',
      renforcement:r'''Choisis la méthode qui simplifie le plus le système. Après avoir trouvé un couple, remplace-le dans les deux équations pour vérifier.''',
      enonce1:r'''Résous x+y=8 et x−y=2.''', solution1:r'''En additionnant : 2x=10, donc x=5 et y=3.''',
      enonce2:r'''Résous 2x+y=7 et x−y=2.''', solution2:r'''y=x−2. Donc 3x−2=7, x=3 et y=1.''',
      motsCles:'système • équation linéaire • substitution • combinaison • droites', quiz1:'Graphiquement, que représente la solution d’un système de deux droites sécantes ?', quizBonne:'Leur point d’intersection',
    ),



    '1ere_D_math_ch01': _math1ereDChapitre(
      code:'ch01', titre:'Équations et inéquations du second degré dans ℝ',
      cours:r'''Une équation du second degré s’écrit ax²+bx+c=0 avec a≠0. Le discriminant Δ=b²−4ac permet de déterminer le nombre de solutions réelles. Les inéquations du second degré se résolvent à l’aide du signe du trinôme et de ses racines.''',
      renforcement:r'''Calcule d’abord Δ. Si Δ>0, le trinôme possède deux racines réelles ; si Δ=0, une racine double ; si Δ<0, aucune racine réelle. Pour une inéquation, construis ensuite le tableau de signes.''',
      enonce1:r'''Résous x²−5x+6=0.''', solution1:r'''(x−2)(x−3)=0, donc x=2 ou x=3.''',
      enonce2:r'''Résous x²−4x+3≤0.''', solution2:r'''Les racines sont 1 et 3 et le coefficient de x² est positif : solution [1;3].''',
      motsCles:'trinôme • second degré • discriminant • racines • signe', quiz1:'Que permet de déterminer le discriminant d’un trinôme ?', quizBonne:'Le nombre de solutions réelles et la nature des racines',
    ),
    '1ere_D_math_ch02': _math1ereDChapitre(
      code:'ch02', titre:'Angles orientés et trigonométrie',
      cours:r'''Les angles orientés décrivent un sens de rotation et sont définis modulo 2π. Le cercle trigonométrique permet de lire sinus et cosinus. Les identités fondamentales et les formules trigonométriques servent à transformer et résoudre des expressions.''',
      renforcement:r'''Travaille dans un repère trigonométrique et respecte le sens des angles. Utilise notamment sin²x+cos²x=1 et les relations de périodicité.''',
      enonce1:r'''Donne sin(π/2) et cos(π/2).''', solution1:r'''sin(π/2)=1 et cos(π/2)=0.''',
      enonce2:r'''Simplifie cos²x+sin²x.''', solution2:r'''L’expression vaut 1 pour tout réel x.''',
      motsCles:'angle orienté • cercle trigonométrique • sinus • cosinus • périodicité', quiz1:'Quelle relation fondamentale relie sinus et cosinus ?', quizBonne:'sin²x+cos²x=1',
    ),
    '1ere_D_math_ch03': _math1ereDChapitre(
      code:'ch03', titre:'Généralités sur les fonctions',
      cours:r'''Une fonction associe une image unique à chaque élément de son domaine. Son étude comprend domaine de définition, images, antécédents, zéros, signe, variations et représentation graphique. Les fonctions usuelles servent de modèles pour l’interprétation de situations.''',
      renforcement:r'''Dans f(a)=b, a est un antécédent de b et b est l’image de a. Pour déterminer les zéros, résous f(x)=0 et respecte le domaine de définition.''',
      enonce1:r'''Soit f(x)=4x−1. Calcule f(2).''', solution1:r'''f(2)=7.''',
      enonce2:r'''Pour f(x)=x²−16, trouve les zéros.''', solution2:r'''x²−16=(x−4)(x+4), donc x=−4 ou x=4.''',
      motsCles:'fonction • domaine • image • antécédent • zéro • variation', quiz1:'Dans f(3)=10, quelle est l’image de 3 ?', quizBonne:'10',
    ),
    '1ere_D_math_ch04': _math1ereDChapitre(
      code:'ch04', titre:'Limites et continuité',
      cours:r'''La limite décrit le comportement d’une fonction au voisinage d’un point ou lorsque la variable tend vers l’infini. La continuité en a signifie que la limite en a est égale à f(a). Les limites permettent d’étudier asymptotes et comportements aux bornes du domaine.''',
      renforcement:r'''Commence par identifier le point étudié et le domaine. Si une forme indéterminée apparaît, transforme l’expression par factorisation ou simplification avant de calculer la limite.''',
      enonce1:r'''Calcule lim(x→1)(2x+3).''', solution1:r'''La limite vaut 5.''',
      enonce2:r'''Calcule lim(x→+∞)(3x+2)/x.''', solution2:r'''La limite vaut 3.''',
      motsCles:'limite • continuité • voisinage • infini • asymptote', quiz1:'Une fonction continue en a vérifie quelle relation ?', quizBonne:'lim f(x) quand x tend vers a = f(a)',
    ),
    '1ere_D_math_ch05': _math1ereDChapitre(
      code:'ch05', titre:'Dénombrement',
      cours:r'''Le dénombrement permet de compter des possibilités sans les énumérer une à une. Les principes additif et multiplicatif, les arrangements, permutations et combinaisons répondent à des situations différentes selon que l’ordre compte ou non.''',
      renforcement:r'''Analyse d’abord le type de choix. Pour des étapes successives, multiplie les possibilités ; pour des cas exclusifs, additionne. Vérifie si l’ordre intervient.''',
      enonce1:r'''Un menu propose 3 entrées et 5 plats. Combien de menus entrée+plat ?''', solution1:r'''3×5=15 menus.''',
      enonce2:r'''Combien de façons de choisir 2 délégués parmi 8 sans ordre ?''', solution2:r'''C(8,2)=28.''',
      motsCles:'dénombrement • choix • arrangement • combinaison • permutation', quiz1:'Dans une combinaison, l’ordre du choix est-il pris en compte ?', quizBonne:'Non',
    ),
    '1ere_D_math_ch06': _math1ereDChapitre(
      code:'ch06', titre:'Dérivation',
      cours:r'''La dérivée d’une fonction donne son taux de variation instantané et le coefficient directeur de la tangente. Les règles de dérivation permettent d’étudier rapidement les variations d’une fonction.''',
      renforcement:r'''Reconnais la forme de la fonction, applique la règle de dérivation puis simplifie. Le signe de la dérivée permet ensuite de construire les variations.''',
      enonce1:r'''Dérive f(x)=x³+2x²−x.''', solution1:r'''f’(x)=3x²+4x−1.''',
      enonce2:r'''Détermine la dérivée de f(x)=5x²−3x+4.''', solution2:r'''f’(x)=10x−3.''',
      motsCles:'dérivée • taux de variation • tangente • pente • variation', quiz1:'Que représente f’(a) graphiquement ?', quizBonne:'Le coefficient directeur de la tangente à la courbe en a',
    ),
    '1ere_D_math_ch07': _math1ereDChapitre(
      code:'ch07', titre:'Extension de la notion de limite',
      cours:r'''L’étude des limites s’étend aux comportements à l’infini et aux limites infinies. Elle permet d’identifier des asymptotes et de traiter des expressions dont la forme initiale peut être indéterminée.''',
      renforcement:r'''Compare les termes dominants à l’infini. Pour une fraction rationnelle, divise par la plus grande puissance de x afin de faire apparaître la limite.''',
      enonce1:r'''Calcule lim(x→+∞)(2x²+1)/x².''', solution1:r'''La limite vaut 2.''',
      enonce2:r'''Calcule lim(x→+∞)(x+2)/(x²+1).''', solution2:r'''La limite vaut 0.''',
      motsCles:'limite à l’infini • limite infinie • asymptote • terme dominant', quiz1:'À l’infini, quelle idée permet souvent de simplifier une fraction rationnelle ?', quizBonne:'Comparer ou diviser par les termes de plus haut degré',
    ),
    '1ere_D_math_ch08': _math1ereDChapitre(
      code:'ch08', titre:'Barycentre',
      cours:r'''Le barycentre de points pondérés permet de représenter un centre associé à des coefficients. Il est défini lorsque la somme des coefficients n’est pas nulle. Les relations vectorielles du barycentre permettent d’étudier positions, alignements et milieux pondérés.''',
      renforcement:r'''Écris la relation vectorielle avec les coefficients. Vérifie leur somme avant d’utiliser la formule et simplifie les vecteurs avec soin.''',
      enonce1:r'''G est barycentre de (A,2) et (B,1). Quelle relation vérifie-t-il ?''', solution1:r'''2\vec{GA}+\vec{GB}=\vec{0}.''',
      enonce2:r'''Si G est barycentre de (A,1) et (B,3), exprime \vec{OG}.''', solution2:r'''\vec{OG}=(\vec{OA}+3\vec{OB})/4.''',
      motsCles:'barycentre • coefficients • points pondérés • vecteurs • position', quiz1:'Que doit vérifier la somme des coefficients d’un barycentre ?', quizBonne:'Elle doit être non nulle',
    ),
    '1ere_D_math_ch09': _math1ereDChapitre(
      code:'ch09', titre:'Étude et représentation graphique d’une fonction',
      cours:r'''L’étude d’une fonction organise les informations nécessaires à sa représentation : domaine, limites, dérivée, signe, variations et valeurs remarquables. Le tableau de variations sert de guide pour construire une courbe cohérente.''',
      renforcement:r'''Respecte l’ordre d’étude et place les points remarquables. Contrôle ensuite la cohérence de la courbe avec les variations et les limites.''',
      enonce1:r'''Pour f(x)=x²−2x, calcule f’(x).''', solution1:r'''f’(x)=2x−2.''',
      enonce2:r'''Détermine le minimum de f(x)=x²−2x−3.''', solution2:r'''Le sommet est en x=1 et f(1)=−4. Le minimum est −4.''',
      motsCles:'étude de fonction • dérivée • variations • tableau • courbe', quiz1:'Quelle information permet directement de construire le tableau de variations ?', quizBonne:'Le signe de la dérivée',
    ),
    '1ere_D_math_ch10': _math1ereDChapitre(
      code:'ch10', titre:'Probabilité',
      cours:r'''Une expérience aléatoire possède un ensemble d’issues. Une probabilité mesure la chance qu’un événement se réalise. Dans un univers fini équiprobable, elle se calcule comme le rapport des cas favorables aux cas possibles. Les événements contraires et incompatibles permettent de simplifier les calculs.''',
      renforcement:r'''Définis l’univers avant de compter. Vérifie que la probabilité obtenue appartient à [0;1] et utilise P(Ā)=1−P(A) pour un événement contraire.''',
      enonce1:r'''Un dé équilibré est lancé. Quelle est la probabilité d’obtenir 5 ?''', solution1:r'''P=1/6.''',
      enonce2:r'''Si P(A)=0,25, calcule P(Ā).''', solution2:r'''P(Ā)=1−0,25=0,75.''',
      motsCles:'probabilité • événement • univers • équiprobabilité • contraire', quiz1:'Quelle formule donne la probabilité de l’événement contraire ?', quizBonne:'P(Ā)=1−P(A)',
    ),
    '1ere_D_math_ch11': _math1ereDChapitre(
      code:'ch11', titre:'Suites numériques',
      cours:r'''Une suite associe des nombres aux entiers naturels. Elle peut être définie par une formule explicite ou une relation de récurrence. Les suites arithmétiques ont une raison additive constante et les suites géométriques une raison multiplicative constante.''',
      renforcement:r'''Compare deux termes consécutifs. Une différence constante indique une suite arithmétique ; un quotient constant indique une suite géométrique.''',
      enonce1:r'''Une suite arithmétique vérifie u_0=6 et r=3. Calcule u_5.''', solution1:r'''u_5=6+5×3=21.''',
      enonce2:r'''Une suite géométrique vérifie u_0=4 et q=2. Calcule u_4.''', solution2:r'''u_4=4×2^4=64.''',
      motsCles:'suite • terme • récurrence • arithmétique • géométrique • raison', quiz1:'Comment obtient-on le terme suivant d’une suite arithmétique ?', quizBonne:'En ajoutant la raison',
    ),
    '1ere_D_math_ch12': _math1ereDChapitre(
      code:'ch12', titre:'Composées de transformations du plan',
      cours:r'''Une transformation du plan associe des points à leurs images. Une composition applique plusieurs transformations successivement. Les translations, rotations, symétries et homothéties conservent certaines propriétés et permettent de construire ou démontrer des configurations.''',
      renforcement:r'''Respecte l’ordre de composition et suis les images de points caractéristiques. Pour une translation, additionne les vecteurs ; pour une rotation, conserve le centre et additionne les angles lorsqu’elle est composée avec elle-même.''',
      enonce1:r'''Deux translations de vecteurs u puis v donnent quelle translation ?''', solution1:r'''La translation de vecteur u+v.''',
      enonce2:r'''Deux rotations de même centre et d’angles 40° puis 50° donnent quelle rotation ?''', solution2:r'''Une rotation de même centre et d’angle 90°.''',
      motsCles:'transformation • composition • translation • rotation • symétrie', quiz1:'Dans une composition, l’ordre des transformations doit-il être respecté ?', quizBonne:'Oui',
    ),
    '1ere_D_math_ch13': _math1ereDChapitre(
      code:'ch13', titre:'Statistique à une variable',
      cours:r'''Une série statistique à une variable décrit les valeurs d’un caractère observé. Effectifs, fréquences, moyenne, médiane, quartiles et étendue permettent de résumer la série et d’en comparer les distributions.''',
      renforcement:r'''Ordonne les valeurs avant de déterminer médiane et quartiles. Avec des effectifs, utilise une moyenne pondérée et vérifie l’effectif total.''',
      enonce1:r'''Calcule la moyenne de 5, 7, 9, 11 et 13.''', solution1:r'''La moyenne est 9.''',
      enonce2:r'''Pour 2,4,6,8,10,12,14, donne la médiane et l’étendue.''', solution2:r'''La médiane est 8 et l’étendue est 12.''',
      motsCles:'statistique • effectif • fréquence • moyenne • médiane • quartile • étendue', quiz1:'Comment calcule-t-on l’étendue ?', quizBonne:'Maximum − minimum',
    ),
    '1ere_D_math_ch14': _math1ereDChapitre(
      code:'ch14', titre:'Systèmes d’équations linéaires dans ℝ² et ℝ³',
      cours:r'''Un système linéaire rassemble plusieurs équations portant sur plusieurs inconnues. La résolution cherche les valeurs qui satisfont simultanément toutes les équations. On utilise substitution ou combinaisons linéaires et on vérifie la solution dans le système.''',
      renforcement:r'''Choisis une inconnue facile à isoler ou éliminer. Pour trois inconnues, réduis progressivement le système à deux puis une inconnue avant de remonter aux autres.''',
      enonce1:r'''Résous x+y=9 et x−y=3.''', solution1:r'''En additionnant, 2x=12 donc x=6 et y=3.''',
      enonce2:r'''Résous x+y+z=6, x−y=2 et z=1.''', solution2:r'''x+y=5 et x−y=2, donc x=3,5 et y=1,5 ; z=1.''',
      motsCles:'système • équation linéaire • substitution • combinaison • inconnues', quiz1:'Une solution d’un système doit-elle vérifier toutes les équations ?', quizBonne:'Oui',
    ),
    '1ere_D_math_ch15': _math1ereDChapitre(
      code:'ch15', titre:'Orthogonalité dans l’espace',
      cours:r'''L’orthogonalité dans l’espace peut être étudiée avec les vecteurs et le produit scalaire. Deux vecteurs sont orthogonaux lorsque leur produit scalaire est nul. Une droite perpendiculaire à un plan est orthogonale à deux directions non colinéaires de ce plan.''',
      renforcement:r'''Pour démontrer une orthogonalité, choisis des vecteurs directeurs adaptés et calcule leur produit scalaire. Pour une droite et un plan, utilise deux directions indépendantes du plan.''',
      enonce1:r'''Les vecteurs u=(1,1,0) et v=(1,−1,0) sont-ils orthogonaux ?''', solution1:r'''u·v=1−1=0, donc ils sont orthogonaux.''',
      enonce2:r'''Un vecteur directeur d=(2,0,0) est-il orthogonal au vecteur n=(0,1,0) ?''', solution2:r'''Oui, d·n=0.''',
      motsCles:'orthogonalité • espace • produit scalaire • vecteur • plan', quiz1:'Quelle condition caractérise deux vecteurs orthogonaux ?', quizBonne:'Leur produit scalaire est nul',
    ),



    '1ere_C_math_ch01': _math1ereCChapitre(
      code:'ch01', titre:'Équations et inéquations dans ℝ',
      cours:r'''Une équation cherche les réels qui rendent une égalité vraie. Les inéquations décrivent des ensembles de solutions. La factorisation, le produit nul et les tableaux de signes permettent de traiter des expressions algébriques plus complexes.''',
      renforcement:r'''Simplifie avant de résoudre. Pour une inéquation, surveille le signe lors d’une multiplication ou division. Pour un produit, repère les valeurs qui annulent chaque facteur puis construis le tableau de signes.''',
      enonce1:r'''Résous 3x−8=13.''', solution1:r'''3x=21, donc x=7.''',
      enonce2:r'''Résous (x−2)(x+4)>0.''', solution2:r'''Le produit est positif pour x<−4 ou x>2.''',
      motsCles:'équation • inéquation • produit nul • factorisation • signe', quiz1:'Lorsqu’on divise une inéquation par un nombre négatif, que fait-on ?', quizBonne:'On inverse le sens de l’inégalité',
    ),
    '1ere_C_math_ch02': _math1ereCChapitre(
      code:'ch02', titre:'Angles orientés et trigonométrie',
      cours:r'''Les angles orientés permettent de tenir compte du sens de rotation. En trigonométrie, le cercle trigonométrique relie les angles aux valeurs de sinus, cosinus et tangente. Les identités fondamentales et les formules d’addition permettent de transformer et résoudre des expressions trigonométriques.''',
      renforcement:r'''Repère d’abord l’angle sur le cercle trigonométrique et respecte les unités. Utilise cos²x+sin²x=1 et les relations de périodicité pour simplifier les expressions.''',
      enonce1:r'''Donne cos(0) et sin(0).''', solution1:r'''cos(0)=1 et sin(0)=0.''',
      enonce2:r'''Simplifie sin²x+cos²x.''', solution2:r'''L’expression vaut 1 pour tout réel x.''',
      motsCles:'angle orienté • cercle trigonométrique • sinus • cosinus • tangente', quiz1:'Quelle identité est toujours vraie ?', quizBonne:'sin²x+cos²x=1',
    ),
    '1ere_C_math_ch03': _math1ereCChapitre(
      code:'ch03', titre:'Généralités sur les fonctions',
      cours:r'''Une fonction associe à chaque élément de son domaine une unique image. Son étude porte sur le domaine, les images, les antécédents, les zéros, le signe, les variations et les représentations graphiques. Les fonctions peuvent être étudiées algébriquement ou graphiquement.''',
      renforcement:r'''Dans f(a)=b, a est un antécédent de b. Pour trouver les zéros, résous f(x)=0. Pour une lecture graphique, utilise les coordonnées et les intersections avec les axes.''',
      enonce1:r'''Soit f(x)=2x+1. Calcule f(3).''', solution1:r'''f(3)=7.''',
      enonce2:r'''Pour f(x)=x²−9, détermine les zéros.''', solution2:r'''x²−9=(x−3)(x+3), donc les zéros sont −3 et 3.''',
      motsCles:'fonction • domaine • image • antécédent • zéro • variation', quiz1:'Dans f(2)=−5, quel est l’antécédent de −5 ?', quizBonne:'2',
    ),
    '1ere_C_math_ch04': _math1ereCChapitre(
      code:'ch04', titre:'Barycentre',
      cours:r'''Le barycentre généralise la notion de centre de gravité d’un système de points pondérés. Pour deux points A et B affectés de coefficients non opposés, le barycentre G vérifie une relation vectorielle entre GA et GB. La notion permet de démontrer des alignements et de déterminer des lieux géométriques.''',
      renforcement:r'''Écris la relation vectorielle du barycentre avec les coefficients donnés. Vérifie que leur somme n’est pas nulle avant d’utiliser la formule.''',
      enonce1:r'''Pour deux points A et B de coefficients 2 et 1, quelle relation vérifie leur barycentre G ?''', solution1:r'''2\vec{GA}+\vec{GB}=\vec{0}.''',
      enonce2:r'''Si G est le barycentre de (A,2) et (B,1), exprime \vec{OG}.''', solution2:r'''\vec{OG}=(2\vec{OA}+\vec{OB})/3.''',
      motsCles:'barycentre • points pondérés • coefficients • vecteurs • centre de gravité', quiz1:'Quelle condition faut-il pour définir le barycentre de points pondérés ?', quizBonne:'La somme des coefficients doit être non nulle',
    ),
    '1ere_C_math_ch05': _math1ereCChapitre(
      code:'ch05', titre:'Limites et continuité',
      cours:r'''La limite décrit le comportement d’une fonction lorsque la variable se rapproche d’une valeur ou devient très grande. Une fonction est continue en a lorsque sa limite en a existe et vaut f(a). Les limites permettent notamment d’étudier les comportements aux bornes du domaine.''',
      renforcement:r'''Identifie le point ou l’infini étudié. Cherche d’abord une forme simple ; en cas d’indétermination, factorise ou utilise une transformation adaptée.''',
      enonce1:r'''Calcule lim(x→2) (x+3).''', solution1:r'''La limite vaut 5.''',
      enonce2:r'''Calcule lim(x→+∞) (2x+1)/x.''', solution2:r'''En divisant par x, on obtient 2+1/x, donc la limite est 2.''',
      motsCles:'limite • continuité • voisinage • infini • indétermination', quiz1:'Que signifie qu’une fonction est continue en a ?', quizBonne:'Sa limite en a existe et vaut f(a)',
    ),
    '1ere_C_math_ch06': _math1ereCChapitre(
      code:'ch06', titre:'Dénombrement',
      cours:r'''Le dénombrement compte des configurations finies. Selon le problème, on utilise les principes additif et multiplicatif, les arrangements, les permutations ou les combinaisons. La distinction entre ordre important et ordre non important est essentielle.''',
      renforcement:r'''Décris précisément l’expérience avant de choisir une formule. Un arbre aide à visualiser les choix successifs et les répétitions.''',
      enonce1:r'''Combien de codes à deux chiffres peut-on former avec 0 à 9 si les répétitions sont autorisées ?''', solution1:r'''10×10=100 codes.''',
      enonce2:r'''Combien de groupes de 3 élèves peut-on choisir parmi 6 ?''', solution2:r'''C(6,3)=20.''',
      motsCles:'dénombrement • permutation • arrangement • combinaison • choix', quiz1:'Dans une combinaison, l’ordre des éléments choisis compte-t-il ?', quizBonne:'Non',
    ),
    '1ere_C_math_ch07': _math1ereCChapitre(
      code:'ch07', titre:'Extension de la notion de limite',
      cours:r'''Les limites peuvent être étudiées lorsqu’une variable tend vers un réel, vers +∞ ou vers −∞. L’extension permet d’analyser les asymptotes et des expressions présentant des formes indéterminées. Les transformations algébriques facilitent le calcul des limites.''',
      renforcement:r'''Repère la forme obtenue avant de conclure. Pour une fraction rationnelle à l’infini, compare les degrés ou divise par la plus grande puissance de x.''',
      enonce1:r'''Calcule lim(x→+∞) (3x²+1)/x².''', solution1:r'''En divisant par x², la limite vaut 3.''',
      enonce2:r'''Calcule lim(x→+∞) (x+1)/(x²+2).''', solution2:r'''En divisant par x², on obtient (1/x+1/x²)/(1+2/x²), donc la limite est 0.''',
      motsCles:'limite à l’infini • forme indéterminée • asymptote • degré • comportement', quiz1:'Pour une fraction rationnelle à l’infini, quel élément compare-t-on souvent en premier ?', quizBonne:'Les degrés du numérateur et du dénominateur',
    ),
    '1ere_C_math_ch08': _math1ereCChapitre(
      code:'ch08', titre:'Composées de transformations du plan',
      cours:r'''Les transformations du plan, comme les translations, rotations, symétries et homothéties, peuvent être composées. Une composition consiste à appliquer successivement plusieurs transformations. L’étude des images de points et des propriétés conservées permet d’identifier la transformation résultante.''',
      renforcement:r'''Respecte l’ordre des transformations : appliquer T puis S signifie S∘T. Suis quelques points caractéristiques pour comprendre la transformation obtenue.''',
      enonce1:r'''Une translation de vecteur u suivie d’une translation de vecteur v équivaut à quelle translation ?''', solution1:r'''À la translation de vecteur u+v.''',
      enonce2:r'''Une rotation de centre O et d’angle 90° est appliquée deux fois. Quelle rotation obtient-on ?''', solution2:r'''Une rotation de centre O et d’angle 180°.''',
      motsCles:'transformation • composition • translation • rotation • symétrie', quiz1:'Dans une composition T puis S, quelle transformation est appliquée en premier ?', quizBonne:'T',
    ),
    '1ere_C_math_ch09': _math1ereCChapitre(
      code:'ch09', titre:'Dérivation',
      cours:r'''La dérivée donne le taux de variation instantané d’une fonction. Elle permet de calculer la pente de la tangente et d’étudier les variations. Les règles de dérivation s’appliquent aux fonctions usuelles et à leurs sommes, produits ou compositions selon le niveau étudié.''',
      renforcement:r'''Commence par reconnaître la forme de la fonction. Applique la règle de dérivation puis simplifie. Le signe de la dérivée donne les variations.''',
      enonce1:r'''Dérive f(x)=x³−2x.''', solution1:r'''f’(x)=3x²−2.''',
      enonce2:r'''Détermine la dérivée de f(x)=5x²+4x−7.''', solution2:r'''f’(x)=10x+4.''',
      motsCles:'dérivée • taux de variation • tangente • pente • variation', quiz1:'Que représente graphiquement f’(a) ?', quizBonne:'Le coefficient directeur de la tangente à la courbe en a',
    ),
    '1ere_C_math_ch10': _math1ereCChapitre(
      code:'ch10', titre:'Orthogonalité de l’espace',
      cours:r'''Dans l’espace, l’orthogonalité concerne les droites, plans et vecteurs. Deux vecteurs sont orthogonaux lorsque leur produit scalaire est nul. Une droite est perpendiculaire à un plan lorsqu’elle est orthogonale à toutes les directions du plan.''',
      renforcement:r'''Utilise les vecteurs directeurs et le produit scalaire. Pour montrer qu’une droite est perpendiculaire à un plan, vérifie son orthogonalité avec deux directions non colinéaires du plan.''',
      enonce1:r'''Calcule le produit scalaire de u=(1,2,−1) et v=(2,0,2).''', solution1:r'''u·v=1×2+2×0+(−1)×2=0. Les vecteurs sont orthogonaux.''',
      enonce2:r'''Que peut-on conclure si un vecteur normal n d’un plan est colinéaire au vecteur directeur d’une droite d ?''', solution2:r'''La droite d est perpendiculaire au plan.''',
      motsCles:'espace • orthogonalité • produit scalaire • plan • vecteur normal', quiz1:'Quand deux vecteurs sont-ils orthogonaux ?', quizBonne:'Lorsque leur produit scalaire est nul',
    ),
    '1ere_C_math_ch11': _math1ereCChapitre(
      code:'ch11', titre:'Étude et représentation graphique d’une fonction',
      cours:r'''L’étude d’une fonction rassemble domaine, limites éventuelles, dérivée, signe, variations et valeurs remarquables. Le tableau de variations organise les résultats et permet ensuite de construire une représentation graphique cohérente.''',
      renforcement:r'''Travaille dans l’ordre : domaine → limites → dérivée → signe de la dérivée → variations → points remarquables. Vérifie la cohérence graphique avec les résultats obtenus.''',
      enonce1:r'''Pour f(x)=x²−4x, calcule f’(x).''', solution1:r'''f’(x)=2x−4.''',
      enonce2:r'''Détermine le minimum de f(x)=x²−4x+3.''', solution2:r'''Le sommet est en x=2 et f(2)=−1. Le minimum vaut −1.''',
      motsCles:'étude de fonction • dérivée • variation • tableau • courbe', quiz1:'Quelle information fournit le signe de la dérivée ?', quizBonne:'Le sens de variation de la fonction',
    ),
    '1ere_C_math_ch12': _math1ereCChapitre(
      code:'ch12', titre:'Probabilité',
      cours:r'''Une expérience aléatoire possède plusieurs issues possibles. Une probabilité associe à chaque événement un nombre entre 0 et 1. Dans un univers fini équiprobable, P(A)=nombre de cas favorables/nombre de cas possibles. On utilise aussi les événements contraires et les réunions.''',
      renforcement:r'''Définis clairement l’univers et l’événement. Vérifie que les probabilités sont comprises entre 0 et 1 et que les événements incompatibles sont traités correctement.''',
      enonce1:r'''On lance un dé équilibré. Quelle est la probabilité d’obtenir un nombre pair ?''', solution1:r'''Les issues favorables sont 2,4,6 : P=3/6=1/2.''',
      enonce2:r'''Si P(A)=0,3, quelle est P(Ā) ?''', solution2:r'''P(Ā)=1−0,3=0,7.''',
      motsCles:'probabilité • événement • univers • équiprobabilité • contraire', quiz1:'Quelle est la probabilité de l’événement contraire de A ?', quizBonne:'1−P(A)',
    ),
    '1ere_C_math_ch13': _math1ereCChapitre(
      code:'ch13', titre:'Système d’équations linéaires dans ℝ² et ℝ³',
      cours:r'''Un système linéaire à deux ou trois inconnues cherche les valeurs qui vérifient simultanément plusieurs équations. On peut utiliser substitution, combinaison linéaire ou une méthode matricielle selon le niveau. Une solution doit satisfaire toutes les équations du système.''',
      renforcement:r'''Élimine progressivement les inconnues ou isole une variable. Après résolution, remplace les valeurs trouvées dans chaque équation pour vérifier.''',
      enonce1:r'''Résous x+y=7 et x−y=1.''', solution1:r'''En additionnant, 2x=8 donc x=4 et y=3.''',
      enonce2:r'''Résous x+y+z=6, x−y=0 et z=2.''', solution2:r'''z=2 et x=y. Donc 2x+2=6, x=y=2. Solution (2,2,2).''',
      motsCles:'système linéaire • inconnue • substitution • combinaison • solution', quiz1:'Combien d’équations faut-il au minimum pour déterminer trois inconnues dans un système linéaire indépendant ?', quizBonne:'Trois',
    ),
    '1ere_C_math_ch14': _math1ereCChapitre(
      code:'ch14', titre:'Géométrie analytique du plan',
      cours:r'''La géométrie analytique décrit les objets du plan avec des coordonnées et des équations. Les vecteurs permettent de calculer directions et colinéarité. Une droite peut être décrite par une équation cartésienne ou paramétrique, et les coordonnées permettent d’étudier intersections et distances.''',
      renforcement:r'''Choisis un repère adapté. Pour une droite, identifie un point et une direction ou un vecteur normal. Vérifie les coordonnées en les remplaçant dans l’équation.''',
      enonce1:r'''Donne un vecteur directeur de la droite 2x−y+3=0.''', solution1:r'''Un vecteur directeur est (1,2), car 2×1−2=0.''',
      enonce2:r'''Le point A(2,1) appartient-il à la droite x+2y−4=0 ?''', solution2:r'''2+2×1−4=0, donc oui.''',
      motsCles:'repère • coordonnées • vecteur • droite • équation cartésienne', quiz1:'Comment vérifier qu’un point appartient à une droite donnée par une équation ?', quizBonne:'En remplaçant ses coordonnées dans l’équation',
    ),
    '1ere_C_math_ch15': _math1ereCChapitre(
      code:'ch15', titre:'Suites numériques',
      cours:r'''Une suite numérique associe un réel à chaque entier naturel de son domaine. Elle peut être définie explicitement ou par récurrence. Les suites arithmétiques et géométriques constituent deux familles fondamentales, avec des formules permettant de calculer leurs termes.''',
      renforcement:r'''Observe la relation entre deux termes consécutifs. Une différence constante indique une suite arithmétique ; un quotient constant non nul indique une suite géométrique.''',
      enonce1:r'''Une suite arithmétique vérifie u_0=4 et r=5. Calcule u_6.''', solution1:r'''u_6=4+6×5=34.''',
      enonce2:r'''Une suite géométrique vérifie u_0=2 et q=3. Calcule u_3.''', solution2:r'''u_3=2×3³=54.''',
      motsCles:'suite • terme • récurrence • arithmétique • géométrique • raison', quiz1:'Quel est le point commun caractéristique d’une suite arithmétique ?', quizBonne:'La différence entre deux termes consécutifs est constante',
    ),
    '1ere_C_math_ch16': _math1ereCChapitre(
      code:'ch16', titre:'Vecteurs de l’espace',
      cours:r'''Dans l’espace, un vecteur est caractérisé par ses coordonnées dans un repère. On peut additionner des vecteurs, les multiplier par un réel et étudier leur colinéarité. Les vecteurs servent à décrire directions, parallélisme et positions de points.''',
      renforcement:r'''Pour calculer AB, fais coordonnées de B moins coordonnées de A. Deux vecteurs sont colinéaires lorsqu’il existe un réel k tel que v=ku.''',
      enonce1:r'''Détermine \vec{AB} pour A(1,2,−1) et B(4,0,2).''', solution1:r'''\vec{AB}=(3,−2,3).''',
      enonce2:r'''Les vecteurs u=(1,−2,3) et v=(2,−4,6) sont-ils colinéaires ?''', solution2:r'''Oui, v=2u.''',
      motsCles:'vecteur • espace • coordonnées • colinéarité • repère', quiz1:'Comment obtient-on les coordonnées de \vec{AB} ?', quizBonne:'Coordonnées de B moins coordonnées de A',
    ),
    '1ere_C_math_ch17': _math1ereCChapitre(
      code:'ch17', titre:'Statistique à une variable',
      cours:r'''Une série statistique à une variable étudie un caractère sur une population. Les effectifs, fréquences, moyenne, médiane, quartiles et étendue permettent de résumer les données. Les représentations graphiques aident à interpréter la distribution.''',
      renforcement:r'''Ordonne les données avant de déterminer médiane et quartiles. Pour une série avec effectifs, calcule la moyenne à partir des produits valeur×effectif et vérifie l’effectif total.''',
      enonce1:r'''Calcule la moyenne de 4, 6, 8, 10 et 12.''', solution1:r'''La moyenne est 8.''',
      enonce2:r'''Pour 2,4,5,7,9,11,14, donne la médiane et l’étendue.''', solution2:r'''La médiane est 7 et l’étendue est 14−2=12.''',
      motsCles:'statistique • effectif • fréquence • moyenne • médiane • quartile • étendue', quiz1:'Que mesure l’étendue d’une série ?', quizBonne:'La différence entre la plus grande et la plus petite valeur',
    ),



    '1ere_A2_math_ch01': _math1ereA2Chapitre(
      code: 'ch01', titre: 'Équations et inéquations dans ℝ',
      cours: r'''Dans ℝ, une équation cherche les réels qui rendent une égalité vraie. Une inéquation décrit un ensemble de solutions. On utilise les propriétés de l’ordre, les produits nuls, les factorisations et les tableaux de signes pour résoudre des expressions plus complexes.''',
      renforcement: r'''Commence par simplifier puis ramène l’expression à une forme connue. Pour une inéquation, conserve le sens du signe lors d’une multiplication ou division par un nombre positif et inverse-le pour un nombre négatif.''',
      enonce1: r'''Résous 2x−5=9.''', solution1: r'''2x=14, donc x=7.''',
      enonce2: r'''Résous (x−3)(x+2)≤0.''', solution2: r'''Le produit est négatif ou nul entre les deux racines : x∈[−2;3].''',
      motsCles: 'équation • inéquation • ordre • factorisation • tableau de signes', quiz1: 'Que faut-il faire lorsqu’on divise une inéquation par un nombre négatif ?', quizBonne: 'Inverser le sens de l’inégalité',
    ),

    '1ere_A2_math_ch02': _math1ereA2Chapitre(
      code: 'ch02', titre: 'Dénombrement',
      cours: r'''Le dénombrement permet de déterminer le nombre de résultats possibles dans une expérience. Le principe additif s’utilise pour des cas séparés et le principe multiplicatif pour des choix successifs. Les arrangements, permutations et combinaisons permettent de compter des sélections selon que l’ordre compte ou non.''',
      renforcement: r'''Avant de compter, précise si l’ordre intervient et si les répétitions sont autorisées. Organise les cas avec un arbre ou une formule adaptée.''',
      enonce1: r'''Une tenue est composée d’une chemise parmi 4 et d’un pantalon parmi 3. Combien de tenues ?''', solution1: r'''4×3=12 tenues.''',
      enonce2: r'''Combien de façons de choisir 2 élèves parmi 5, sans tenir compte de l’ordre ?''', solution2: r'''Il y en a C(5,2)=5×4/2=10.''',
      motsCles: 'dénombrement • principe additif • principe multiplicatif • arrangement • combinaison', quiz1: 'Si deux choix successifs offrent 5 puis 4 possibilités, combien de résultats ?', quizBonne: '20',
    ),

    '1ere_A2_math_ch03': _math1ereA2Chapitre(
      code: 'ch03', titre: 'Généralités sur les fonctions',
      cours: r'''Une fonction f associe à chaque élément de son domaine une unique image. On étudie notamment son domaine de définition, ses images et antécédents, ses zéros, son signe et ses variations. Une fonction peut être représentée par une expression, un tableau ou une courbe.''',
      renforcement: r'''Dans f(a)=b, a est un antécédent de b et b est l’image de a. Pour résoudre f(x)=k, recherche les antécédents de k. Vérifie toujours que les valeurs utilisées appartiennent au domaine.''',
      enonce1: r'''Soit f(x)=3x−2. Calcule f(4).''', solution1: r'''f(4)=3×4−2=10.''',
      enonce2: r'''Soit f(x)=x²−4. Détermine ses zéros.''', solution2: r'''x²−4=0, donc (x−2)(x+2)=0 et x=−2 ou x=2.''',
      motsCles: 'fonction • domaine • image • antécédent • zéro • variations', quiz1: 'Dans f(5)=12, quelle est l’image de 5 ?', quizBonne: '12',
    ),

    '1ere_A2_math_ch04': _math1ereA2Chapitre(
      code: 'ch04', titre: 'Dérivabilité et étude de fonctions',
      cours: r'''La dérivée f' mesure la variation locale d’une fonction dérivable. Son signe permet d’établir les variations : f’>0 correspond à une croissance et f’<0 à une décroissance. L’étude complète associe domaine, limites éventuelles, dérivée, signe et tableau de variations.''',
      renforcement: r'''Détermine d’abord le domaine, puis calcule f'. Résous f’(x)=0, étudie le signe de f' et déduis les variations. Vérifie les valeurs aux points remarquables.''',
      enonce1: r'''Calcule la dérivée de f(x)=x²+3x−1.''', solution1: r'''f’(x)=2x+3.''',
      enonce2: r'''Pour f(x)=x²−6x+2, indique le sens de variation de f.''', solution2: r'''f’(x)=2x−6. Donc f est décroissante sur ]−∞;3] puis croissante sur [3;+∞[.''',
      motsCles: 'dérivée • dérivabilité • signe • variations • extremum', quiz1: 'Si f’(x)<0 sur un intervalle, que peut-on conclure ?', quizBonne: 'f est décroissante sur cet intervalle',
    ),

    '1ere_A2_math_ch05': _math1ereA2Chapitre(
      code: 'ch05', titre: 'Suites numériques',
      cours: r'''Une suite numérique est une fonction définie sur une partie de ℕ. Elle peut être donnée explicitement ou par récurrence. Les suites arithmétiques ont une différence constante et les suites géométriques un quotient constant. On peut calculer leurs termes et étudier leur évolution.''',
      renforcement: r'''Identifie la relation entre deux termes consécutifs. Pour une suite arithmétique, u_{n+1}=u_n+r. Pour une suite géométrique, u_{n+1}=q u_n.''',
      enonce1: r'''Une suite arithmétique vérifie u_0=7 et r=4. Calcule u_5.''', solution1: r'''u_5=7+5×4=27.''',
      enonce2: r'''Une suite géométrique vérifie u_0=3 et q=2. Calcule u_4.''', solution2: r'''u_4=3×2^4=48.''',
      motsCles: 'suite • terme • récurrence • arithmétique • géométrique • raison', quiz1: 'Dans une suite géométrique de raison q, comment obtient-on u_{n+1} ?', quizBonne: 'En multipliant u_n par q',
    ),

    '1ere_A2_math_ch06': _math1ereA2Chapitre(
      code: 'ch06', titre: 'Statistique',
      cours: r'''La statistique décrit une population à partir d’un caractère étudié. On utilise effectifs, fréquences, moyenne, médiane, quartiles et étendue pour résumer une série. Les représentations graphiques facilitent la lecture et la comparaison des données.''',
      renforcement: r'''Trie les données avant de chercher médiane et quartiles. Pour une moyenne avec effectifs, utilise la somme des produits valeur×effectif divisée par l’effectif total. L’étendue vaut maximum−minimum.''',
      enonce1: r'''Calcule la moyenne de 8, 10, 12, 14 et 16.''', solution1: r'''La moyenne est (8+10+12+14+16)/5=12.''',
      enonce2: r'''Pour la série 3, 5, 7, 9, 11, 15, détermine la médiane et l’étendue.''', solution2: r'''La médiane est (7+9)/2=8 et l’étendue est 15−3=12.''',
      motsCles: 'statistique • effectif • fréquence • moyenne • médiane • quartile • étendue', quiz1: 'Comment calcule-t-on l’étendue d’une série ?', quizBonne: 'Maximum − minimum',
    ),

    '1ere_A2_math_ch07': _math1ereA2Chapitre(
      code: 'ch07', titre: 'Systèmes d’équations linéaires dans ℝ × ℝ',
      cours: r'''Un système linéaire à deux inconnues recherche les couples (x,y) qui vérifient simultanément deux équations. On peut utiliser la substitution, la combinaison linéaire ou une lecture graphique. Une solution correspond à l’intersection des deux droites lorsqu’elle existe.''',
      renforcement: r'''Choisis une inconnue facile à isoler ou cherche une combinaison qui élimine une inconnue. Vérifie toujours le couple obtenu dans les deux équations.''',
      enonce1: r'''Résous le système x+y=10 et x−y=2.''', solution1: r'''En additionnant, 2x=12 donc x=6 puis y=4. Solution : (6;4).''',
      enonce2: r'''Résous le système 2x+y=7 et x−y=2.''', solution2: r'''De x−y=2, y=x−2. Donc 2x+x−2=7, soit x=3 et y=1. Solution : (3;1).''',
      motsCles: 'système • équation linéaire • substitution • combinaison • couple solution', quiz1: 'Que représente graphiquement la solution d’un système de deux droites sécantes ?', quizBonne: 'Le point d’intersection des deux droites',
    ),



    '1ere_A1_math_ch01': _math1ereA1Chapitre(
      code: 'ch01', titre: 'Équations et inéquations',
      cours: r'''Une équation cherche les valeurs qui rendent une égalité vraie. Une inéquation décrit un ensemble de réels vérifiant une relation d’ordre. Pour un produit nul, AB=0 équivaut à A=0 ou B=0. Lorsqu’on multiplie ou divise une inéquation par un nombre négatif, le sens du signe s’inverse.''',
      renforcement: r'''Isole l’inconnue étape par étape. Pour une inéquation, surveille toujours le signe du coefficient par lequel tu divises. Pour un produit ou quotient, utilise un tableau de signes.''',
      enonce1: r'''Résous 3x−7=11.''', solution1: r'''3x=18, donc x=6.''',
      enonce2: r'''Résous (x−2)(x+5)>0.''', solution2: r'''Le produit est positif pour x<−5 ou x>2.''',
      motsCles: 'équation • inéquation • produit nul • signe • intervalle', quiz1: 'Que devient le signe d’une inéquation lorsqu’on divise par un nombre négatif ?', quizBonne: 'Il s’inverse',
    ),

    '1ere_A1_math_ch02': _math1ereA1Chapitre(
      code: 'ch02', titre: 'Dénombrement',
      cours: r'''Le dénombrement permet de compter des possibilités. Pour des choix successifs indépendants, le principe multiplicatif consiste à multiplier les nombres de possibilités. Les arbres et tableaux organisent les cas et évitent les oublis.''',
      renforcement: r'''Avant de multiplier, identifie clairement chaque étape et vérifie si les répétitions sont autorisées. Pour des cas séparés, on additionne les possibilités ; pour des choix successifs, on multiplie.''',
      enonce1: r'''Une tenue comprend 5 chemises et 4 pantalons. Combien de tenues ?''', solution1: r'''5×4=20 tenues.''',
      enonce2: r'''Un code comporte 3 lettres parmi A, B, C, D puis 2 chiffres parmi 0,1,2. Les répétitions sont autorisées. Combien de codes ?''', solution2: r'''4×4×4×3×3=432 codes.''',
      motsCles: 'dénombrement • choix • arbre • principe multiplicatif • cas', quiz1: 'Quel principe utilise-t-on pour deux choix successifs de 6 puis 3 possibilités ?', quizBonne: 'Le produit 6×3',
    ),

    '1ere_A1_math_ch03': _math1ereA1Chapitre(
      code: 'ch03', titre: 'Généralités sur les fonctions',
      cours: r'''Une fonction associe à chaque nombre de son domaine une unique image. On peut l’étudier à partir d’une expression, d’un tableau ou d’une courbe. Les notions d’image, d’antécédent, de zéro et de variations sont fondamentales.''',
      renforcement: r'''Dans f(a)=b, a est un antécédent de b et b est l’image de a. Pour résoudre f(x)=k, cherche les antécédents de k. Pour f(x)=0, cherche les zéros.''',
      enonce1: r'''On donne f(x)=2x+3. Calcule f(4) et l’antécédent de 11.''', solution1: r'''f(4)=11. Pour 2x+3=11, x=4.''',
      enonce2: r'''Une fonction vérifie f(−2)=5 et f(3)=0. Donne un antécédent de 5 et un zéro de la fonction.''', solution2: r'''−2 est un antécédent de 5 et 3 est un zéro.''',
      motsCles: 'fonction • image • antécédent • zéro • domaine • variations', quiz1: 'Dans f(−1)=8, quelle est l’image de −1 ?', quizBonne: '8',
    ),

    '1ere_A1_math_ch04': _math1ereA1Chapitre(
      code: 'ch04', titre: 'Dérivabilité et étude de fonctions',
      cours: r'''Une fonction dérivable sur un intervalle admet une dérivée. Le signe de f' permet d’étudier les variations : si f’>0 la fonction est croissante et si f’<0 elle est décroissante. Les extrema locaux peuvent être repérés à partir des changements de signe de la dérivée.''',
      renforcement: r'''Pour étudier une fonction, commence par son domaine puis calcule sa dérivée. Résous f’(x)=0, construis le tableau de signe de f' et déduis le tableau de variations.''',
      enonce1: r'''Dérive f(x)=x²−3x+2.''', solution1: r'''f’(x)=2x−3.''',
      enonce2: r'''Pour f(x)=x²−4x+1, détermine le point où la dérivée s’annule et indique le sens de variation.''', solution2: r'''f’(x)=2x−4, donc f’=0 pour x=2. La fonction décroît avant 2 puis croît après 2.''',
      motsCles: 'dérivée • dérivabilité • variations • extremum • tableau', quiz1: 'Si f’(x)>0 sur un intervalle, comment varie f ?', quizBonne: 'Elle est croissante',
    ),

    '1ere_A1_math_ch05': _math1ereA1Chapitre(
      code: 'ch05', titre: 'Suites numériques',
      cours: r'''Une suite numérique associe à chaque entier naturel n un nombre réel u_n. Elle peut être définie explicitement, par exemple u_n=f(n), ou par récurrence, par exemple u_{n+1}=g(u_n). Les suites arithmétiques ont une différence constante et les suites géométriques un quotient constant non nul.''',
      renforcement: r'''Pour une suite arithmétique, u_n=u_0+nr si elle commence à n=0. Pour une suite géométrique, u_n=u_0q^n. Identifie d’abord la nature de la suite avant d’appliquer une formule.''',
      enonce1: r'''Une suite arithmétique vérifie u_0=5 et r=3. Calcule u_4.''', solution1: r'''u_4=5+4×3=17.''',
      enonce2: r'''Une suite géométrique vérifie u_0=2 et q=3. Calcule u_4.''', solution2: r'''u_4=2×3^4=162.''',
      motsCles: 'suite • terme • récurrence • arithmétique • géométrique • raison', quiz1: 'Dans une suite arithmétique, comment obtient-on le terme suivant ?', quizBonne: 'On ajoute la raison',
    ),

    '1ere_A1_math_ch06': _math1ereA1Chapitre(
      code: 'ch06', titre: 'Statistique',
      cours: r'''Une série statistique décrit un caractère observé sur une population. On utilise effectifs, fréquences, moyenne, médiane, quartiles et étendue. La moyenne pondérée tient compte des effectifs. Les indicateurs permettent de résumer et comparer des séries.''',
      renforcement: r'''Ordonne les données avant médiane et quartiles. Vérifie l’effectif total. La moyenne se calcule par somme(valeur×effectif)/effectif total et l’étendue par maximum−minimum.''',
      enonce1: r'''Pour les données 6, 8, 9, 11, 16, calcule la moyenne et la médiane.''', solution1: r'''Moyenne=50/5=10. Médiane=9.''',
      enonce2: r'''Pour 2,4,5,7,10,12,14, calcule la médiane et l’étendue.''', solution2: r'''Médiane=7. Étendue=14−2=12.''',
      motsCles: 'statistique • effectif • fréquence • moyenne • médiane • quartile • étendue', quiz1: 'Dans une série ordonnée de 5 valeurs, quelle est la position de la médiane ?', quizBonne: 'La 3e valeur',
    ),

    '1ere_A1_math_ch07': _math1ereA1Chapitre(
      code: 'ch07', titre: 'Systèmes d’équations dans ℝ × ℝ',
      cours: r'''Un système de deux équations linéaires à deux inconnues cherche un couple qui vérifie simultanément les deux égalités. Les méthodes principales sont la substitution et la combinaison linéaire. Graphiquement, les équations représentent des droites et une solution unique correspond à leur intersection.''',
      renforcement: r'''Choisis une inconnue à éliminer ou à exprimer. Après obtention du couple, vérifie-le dans les deux équations. La lecture graphique permet d’interpréter les cas d’une solution, d’aucune solution ou d’une infinité de solutions.''',
      enonce1: r'''Résous x+y=9 et 2x−y=6.''', solution1: r'''En additionnant les deux équations, 3x=15 donc x=5 et y=4.''',
      enonce2: r'''Résous 3x+2y=16 et x−y=1.''', solution2: r'''De la seconde, x=y+1. Donc 3(y+1)+2y=16, 5y=13, y=13/5 et x=18/5.''',
      motsCles: 'système • substitution • combinaison • inconnues • droites • intersection', quiz1: 'Graphiquement, que représente la solution unique d’un système ?', quizBonne: 'Le point d’intersection des deux droites',
    ),


    '2nde_C_math_ch01': _math2ndeCChapitre(
      code: 'ch01', titre: 'Vecteurs et points du plan',
      cours: r'''Un vecteur est caractérisé par une direction, un sens et une longueur. Dans un repère, si A(xA;yA) et B(xB;yB), alors AB=(xB−xA ; yB−yA). Deux vecteurs sont égaux lorsqu’ils ont les mêmes coordonnées. La relation de Chasles permet d’écrire AB+BC=AC.''',
      renforcement: r'''Pour travailler avec des vecteurs, commence par identifier l’origine et l’extrémité. Calcule les coordonnées par différence. Pour une égalité de vecteurs, compare les deux composantes.''',
      enonce1: r'''Dans un repère, A(2;−1) et B(7;3). Détermine les coordonnées de AB.''', solution1: r'''AB=(7−2 ; 3−(−1))=(5;4).''',
      enonce2: r'''On donne A(−2;3), B(4;1) et C(5;6). Calcule AB puis AC et vérifie que AB+BC=AC.''', solution2: r'''AB=(6;−2), AC=(7;3), BC=(1;5), donc AB+BC=(7;3)=AC.''',
      motsCles: 'vecteur • coordonnées • direction • sens • Chasles', quiz1: 'Si A(1;2) et B(5;7), quelles sont les coordonnées de AB ?', quizBonne: '(4;5)',
    ),

    '2nde_C_math_ch02': _math2ndeCChapitre(
      code: 'ch02', titre: 'Ensemble des nombres réels',
      cours: r'''ℝ contient les nombres rationnels et les nombres irrationnels. Les intervalles permettent de décrire des ensembles de réels. La valeur absolue |x| représente la distance de x à zéro. Les racines carrées réelles sont définies pour les nombres positifs ou nuls.''',
      renforcement: r'''Pour comparer des réels, place-les sur une droite graduée. Pour une racine carrée, vérifie d’abord que le radicande est positif ou nul. Pour une valeur absolue, pense à une distance.''',
      enonce1: r'''Classe −√2, −1, 0 et 3/2 dans l’ordre croissant.''', solution1: r'''−√2≈−1,414, donc −√2<−1<0<3/2.''',
      enonce2: r'''Résous |x−2|≤3 et donne la réponse sous forme d’intervalle.''', solution2: r'''−3≤x−2≤3, donc −1≤x≤5. Solution : [−1;5].''',
      motsCles: 'réel • rationnel • irrationnel • intervalle • valeur absolue • racine', quiz1: 'Lequel appartient à ℝ ?', quizBonne: '√2',
    ),

    '2nde_C_math_ch03': _math2ndeCChapitre(
      code: 'ch03', titre: 'Utilisation des symétries et translations',
      cours: r'''Une symétrie axiale conserve les distances et les angles et utilise un axe. Une symétrie centrale utilise un centre qui est le milieu de chaque segment reliant un point à son image. Une translation déplace tous les points d’un même vecteur.''',
      renforcement: r'''Pour une symétrie centrale, cherche le milieu du point et de son image. Pour une translation, le vecteur de déplacement est identique pour tous les points. Ces transformations conservent la forme et les longueurs.''',
      enonce1: r'''Une symétrie centrale de centre O envoie A sur A'. Que représente O pour [AA'] ?''', solution1: r'''O est le milieu de [AA'].''',
      enonce2: r'''Une translation de vecteur u envoie A sur A' et B sur B'. Que peut-on dire de AA' et BB' ?''', solution2: r'''AA’=BB’=u : les deux segments ont même direction, même sens et même longueur.''',
      motsCles: 'symétrie axiale • symétrie centrale • translation • image • vecteur', quiz1: 'Dans une symétrie centrale, le centre est quoi par rapport à un point et son image ?', quizBonne: 'Le milieu du segment',
    ),

    '2nde_C_math_ch04': _math2ndeCChapitre(
      code: 'ch04', titre: 'Généralités sur les fonctions',
      cours: r'''Une fonction associe à un nombre x de son domaine une unique image f(x). Un antécédent de y est un nombre x tel que f(x)=y. Une fonction peut être donnée par une expression, un tableau ou une courbe. Les variations indiquent où elle augmente ou diminue.''',
      renforcement: r'''Dans f(3)=7, 3 est l’antécédent et 7 l’image. Pour résoudre f(x)=k graphiquement, cherche les abscisses des points de la courbe d’ordonnée k.''',
      enonce1: r'''On donne f(x)=3x−2. Calcule f(4) et l’antécédent de 10.''', solution1: r'''f(4)=12−2=10. Pour f(x)=10 : 3x−2=10, donc x=4.''',
      enonce2: r'''Une courbe passe par A(−2;5) et B(3;−1). Donne une image et un antécédent lisibles dans ces données.''', solution2: r'''5 est l’image de −2 et −2 est un antécédent de 5. −1 est l’image de 3 et 3 est un antécédent de −1.''',
      motsCles: 'fonction • image • antécédent • domaine • courbe • variations', quiz1: 'Dans f(2)=9, quelle est l’image de 2 ?', quizBonne: '9',
    ),

    '2nde_C_math_ch05': _math2ndeCChapitre(
      code: 'ch05', titre: 'Droites et plans de l’espace',
      cours: r'''Dans l’espace, deux droites peuvent être sécantes, parallèles ou non coplanaires. Une droite et un plan peuvent être sécants, parallèles ou une droite peut être contenue dans le plan. Deux plans peuvent être sécants ou parallèles. Les positions relatives se démontrent à partir de propriétés géométriques.''',
      renforcement: r'''Pour analyser une figure de l’espace, repère d’abord les éléments qui appartiennent au même plan. Deux droites non coplanaires ne peuvent ni être sécantes ni parallèles.''',
      enonce1: r'''Deux droites distinctes d’un même plan ne se coupent pas. Quelle relation peut-on conclure ?''', solution1: r'''Elles sont parallèles.''',
      enonce2: r'''Une droite d est contenue dans un plan P. Une droite e est parallèle à d mais n’est pas contenue dans P. Que peut-on dire de e et P ?''', solution2: r'''e est parallèle au plan P.''',
      motsCles: 'espace • droite • plan • sécantes • parallèles • coplanaires', quiz1: 'Deux droites non coplanaires sont-elles nécessairement sécantes ?', quizBonne: 'Non',
    ),

    '2nde_C_math_ch06': _math2ndeCChapitre(
      code: 'ch06', titre: 'Fonctions polynômes et fractions rationnelles',
      cours: r'''Une fonction polynôme est une somme de puissances entières positives ou nulles de x. Une fonction fraction rationnelle est un quotient de deux polynômes, défini lorsque le dénominateur est non nul. On étudie notamment le domaine, les zéros et le signe.''',
      renforcement: r'''Avant toute étude d’une fraction rationnelle, détermine les valeurs interdites. Pour factoriser un polynôme, cherche un facteur commun ou une identité remarquable. Le signe d’un quotient dépend des signes du numérateur et du dénominateur.''',
      enonce1: r'''Détermine l’ensemble de définition de f(x)=(2x+1)/(x−3).''', solution1: r'''Le dénominateur ne doit pas être nul : x≠3. Donc Df=ℝ\\{3}.''',
      enonce2: r'''Factorise x²−5x+6 puis détermine ses zéros.''', solution2: r'''x²−5x+6=(x−2)(x−3). Les zéros sont 2 et 3.''',
      motsCles: 'polynôme • fraction rationnelle • domaine • valeur interdite • zéro • signe', quiz1: 'Quelle valeur est interdite pour 1/(x−4) ?', quizBonne: '4',
    ),

    '2nde_C_math_ch07': _math2ndeCChapitre(
      code: 'ch07', titre: 'Angles inscrits',
      cours: r'''Un angle inscrit a son sommet sur un cercle et intercepte un arc. La mesure d’un angle inscrit est la moitié de la mesure de l’angle au centre qui intercepte le même arc. Deux angles inscrits qui interceptent le même arc ont la même mesure.''',
      renforcement: r'''Identifie toujours l’arc intercepté avant de calculer. Si un angle au centre mesure 100° sur le même arc, l’angle inscrit correspondant mesure 50°.''',
      enonce1: r'''Dans un cercle, un angle au centre mesure 120°. Calcule l’angle inscrit qui intercepte le même arc.''', solution1: r'''L’angle inscrit mesure 120°/2=60°.''',
      enonce2: r'''Deux angles inscrits interceptent le même arc. Le premier mesure 37°. Quelle est la mesure du second ?''', solution2: r'''37°, car deux angles inscrits interceptant le même arc sont égaux.''',
      motsCles: 'cercle • angle inscrit • angle au centre • arc', quiz1: 'Un angle inscrit qui intercepte le même arc qu’un angle au centre de 80° mesure combien ?', quizBonne: '40°',
    ),

    '2nde_C_math_ch08': _math2ndeCChapitre(
      code: 'ch08', titre: 'Angles orientés et trigonométrie',
      cours: r'''Un angle orienté tient compte du sens de rotation. En trigonométrie, dans un triangle rectangle, cosinus = adjacent/hypoténuse, sinus = opposé/hypoténuse et tangente = opposé/adjacent. Les angles remarquables et le cercle trigonométrique permettent d’étendre ces notions.''',
      renforcement: r'''Choisis le rapport trigonométrique correspondant aux côtés connus. Vérifie toujours quel côté est opposé, adjacent ou hypoténuse par rapport à l’angle étudié.''',
      enonce1: r'''Dans un triangle rectangle, l’hypoténuse mesure 10 cm et le côté opposé à A mesure 6 cm. Calcule sin(A).''', solution1: r'''sin(A)=6/10=0,6.''',
      enonce2: r'''Si cos(A)=√3/2 et A est aigu, donne la mesure de A.''', solution2: r'''A=30°.''',
      motsCles: 'angle orienté • sinus • cosinus • tangente • cercle trigonométrique', quiz1: 'Dans un triangle rectangle, quel rapport vaut opposé/hypoténuse ?', quizBonne: 'Le sinus',
    ),

    '2nde_C_math_ch09': _math2ndeCChapitre(
      code: 'ch09', titre: 'Statistique à une variable',
      cours: r'''Une série statistique à une variable décrit un caractère étudié sur une population. On utilise effectifs, fréquences, moyenne, médiane, quartiles et étendue. La moyenne pondérée vaut somme(valeur×effectif)/effectif total.''',
      renforcement: r'''Ordonne les données avant de chercher médiane et quartiles. Vérifie que la somme des fréquences vaut 1 ou 100 %. L’étendue est la différence entre la plus grande et la plus petite valeur.''',
      enonce1: r'''Pour 4, 6, 7, 9, 14, calcule la moyenne et la médiane.''', solution1: r'''Moyenne=40/5=8. Médiane=7.''',
      enonce2: r'''Pour 2, 4, 4, 5, 8, 10, 12, 15, calcule la médiane et l’étendue.''', solution2: r'''Médiane=(5+8)/2=6,5. Étendue=15−2=13.''',
      motsCles: 'population • caractère • effectif • fréquence • moyenne • médiane • quartile • étendue', quiz1: 'Dans une série ordonnée de 7 valeurs, quelle position occupe la médiane ?', quizBonne: 'La 4e valeur',
    ),

    '2nde_C_math_ch10': _math2ndeCChapitre(
      code: 'ch10', titre: 'Produit scalaire',
      cours: r'''Le produit scalaire de deux vecteurs peut se définir par u·v=||u|| ||v|| cos(θ). Dans un repère orthonormé, si u=(x;y) et v=(x';y'), alors u·v=xx'+yy'. Deux vecteurs non nuls sont orthogonaux si leur produit scalaire est nul.''',
      renforcement: r'''Choisis la formule selon les données disponibles. En repère, multiplie les coordonnées correspondantes puis additionne. Pour une orthogonalité, cherche immédiatement si le produit scalaire vaut zéro.''',
      enonce1: r'''Calcule le produit scalaire de u=(2;−3) et v=(4;1).''', solution1: r'''u·v=2×4+(−3)×1=8−3=5.''',
      enonce2: r'''Les vecteurs u=(2;1) et v=(−1;2) sont-ils orthogonaux ?''', solution2: r'''u·v=2×(−1)+1×2=0. Oui, ils sont orthogonaux.''',
      motsCles: 'produit scalaire • orthogonalité • coordonnées • norme • angle', quiz1: 'Si u·v=0 pour deux vecteurs non nuls, que peut-on conclure ?', quizBonne: 'Ils sont orthogonaux',
    ),

    '2nde_C_math_ch11': _math2ndeCChapitre(
      code: 'ch11', titre: 'Équations et inéquations dans ℝ',
      cours: r'''Une équation cherche les valeurs qui rendent une égalité vraie. Une inéquation décrit un ensemble de réels vérifiant une relation d’ordre. Lorsqu’on multiplie ou divise une inéquation par un nombre négatif, le sens du signe s’inverse. Pour un produit nul, AB=0 équivaut à A=0 ou B=0.''',
      renforcement: r'''Écris les étapes de façon réversible. Pour les inéquations, surveille le signe du coefficient de x. Pour un produit ou quotient, construis un tableau de signes si nécessaire.''',
      enonce1: r'''Résous 5x−8=2x+7.''', solution1: r'''3x=15, donc x=5.''',
      enonce2: r'''Résous (x−2)(x+4)≤0.''', solution2: r'''Les racines sont −4 et 2. Le produit est négatif ou nul entre les racines : x∈[−4;2].''',
      motsCles: 'équation • inéquation • produit nul • tableau de signes • intervalle', quiz1: 'Que devient le signe d’une inéquation si on multiplie par −2 ?', quizBonne: 'Il s’inverse',
    ),

    '2nde_C_math_ch12': _math2ndeCChapitre(
      code: 'ch12', titre: 'Homothéties',
      cours: r'''Une homothétie de centre O et de rapport k transforme un point M en M' tel que OM’=k·OM. Elle conserve les alignements et transforme les longueurs dans le rapport |k|. Si k>0, M et M' sont du même côté de O ; si k<0, ils sont de côtés opposés.''',
      renforcement: r'''Pour utiliser une homothétie, identifie le centre et le rapport. Les longueurs correspondantes sont multipliées par |k|. Les aires sont multipliées par k².''',
      enonce1: r'''Une homothétie de rapport 3 transforme une longueur de 4 cm. Quelle est la longueur image ?''', solution1: r'''4×|3|=12 cm.''',
      enonce2: r'''Une homothétie de centre O et de rapport −2 envoie A sur A'. Que peut-on dire de la position de A' par rapport à O et A ?''', solution2: r'''A' est sur la demi-droite opposée à OA et OA’=2×OA.''',
      motsCles: 'homothétie • centre • rapport • image • longueur • aire', quiz1: 'Par une homothétie de rapport 2, une longueur est multipliée par combien ?', quizBonne: '2',
    ),

    '2nde_C_math_ch13': _math2ndeCChapitre(
      code: 'ch13', titre: 'Étude de fonctions élémentaires',
      cours: r'''Les fonctions usuelles de seconde C comprennent notamment les fonctions affine, carré, inverse et racine carrée. Pour chacune, on étudie domaine, signe, variations et représentation graphique. La fonction inverse est définie sur ℝ\\{0} et la fonction racine carrée sur [0;+∞[.''',
      renforcement: r'''Pour étudier une fonction, commence par son domaine. Cherche ensuite zéros, signe et variations. Compare la forme de l’expression avec les fonctions usuelles pour choisir les propriétés adaptées.''',
      enonce1: r'''Donne le domaine de définition de f(x)=√(x−2).''', solution1: r'''Il faut x−2≥0, donc Df=[2;+∞[.''',
      enonce2: r'''Étudie le signe de g(x)=1/(x−3).''', solution2: r'''g(x)<0 pour x<3 et g(x)>0 pour x>3 ; x=3 est interdit.''',
      motsCles: 'fonction affine • carré • inverse • racine • domaine • variations', quiz1: 'Quel est le domaine de définition de √x ?', quizBonne: '[0;+∞[',
    ),

    '2nde_C_math_ch14': _math2ndeCChapitre(
      code: 'ch14', titre: 'Rotations',
      cours: r'''Une rotation de centre O et d’angle θ conserve les distances, les angles et les aires. Elle fait tourner chaque point autour de O du même angle orienté et dans le même sens. Une rotation de 180° correspond à une symétrie centrale.''',
      renforcement: r'''Pour construire une image par rotation, conserve la distance au centre puis reporte l’angle orienté. Identifie le centre, l’angle et le sens avant de commencer.''',
      enonce1: r'''Une rotation de centre O et d’angle 90° envoie A sur A'. Quelle relation entre OA et OA' ?''', solution1: r'''OA=OA' et l’angle orienté (OA,OA') mesure 90°.''',
      enonce2: r'''Quelle transformation obtient-on avec une rotation de centre O et d’angle 180° ?''', solution2: r'''Une symétrie centrale de centre O.''',
      motsCles: 'rotation • centre • angle orienté • conservation • symétrie centrale', quiz1: 'Quelle grandeur est conservée par une rotation ?', quizBonne: 'La distance',
    ),

    '2nde_C_math_ch15': _math2ndeCChapitre(
      code: 'ch15', titre: 'Inéquations dans ℝ × ℝ',
      cours: r'''Une inéquation linéaire à deux inconnues décrit un demi-plan du plan. Une expression ax+by+c=0 représente une droite frontière. L’inéquation indique le demi-plan situé d’un côté de cette droite ; la frontière est incluse pour ≤ ou ≥.''',
      renforcement: r'''Pour résoudre graphiquement, trace d’abord la droite frontière. Choisis ensuite un point test qui n’est pas sur la droite pour déterminer le bon demi-plan. Avec ≤ ou ≥, la frontière appartient à l’ensemble solution.''',
      enonce1: r'''Décris graphiquement l’ensemble solution de x+y≤4.''', solution1: r'''C’est le demi-plan situé sous la droite x+y=4, frontière comprise.''',
      enonce2: r'''Le point A(1;2) appartient-il à l’ensemble x−2y≥−3 ?''', solution2: r'''1−4=−3, donc oui, A appartient à l’ensemble solution.''',
      motsCles: 'inéquation • deux inconnues • droite frontière • demi-plan • point test', quiz1: 'Pour une inéquation ≤, la droite frontière est-elle incluse ?', quizBonne: 'Oui',
    ),


    '2nde_A_math_ch01': _math2ndeAChapitre(
      code: 'ch01', titre: 'Calcul numérique',
      cours: r'''En seconde, on consolide les ensembles de nombres et les techniques de calcul. Les priorités opératoires sont : parenthèses, puissances, multiplications et divisions, puis additions et soustractions. Les fractions se simplifient en divisant numérateur et dénominateur par un même nombre non nul. Pour les puissances, a^m × a^n = a^(m+n) et (a^m)^n = a^(mn).''',
      renforcement: r'''Pour calculer proprement, repère d’abord les parenthèses et les puissances. Garde une écriture exacte avec les fractions aussi longtemps que possible. Dans un quotient, vérifie que le dénominateur n’est pas nul. Une racine carrée réelle n’est définie que pour un nombre positif ou nul.''',
      enonce1: r'''Calcule A = 3 - 2(5 - 8) + 4².''', solution1: r'''5 - 8 = -3 ; 2(-3) = -6 ; 4² = 16. Donc A = 3 - (-6) + 16 = 25.''',
      enonce2: r'''Simplifie B = 3/4 + 5/6 sous forme irréductible.''', solution2: r'''PPCM(4,6)=12. B = 9/12 + 10/12 = 19/12. La fraction est irréductible.''',
      motsCles: 'ensembles de nombres • priorités • puissances • fractions • racines',
      quiz1: 'Quelle règle respecte les priorités opératoires ?', quizBonne: 'Effectuer les puissances avant les multiplications et les additions',
    ),
    '2nde_A_math_ch02': _math2ndeAChapitre(
      code: 'ch02', titre: 'Dénombrement',
      cours: r'''Le dénombrement consiste à compter des possibilités sans les énumérer une à une. Lorsque deux choix successifs offrent respectivement m et n possibilités, le principe multiplicatif donne m×n possibilités. Un arbre ou un tableau aide à organiser les choix et à éviter les oublis.''',
      renforcement: r'''Demande-toi combien de choix sont disponibles à chaque étape. Pour des choix successifs, multiplie les nombres de possibilités. Fais attention à savoir si les répétitions sont autorisées ou non : cela change le calcul.''',
      enonce1: r'''Une tenue comprend 4 chemises et 3 pantalons. Combien de tenues différentes peut-on former ?''', solution1: r'''4×3 = 12 tenues.''',
      enonce2: r'''Un code est formé de 2 lettres parmi A, B, C puis de 2 chiffres parmi 1, 2, 3. Les répétitions sont autorisées. Combien de codes ?''', solution2: r'''3×3×3×3 = 81 codes.''',
      motsCles: 'dénombrement • choix • arbre • tableau • principe multiplicatif',
      quiz1: 'Une première étape offre 5 choix et une seconde 4 choix pour chacun. Combien de possibilités ?', quizBonne: '20 possibilités',
    ),
    '2nde_A_math_ch03': _math2ndeAChapitre(
      code: 'ch03', titre: 'Calcul littéral',
      cours: r'''Le calcul littéral utilise des lettres pour représenter des nombres. On développe avec la distributivité : a(b+c)=ab+ac. On factorise en mettant un facteur commun en évidence. Les identités remarquables sont (a+b)²=a²+2ab+b², (a-b)²=a²-2ab+b² et (a-b)(a+b)=a²-b². Réduire une expression consiste à regrouper les termes de même nature.''',
      renforcement: r'''Après un développement, regroupe les termes semblables. Pour factoriser, cherche d’abord un facteur commun, puis une identité remarquable. Une vérification numérique avec une valeur simple de x permet souvent de détecter une erreur de signe.''',
      enonce1: r'''Développe et réduis E = 3(2x - 5) + 4x.''', solution1: r'''E = 6x - 15 + 4x = 10x - 15.''',
      enonce2: r'''Factorise F = x² - 10x + 25.''', solution2: r'''F = x² - 2×5×x + 5² = (x - 5)².''',
      motsCles: 'expression • développer • réduire • factoriser • identité remarquable',
      quiz1: 'Quelle identité correspond à (a-b)² ?', quizBonne: 'a² - 2ab + b²',
    ),
    '2nde_A_math_ch04': _math2ndeAChapitre(
      code: 'ch04', titre: 'Équations et inéquations dans ℝ',
      cours: r'''Une équation est une égalité contenant une inconnue. Résoudre une équation revient à trouver les valeurs qui rendent l’égalité vraie. Pour une inéquation, l’addition ou la soustraction conserve le sens ; une multiplication ou division par un nombre négatif inverse le sens. Pour AB=0, on utilise la propriété du produit nul : A=0 ou B=0.''',
      renforcement: r'''Effectue la même opération aux deux membres d’une équation. Pour une inéquation, surveille le signe du diviseur. Dans une équation-produit, utilise directement le produit nul. Termine par une vérification et écris clairement l’ensemble solution.''',
      enonce1: r'''Résous 4x - 7 = 2x + 9.''', solution1: r'''2x = 16, donc x = 8.''',
      enonce2: r'''Résous (x - 3)(2x + 5) = 0 puis -3x + 6 > 0.''', solution2: r'''x=3 ou x=-5/2. Puis -3x>-6, donc x<2. Solution de la seconde inéquation : ]-∞;2[.''',
      motsCles: 'équation • inéquation • produit nul • ensemble solution • signe',
      quiz1: 'Que se passe-t-il lorsqu’on divise une inéquation par un nombre négatif ?', quizBonne: 'Le sens de l’inégalité s’inverse',
    ),
    '2nde_A_math_ch05': _math2ndeAChapitre(
      code: 'ch05', titre: 'Généralités sur les fonctions',
      cours: r'''Une fonction associe à chaque nombre x de son ensemble de définition au plus un nombre f(x). x est un antécédent et f(x) est son image. Une fonction peut être représentée par une formule, un tableau de valeurs ou une courbe. Résoudre f(x)=k revient à chercher les antécédents de k. Les variations indiquent les intervalles où la fonction augmente ou diminue.''',
      renforcement: r'''Dans f(3)=7, 3 est l’antécédent et 7 est l’image. Sur une courbe, une image se lit avec une verticale et un antécédent avec une horizontale. Pour résoudre f(x)=0, cherche les abscisses des points où la courbe rencontre l’axe des abscisses.''',
      enonce1: r'''On donne f(x)=2x-1. Calcule f(4) et détermine l’antécédent de 9.''', solution1: r'''f(4)=7. Pour l’antécédent de 9 : 2x-1=9, donc x=5.''',
      enonce2: r'''Une fonction vérifie f(-2)=5 et f(3)=-1. Que représentent -2 et 5 ? Que représente 3 par rapport à -1 ?''', solution2: r'''-2 est un antécédent de 5 et 5 est l’image de -2. 3 est un antécédent de -1.''',
      motsCles: 'fonction • image • antécédent • courbe • variation • domaine',
      quiz1: 'Dans f(2)=7, quelle est l’image de 2 ?', quizBonne: '7',
    ),
    '2nde_A_math_ch06': _math2ndeAChapitre(
      code: 'ch06', titre: 'Étude de fonctions élémentaires',
      cours: r'''La fonction affine s’écrit f(x)=ax+b et sa représentation est une droite. La fonction linéaire est f(x)=ax. La fonction carré est f(x)=x² ; elle est décroissante sur ]-∞;0] et croissante sur [0;+∞[. La fonction inverse f(x)=1/x est définie pour x≠0 et sa courbe est une hyperbole.''',
      renforcement: r'''Pour reconnaître une affine, cherche la forme ax+b. Pour la fonction carré, retiens x²≥0 et ses variations. Pour l’inverse, 0 est interdit et le signe de 1/x dépend du signe de x. Les tableaux de valeurs permettent de construire et contrôler une représentation.''',
      enonce1: r'''Soit f(x)=-2x+6. Donne son coefficient directeur, son ordonnée à l’origine et calcule f(4).''', solution1: r'''a=-2, b=6 et f(4)=-8+6=-2.''',
      enonce2: r'''Étudie le signe de g(x)=x²-9 et résous g(x)≥0.''', solution2: r'''g(x)=(x-3)(x+3). Donc g(x)≥0 pour x≤-3 ou x≥3.''',
      motsCles: 'affine • linéaire • carré • inverse • coefficient directeur • variations',
      quiz1: 'Quelle est la forme d’une fonction affine ?', quizBonne: 'f(x)=ax+b',
    ),
    '2nde_A_math_ch07': _math2ndeAChapitre(
      code: 'ch07', titre: 'Statistique',
      cours: r'''Une série statistique décrit un caractère observé sur une population. L’effectif est le nombre d’observations et la fréquence est l’effectif divisé par l’effectif total. La moyenne pondérée est la somme des produits valeur×effectif divisée par l’effectif total. La médiane partage la série ordonnée en deux groupes de même effectif. Les quartiles décrivent la dispersion de la série.''',
      renforcement: r'''Ordonne les valeurs avant de déterminer médiane et quartiles. Vérifie la somme des effectifs. Une moyenne peut être influencée par des valeurs extrêmes, alors que la médiane est basée sur la position centrale.''',
      enonce1: r'''Les notes 8, 10, 10, 12 et 15 sont obtenues par cinq élèves. Calcule la moyenne et la médiane.''', solution1: r'''Moyenne = 55/5 = 11. La médiane est la troisième valeur : 10.''',
      enonce2: r'''Pour la série 5, 7, 7, 8, 9, 12, 15, 15, détermine la médiane et l’étendue.''', solution2: r'''Il y a 8 valeurs : médiane=(8+9)/2=8,5. Étendue=15-5=10.''',
      motsCles: 'population • caractère • effectif • fréquence • moyenne • médiane • quartiles',
      quiz1: 'Que représente la médiane d’une série ordonnée ?', quizBonne: 'Une valeur qui partage la série en deux groupes de même effectif',
    ),
    '2nde_A_math_ch08': _math2ndeAChapitre(
      code: 'ch08', titre: 'Systèmes d’équations linéaires dans ℝ × ℝ',
      cours: r'''Un système de deux équations linéaires à deux inconnues s’écrit ax+by=c et a’x+b’y=c'. Sa solution est un couple (x;y) qui vérifie simultanément les deux équations. On peut utiliser la substitution, la combinaison linéaire ou la résolution graphique. Graphiquement, les équations représentent des droites et une solution unique correspond à leur point d’intersection.''',
      renforcement: r'''Avec la substitution, isole une inconnue puis remplace dans l’autre équation. Avec la combinaison, fais disparaître une inconnue en additionnant ou soustrayant des équations convenablement multipliées. Vérifie toujours le couple obtenu dans les deux équations.''',
      enonce1: r'''Résous le système x+y=7 et 2x-y=5.''', solution1: r'''En additionnant : 3x=12, donc x=4. Puis y=3. Solution : (4;3).''',
      enonce2: r'''Un cahier coûte x francs et un stylo y francs. 3 cahiers et 2 stylos coûtent 2 100 F ; 2 cahiers et 3 stylos coûtent 1 900 F. Détermine x et y.''', solution2: r'''3x+2y=2100 et 2x+3y=1900. Par combinaison, 5x=2500, donc x=500. Puis y=300. Le cahier coûte 500 F et le stylo 300 F.''',
      motsCles: 'système • inconnues • substitution • combinaison • droite • intersection',
      quiz1: 'Que représente graphiquement la solution d’un système de deux droites sécantes ?', quizBonne: 'Le point d’intersection des deux droites',
    ),


    '4e_math_ch01': _math4eChapitre(
      code: 'ch01',
      titre: 'Nombres décimaux relatifs',
      cours: r'''Les nombres décimaux relatifs sont des nombres positifs, négatifs ou nuls. On les compare sur une droite graduée : celui qui est le plus à droite est le plus grand. Pour calculer avec eux, on applique les règles des signes et les propriétés des opérations.''',
      renforcement: r'''Pour une somme de relatifs, deux nombres de même signe donnent une somme de même signe ; des signes différents conduisent à une différence des distances à zéro. Pour un produit ou quotient, même signe donne positif et signes différents donnent négatif.''',
      enonce1: r'''Calcule -7,5 + 3,2.''', solution1: r'''-4,3.''',
      enonce2: r'''Calcule (-4) × (-2,5) - 3.''', solution2: r'''10 - 3 = 7.''',
      motsCles: 'relatif • opposé • distance à zéro • règles de signes',
    ),

    '4e_math_ch02': _math4eChapitre(
      code: 'ch02',
      titre: 'Angles',
      cours: r'''Les angles peuvent être complémentaires, supplémentaires, opposés par le sommet ou adjacents. Dans un triangle, la somme des angles est 180°. Les angles formés par deux droites parallèles et une sécante présentent aussi des relations utiles.''',
      renforcement: r'''Avant de calculer, identifie la relation géométrique : angles opposés par le sommet égaux, angles complémentaires de somme 90°, supplémentaires de somme 180°. Avec des parallèles, utilise les angles correspondants ou alternes-internes.''',
      enonce1: r'''Un angle mesure 128°. Quel est son supplémentaire ?''', solution1: r'''52°.''',
      enonce2: r'''Deux angles opposés par le sommet : l’un mesure 67°. Combien mesure l’autre ?''', solution2: r'''67°, car les angles opposés par le sommet sont égaux.''',
      motsCles: 'angle • complémentaire • supplémentaire • parallèle • sécante',
    ),

    '4e_math_ch03': _math4eChapitre(
      code: 'ch03',
      titre: 'Nombres rationnels',
      cours: r'''Un nombre rationnel est un nombre qui peut s’écrire a/b avec a et b entiers et b non nul. Les fractions, les décimaux finis et leurs opposés appartiennent à l’ensemble des rationnels ℚ.''',
      renforcement: r'''Pour comparer ou calculer avec des rationnels, on peut utiliser des fractions équivalentes et un dénominateur commun. Pour une division par un rationnel non nul, on multiplie par son inverse.''',
      enonce1: r'''Compare -3/4 et -2/3.''', solution1: r'''-3/4 = -9/12 et -2/3 = -8/12, donc -3/4 < -2/3.''',
      enonce2: r'''Calcule 5/6 - 3/4.''', solution2: r'''10/12 - 9/12 = 1/12.''',
      motsCles: 'rationnel • fraction • ℚ • inverse • dénominateur commun',
    ),

    '4e_math_ch04': _math4eChapitre(
      code: 'ch04',
      titre: 'Distances',
      cours: r'''La distance entre deux points A et B est la longueur du segment [AB]. Sur une droite graduée, elle correspond à la valeur absolue de la différence de leurs coordonnées. Dans un plan, les propriétés de perpendicularité et de médiatrice permettent de raisonner sur les distances.''',
      renforcement: r'''La médiatrice d’un segment est la droite perpendiculaire au segment passant par son milieu. Tout point de la médiatrice est équidistant des extrémités du segment. Pour construire une médiatrice, on peut utiliser règle et compas.''',
      enonce1: r'''A(-2) et B(7) sur une droite graduée. Calcule AB.''', solution1: r'''AB = |7 - (-2)| = 9.''',
      enonce2: r'''M appartient à la médiatrice de [AB] et MA = 6 cm. Quelle est la longueur MB ?''', solution2: r'''MB = 6 cm.''',
      motsCles: 'distance • segment • médiatrice • équidistance',
    ),

    '4e_math_ch05': _math4eChapitre(
      code: 'ch05',
      titre: 'Perspective cavalière',
      cours: r'''La perspective cavalière est une représentation plane d’un solide. Les faces parallèles du solide sont représentées par des figures parallèles ; les arêtes fuyantes sont tracées selon une direction choisie et avec une réduction éventuelle.''',
      renforcement: r'''Pour lire un dessin en perspective, distingue les arêtes visibles, cachées et fuyantes. Les longueurs sur les arêtes fuyantes peuvent être représentées réduites selon le choix de la construction, mais les relations de parallélisme sont conservées.''',
      enonce1: r'''Dans un pavé droit, deux arêtes opposées d’une même face sont-elles parallèles ?''', solution1: r'''Oui, les côtés opposés d’une face rectangulaire sont parallèles.''',
      enonce2: r'''Un solide est représenté avec des arêtes fuyantes dans une même direction. Pourquoi cette convention aide-t-elle à lire le solide ?''', solution2: r'''Elle permet de conserver une représentation cohérente de la profondeur et des faces parallèles.''',
      motsCles: 'perspective • solide • arête • face • fuyante • parallélisme',
    ),

    '4e_math_ch06': _math4eChapitre(
      code: 'ch06',
      titre: 'Calcul littéral',
      cours: r'''Le calcul littéral utilise des lettres pour représenter des nombres. En 4e, on développe, réduit et factorise des expressions, puis on utilise des identités remarquables et des propriétés des puissances.''',
      renforcement: r'''Pour développer, applique la distributivité. Pour factoriser, cherche d’abord un facteur commun puis une identité remarquable. Toujours réduire les termes semblables et respecter les signes.''',
      enonce1: r'''Développe A = 3(x - 4) + 2x.''', solution1: r'''A = 3x - 12 + 2x = 5x - 12.''',
      enonce2: r'''Factorise B = 9x² - 25.''', solution2: r'''B = (3x - 5)(3x + 5).''',
      motsCles: 'développer • réduire • factoriser • identité remarquable',
    ),

    '4e_math_ch07': _math4eChapitre(
      code: 'ch07',
      titre: 'Cercles et triangles',
      cours: r'''Dans un cercle, le rayon relie le centre à un point du cercle et le diamètre vaut deux rayons. Dans un triangle, la somme des angles est 180°. Les propriétés du cercle et des triangles permettent de démontrer des longueurs ou des angles.''',
      renforcement: r'''Le triangle inscrit dans un cercle peut être étudié avec le diamètre et les angles. Le cas du triangle rectangle inscrit dans un cercle de diamètre donné est particulièrement important. Pour chaque figure, identifie d’abord les données et la propriété adaptée.''',
      enonce1: r'''Un cercle a un diamètre de 12 cm. Quel est son rayon ?''', solution1: r'''6 cm.''',
      enonce2: r'''ABC est un triangle dont deux angles mesurent 35° et 80°. Calcule le troisième angle.''', solution2: r'''180° - 35° - 80° = 65°.''',
      motsCles: 'cercle • rayon • diamètre • triangle • angle',
    ),

    '4e_math_ch08': _math4eChapitre(
      code: 'ch08',
      titre: 'Équations et inéquations dans ℚ',
      cours: r'''Une équation est une égalité contenant une inconnue. Résoudre une équation consiste à trouver toutes les valeurs qui rendent l’égalité vraie. Une inéquation utilise les signes <, >, ≤ ou ≥ et décrit un ensemble de solutions.''',
      renforcement: r'''Pour isoler l’inconnue, on effectue la même opération aux deux membres d’une équation. Dans une inéquation, si on multiplie ou divise par un nombre négatif, le sens du signe change.''',
      enonce1: r'''Résous 3x - 5 = 10.''', solution1: r'''3x = 15 donc x = 5.''',
      enonce2: r'''Résous -2x + 4 > 10.''', solution2: r'''-2x > 6 ; en divisant par -2, on inverse le signe : x < -3.''',
      motsCles: 'équation • inconnue • inéquation • solution • intervalle',
    ),

    '4e_math_ch09': _math4eChapitre(
      code: 'ch09',
      titre: 'Vecteurs',
      cours: r'''Un vecteur représente un déplacement caractérisé par une direction, un sens et une longueur. Deux vecteurs sont égaux lorsqu’ils ont même direction, même sens et même longueur. La somme de vecteurs peut se construire avec la relation de Chasles.''',
      renforcement: r'''La relation de Chasles s’écrit AB + BC = AC. Pour additionner des vecteurs, on peut les placer bout à bout. Dans un repère, les coordonnées d’un vecteur se calculent par différence des coordonnées de son extrémité et de son origine.''',
      enonce1: r'''A(1;2) et B(5;7). Donne les coordonnées du vecteur AB.''', solution1: r'''AB = (5-1 ; 7-2) = (4 ; 5).''',
      enonce2: r'''A, B, C sont des points et AB + BC = AC. Si AB = (2; -1) et BC = (3; 4), donne AC.''', solution2: r'''AC = (5 ; 3).''',
      motsCles: 'vecteur • direction • sens • norme • Chasles • coordonnées',
    ),

    '4e_math_ch10': _math4eChapitre(
      code: 'ch10',
      titre: 'Statistique',
      cours: r'''Une série statistique se décrit avec des effectifs et des fréquences. En 4e, on utilise aussi la moyenne pour résumer une série. La moyenne est la somme des valeurs pondérées par leurs effectifs, divisée par l’effectif total.''',
      renforcement: r'''Pour calculer une moyenne avec des effectifs : moyenne = somme(valeur × effectif) / effectif total. Une moyenne ne remplace pas l’analyse de la dispersion ou des valeurs extrêmes, mais elle donne un indicateur central.''',
      enonce1: r'''Les notes 8, 10 et 12 ont chacune le même effectif. Quelle est la moyenne ?''', solution1: r'''(8 + 10 + 12)/3 = 10.''',
      enonce2: r'''Les valeurs 5, 10 et 15 ont les effectifs 2, 3 et 1. Calcule la moyenne.''', solution2: r'''(5×2 + 10×3 + 15×1)/6 = 65/6 ≈ 10,83.''',
      motsCles: 'population • caractère • effectif • fréquence • moyenne',
    ),

    '4e_math_ch11': _math4eChapitre(
      code: 'ch11',
      titre: 'Symétries et translations',
      cours: r'''Une symétrie axiale utilise un axe ; une symétrie centrale utilise un centre ; une translation déplace tous les points selon un même vecteur. Ces transformations conservent les longueurs et les angles, et donc la forme des figures.''',
      renforcement: r'''Pour une symétrie axiale, l’axe est la médiatrice entre un point et son image. Pour une symétrie centrale, le centre est le milieu du segment reliant un point à son image. Pour une translation, chaque point est déplacé du même vecteur.''',
      enonce1: r'''Une symétrie centrale de centre O envoie A sur A'. Que représente O pour [AA'] ?''', solution1: r'''O est le milieu de [AA'].''',
      enonce2: r'''Une translation de vecteur u envoie A sur A'. Que peut-on dire du déplacement de B vers B' ?''', solution2: r'''BB' a le même vecteur que AA' : même direction, même sens et même longueur.''',
      motsCles: 'symétrie axiale • symétrie centrale • translation • vecteur',
    ),


    '5e_math_ch01': _math5eChapitre(
      code: 'ch01',
      titre: 'Nombres premiers',
      cours: r'''Un nombre premier est un entier naturel supérieur à 1 qui possède exactement deux diviseurs positifs : 1 et lui-même. Pour reconnaître un nombre premier, on teste les diviseurs premiers jusqu’à la racine carrée du nombre. La décomposition en facteurs premiers permet ensuite de déterminer PGCD, PPCM et de simplifier certains calculs.''',
      renforcement: r'''Un nombre composé possède au moins un diviseur autre que 1 et lui-même. Pour 84 : 84 = 2 × 42 = 2² × 21 = 2² × 3 × 7. La décomposition doit être complète et chaque facteur doit être premier.''',
      enonce1: r'''91 est-il premier ?''', solution1: r'''Non, car 91 = 7 × 13.''',
      enonce2: r'''Décompose 180 en facteurs premiers.''', solution2: r'''180 = 2² × 3² × 5.''',
      motsCles: 'diviseur • nombre premier • composé • décomposition',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch02': _math5eChapitre(
      code: 'ch02',
      titre: 'Segments',
      cours: r'''Un segment [AB] est la portion de droite comprise entre A et B. Sa longueur se note AB. Le milieu M de [AB] vérifie AM = MB et AB = AM + MB. Pour calculer une longueur manquante, on utilise ces relations et on respecte les unités.''',
      renforcement: r'''Sur une droite graduée, la distance entre deux points correspond à la valeur absolue de la différence de leurs abscisses. Pour construire le milieu d’un segment, on peut utiliser la règle et le compas ou calculer sa position sur une droite graduée.''',
      enonce1: r'''AB = 12 cm et M est le milieu de [AB]. Calcule AM.''', solution1: r'''AM = 6 cm.''',
      enonce2: r'''Sur une droite graduée, A a pour abscisse -3 et B a pour abscisse 5. Calcule AB.''', solution2: r'''AB = |5 - (-3)| = 8 unités.''',
      motsCles: 'segment • longueur • milieu • distance',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch03': _math5eChapitre(
      code: 'ch03',
      titre: 'Angles',
      cours: r'''Un angle est formé par deux demi-droites de même origine. On distingue notamment l’angle aigu, droit, obtus, plat et rentrant. Deux angles complémentaires ont une somme de 90° et deux angles supplémentaires une somme de 180°. Le rapporteur sert à mesurer et construire un angle.''',
      renforcement: r'''Pour raisonner, commence par identifier la nature de l’angle et les relations données. Dans un triangle, la somme des angles vaut 180°. Deux angles adjacents peuvent aussi être complémentaires ou supplémentaires selon la situation.''',
      enonce1: r'''Un angle mesure 37°. Quelle est la mesure de son complémentaire ?''', solution1: r'''90° - 37° = 53°.''',
      enonce2: r'''Deux angles supplémentaires mesurent 68° et x. Détermine x.''', solution2: r'''x = 180° - 68° = 112°.''',
      motsCles: 'sommet • côtés • aigu • droit • obtus • complémentaire',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch04': _math5eChapitre(
      code: 'ch04',
      titre: 'Nombres décimaux relatifs',
      cours: r'''Les nombres décimaux relatifs peuvent être positifs, négatifs ou nuls. Sur une droite graduée, le nombre le plus à droite est le plus grand. Pour additionner des relatifs, on tient compte des signes ; pour soustraire un nombre, on ajoute son opposé.''',
      renforcement: r'''Pour additionner deux nombres de même signe, on additionne leurs distances à zéro et on garde le signe. Pour des signes différents, on soustrait les distances à zéro et on garde le signe du nombre de plus grande distance à zéro. La soustraction se transforme en addition de l’opposé.''',
      enonce1: r'''Calcule A = -7,5 + 3,2.''', solution1: r'''A = -4,3.''',
      enonce2: r'''Calcule B = 4,8 - (-2,7).''', solution2: r'''B = 4,8 + 2,7 = 7,5.''',
      motsCles: 'relatif • opposé • valeur absolue • comparaison',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch05': _math5eChapitre(
      code: 'ch05',
      titre: 'Figures symétriques par rapport à une droite',
      cours: r'''La symétrie axiale par rapport à une droite d est une transformation qui associe à un point A un point A' tel que d soit la médiatrice de [AA']. La distance à l’axe est conservée et [AA'] est perpendiculaire à d.''',
      renforcement: r'''Pour construire l’image d’un point, on trace la perpendiculaire à l’axe passant par le point, puis on reporte la même distance de l’autre côté. Une figure et son image ont la même forme et les mêmes longueurs.''',
      enonce1: r'''A est à 3 cm de l’axe d. Quelle est la distance de A' à d ?''', solution1: r'''A' est aussi à 3 cm de d.''',
      enonce2: r'''Que représente l’axe de symétrie pour le segment [AA'] ?''', solution2: r'''L’axe est la médiatrice de [AA'] : il est perpendiculaire au segment et passe par son milieu.''',
      motsCles: 'symétrie axiale • axe • médiatrice • image',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch06': _math5eChapitre(
      code: 'ch06',
      titre: 'Fractions',
      cours: r'''Une fraction représente un quotient et peut exprimer une partie d’un tout. Pour additionner ou soustraire des fractions, on utilise un dénominateur commun. Pour multiplier, on multiplie numérateurs entre eux et dénominateurs entre eux. Pour diviser par une fraction non nulle, on multiplie par son inverse.''',
      renforcement: r'''Pour simplifier une fraction, on divise le numérateur et le dénominateur par un même diviseur non nul. Avant une addition, ne jamais additionner directement les dénominateurs. Exemple : 2/3 + 1/6 = 4/6 + 1/6 = 5/6.''',
      enonce1: r'''Calcule 3/4 + 1/8.''', solution1: r'''3/4 = 6/8, donc 3/4 + 1/8 = 7/8.''',
      enonce2: r'''Calcule 5/6 ÷ 10/9.''', solution2: r'''5/6 × 9/10 = 45/60 = 3/4.''',
      motsCles: 'numérateur • dénominateur • simplifier • inverse',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch07': _math5eChapitre(
      code: 'ch07',
      titre: 'Prismes droits',
      cours: r'''Un prisme droit possède deux bases polygonales parallèles et superposables ; ses faces latérales sont des rectangles. Le volume d’un prisme droit se calcule par V = aire de la base × hauteur.''',
      renforcement: r'''Pour un prisme droit, commence par identifier la base. Pour un pavé droit, V = longueur × largeur × hauteur. Les unités de volume sont cubiques : cm³, dm³, m³.''',
      enonce1: r'''Un prisme a une aire de base de 12 cm² et une hauteur de 8 cm. Calcule son volume.''', solution1: r'''V = 12 × 8 = 96 cm³.''',
      enonce2: r'''Un pavé mesure 5 cm × 4 cm × 3 cm. Calcule son volume.''', solution2: r'''V = 5 × 4 × 3 = 60 cm³.''',
      motsCles: 'prisme droit • base • hauteur • volume',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch08': _math5eChapitre(
      code: 'ch08',
      titre: 'Triangles',
      cours: r'''Un triangle possède trois côtés et trois angles. La somme de ses angles est 180°. Dans un triangle isocèle, les angles à la base sont égaux ; dans un triangle équilatéral, les trois angles mesurent 60°. La construction d’un triangle dépend des longueurs ou angles connus.''',
      renforcement: r'''Pour déterminer un angle inconnu, utilise la somme 180°. Pour reconnaître un triangle isocèle, cherche deux côtés de même longueur ou deux angles de même mesure. Dans un triangle rectangle, un angle mesure 90°.''',
      enonce1: r'''Deux angles d’un triangle mesurent 48° et 67°. Calcule le troisième.''', solution1: r'''180° - 48° - 67° = 65°.''',
      enonce2: r'''Dans un triangle isocèle, l’angle au sommet mesure 40°. Calcule chacun des angles à la base.''', solution2: r'''Les deux angles à la base sont égaux : (180° - 40°)/2 = 70° chacun.''',
      motsCles: 'triangle • isocèle • équilatéral • rectangle • somme des angles',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch09': _math5eChapitre(
      code: 'ch09',
      titre: 'Proportionnalité',
      cours: r'''Deux grandeurs sont proportionnelles lorsqu’on peut passer de l’une à l’autre en multipliant toujours par un même nombre, appelé coefficient de proportionnalité. On peut utiliser un tableau de proportionnalité, le passage à l’unité ou le produit en croix.''',
      renforcement: r'''Pour vérifier une proportionnalité, les rapports correspondants doivent être égaux. Dans un tableau, on peut multiplier ou diviser une ligne par un même nombre. Le pourcentage est une situation fréquente de proportionnalité.''',
      enonce1: r'''4 kg de cacao coûtent 2 400 F. Combien coûtent 7 kg au même tarif ?''', solution1: r'''1 kg coûte 600 F, donc 7 kg coûtent 4 200 F.''',
      enonce2: r'''Un article à 8 000 F augmente de 15 %. Quel est le nouveau prix ?''', solution2: r'''Augmentation = 8 000 × 15/100 = 1 200 F. Nouveau prix = 9 200 F.''',
      motsCles: 'coefficient • tableau • produit en croix • pourcentage',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch10': _math5eChapitre(
      code: 'ch10',
      titre: 'Cercles',
      cours: r'''Un cercle de centre O et de rayon r est l’ensemble des points situés à la distance r de O. Le diamètre d vaut 2r. La longueur du cercle est L = 2πr et son aire est A = πr². On utilise souvent π ≈ 3,14.''',
      renforcement: r'''Pour résoudre un problème, repère le rayon ou le diamètre puis choisis la bonne formule. Si le diamètre est donné, commence par calculer r = d/2. Pense à l’unité : longueur en cm, aire en cm².''',
      enonce1: r'''Un cercle a un rayon de 5 cm. Calcule son diamètre.''', solution1: r'''d = 2 × 5 = 10 cm.''',
      enonce2: r'''Avec r = 5 cm et π ≈ 3,14, calcule l’aire du disque.''', solution2: r'''A = πr² ≈ 3,14 × 25 = 78,5 cm².''',
      motsCles: 'centre • rayon • diamètre • disque • périmètre • aire',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch11': _math5eChapitre(
      code: 'ch11',
      titre: 'Statistique',
      cours: r'''Une série statistique décrit une population à partir d’un caractère. L’effectif est le nombre d’observations d’une valeur et l’effectif total est la somme des effectifs. La fréquence est effectif ÷ effectif total, souvent exprimée en pourcentage.''',
      renforcement: r'''Un tableau d’effectifs permet de lire et organiser les données. La fréquence d’une modalité peut être convertie en pourcentage en multipliant par 100. La somme des fréquences vaut 1, ou 100 %.''',
      enonce1: r'''Dans une classe de 30 élèves, 12 viennent à pied. Quelle est la fréquence en pourcentage ?''', solution1: r'''12/30 = 0,4, soit 40 %.''',
      enonce2: r'''Une série a les effectifs 5, 8, 7 et 10. Calcule l’effectif total puis la fréquence de la deuxième valeur.''', solution2: r'''Effectif total = 30. Fréquence = 8/30 ≈ 26,7 %.''',
      motsCles: 'population • caractère • effectif • fréquence • tableau',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),

    '5e_math_ch12': _math5eChapitre(
      code: 'ch12',
      titre: 'Parallélogrammes particuliers',
      cours: r'''Le rectangle, le losange et le carré sont des parallélogrammes particuliers. Un rectangle possède quatre angles droits ; un losange possède quatre côtés de même longueur ; un carré possède quatre côtés égaux et quatre angles droits.''',
      renforcement: r'''Les diagonales permettent aussi de reconnaître certaines propriétés : celles d’un rectangle sont de même longueur ; celles d’un losange sont perpendiculaires et se coupent en leur milieu ; celles d’un carré cumulent ces propriétés.''',
      enonce1: r'''Un rectangle a une longueur de 8 cm et une largeur de 5 cm. Calcule son périmètre.''', solution1: r'''P = 2(8 + 5) = 26 cm.''',
      enonce2: r'''Un losange a un côté de 6 cm. Calcule son périmètre.''', solution2: r'''P = 4 × 6 = 24 cm.''',
      motsCles: 'rectangle • losange • carré • diagonales • angles droits',
      quiz1: r'''undefined''', quiz1Bonne: r'''undefined''',
    ),


    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 1 : CALCUL LITTERAL
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch01': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Le calcul littéral',
        ordre: 1,
        contenu: r'''
1. POURQUOI CALCULER AVEC DES LETTRES

Une lettre remplace un nombre que l’on ne connaît pas encore, ou qui peut
changer. Écrire une formule avec des lettres permet de la réutiliser autant
de fois qu’on veut, avec n’importe quelle valeur.

Exemple : le périmètre d’un rectangle s’écrit P = 2(L + l).
Cette seule ligne remplace une infinité de calculs.


2. VOCABULAIRE DES POLYNÔMES

Un monôme est un produit d’un nombre et d’une ou plusieurs lettres :
    5x²    -3xy    7

Un polynôme est une somme de monômes :
    3x² - 5x + 2

Chaque monôme s’appelle un terme. Le nombre placé devant la lettre est le
coefficient. Dans 3x², le coefficient est 3 et le degré est 2.

Le degré d’un polynôme est le plus grand degré de ses termes.
    3x² - 5x + 2  est de degré 2.


3. RÉDUIRE UN POLYNÔME

Réduire, c’est regrouper les termes semblables, c’est-à-dire ceux qui ont
exactement la même partie littérale.

    5x + 3x = 8x            (on peut regrouper)
    5x + 3x² : impossible   (x et x² sont différents)

Exemple complet :
    2x² + 5x - 3x² + x - 4
  = (2x² - 3x²) + (5x + x) - 4
  = -x² + 6x - 4


4. DÉVELOPPER

Développer, c’est transformer un produit en somme.

Simple distributivité :
    k(a + b) = ka + kb

Double distributivité :
    (a + b)(c + d) = ac + ad + bc + bd

Exemple :
    (x + 3)(x - 2)
  = x·x - 2x + 3x - 6
  = x² + x - 6

ATTENTION AU SIGNE MOINS DEVANT UNE PARENTHÈSE :
    -(x - 4) = -x + 4
Tous les signes à l’intérieur changent.


5. LES TROIS IDENTITÉS REMARQUABLES

À connaître par cœur. Elles tombent à chaque BEPC.

    (a + b)² = a² + 2ab + b²
    (a - b)² = a² - 2ab + b²
    (a + b)(a - b) = a² - b²

Exemples :
    (x + 5)² = x² + 10x + 25
    (2x - 3)² = 4x² - 12x + 9
    (x + 7)(x - 7) = x² - 49


6. FACTORISER

Factoriser, c’est l’opération inverse : transformer une somme en produit.

Méthode 1 — le facteur commun :
    6x² + 9x = 3x(2x + 3)

Méthode 2 — une identité remarquable lue de droite à gauche :
    x² - 16 = x² - 4² = (x + 4)(x - 4)
    x² + 6x + 9 = (x + 3)²

Méthode 3 — le facteur commun est une parenthèse :
    (x + 1)(x - 2) + (x + 1)(3x) = (x + 1)(x - 2 + 3x) = (x + 1)(4x - 2)


7. LES PUISSANCES D’EXPOSANT ENTIER RELATIF

Pour tout nombre a non nul et tous entiers m et n :

    a⁰ = 1
    a⁻ⁿ = 1 / aⁿ
    aᵐ × aⁿ = aᵐ⁺ⁿ
    aᵐ / aⁿ = aᵐ⁻ⁿ
    (aᵐ)ⁿ = aᵐˣⁿ
    (ab)ⁿ = aⁿ × bⁿ

Exemples :
    2⁻³ = 1/2³ = 1/8
    x⁵ × x⁻² = x³
    (3x²)³ = 27x⁶


8. LES FRACTIONS RATIONNELLES

Une fraction rationnelle est un quotient de deux polynômes.

Condition d’existence : le dénominateur ne doit jamais être nul.
    Pour (x + 1)/(x - 3), il faut x ≠ 3.

Pour simplifier, on factorise le numérateur et le dénominateur, puis on
supprime les facteurs communs :

    (x² - 9)/(x + 3) = (x + 3)(x - 3)/(x + 3) = x - 3    pour x ≠ -3
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Développer et factoriser sans se tromper',
        ordre: 1,
        contenu: r'''
DÉVELOPPER OU FACTORISER : COMMENT SAVOIR ?

Regarde ce que tu as devant toi.
    Des parenthèses multipliées → tu peux DÉVELOPPER
    Une somme de termes         → tu peux FACTORISER

Retiens : développer casse les parenthèses, factoriser en fabrique.


LE PIÈGE DU SIGNE MOINS

C’est l’erreur la plus fréquente au BEPC, et elle coûte cher.

    A = 5x - (2x - 3)

Beaucoup écrivent : 5x - 2x - 3 = 3x - 3. C’est FAUX.

Le moins devant la parenthèse change TOUS les signes à l’intérieur :
    A = 5x - 2x + 3 = 3x + 3

L’astuce : imagine que le moins est un -1 qui multiplie tout.
    -(2x - 3) = -1 × 2x + (-1) × (-3) = -2x + 3


RECONNAÎTRE UNE IDENTITÉ REMARQUABLE

Trois questions dans l’ordre :

1. Y a-t-il DEUX termes séparés par un moins, tous deux des carrés ?
   → c’est a² - b² = (a + b)(a - b)
   Exemple : 25x² - 4 = (5x)² - 2² = (5x + 2)(5x - 2)

2. Y a-t-il TROIS termes, dont le premier et le dernier sont des carrés ?
   → vérifie si le terme du milieu vaut 2ab
   Exemple : x² + 10x + 25 → a = x, b = 5, et 2ab = 10x. Oui !
   Donc x² + 10x + 25 = (x + 5)²

3. Sinon, cherche un facteur commun.


LA MÉTHODE POUR FACTORISER, PAS À PAS

Étape 1 : y a-t-il un facteur commun à tous les termes ?
    6x² + 12x → oui, 6x → 6x(x + 2)

Étape 2 : sinon, est-ce une identité remarquable ?
    x² - 49 → oui → (x + 7)(x - 7)

Étape 3 : sinon, le facteur commun est-il une parenthèse ?
    (x - 1)(x + 4) + (x - 1)(2x) → oui, (x - 1)
    → (x - 1)(x + 4 + 2x) = (x - 1)(3x + 4)

Étape 4 : n’oublie pas de réduire ce qui reste dans la parenthèse.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : (a + b)² = a² + b². FAUX.
Il manque le double produit. (a + b)² = a² + 2ab + b².
Vérifie toi-même avec a = 3 et b = 2 : (3+2)² = 25, mais 9 + 4 = 13.

Erreur 2 : oublier de réduire après avoir développé.
Un développement non réduit vaut rarement tous les points.

Erreur 3 : simplifier une fraction avant de factoriser.
    (x + 3)/(x + 6) ne se simplifie PAS en 3/6.
On ne simplifie que des FACTEURS, jamais des termes d’une somme.

Erreur 4 : oublier la condition d’existence d’une fraction.
Le dénominateur ne doit jamais être nul. Écris-le, cela rapporte des points.


CONSEIL POUR LE BEPC

Vérifie toujours ton résultat en remplaçant x par un nombre simple, par
exemple x = 1 ou x = 2, dans l’expression de départ et dans ton résultat.
Si tu trouves deux valeurs différentes, tu t’es trompé quelque part.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Développer, réduire, factoriser',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
On considère les expressions suivantes :

    A = 3(2x + 5) - 2(x - 4)
    B = (x + 6)(x - 2)
    C = 9x² - 25
    D = x² + 8x + 16

1) Développe et réduis A.
2) Développe et réduis B.
3) Factorise C.
4) Factorise D.
''',
        solution: r'''
1) DÉVELOPPEMENT DE A

    A = 3(2x + 5) - 2(x - 4)

On distribue, en faisant attention au signe moins :

    A = 6x + 15 - 2x + 8

Attention : -2 × (-4) = +8.

On regroupe les termes semblables :

    A = (6x - 2x) + (15 + 8)
    A = 4x + 23


2) DÉVELOPPEMENT DE B

    B = (x + 6)(x - 2)

Double distributivité :

    B = x × x + x × (-2) + 6 × x + 6 × (-2)
    B = x² - 2x + 6x - 12
    B = x² + 4x - 12


3) FACTORISATION DE C

    C = 9x² - 25

On reconnaît une différence de deux carrés :

    9x² = (3x)²   et   25 = 5²

Donc :

    C = (3x)² - 5²
    C = (3x + 5)(3x - 5)


4) FACTORISATION DE D

    D = x² + 8x + 16

Trois termes. Le premier et le dernier sont des carrés :

    x² = x²   et   16 = 4²

On vérifie le double produit : 2 × x × 4 = 8x. C’est bien le terme du
milieu.

Donc :

    D = (x + 4)²


VÉRIFICATION
Prenons x = 1 pour contrôler la question 1 :
Expression de départ : 3(2+5) - 2(1-4) = 3×7 - 2×(-3) = 21 + 6 = 27
Résultat trouvé : 4×1 + 23 = 27. Les deux concordent.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Le carré de Monsieur Bamba',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''
Monsieur Bamba possède un terrain carré de côté x mètres, à Bingerville.

Il décide de l’agrandir : il ajoute 5 m sur la longueur et 5 m sur la
largeur, de façon à obtenir un nouveau carré.

1) Exprime l’aire du terrain de départ en fonction de x.
2) Exprime l’aire du nouveau terrain en fonction de x, sous forme
   développée et réduite.
3) Exprime, en fonction de x, l’aire gagnée par cet agrandissement.
4) Le terrain de départ mesurait 20 m de côté. Calcule l’aire gagnée.
''',
        solution: r'''
1) AIRE DU TERRAIN DE DÉPART

C’est un carré de côté x :

    Aire₁ = x²   (en m²)


2) AIRE DU NOUVEAU TERRAIN

Le nouveau côté mesure x + 5 mètres. C’est encore un carré :

    Aire₂ = (x + 5)²

On développe avec l’identité remarquable (a + b)² = a² + 2ab + b² :

    Aire₂ = x² + 2 × x × 5 + 5²
    Aire₂ = x² + 10x + 25   (en m²)


3) AIRE GAGNÉE

L’aire gagnée est la différence entre le nouveau terrain et l’ancien :

    Gain = Aire₂ - Aire₁
    Gain = (x² + 10x + 25) - x²
    Gain = 10x + 25   (en m²)

On peut aussi la factoriser :

    Gain = 5(2x + 5)


4) APPLICATION NUMÉRIQUE

Pour x = 20 :

    Gain = 10 × 20 + 25
    Gain = 200 + 25
    Gain = 225

CONCLUSION : Monsieur Bamba a gagné 225 m².


VÉRIFICATION
Terrain de départ : 20 × 20 = 400 m²
Nouveau terrain : 25 × 25 = 625 m²
Différence : 625 - 400 = 225 m². Le résultat est confirmé.


CE QU’IL FAUT RETENIR
Le gain n’est PAS égal à 5² = 25 m², comme on pourrait le croire.
Agrandir un carré de 5 m de côté ajoute deux bandes rectangulaires de
10x m² au total, plus un petit carré de 25 m². C’est exactement ce que dit
l’identité remarquable.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Calcul littéral — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
LES TROIS IDENTITÉS REMARQUABLES

    (a + b)² = a² + 2ab + b²
    (a - b)² = a² - 2ab + b²
    (a + b)(a - b) = a² - b²

De gauche à droite : on développe.
De droite à gauche : on factorise.


LA DISTRIBUTIVITÉ

    k(a + b) = ka + kb
    (a + b)(c + d) = ac + ad + bc + bd


LE SIGNE MOINS DEVANT UNE PARENTHÈSE

    -(a - b) = -a + b

Tous les signes changent. C’est l’erreur la plus fréquente.


LES PUISSANCES

    a⁰ = 1
    a⁻ⁿ = 1/aⁿ
    aᵐ × aⁿ = aᵐ⁺ⁿ
    aᵐ / aⁿ = aᵐ⁻ⁿ
    (aᵐ)ⁿ = aᵐˣⁿ


FACTORISER : L’ORDRE DES RÉFLEXES

1. Un facteur commun ?
2. Une identité remarquable ?
3. Une parenthèse en commun ?
4. Réduire ce qui reste dans la parenthèse.


LES FRACTIONS RATIONNELLES

Condition d’existence : dénominateur ≠ 0. À écrire toujours.
On ne simplifie que des FACTEURS, jamais des termes d’une somme.


LES CARRÉS À RECONNAÎTRE AU PREMIER COUP D'ŒIL

    1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144


LA VÉRIFICATION QUI SAUVE

Remplace x par 1 ou par 2 dans l’expression de départ et dans ton
résultat. Si les deux valeurs diffèrent, il y a une erreur.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : le calcul littéral',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'cl1',
            type: TypeQuestion.qcm,
            enonce: 'Que vaut (x + 4)² après développement ?',
            choix: [
              'x² + 16',
              'x² + 8x + 16',
              'x² + 4x + 16',
              'x² + 16x + 8',
            ],
            bonnesReponses: [1],
            explication:
                '(a + b)² = a² + 2ab + b². Ici a = x et b = 4, donc le double '
                'produit vaut 2 × x × 4 = 8x. Le piège classique est d\'oublier '
                'ce terme du milieu.',
          ),
          QuestionQuiz(
            id: 'cl2',
            type: TypeQuestion.vraiFaux,
            enonce: 'L\'expression 5x - (3x - 2) est égale à 2x - 2.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [1],
            explication:
                'Le moins devant la parenthèse change TOUS les signes : '
                '5x - 3x + 2 = 2x + 2, et non 2x - 2.',
          ),
          QuestionQuiz(
            id: 'cl3',
            type: TypeQuestion.qcm,
            enonce: 'Quelle est la forme factorisée de 16x² - 9 ?',
            choix: [
              '(4x - 3)²',
              '(4x + 3)(4x - 3)',
              '(16x + 9)(16x - 9)',
              'Cette expression ne se factorise pas',
            ],
            bonnesReponses: [1],
            explication:
                '16x² = (4x)² et 9 = 3². On reconnaît a² - b², qui se factorise '
                'en (a + b)(a - b), soit (4x + 3)(4x - 3).',
          ),
          QuestionQuiz(
            id: 'cl4',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Que vaut 2⁻³ ? Écris le résultat sous forme de fraction '
                'simplifiée, par exemple 1/4.',
            reponseAttendue: '1/8',
            explication:
                'a⁻ⁿ = 1/aⁿ. Donc 2⁻³ = 1/2³ = 1/8.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 2 : RACINES CARREES
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch03': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Les racines carrées',
        ordre: 1,
        contenu: r'''
1. DÉFINITION

Soit a un nombre positif. La racine carrée de a, notée √a, est le nombre
POSITIF dont le carré vaut a.

    (√a)² = a       et       √(a²) = a   si a ≥ 0

Exemples :
    √25 = 5   car 5² = 25
    √0 = 0
    √9 = 3

ATTENTION : √a n’existe pas si a est négatif. √(-4) n’a pas de sens.


2. LES CARRÉS PARFAITS À CONNAÎTRE

    √1 = 1     √4 = 2     √9 = 3      √16 = 4    √25 = 5
    √36 = 6    √49 = 7    √64 = 8     √81 = 9    √100 = 10
    √121 = 11  √144 = 12  √169 = 13   √196 = 14  √225 = 15


3. LES NOMBRES RÉELS

L’ensemble des nombres réels, noté ℝ, contient :
    les entiers naturels (0, 1, 2, ...)
    les entiers relatifs (..., -2, -1, 0, 1, ...)
    les nombres décimaux et les fractions
    les nombres irrationnels comme √2 ou π

√2 est irrationnel : il ne peut pas s’écrire comme une fraction, et son
écriture décimale ne s’arrête jamais et ne se répète jamais.
√2 ≈ 1,414 213 56...


4. LA VALEUR ABSOLUE

La valeur absolue d’un nombre a, notée |a|, est sa distance à zéro.

    |5| = 5        |-5| = 5        |0| = 0

Règle générale :
    |a| = a    si a ≥ 0
    |a| = -a   si a < 0

Propriété importante :
    √(a²) = |a|   pour TOUT nombre réel a

Exemple : √((-7)²) = √49 = 7 = |-7|


5. OPÉRATIONS AVEC LES RADICAUX

Pour a ≥ 0 et b ≥ 0 :

    √a × √b = √(ab)
    √a / √b = √(a/b)      avec b > 0

ATTENTION, CECI EST FAUX :
    √(a + b) ≠ √a + √b

Contre-exemple : √(9 + 16) = √25 = 5, alors que √9 + √16 = 3 + 4 = 7.


6. SIMPLIFIER UNE RACINE

Méthode : chercher le plus grand carré parfait qui divise le nombre.

    √50 = √(25 × 2) = √25 × √2 = 5√2
    √72 = √(36 × 2) = 6√2
    √12 = √(4 × 3) = 2√3
    √98 = √(49 × 2) = 7√2


7. ADDITIONNER DES RADICAUX

On ne peut additionner que des radicaux IDENTIQUES, comme on regroupe des
termes semblables en calcul littéral.

    3√2 + 5√2 = 8√2
    3√2 + 5√3 : impossible à réduire

Astuce : simplifie d’abord chaque racine, des termes semblables peuvent
apparaître.

    √8 + √18 = 2√2 + 3√2 = 5√2


8. L’EXPRESSION CONJUGUÉE

Rendre un dénominateur rationnel, c’est le débarrasser de sa racine.

Cas simple :
    3/√2 = 3√2/(√2 × √2) = 3√2/2

Cas avec une somme : on multiplie par l’expression conjuguée.
L’expression conjuguée de (a + √b) est (a - √b), et inversement.

    1/(√3 - 1)
  = (√3 + 1) / [(√3 - 1)(√3 + 1)]
  = (√3 + 1) / (3 - 1)
  = (√3 + 1) / 2

Cela fonctionne grâce à l’identité (a + b)(a - b) = a² - b², qui fait
disparaître la racine du dénominateur.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Manipuler les racines sans paniquer',
        ordre: 1,
        contenu: r'''
LA RÈGLE QUI RÉSUME TOUT

Le produit et le quotient traversent la racine.
La somme et la différence, JAMAIS.

    √a × √b = √(ab)        ✓ vrai
    √(a + b) = √a + √b     ✗ faux

Si tu ne retiens qu’une chose, retiens celle-là.


SIMPLIFIER UNE RACINE, PAS À PAS

Objectif : sortir le plus grand carré parfait possible.

Étape 1 — décompose le nombre en cherchant un carré parfait.
    Pour √48 : est-ce divisible par 4 ? par 9 ? par 16 ?
    48 = 16 × 3, et 16 est un carré parfait.

Étape 2 — sépare la racine.
    √48 = √16 × √3

Étape 3 — calcule la partie qui sort.
    √48 = 4√3

Si tu ne trouves pas le plus grand carré du premier coup, ce n’est pas
grave : recommence sur ce qui reste.
    √48 = √(4 × 12) = 2√12 = 2 × √(4 × 3) = 2 × 2√3 = 4√3
Même résultat, en deux temps.


COMMENT SAVOIR SI ON PEUT ADDITIONNER

Traite les radicaux comme des lettres en calcul littéral.

    3√5 + 2√5 = 5√5        comme 3x + 2x = 5x
    3√5 + 2√7 : impossible  comme 3x + 2y

Mais attention : simplifie TOUJOURS d’abord. Deux radicaux qui semblent
différents peuvent devenir identiques.

    √27 + √12 = 3√3 + 2√3 = 5√3


L’EXPRESSION CONJUGUÉE : POURQUOI ÇA MARCHE

Tu veux enlever la racine du dénominateur de 1/(√5 - 2).

L’idée : utiliser (a + b)(a - b) = a² - b², qui transforme les racines en
nombres entiers.

Multiplie en haut et en bas par le conjugué, c’est-à-dire la même
expression avec le signe opposé au milieu :

    1/(√5 - 2)
  = (√5 + 2) / [(√5 - 2)(√5 + 2)]
  = (√5 + 2) / (5 - 4)
  = (√5 + 2) / 1
  = √5 + 2

Le dénominateur devient un entier : c’est gagné.

Retiens le conjugué :
    de (√a + b), c’est (√a - b)
    de (√a - b), c’est (√a + b)


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : √(a + b) = √a + √b. FAUX, on l’a vu.

Erreur 2 : écrire √(-9) = -3. La racine d’un nombre négatif n’existe pas,
et une racine carrée n’est jamais négative.

Erreur 3 : oublier la valeur absolue.
√(x²) = |x|, pas x. Si x = -3, alors √((-3)²) = 3, pas -3.

Erreur 4 : laisser une racine au dénominateur.
En devoir, un résultat comme 1/√2 doit être écrit √2/2.

Erreur 5 : ne pas simplifier le résultat final.
√8 n’est pas une réponse aboutie : écris 2√2.


CONSEIL POUR LE BEPC

Apprends par cœur les carrés parfaits jusqu’à 225. Tu repéreras
instantanément qu’il faut sortir 12 de √144, et tu gagneras du temps sur
tout le sujet.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Simplifier et réduire des radicaux',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
1) Simplifie chacune des racines suivantes :
       √32        √75        √200

2) Réduis l’expression :
       A = √18 + √50 - √8

3) Calcule et simplifie :
       B = √3 × √12
''',
        solution: r'''
1) SIMPLIFICATION DES RACINES

√32 : on cherche le plus grand carré parfait qui divise 32. C’est 16.
    √32 = √(16 × 2) = √16 × √2 = 4√2

√75 : le plus grand carré parfait qui divise 75 est 25.
    √75 = √(25 × 3) = √25 × √3 = 5√3

√200 : le plus grand carré parfait qui divise 200 est 100.
    √200 = √(100 × 2) = √100 × √2 = 10√2


2) RÉDUCTION DE A

On simplifie d’abord chaque racine séparément :

    √18 = √(9 × 2) = 3√2
    √50 = √(25 × 2) = 5√2
    √8  = √(4 × 2)  = 2√2

Les trois radicaux sont maintenant identiques : on peut les regrouper.

    A = 3√2 + 5√2 - 2√2
    A = (3 + 5 - 2)√2
    A = 6√2


3) CALCUL DE B

Le produit traverse la racine :

    B = √3 × √12
    B = √(3 × 12)
    B = √36
    B = 6

Le résultat est un entier.


REMARQUE
On aurait aussi pu simplifier d’abord :
    √12 = 2√3
    B = √3 × 2√3 = 2 × (√3)² = 2 × 3 = 6
Même résultat, les deux méthodes sont acceptées.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Rendre un dénominateur rationnel',
        ordre: 2,
        difficulte: Difficulte.difficile,
        enonce: r'''
On considère les nombres :

    A = 5 / √5
    B = 1 / (√7 - 2)
    C = (√3 + 1) / (√3 - 1)

Écris chacun de ces nombres sans racine au dénominateur, sous la forme la
plus simple possible.
''',
        solution: r'''
CALCUL DE A

On multiplie le numérateur et le dénominateur par √5 :

    A = 5 / √5
    A = (5 × √5) / (√5 × √5)
    A = 5√5 / 5
    A = √5


CALCUL DE B

Le dénominateur est (√7 - 2). Son expression conjuguée est (√7 + 2).
On multiplie en haut et en bas par ce conjugué :

    B = 1 / (√7 - 2)
    B = (√7 + 2) / [(√7 - 2)(√7 + 2)]

Le dénominateur est de la forme (a - b)(a + b) = a² - b² :

    (√7 - 2)(√7 + 2) = (√7)² - 2² = 7 - 4 = 3

Donc :

    B = (√7 + 2) / 3


CALCUL DE C

Le dénominateur est (√3 - 1). Son conjugué est (√3 + 1).

    C = (√3 + 1) / (√3 - 1)
    C = [(√3 + 1)(√3 + 1)] / [(√3 - 1)(√3 + 1)]

Numérateur — c’est une identité remarquable (a + b)² :

    (√3 + 1)² = (√3)² + 2 × √3 × 1 + 1²
              = 3 + 2√3 + 1
              = 4 + 2√3

Dénominateur :

    (√3 - 1)(√3 + 1) = (√3)² - 1² = 3 - 1 = 2

Donc :

    C = (4 + 2√3) / 2

On factorise le numérateur par 2 :

    C = 2(2 + √3) / 2
    C = 2 + √3


VÉRIFICATION APPROCHÉE
√3 ≈ 1,732
Expression de départ : (1,732 + 1) / (1,732 - 1) ≈ 2,732 / 0,732 ≈ 3,732
Résultat trouvé : 2 + 1,732 = 3,732. Les deux concordent.


MÉTHODE À RETENIR
1. Repère le conjugué du dénominateur : même expression, signe opposé.
2. Multiplie en haut ET en bas par ce conjugué.
3. Développe le dénominateur avec a² - b² : la racine disparaît.
4. Simplifie la fraction obtenue.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Racines carrées — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
DÉFINITION

√a est le nombre POSITIF dont le carré vaut a. Il faut a ≥ 0.

    (√a)² = a          √(a²) = |a|


CE QUI TRAVERSE LA RACINE

    √a × √b = √(ab)        ✓
    √a / √b = √(a/b)       ✓
    √(a + b) = √a + √b     ✗ FAUX


LES CARRÉS PARFAITS

    1  4  9  16  25  36  49  64  81  100
    121  144  169  196  225


SIMPLIFIER

Sortir le plus grand carré parfait :
    √50 = √(25 × 2) = 5√2
    √72 = √(36 × 2) = 6√2
    √12 = √(4 × 3)  = 2√3


ADDITIONNER

Seulement des radicaux identiques, comme des termes semblables.
    3√2 + 5√2 = 8√2
Simplifie toujours AVANT de conclure que c’est impossible.


L’EXPRESSION CONJUGUÉE

    conjugué de (√a + b)  →  (√a - b)
    conjugué de (√a - b)  →  (√a + b)

On multiplie en haut et en bas, et (a + b)(a - b) = a² - b² fait
disparaître la racine.

    1/(√3 - 1) = (√3 + 1)/2


LA VALEUR ABSOLUE

    |a| = a si a ≥ 0        |a| = -a si a < 0
    √(x²) = |x|, jamais x tout court


LES PIÈGES

- Une racine carrée n’est jamais négative.
- √(nombre négatif) n’existe pas.
- Ne jamais laisser de racine au dénominateur d’un résultat final.
- √8 n’est pas une réponse : écris 2√2.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : les racines carrées',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'rc1',
            type: TypeQuestion.qcm,
            enonce: 'Quelle est la forme simplifiée de √72 ?',
            choix: ['6√2', '2√36', '8√3', '36√2'],
            bonnesReponses: [0],
            explication:
                '72 = 36 × 2, et 36 est un carré parfait. Donc '
                '√72 = √36 × √2 = 6√2.',
          ),
          QuestionQuiz(
            id: 'rc2',
            type: TypeQuestion.vraiFaux,
            enonce: 'Pour tous nombres positifs a et b, √(a + b) = √a + √b.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [1],
            explication:
                'C\'est faux. Contre-exemple : √(9 + 16) = √25 = 5, alors que '
                '√9 + √16 = 3 + 4 = 7. Seuls le produit et le quotient '
                'traversent la racine.',
          ),
          QuestionQuiz(
            id: 'rc3',
            type: TypeQuestion.qcm,
            enonce: 'Quelle est l\'expression conjuguée de (√5 - 3) ?',
            choix: ['(√5 + 3)', '(3 - √5)', '(-√5 - 3)', '(√5 - 3)'],
            bonnesReponses: [0],
            explication:
                'Le conjugué garde les mêmes termes en changeant le signe du '
                'milieu. Leur produit vaut (√5)² - 3² = 5 - 9 = -4, un nombre '
                'sans racine.',
          ),
          QuestionQuiz(
            id: 'rc4',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Combien vaut √20 + √45 ? Écris le résultat sous la forme '
                'a√b, par exemple 7√2.',
            reponseAttendue: '5√5',
            explication:
                '√20 = √(4 × 5) = 2√5 et √45 = √(9 × 5) = 3√5. '
                'Donc 2√5 + 3√5 = 5√5.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 3 : CALCUL NUMERIQUE
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch05': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Intervalles, encadrements et arrondis',
        ordre: 1,
        contenu: r'''
1. COMPARER DEUX NOMBRES

Comparer a et b, c’est déterminer lequel est le plus grand.

La méthode générale : étudier le signe de la différence a - b.

    si a - b > 0   alors a > b
    si a - b < 0   alors a < b
    si a - b = 0   alors a = b

Exemple : comparer 3/7 et 2/5.
    3/7 - 2/5 = 15/35 - 14/35 = 1/35 > 0
    Donc 3/7 > 2/5.


2. LES INTERVALLES

Un intervalle est un ensemble de nombres réels compris entre deux bornes.

Intervalle fermé :
    [2 ; 5]  est l’ensemble des x tels que 2 ≤ x ≤ 5
    Les bornes 2 et 5 sont incluses.

Intervalle ouvert :
    ]2 ; 5[  est l’ensemble des x tels que 2 < x < 5
    Les bornes sont exclues.

Intervalles semi-ouverts :
    [2 ; 5[  signifie 2 ≤ x < 5
    ]2 ; 5]  signifie 2 < x ≤ 5

Intervalles non bornés :
    [3 ; +∞[  signifie x ≥ 3
    ]-∞ ; 4]  signifie x ≤ 4

Le crochet est TOURNÉ VERS LE NOMBRE quand la borne est incluse.
Vers l’infini, le crochet est toujours ouvert.


3. RÉUNION ET INTERSECTION

L’intersection de deux intervalles, notée ∩, est l’ensemble des nombres
qui appartiennent aux DEUX.

    [1 ; 6] ∩ [4 ; 9] = [4 ; 6]

La réunion, notée ∪, est l’ensemble des nombres qui appartiennent à l’UN
ou à l’AUTRE.

    [1 ; 3] ∪ [5 ; 8] : les deux morceaux, sans les nombres entre 3 et 5.


4. ENCADRER UN NOMBRE

Encadrer x, c’est trouver deux nombres a et b tels que a ≤ x ≤ b.

L’amplitude de l’encadrement est la différence b - a. Plus elle est
petite, plus l’encadrement est précis.

Exemple : 3,14 < π < 3,15 est un encadrement de π d’amplitude 0,01.


5. OPÉRATIONS SUR LES ENCADREMENTS

Addition — on additionne membre à membre :
    si  2 < x < 5  et  1 < y < 3
    alors  3 < x + y < 8

Multiplication par un nombre POSITIF — on multiplie tout :
    si  2 < x < 5   alors  6 < 3x < 15

Multiplication par un nombre NÉGATIF — l’ordre s’INVERSE :
    si  2 < x < 5   alors  -15 < -3x < -6

Soustraction — attention, on ne soustrait pas membre à membre.
    si  2 < x < 5  et  1 < y < 3
    on écrit  -3 < -y < -1
    puis on additionne :  -1 < x - y < 4


6. VALEUR APPROCHÉE ET ARRONDI

Une valeur approchée par DÉFAUT est inférieure au nombre exact.
Une valeur approchée par EXCÈS est supérieure.

Pour π = 3,14159...
    3,14 est une valeur approchée par défaut à 10⁻²
    3,15 est une valeur approchée par excès à 10⁻²

L’ARRONDI est la valeur approchée la plus proche.

Règle : on regarde le chiffre qui suit le rang demandé.
    s’il vaut 0, 1, 2, 3 ou 4 → on garde le chiffre
    s’il vaut 5, 6, 7, 8 ou 9 → on ajoute 1 au chiffre

Exemples pour 7,3846 :
    arrondi d’ordre 1 (au dixième)    : 7,4
    arrondi d’ordre 2 (au centième)   : 7,38
    arrondi d’ordre 3 (au millième)   : 7,385


7. TRONCATURE

Tronquer, c’est couper sans arrondir.

Pour 7,3846 :
    troncature d’ordre 2 : 7,38   (on coupe, sans regarder la suite)
    arrondi d’ordre 2    : 7,38   (identique ici)

Pour 7,3876 :
    troncature d’ordre 2 : 7,38
    arrondi d’ordre 2    : 7,39   (différent)
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Encadrements et intervalles, pas à pas',
        ordre: 1,
        contenu: r'''
LE CROCHET : COMMENT NE PLUS SE TROMPER

Imagine que le crochet est une main qui attrape le nombre.

    [2      la main est tournée vers 2 : elle l’attrape, 2 est INCLUS
    ]2      la main est tournée vers l’extérieur : 2 est EXCLU

Même logique à droite :
    5]      5 est inclus
    5[      5 est exclu

Vers l’infini, on ne peut jamais attraper : le crochet est toujours ouvert.
    [3 ; +∞[


TRADUIRE UNE PHRASE EN INTERVALLE

    « x est compris entre 2 et 7, bornes comprises »  →  [2 ; 7]
    « x est strictement supérieur à 4 »               →  ]4 ; +∞[
    « x est au plus égal à 10 »                       →  ]-∞ ; 10]
    « x est positif ou nul »                          →  [0 ; +∞[

Le mot « strictement » signifie toujours un crochet ouvert.


LA RÈGLE QUI PIÈGE TOUT LE MONDE

Multiplier un encadrement par un nombre NÉGATIF inverse l’ordre.

    Si  2 < x < 5

Multiplions par -1 :
    Faux : -2 < -x < -5   (impossible, -2 n’est pas inférieur à -5)
    Juste : -5 < -x < -2

Pourquoi ? Parce que sur la droite des nombres, multiplier par un négatif
retourne tout comme un miroir. Le plus grand devient le plus petit.

Le réflexe : après avoir multiplié par un négatif, RELIS ton encadrement.
Le nombre de gauche doit être le plus petit. Si ce n’est pas le cas,
échange-les.


SOUSTRAIRE DEUX ENCADREMENTS

On ne soustrait JAMAIS membre à membre. On transforme en addition.

    Si  2 < x < 5  et  1 < y < 3, encadrer x - y.

Étape 1 : encadrer -y en multipliant par -1, donc en inversant.
    de  1 < y < 3   on obtient   -3 < -y < -1

Étape 2 : additionner membre à membre.
    2 + (-3) < x - y < 5 + (-1)
    -1 < x - y < 4


ARRONDI : LA MÉTHODE EN DEUX GESTES

Pour arrondir 12,4571 au centième (ordre 2) :

Geste 1 — souligne les deux décimales demandées : 12,45|71
Geste 2 — regarde le PREMIER chiffre après la barre : c’est 7.
          7 ≥ 5, donc on ajoute 1 à la dernière décimale gardée.

    Arrondi = 12,46

On ne regarde QUE le chiffre juste après. Pas les suivants.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : oublier d’inverser l’encadrement après multiplication par un
négatif.

Erreur 2 : confondre arrondi et troncature. Tronquer, c’est couper.
Arrondir, c’est prendre le plus proche.

Erreur 3 : écrire l’intersection au lieu de la réunion.
∩ signifie « les deux à la fois », ∪ signifie « l’un ou l’autre ».

Erreur 4 : oublier de préciser l’amplitude quand elle est demandée.
L’amplitude est la différence entre les deux bornes.


CONSEIL POUR LE BEPC

Trace une droite graduée dès que tu manipules des intervalles. Hachure la
zone concernée. Beaucoup d’erreurs disparaissent quand on voit la
situation au lieu de la calculer de tête.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Intervalles et encadrements',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
1) Traduis chaque phrase par un intervalle :
   a) x est compris entre -3 et 4, bornes comprises
   b) x est strictement inférieur à 6
   c) x est supérieur ou égal à 2

2) Détermine l’intersection [1 ; 8] ∩ [5 ; 12].

3) On sait que 3 < x < 7 et 2 < y < 4.
   Encadre x + y, puis 2x.

4) Donne l’arrondi d’ordre 2 du nombre 5,2748.
''',
        solution: r'''
1) TRADUCTION EN INTERVALLES

a) « bornes comprises » : les deux crochets sont fermés.
       x ∈ [-3 ; 4]

b) « strictement inférieur » : crochet ouvert, et pas de borne à gauche.
       x ∈ ]-∞ ; 6[

c) « supérieur ou égal » : crochet fermé sur 2.
       x ∈ [2 ; +∞[


2) INTERSECTION

L’intersection est l’ensemble des nombres appartenant aux DEUX
intervalles à la fois.

    [1 ; 8]  contient les x tels que 1 ≤ x ≤ 8
    [5 ; 12] contient les x tels que 5 ≤ x ≤ 12

Pour appartenir aux deux, il faut x ≥ 5 et x ≤ 8.

    [1 ; 8] ∩ [5 ; 12] = [5 ; 8]


3) ENCADREMENTS

Encadrement de x + y — on additionne membre à membre :

    3 < x < 7
    2 < y < 4
    ------------
    3 + 2 < x + y < 7 + 4
    5 < x + y < 11

Encadrement de 2x — on multiplie par 2, qui est positif, donc l’ordre est
conservé :

    3 < x < 7
    3 × 2 < 2x < 7 × 2
    6 < 2x < 14


4) ARRONDI D’ORDRE 2

Le nombre est 5,2748.
L’ordre 2 signifie deux chiffres après la virgule : 5,27

On regarde le chiffre suivant : c’est 4.
Comme 4 < 5, on garde le 7 sans le modifier.

    Arrondi d’ordre 2 : 5,27


ATTENTION
On ne regarde QUE le chiffre juste après le rang demandé. Le 8 final ne
doit pas être pris en compte, même s’il est grand.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Le champ de Madame Adjoua',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''
Madame Adjoua possède un champ rectangulaire à Adzopé.

Elle a mesuré ses dimensions avec un décamètre, mais ses mesures ne sont
pas parfaitement précises. Elle sait seulement que :

    la longueur L vérifie   24,5 m < L < 25,5 m
    la largeur  l vérifie   17,5 m < l < 18,5 m

1) Encadre le périmètre du champ.
2) Encadre l’aire du champ.
3) Donne l’amplitude de l’encadrement de l’aire, puis un arrondi d’ordre 0
   de l’aire moyenne.
''',
        solution: r'''
1) ENCADREMENT DU PÉRIMÈTRE

Le périmètre d’un rectangle est P = 2(L + l), soit P = 2L + 2l.

Encadrons d’abord 2L. On multiplie par 2, qui est positif : l’ordre est
conservé.

    24,5 < L < 25,5
    49 < 2L < 51

De même pour 2l :

    17,5 < l < 18,5
    35 < 2l < 37

On additionne membre à membre :

    49 + 35 < 2L + 2l < 51 + 37
    84 < P < 88

CONCLUSION : le périmètre est compris entre 84 m et 88 m.


2) ENCADREMENT DE L’AIRE

L’aire d’un rectangle est A = L × l.

Toutes les valeurs étant positives, on peut multiplier membre à membre :

    24,5 × 17,5 < L × l < 25,5 × 18,5

Calculons les deux produits.

    24,5 × 17,5 = 428,75
    25,5 × 18,5 = 471,75

Donc :

    428,75 < A < 471,75

CONCLUSION : l’aire est comprise entre 428,75 m² et 471,75 m².


3) AMPLITUDE ET ARRONDI

Amplitude de l’encadrement :

    471,75 - 428,75 = 43

L’amplitude vaut 43 m². L’incertitude est donc importante : une erreur de
50 cm sur chaque dimension entraîne une incertitude de 43 m² sur l’aire.

Aire moyenne — on prend le milieu de l’encadrement :

    (428,75 + 471,75) / 2 = 900,5 / 2 = 450,25

Arrondi d’ordre 0, c’est-à-dire à l’unité : le chiffre après la virgule
est 2, donc inférieur à 5. On garde 450.

    Aire moyenne ≈ 450 m²


CE QU’IL FAUT RETENIR
Une petite imprécision sur les mesures se traduit par une imprécision
beaucoup plus grande sur l’aire. C’est pour cela qu’un géomètre mesure au
centimètre près : sur un terrain, chaque mètre carré compte.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Calcul numérique — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
LES INTERVALLES

    [a ; b]   a ≤ x ≤ b     bornes incluses
    ]a ; b[   a < x < b     bornes exclues
    [a ; b[   a ≤ x < b
    [a ; +∞[  x ≥ a
    ]-∞ ; b]  x ≤ b

Le crochet tourné VERS le nombre signifie que la borne est incluse.
Vers l’infini, le crochet est toujours ouvert.


INTERSECTION ET RÉUNION

    ∩  les deux à la fois
    ∪  l’un ou l’autre


COMPARER DEUX NOMBRES

Étudier le signe de la différence a - b.
    a - b > 0  →  a > b


OPÉRATIONS SUR LES ENCADREMENTS

Addition : on additionne membre à membre.
    2 < x < 5  et  1 < y < 3   →   3 < x + y < 8

Multiplication par un POSITIF : l’ordre est conservé.
    2 < x < 5   →   6 < 3x < 15

Multiplication par un NÉGATIF : l’ordre s’INVERSE.
    2 < x < 5   →   -15 < -3x < -6

Soustraction : encadrer -y, puis additionner.


AMPLITUDE

    amplitude = borne supérieure - borne inférieure

Plus elle est petite, plus l’encadrement est précis.


ARRONDI

On regarde le chiffre JUSTE APRÈS le rang demandé.
    0 à 4  →  on garde
    5 à 9  →  on ajoute 1

Pour 7,3876 :
    ordre 1 : 7,4
    ordre 2 : 7,39
    ordre 3 : 7,388


ARRONDI OU TRONCATURE

Tronquer = couper sans regarder la suite.
Arrondir = prendre la valeur la plus proche.

Pour 7,3876 : troncature d’ordre 2 = 7,38, arrondi d’ordre 2 = 7,39.


LE PIÈGE PRINCIPAL

Après multiplication par un nombre négatif, relis ton encadrement :
le nombre de gauche doit toujours être le plus petit.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : intervalles et encadrements',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'cn1',
            type: TypeQuestion.qcm,
            enonce:
                'Comment traduit-on « x est strictement supérieur à 5 » ?',
            choix: ['[5 ; +∞[', ']5 ; +∞[', ']-∞ ; 5[', '[5 ; +∞]'],
            bonnesReponses: [1],
            explication:
                '« Strictement » exclut la borne : le crochet est ouvert sur 5. '
                'Vers l\'infini, le crochet est toujours ouvert.',
          ),
          QuestionQuiz(
            id: 'cn2',
            type: TypeQuestion.qcm,
            enonce: 'Si 2 < x < 6, que peut-on dire de -x ?',
            choix: [
              '-2 < -x < -6',
              '-6 < -x < -2',
              '2 < -x < 6',
              '-6 < -x < 6',
            ],
            bonnesReponses: [1],
            explication:
                'Multiplier par un nombre négatif inverse l\'ordre. Le plus '
                'grand devient le plus petit : -6 < -x < -2. Vérification : '
                'le nombre de gauche doit bien être le plus petit.',
          ),
          QuestionQuiz(
            id: 'cn3',
            type: TypeQuestion.vraiFaux,
            enonce: 'L\'intersection [2 ; 9] ∩ [6 ; 15] est égale à [6 ; 9].',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication:
                'Pour appartenir aux deux intervalles, il faut x ≥ 6 et x ≤ 9. '
                'L\'intersection est donc bien [6 ; 9].',
          ),
          QuestionQuiz(
            id: 'cn4',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Donne l\'arrondi d\'ordre 2 du nombre 8,4962. '
                '(Écris le nombre avec une virgule)',
            reponseAttendue: '8,50',
            explication:
                'On garde deux décimales : 8,49. Le chiffre suivant est 6, '
                'donc supérieur ou égal à 5 : on ajoute 1 au 9, ce qui donne '
                'une retenue. Le résultat est 8,50.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 4 : EQUATIONS ET INEQUATIONS DANS R
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch08': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Équations et inéquations du premier degré dans ℝ',
        ordre: 1,
        contenu: r'''
1. QU’EST-CE QU’UNE ÉQUATION

Une équation est une égalité qui contient une inconnue, généralement notée x.

Résoudre l’équation, c’est trouver toutes les valeurs de x qui rendent
l’égalité vraie. Ces valeurs s’appellent les solutions.

Une équation du premier degré peut toujours se ramener à la forme :

    ax + b = 0      avec a ≠ 0

Sa solution unique est :

    x = -b / a


2. LES DEUX RÈGLES DE RÉSOLUTION

Règle 1 — on peut ajouter ou retrancher le même nombre aux deux membres.

    x - 5 = 12
    x - 5 + 5 = 12 + 5
    x = 17

Règle 2 — on peut multiplier ou diviser les deux membres par un même
nombre NON NUL.

    3x = 21
    3x / 3 = 21 / 3
    x = 7


3. MÉTHODE COMPLÈTE

Étape 1 : développer et réduire chaque membre s’il y a des parenthèses.
Étape 2 : regrouper les x d’un côté, les nombres de l’autre.
Étape 3 : diviser par le coefficient de x.
Étape 4 : vérifier en remplaçant dans l’équation de départ.

Exemple :

    5(x - 2) = 3x + 4
    5x - 10 = 3x + 4
    5x - 3x = 4 + 10
    2x = 14
    x = 7

Vérification : 5(7-2) = 25 et 3×7 + 4 = 25. C’est juste.


4. ÉQUATION-PRODUIT

Un produit de facteurs est nul si et seulement si l’un au moins des
facteurs est nul.

    A × B = 0   équivaut à   A = 0  ou  B = 0

Exemple :

    (x - 3)(2x + 8) = 0
    x - 3 = 0   ou   2x + 8 = 0
    x = 3       ou   x = -4

Les solutions sont 3 et -4.

C’est pour cela que la factorisation est si utile : elle transforme une
équation compliquée en deux équations simples.


5. LES INÉQUATIONS

Une inéquation utilise un des symboles <, >, ≤ ou ≥.

Les solutions ne sont plus un ou deux nombres, mais tout un INTERVALLE.

LA RÈGLE ESSENTIELLE :
Quand on multiplie ou divise les deux membres par un nombre NÉGATIF, le
sens de l’inégalité s’INVERSE.

    -2x < 6
    x > -3        (on a divisé par -2, donc < devient >)

Avec un nombre positif, rien ne change :

    3x < 12
    x < 4


6. ÉCRIRE L’ENSEMBLE DES SOLUTIONS

On peut l’écrire de trois façons :

    x > -3
    x ∈ ]-3 ; +∞[
    ou par une représentation sur une droite graduée, la zone hachurée.

Rappel : le crochet est fermé si la borne est incluse (≤ ou ≥), ouvert
sinon (< ou >).


7. SYSTÈME DE DEUX INÉQUATIONS

Résoudre un système, c’est chercher les nombres qui vérifient les DEUX
inéquations en même temps. On résout chacune séparément, puis on prend
l’INTERSECTION.

Exemple :

    2x - 1 ≥ 3        et        x + 4 < 10
    2x ≥ 4                      x < 6
    x ≥ 2                       x < 6

Intersection : 2 ≤ x < 6, soit x ∈ [2 ; 6[.


8. RÉSOUDRE UN PROBLÈME

Étape 1 : choisir l’inconnue et écrire ce qu’elle représente.
Étape 2 : mettre le problème en équation.
Étape 3 : résoudre.
Étape 4 : vérifier que la solution a du sens dans le contexte.
Étape 5 : rédiger une phrase de conclusion.

Un âge, un prix ou une longueur ne peuvent pas être négatifs : si vous
trouvez une valeur négative, relisez votre mise en équation.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Résoudre pas à pas, sans se perdre',
        ordre: 1,
        contenu: r'''
L’IMAGE DE LA BALANCE

Une équation, c’est une balance en équilibre. Le signe égal est le point
d’appui.

Tu peux faire ce que tu veux, à UNE condition : faire exactement la même
chose des deux côtés. Sinon la balance penche et l’égalité est fausse.

    Tu retires 5 à gauche ? Retire 5 à droite.
    Tu divises par 3 à gauche ? Divise par 3 à droite.


L’ORDRE DES OPÉRATIONS

Beaucoup d’élèves s’emmêlent parce qu’ils font tout en même temps. Fais-le
en trois temps, toujours dans le même ordre.

    7x - 4 = 3x + 12

Temps 1 — les x à gauche. Je retire 3x des deux côtés.
    7x - 3x - 4 = 12
    4x - 4 = 12

Temps 2 — les nombres à droite. J’ajoute 4 des deux côtés.
    4x = 16

Temps 3 — je divise par le coefficient de x.
    x = 4

Vérifie : 7×4 - 4 = 24 et 3×4 + 12 = 24. Parfait.


LE PIÈGE QUI FAIT PERDRE LE PLUS DE POINTS

Dans une INÉQUATION, multiplier ou diviser par un nombre NÉGATIF inverse
le sens.

    -3x ≥ 12

Faux : x ≥ -4
Juste : x ≤ -4

Pourquoi ? Teste avec x = -10 :
    -3 × (-10) = 30, et 30 ≥ 12. C’est vrai.
Or -10 ≤ -4. Donc c’est bien x ≤ -4.

LE RÉFLEXE : dès que tu divises par un négatif, entoure le symbole et
retourne-le. Fais-le systématiquement, même quand tu es sûr de toi.


COMMENT ÉVITER DE DIVISER PAR UN NÉGATIF

Astuce : range les x du côté où le coefficient est positif.

    5 - 2x < 3x + 20

Au lieu de tout mettre à gauche, mets les x à DROITE :
    5 - 20 < 3x + 2x
    -15 < 5x
    -3 < x

Aucune division par un négatif, donc aucun risque d’oublier d’inverser.


L’ÉQUATION-PRODUIT

Si tu vois (quelque chose)(quelque chose) = 0, ne développe surtout pas.

Un produit est nul quand l’un des facteurs est nul. Traite chaque
parenthèse séparément :

    (2x - 6)(x + 1) = 0
    2x - 6 = 0  ou  x + 1 = 0
    x = 3       ou  x = -1

Deux solutions. Développer t’aurait donné une équation du second degré,
que tu ne sais pas encore résoudre en 3e.


METTRE UN PROBLÈME EN ÉQUATION

Écris toujours cette phrase en premier :
    « Soit x le nombre de ... » ou « Soit x le prix de ... »

Puis traduis chaque phrase de l’énoncé en langage mathématique.

    « le double de »        →  2x
    « augmenté de 5 »       →  + 5
    « diminué de 5 »        →  - 5
    « le triple, moins 4 »  →  3x - 4
    « la somme vaut 30 »    →  ... = 30


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : oublier d’inverser le sens dans une inéquation.
Erreur 2 : développer une équation-produit au lieu de l’utiliser.
Erreur 3 : ne pas vérifier sa solution. La vérification prend dix secondes.
Erreur 4 : oublier la phrase de conclusion dans un problème.
Erreur 5 : garder une solution négative pour un prix ou un âge.


CONSEIL POUR LE BEPC

Vérifie TOUJOURS ta solution en la remplaçant dans l’équation de départ.
Si les deux membres ne donnent pas le même nombre, tu as le temps de te
corriger avant de rendre la copie.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Équations, inéquations et système',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
1) Résous l’équation :   4x - 9 = x + 6

2) Résous l’équation-produit :   (3x - 12)(x + 5) = 0

3) Résous l’inéquation :   -5x + 3 ≤ 18
   Donne l’ensemble des solutions sous forme d’intervalle.

4) Résous le système :   x - 2 ≥ 1   et   3x < 21
''',
        solution: r'''
1) ÉQUATION 4x - 9 = x + 6

On regroupe les x à gauche et les nombres à droite :

    4x - x = 6 + 9
    3x = 15
    x = 5

Vérification : 4×5 - 9 = 11 et 5 + 6 = 11. Les deux membres sont égaux.

    La solution est x = 5.


2) ÉQUATION-PRODUIT (3x - 12)(x + 5) = 0

Un produit est nul si l’un au moins de ses facteurs est nul :

    3x - 12 = 0        ou        x + 5 = 0
    3x = 12                     x = -5
    x = 4

    Les solutions sont 4 et -5.


3) INÉQUATION -5x + 3 ≤ 18

On isole le terme en x :

    -5x ≤ 18 - 3
    -5x ≤ 15

On divise par -5. ATTENTION : -5 est négatif, donc le sens de l’inégalité
s’inverse.

    x ≥ 15 / (-5)
    x ≥ -3

    L’ensemble des solutions est [-3 ; +∞[.

Vérification avec x = 0 : -5×0 + 3 = 3, et 3 ≤ 18. C’est vrai, et 0
appartient bien à [-3 ; +∞[.


4) SYSTÈME

On résout chaque inéquation séparément.

Première inéquation :
    x - 2 ≥ 1
    x ≥ 3

Seconde inéquation :
    3x < 21
    x < 7

Les solutions du système sont les nombres qui vérifient les DEUX
conditions : c’est l’intersection.

    3 ≤ x < 7

    L’ensemble des solutions est [3 ; 7[.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Le transport des élèves',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''
Un collège de Yamoussoukro organise une sortie pédagogique.

Une société de transport propose deux formules :

    Formule A : 5 000 F par élève, sans frais fixes.
    Formule B : 60 000 F de frais fixes, puis 3 000 F par élève.

On note x le nombre d’élèves participant à la sortie.

1) Exprime en fonction de x le prix payé avec chaque formule.
2) Pour quel nombre d’élèves les deux formules coûtent-elles le même prix ?
3) À partir de combien d’élèves la formule B devient-elle plus avantageuse ?
4) Le collège inscrit 45 élèves. Quelle formule doit-il choisir, et
   combien économise-t-il ?
''',
        solution: r'''
1) EXPRESSION DES DEUX PRIX

Soit x le nombre d’élèves.

Formule A : 5 000 F par élève, sans frais fixes.
    Prix A = 5000x

Formule B : 60 000 F fixes, plus 3 000 F par élève.
    Prix B = 3000x + 60000


2) ÉGALITÉ DES DEUX FORMULES

On résout l’équation Prix A = Prix B :

    5000x = 3000x + 60000
    5000x - 3000x = 60000
    2000x = 60000
    x = 30

Vérification :
    Formule A : 5000 × 30 = 150 000 F
    Formule B : 3000 × 30 + 60000 = 90 000 + 60 000 = 150 000 F

CONCLUSION : pour 30 élèves, les deux formules coûtent 150 000 F.


3) QUAND LA FORMULE B EST-ELLE PLUS AVANTAGEUSE ?

La formule B est plus avantageuse lorsque son prix est INFÉRIEUR :

    Prix B < Prix A
    3000x + 60000 < 5000x
    60000 < 5000x - 3000x
    60000 < 2000x
    30 < x

Ici on divise par 2000, qui est positif : le sens ne change pas.

CONCLUSION : la formule B devient plus avantageuse à partir de 31 élèves.

Le nombre d’élèves étant un entier, on ne peut pas s’arrêter à « x > 30 » :
il faut préciser 31.


4) CAS DE 45 ÉLÈVES

    Formule A : 5000 × 45 = 225 000 F
    Formule B : 3000 × 45 + 60000 = 135 000 + 60 000 = 195 000 F

Comme 45 > 30, la formule B est bien la plus avantageuse, ce qui confirme
la question 3.

Économie réalisée :

    225 000 - 195 000 = 30 000 F

CONCLUSION : le collège doit choisir la formule B et économise 30 000 F.


CE QU’IL FAUT RETENIR
Les frais fixes sont pénalisants quand le groupe est petit, mais deviennent
négligeables quand il grandit. C’est le raisonnement que fait tout
gestionnaire avant de signer un contrat.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Équations et inéquations — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
ÉQUATION DU PREMIER DEGRÉ

    ax + b = 0    →    x = -b / a      (a ≠ 0)

Méthode :
1. développer et réduire
2. les x d’un côté, les nombres de l’autre
3. diviser par le coefficient de x
4. vérifier


LES DEUX RÈGLES

On peut ajouter ou retrancher le même nombre aux deux membres.
On peut multiplier ou diviser par un même nombre NON NUL.


ÉQUATION-PRODUIT

    A × B = 0    équivaut à    A = 0  ou  B = 0

Ne jamais développer une équation-produit : c’est un cadeau, on la garde
telle quelle.


INÉQUATION : LA RÈGLE À NE JAMAIS OUBLIER

Multiplier ou diviser par un NÉGATIF inverse le sens.

    -2x < 6    →    x > -3

Avec un positif, rien ne change.


ÉCRIRE LES SOLUTIONS

    x > 3     →    ]3 ; +∞[
    x ≥ 3     →    [3 ; +∞[
    x < 3     →    ]-∞ ; 3[
    x ≤ 3     →    ]-∞ ; 3]


SYSTÈME DE DEUX INÉQUATIONS

On résout chacune, puis on prend l’INTERSECTION.

    x ≥ 2  et  x < 6    →    [2 ; 6[


TRADUIRE UN ÉNONCÉ

    le double de x            →  2x
    x augmenté de 5           →  x + 5
    le triple de x, moins 4   →  3x - 4
    au plus                   →  ≤
    au moins                  →  ≥
    strictement plus que      →  >


LES RÉFLEXES QUI SAUVENT

- Toujours commencer par « Soit x le ... »
- Toujours vérifier la solution dans l’équation de départ
- Toujours conclure par une phrase
- Un prix, un âge, un effectif ne sont jamais négatifs
- Un effectif est un ENTIER : « x > 30 » se conclut par « à partir de 31 »
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : équations et inéquations',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'eq1',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Résous l\'équation 6x - 4 = 2x + 16. Écris seulement la '
                'valeur de x.',
            reponseAttendue: '5',
            explication:
                '6x - 2x = 16 + 4, donc 4x = 20 et x = 5. '
                'Vérification : 6×5 - 4 = 26 et 2×5 + 16 = 26.',
          ),
          QuestionQuiz(
            id: 'eq2',
            type: TypeQuestion.qcm,
            enonce: 'Quelles sont les solutions de (x - 7)(2x + 3) = 0 ?',
            choix: [
              '7 et -1,5',
              '7 et 1,5',
              '-7 et 1,5',
              'Il n\'y a pas de solution',
            ],
            bonnesReponses: [0],
            explication:
                'Un produit est nul si un facteur est nul. x - 7 = 0 donne '
                'x = 7 ; 2x + 3 = 0 donne 2x = -3, soit x = -1,5.',
          ),
          QuestionQuiz(
            id: 'eq3',
            type: TypeQuestion.vraiFaux,
            enonce:
                'Pour résoudre -4x > 20, on divise par -4 et on obtient x > -5.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [1],
            explication:
                'Diviser par un nombre négatif INVERSE le sens de l\'inégalité. '
                'La bonne réponse est x < -5. Vérifie avec x = -10 : '
                '-4 × (-10) = 40, et 40 > 20. C\'est bien cohérent.',
          ),
          QuestionQuiz(
            id: 'eq4',
            type: TypeQuestion.qcm,
            enonce:
                'Quel est l\'ensemble des solutions du système x ≥ 1 et x < 5 ?',
            choix: ['[1 ; 5]', '[1 ; 5[', ']1 ; 5[', '[5 ; +∞['],
            bonnesReponses: [1],
            explication:
                'x ≥ 1 donne un crochet fermé sur 1 ; x < 5 donne un crochet '
                'ouvert sur 5. L\'intersection est donc [1 ; 5[.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 5 : SYSTEMES DANS R x R
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch14': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Systèmes de deux équations à deux inconnues',
        ordre: 1,
        contenu: r'''
1. QU’EST-CE QU’UN SYSTÈME

Un système de deux équations du premier degré à deux inconnues s’écrit :

    ax + by = c
    a’x + b’y = c'

Résoudre le système, c’est trouver le COUPLE (x ; y) qui vérifie les deux
équations en même temps.

La solution n’est pas un nombre, mais un couple de nombres. On l’écrit
entre parenthèses, avec un point-virgule : (3 ; 5).


2. MÉTHODE 1 — LA SUBSTITUTION

On isole une inconnue dans une équation, puis on la remplace dans l’autre.

Exemple :

    x + 2y = 11        (1)
    3x - y = 5         (2)

Étape 1 — j’isole x dans (1) :
    x = 11 - 2y

Étape 2 — je remplace x par cette expression dans (2) :
    3(11 - 2y) - y = 5
    33 - 6y - y = 5
    33 - 7y = 5
    -7y = -28
    y = 4

Étape 3 — je remplace y par 4 dans l’expression de x :
    x = 11 - 2×4 = 11 - 8 = 3

    La solution est le couple (3 ; 4).

Quand choisir la substitution ? Quand une inconnue a pour coefficient 1
ou -1 : elle s’isole sans fraction.


3. MÉTHODE 2 — LA COMBINAISON

On multiplie les équations pour faire disparaître une inconnue par
addition ou soustraction.

Exemple :

    2x + 3y = 19       (1)
    5x - 2y = 4        (2)

Étape 1 — je veux éliminer y. Je multiplie (1) par 2 et (2) par 3 :
    4x + 6y = 38
    15x - 6y = 12

Étape 2 — j’additionne les deux lignes : les termes en y s’annulent.
    19x = 50 ... 

Reprenons avec des valeurs plus simples pour la démonstration :

    2x + 3y = 19       (1)
    5x - 2y = 11       (2)

Multiplions (1) par 2 et (2) par 3 :
    4x + 6y = 38
    15x - 6y = 33

Additionnons :
    19x = 71 ...

Le principe reste : on choisit les multiplicateurs de façon à obtenir des
coefficients OPPOSÉS pour une inconnue, puis on additionne.

Cas simple :

    3x + 2y = 16       (1)
    x - 2y = 0         (2)

Les coefficients de y sont déjà opposés : +2 et -2. On additionne
directement :

    4x = 16
    x = 4

Puis on remplace dans (2) :
    4 - 2y = 0
    y = 2

    La solution est (4 ; 2).

Quand choisir la combinaison ? Quand aucune inconnue n’a un coefficient
égal à 1, ou quand des coefficients sont déjà opposés.


4. MÉTHODE 3 — LA RÉSOLUTION GRAPHIQUE

Chaque équation représente une DROITE dans un repère.

La solution du système correspond au POINT D’INTERSECTION des deux droites.

Trois cas possibles :

- les droites se coupent en un point → une seule solution
- les droites sont parallèles distinctes → aucune solution
- les droites sont confondues → une infinité de solutions

Pour tracer, on met chaque équation sous la forme y = ax + b, puis on
place deux points par droite.

La lecture graphique donne une solution APPROCHÉE. Pour une valeur exacte,
il faut résoudre algébriquement.


5. VÉRIFIER SA SOLUTION

Il faut remplacer x et y dans les DEUX équations. Une solution qui ne
vérifie qu’une seule équation n’est pas une solution du système.


6. RÉSOUDRE UN PROBLÈME

Étape 1 : nommer les deux inconnues.
    « Soit x le prix d’un cahier et y le prix d’un stylo. »
Étape 2 : traduire chaque information en une équation.
Étape 3 : résoudre le système.
Étape 4 : vérifier dans l’énoncé, pas seulement dans les équations.
Étape 5 : conclure par une phrase.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Substitution ou combinaison : comment choisir',
        ordre: 1,
        contenu: r'''
LA QUESTION À SE POSER EN PREMIER

Regarde les coefficients des inconnues.

Y a-t-il un coefficient égal à 1 ou -1 ?
    OUI  → substitution : l’inconnue s’isole sans fraction
    NON  → combinaison : plus rapide et sans dénominateur

Y a-t-il déjà deux coefficients opposés, comme +2y et -2y ?
    OUI  → combinaison, il suffit d’additionner


LA SUBSTITUTION, PAS À PAS

    x + 3y = 14
    2x - y = 7

Le x de la première a pour coefficient 1 : c’est lui qu’on isole.

    x = 14 - 3y

Maintenant, dans la SECONDE équation, partout où il y a x, j’écris
(14 - 3y). Les parenthèses sont obligatoires.

    2(14 - 3y) - y = 7
    28 - 6y - y = 7
    28 - 7y = 7
    -7y = -21
    y = 3

Je reviens à mon expression de x :
    x = 14 - 3×3 = 14 - 9 = 5

    Solution : (5 ; 3)

L’erreur classique : remplacer dans la MÊME équation que celle utilisée
pour isoler. Cela donne 0 = 0, ce qui n’apprend rien. Il faut remplacer
dans l’AUTRE équation.


LA COMBINAISON, PAS À PAS

    4x + 3y = 27
    2x - 5y = -19

Objectif : faire disparaître une inconnue.

Je choisis d’éliminer x. Le coefficient de x est 4 dans la première et 2
dans la seconde. Si je multiplie la seconde par 2, j’obtiendrai 4x aussi.

    4x + 3y = 27
    4x - 10y = -38

Les coefficients sont maintenant IDENTIQUES, donc je SOUSTRAIS :

    (4x + 3y) - (4x - 10y) = 27 - (-38)
    3y + 10y = 65
    13y = 65
    y = 5

Puis dans la première équation :
    4x + 15 = 27
    4x = 12
    x = 3

    Solution : (3 ; 5)

LA RÈGLE DES SIGNES :
    coefficients IDENTIQUES  → on SOUSTRAIT
    coefficients OPPOSÉS     → on ADDITIONNE


METTRE UN PROBLÈME EN SYSTÈME

Deux inconnues, donc deux phrases à traduire. Cherche dans l’énoncé les
deux informations chiffrées.

    « 3 cahiers et 5 stylos coûtent 2 400 F »   →   3x + 5y = 2400
    « 2 cahiers et 3 stylos coûtent 1 550 F »   →   2x + 3y = 1550

Nomme toujours tes inconnues AVANT d’écrire les équations. Sans cette
phrase, le correcteur ne sait pas ce que représentent x et y, et tu perds
des points même si le calcul est juste.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : oublier les parenthèses lors de la substitution.
Erreur 2 : remplacer dans la même équation que celle utilisée pour isoler.
Erreur 3 : additionner alors que les coefficients sont identiques.
Erreur 4 : trouver x et oublier de calculer y. Une solution est un COUPLE.
Erreur 5 : ne vérifier que dans une seule équation.


CONSEIL POUR LE BEPC

Écris ta solution sous la forme (x ; y) avec un point-virgule, jamais une
virgule : (3 ; 5) et non (3, 5), qui pourrait se lire comme le nombre
décimal 3,5.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Résoudre par les deux méthodes',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
1) Résous par SUBSTITUTION le système :

       x + 4y = 22
       3x - y = 14

2) Résous par COMBINAISON le système :

       5x + 2y = 24
       3x - 2y = 8

3) Vérifie chacune de tes solutions dans les deux équations d’origine.
''',
        solution: r'''
1) RÉSOLUTION PAR SUBSTITUTION

    x + 4y = 22        (1)
    3x - y = 14        (2)

Dans (1), le coefficient de x vaut 1 : on isole x.

    x = 22 - 4y

On remplace x par cette expression dans (2), sans oublier les parenthèses :

    3(22 - 4y) - y = 14
    66 - 12y - y = 14
    66 - 13y = 14
    -13y = 14 - 66
    -13y = -52
    y = 4

On revient à l’expression de x :

    x = 22 - 4×4 = 22 - 16 = 6

    La solution est le couple (6 ; 4).


2) RÉSOLUTION PAR COMBINAISON

    5x + 2y = 24       (1)
    3x - 2y = 8        (2)

Les coefficients de y sont +2 et -2 : ils sont déjà OPPOSÉS. On additionne
donc directement les deux équations.

    (5x + 2y) + (3x - 2y) = 24 + 8
    8x = 32
    x = 4

On remplace x par 4 dans (1) :

    5×4 + 2y = 24
    20 + 2y = 24
    2y = 4
    y = 2

    La solution est le couple (4 ; 2).


3) VÉRIFICATIONS

Premier système, avec (6 ; 4) :
    Équation (1) : 6 + 4×4 = 6 + 16 = 22 ✓
    Équation (2) : 3×6 - 4 = 18 - 4 = 14 ✓

Second système, avec (4 ; 2) :
    Équation (1) : 5×4 + 2×2 = 20 + 4 = 24 ✓
    Équation (2) : 3×4 - 2×2 = 12 - 4 = 8 ✓

Les deux solutions vérifient bien les deux équations de leur système.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'La rentrée au marché de Treichville',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''
Pour la rentrée scolaire, deux familles font leurs achats au marché de
Treichville, chez le même vendeur.

La famille Koné achète 3 cahiers et 5 stylos et paie 2 400 F.
La famille Diallo achète 2 cahiers et 3 stylos et paie 1 550 F.

1) Choisis les inconnues et mets le problème en système d’équations.
2) Résous le système.
3) Combien coûtent un cahier et un stylo ?
4) Une troisième famille veut acheter 6 cahiers et 4 stylos. Combien
   devra-t-elle payer ?
''',
        solution: r'''
1) MISE EN ÉQUATION

Soit x le prix d’un cahier, en francs CFA.
Soit y le prix d’un stylo, en francs CFA.

Famille Koné : 3 cahiers et 5 stylos pour 2 400 F.
    3x + 5y = 2400        (1)

Famille Diallo : 2 cahiers et 3 stylos pour 1 550 F.
    2x + 3y = 1550        (2)


2) RÉSOLUTION

Aucun coefficient ne vaut 1 : la combinaison est la méthode la plus
adaptée.

Éliminons x. Multiplions (1) par 2 et (2) par 3 :

    6x + 10y = 4800
    6x + 9y = 4650

Les coefficients de x sont IDENTIQUES : on soustrait.

    (6x + 10y) - (6x + 9y) = 4800 - 4650
    y = 150

On remplace y par 150 dans (1) :

    3x + 5×150 = 2400
    3x + 750 = 2400
    3x = 1650
    x = 550

    La solution est le couple (550 ; 150).


3) INTERPRÉTATION

CONCLUSION : un cahier coûte 550 F et un stylo coûte 150 F.

Vérification dans l’énoncé, pas seulement dans les équations :
    Famille Koné : 3×550 + 5×150 = 1650 + 750 = 2400 F ✓
    Famille Diallo : 2×550 + 3×150 = 1100 + 450 = 1550 F ✓

Les prix sont positifs et réalistes : la solution a du sens.


4) TROISIÈME FAMILLE

6 cahiers et 4 stylos :

    6 × 550 + 4 × 150
  = 3300 + 600
  = 3900

CONCLUSION : la troisième famille devra payer 3 900 F.


CE QU’IL FAUT RETENIR
Deux informations chiffrées dans l’énoncé donnent deux équations. C’est la
règle : autant d’équations que d’inconnues, sinon le problème n’a pas de
solution unique.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Systèmes — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
LA FORME D’UN SYSTÈME

    ax + by = c
    a’x + b’y = c'

La solution est un COUPLE, noté (x ; y) avec un point-virgule.


CHOISIR SA MÉTHODE

Un coefficient vaut 1 ou -1        →  SUBSTITUTION
Aucun coefficient simple           →  COMBINAISON
Des coefficients déjà opposés      →  COMBINAISON, on additionne


LA SUBSTITUTION

1. isoler une inconnue dans une équation
2. remplacer dans l’AUTRE équation, avec des parenthèses
3. résoudre
4. revenir à l’expression pour trouver la seconde inconnue


LA COMBINAISON

1. multiplier pour obtenir des coefficients égaux ou opposés
2. coefficients IDENTIQUES → on SOUSTRAIT
   coefficients OPPOSÉS    → on ADDITIONNE
3. résoudre l’équation à une inconnue obtenue
4. remplacer pour trouver la seconde


LA RÉSOLUTION GRAPHIQUE

Chaque équation est une droite. La solution est leur point d’intersection.

    droites sécantes      →  une solution
    parallèles distinctes →  aucune solution
    droites confondues    →  une infinité

La lecture graphique donne une valeur APPROCHÉE.


METTRE UN PROBLÈME EN SYSTÈME

1. « Soit x le ... et y le ... » — obligatoire
2. une phrase chiffrée = une équation
3. résoudre
4. vérifier dans l’ÉNONCÉ
5. conclure par une phrase


LES PIÈGES

- oublier les parenthèses en substituant
- remplacer dans la même équation que celle utilisée pour isoler
- additionner quand les coefficients sont identiques
- trouver x et oublier y
- écrire (3, 5) au lieu de (3 ; 5)
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : les systèmes',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'sy1',
            type: TypeQuestion.qcm,
            enonce:
                'Dans le système x + 2y = 9 et 4x - 3y = 3, quelle méthode est '
                'la plus rapide ?',
            choix: [
              'La substitution, car x a pour coefficient 1',
              'La combinaison, car les coefficients sont opposés',
              'La méthode graphique, car elle est exacte',
              'Aucune méthode ne fonctionne',
            ],
            bonnesReponses: [0],
            explication:
                'Le coefficient de x vaut 1 dans la première équation : il '
                's\'isole sans fraction, ce qui rend la substitution très '
                'rapide. La méthode graphique, elle, ne donne qu\'une valeur '
                'approchée.',
          ),
          QuestionQuiz(
            id: 'sy2',
            type: TypeQuestion.vraiFaux,
            enonce:
                'Quand deux équations ont des coefficients IDENTIQUES pour une '
                'inconnue, on additionne les deux équations pour l\'éliminer.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [1],
            explication:
                'Coefficients identiques : on SOUSTRAIT. Coefficients opposés : '
                'on additionne. Additionner 4x et 4x donnerait 8x, l\'inconnue '
                'ne disparaîtrait pas.',
          ),
          QuestionQuiz(
            id: 'sy3',
            type: TypeQuestion.qcm,
            enonce:
                'Deux droites représentant un système sont parallèles et '
                'distinctes. Que peut-on dire du système ?',
            choix: [
              'Il a une solution unique',
              'Il n\'a aucune solution',
              'Il a une infinité de solutions',
              'On ne peut pas conclure',
            ],
            bonnesReponses: [1],
            explication:
                'La solution correspond au point d\'intersection. Deux droites '
                'parallèles distinctes ne se coupent jamais : le système n\'a '
                'aucune solution.',
          ),
          QuestionQuiz(
            id: 'sy4',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Résous le système 2x + y = 13 et x - y = 2. Écris la solution '
                'sous la forme (x ; y), par exemple (4 ; 5).',
            reponseAttendue: '(5 ; 3)',
            explication:
                'Les coefficients de y sont +1 et -1, donc opposés : on '
                'additionne. 3x = 15, soit x = 5. Puis 5 - y = 2 donne y = 3.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 6 : APPLICATIONS AFFINES
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch13': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Applications affines et linéaires',
        ordre: 1,
        contenu: r'''
1. DÉFINITIONS

Une application affine est une application f qui, à tout nombre réel x,
associe le nombre ax + b, où a et b sont deux nombres fixés.

    f(x) = ax + b

    a s’appelle le COEFFICIENT DIRECTEUR
    b s’appelle l’ORDONNÉE À L’ORIGINE

Une application LINÉAIRE est le cas particulier où b = 0 :

    f(x) = ax

Toute application linéaire est affine, mais l’inverse est faux.


2. CALCULER UNE IMAGE

L’image de x par f, c’est f(x). On remplace simplement x par sa valeur.

Pour f(x) = 3x - 5 :
    f(2) = 3×2 - 5 = 1
    f(0) = -5
    f(-1) = -3 - 5 = -8

Remarque : f(0) = b. L’ordonnée à l’origine se lit donc immédiatement.


3. CALCULER UN ANTÉCÉDENT

Chercher l’antécédent de y, c’est résoudre l’équation f(x) = y.

Pour f(x) = 3x - 5, quel est l’antécédent de 7 ?

    3x - 5 = 7
    3x = 12
    x = 4

L’antécédent de 7 est 4.


4. REPRÉSENTATION GRAPHIQUE

La représentation graphique d’une application affine est une DROITE.

    f(x) = ax + b   →   droite d’équation y = ax + b

Celle d’une application linéaire est une droite qui PASSE PAR L’ORIGINE
du repère, puisque f(0) = 0.

Pour tracer, il suffit de deux points. Le plus simple :
    le point (0 ; b), qui est l’intersection avec l’axe des ordonnées
    un second point, par exemple (1 ; a + b)


5. LE SENS DE VARIATION

Le signe du coefficient directeur a détermine tout :

    a > 0   →   f est CROISSANTE   (la droite monte)
    a < 0   →   f est DÉCROISSANTE (la droite descend)
    a = 0   →   f est CONSTANTE    (droite horizontale)

Exemples :
    f(x) = 2x + 1   est croissante
    g(x) = -3x + 7  est décroissante
    h(x) = 4        est constante


6. DÉTERMINER a ET b À PARTIR DE DEUX POINTS

Si l’on connaît deux images, f(x₁) = y₁ et f(x₂) = y₂, alors :

    a = (y₂ - y₁) / (x₂ - x₁)

Puis on trouve b en remplaçant dans f(x) = ax + b.

Exemple : f(2) = 7 et f(5) = 16.

    a = (16 - 7) / (5 - 2) = 9 / 3 = 3

Puis avec f(2) = 7 :
    3×2 + b = 7
    6 + b = 7
    b = 1

    Donc f(x) = 3x + 1.


7. LE COEFFICIENT DIRECTEUR SE LIT SUR LE GRAPHIQUE

a représente l’accroissement de y quand x augmente de 1.

Concrètement : depuis un point de la droite, on avance de 1 vers la
droite, puis on compte de combien on monte (a > 0) ou on descend (a < 0).


8. PROPORTIONNALITÉ

Une application LINÉAIRE traduit une situation de PROPORTIONNALITÉ.

    f(x) = ax   →   y est proportionnel à x, de coefficient a

Une application affine avec b ≠ 0 n’est PAS une situation de
proportionnalité : il y a une part fixe.

Exemple concret :
    Un taxi qui facture 500 F du kilomètre : f(x) = 500x, linéaire.
    Un taxi avec 1 000 F de prise en charge : f(x) = 500x + 1000, affine
    mais pas proportionnelle. Doubler la distance ne double pas le prix.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Lire et construire une droite',
        ordre: 1,
        contenu: r'''
AFFINE OU LINÉAIRE : LA DIFFÉRENCE EN UNE PHRASE

    Linéaire : f(x) = ax        la droite passe par l’origine
    Affine   : f(x) = ax + b    la droite coupe l’axe des y en b

Toute linéaire est affine. Une affine n’est linéaire que si b = 0.


CE QUE SIGNIFIENT a ET b, CONCRÈTEMENT

Imagine une facture de taxi : f(x) = 500x + 1000.

    b = 1000  →  ce que tu paies AVANT de rouler, la prise en charge
    a = 500   →  ce que tu paies pour CHAQUE kilomètre supplémentaire

b est le point de départ, a est le rythme.

C’est vrai partout : un abonnement téléphonique, un tarif d’électricité,
un contrat de transport.


TRACER UNE DROITE EN 30 SECONDES

    f(x) = 2x - 3

Étape 1 — place le point (0 ; -3). C’est b, il se lit directement.

Étape 2 — depuis ce point, avance de 1 vers la droite et monte de 2,
puisque a = 2. Tu arrives en (1 ; -1).

Étape 3 — trace la droite passant par ces deux points, et prolonge-la des
deux côtés.

Si a était négatif, tu descendrais au lieu de monter.


LIRE a SUR UN GRAPHIQUE

Choisis deux points bien lisibles de la droite, aux coordonnées entières.

    a = (différence des y) / (différence des x)

Autrement dit : de combien on monte quand on avance de 1.

Attention au signe : si la droite descend, a est négatif.


IMAGE OU ANTÉCÉDENT : NE PLUS CONFONDRE

    IMAGE      : on te donne x, tu calcules f(x). C’est un CALCUL.
    ANTÉCÉDENT : on te donne f(x), tu cherches x. C’est une ÉQUATION.

Sur le graphique :
    image de 3      → je pars de 3 sur l’axe horizontal, je monte
                      jusqu’à la droite, je lis à gauche
    antécédent de 5 → je pars de 5 sur l’axe vertical, je vais
                      horizontalement jusqu’à la droite, je lis en bas


TROUVER a ET b À PARTIR DE DEUX POINTS

C’est un exercice très fréquent au BEPC.

    f(1) = 5   et   f(4) = 14

Étape 1 — le coefficient directeur :
    a = (14 - 5) / (4 - 1) = 9 / 3 = 3

Étape 2 — l’ordonnée à l’origine, avec l’un des deux points :
    f(1) = 5, donc 3×1 + b = 5, donc b = 2

    f(x) = 3x + 2

Étape 3 — vérifie avec l’AUTRE point :
    f(4) = 3×4 + 2 = 14 ✓


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : inverser image et antécédent.
Erreur 2 : calculer a en inversant le rapport. C’est bien la différence
des y DIVISÉE PAR la différence des x, jamais l’inverse.
Erreur 3 : oublier le signe de a quand la droite descend.
Erreur 4 : dire qu’une application affine traduit une proportionnalité.
Ce n’est vrai que si b = 0.
Erreur 5 : tracer la droite à partir d’un seul point.


CONSEIL POUR LE BEPC

Après avoir trouvé f(x), vérifie toujours avec le second point de
l’énoncé. Si ça ne tombe pas juste, tu as fait une erreur de calcul sur a
ou sur b, et tu peux encore te corriger.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Images, antécédents et variations',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
On considère les applications définies par :

    f(x) = 4x - 6
    g(x) = -2x + 5

1) Calcule f(3), f(0) et f(-2).
2) Détermine l’antécédent de 10 par f.
3) Précise le sens de variation de f et celui de g. Justifie.
4) Laquelle de ces deux applications est linéaire ? Justifie.
''',
        solution: r'''
1) CALCUL D’IMAGES

    f(3) = 4×3 - 6 = 12 - 6 = 6
    f(0) = 4×0 - 6 = -6
    f(-2) = 4×(-2) - 6 = -8 - 6 = -14

Remarque : f(0) = -6, ce qui correspond bien à l’ordonnée à l’origine.


2) ANTÉCÉDENT DE 10 PAR f

Chercher l’antécédent de 10, c’est résoudre l’équation f(x) = 10.

    4x - 6 = 10
    4x = 16
    x = 4

Vérification : f(4) = 4×4 - 6 = 10 ✓

    L’antécédent de 10 par f est 4.


3) SENS DE VARIATION

Pour f(x) = 4x - 6, le coefficient directeur est a = 4.
Comme 4 > 0, l’application f est CROISSANTE.

Pour g(x) = -2x + 5, le coefficient directeur est a = -2.
Comme -2 < 0, l’application g est DÉCROISSANTE.


4) APPLICATION LINÉAIRE

Une application est linéaire lorsqu’elle s’écrit f(x) = ax, c’est-à-dire
lorsque b = 0.

    Pour f : b = -6, donc f n’est pas linéaire.
    Pour g : b = 5, donc g n’est pas linéaire.

CONCLUSION : aucune de ces deux applications n’est linéaire. Elles sont
toutes les deux affines, avec une ordonnée à l’origine non nulle.

Leurs représentations graphiques ne passent donc pas par l’origine du
repère.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Deux forfaits de téléphone',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''
Un opérateur ivoirien propose deux forfaits mensuels.

    Forfait Liberté : 2 000 F par mois, puis 25 F par minute d’appel.
    Forfait Confort : 6 000 F par mois, puis 5 F par minute d’appel.

On note x le nombre de minutes d’appel dans le mois.

1) Exprime le prix de chaque forfait par une application affine, notée
   respectivement L(x) et C(x).
2) Précise, pour chacune, le coefficient directeur et l’ordonnée à
   l’origine, et donne leur signification concrète.
3) Calcule L(100) et C(100). Quel forfait est le plus avantageux pour
   100 minutes ?
4) À partir de combien de minutes le forfait Confort devient-il plus
   avantageux ?
''',
        solution: r'''
1) LES DEUX APPLICATIONS

Soit x le nombre de minutes d’appel dans le mois.

Forfait Liberté : 2 000 F fixes, plus 25 F par minute.
    L(x) = 25x + 2000

Forfait Confort : 6 000 F fixes, plus 5 F par minute.
    C(x) = 5x + 6000


2) COEFFICIENTS ET SIGNIFICATIONS

Pour L(x) = 25x + 2000 :
    coefficient directeur a = 25 → le prix de CHAQUE minute
    ordonnée à l’origine  b = 2000 → l’abonnement mensuel, payé même sans
                                     aucun appel

Pour C(x) = 5x + 6000 :
    a = 5    → le prix de chaque minute, cinq fois moins cher
    b = 6000 → un abonnement mensuel trois fois plus élevé

Les deux applications sont croissantes, puisque leurs coefficients
directeurs sont positifs : plus on appelle, plus on paie.


3) CAS DE 100 MINUTES

    L(100) = 25×100 + 2000 = 2500 + 2000 = 4500
    C(100) = 5×100 + 6000 = 500 + 6000 = 6500

    L(100) = 4 500 F   et   C(100) = 6 500 F

CONCLUSION : pour 100 minutes, le forfait Liberté est plus avantageux. Il
fait économiser 2 000 F.


4) SEUIL DE BASCULEMENT

Le forfait Confort devient plus avantageux lorsque son prix est inférieur :

    C(x) < L(x)
    5x + 6000 < 25x + 2000
    6000 - 2000 < 25x - 5x
    4000 < 20x
    200 < x

On divise par 20, qui est positif : le sens de l’inégalité ne change pas.

CONCLUSION : le forfait Confort devient plus avantageux à partir de
201 minutes d’appel par mois.

Vérification au point d’équilibre, pour x = 200 :
    L(200) = 25×200 + 2000 = 5000 + 2000 = 7000
    C(200) = 5×200 + 6000 = 1000 + 6000 = 7000
Les deux forfaits coûtent exactement 7 000 F : c’est bien le seuil.


INTERPRÉTATION GRAPHIQUE
Les deux droites se coupent au point de coordonnées (200 ; 7000). Avant ce
point, la droite de Liberté est en dessous ; après, c’est celle de Confort.
Le point d’intersection donne toujours le seuil de basculement.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Applications affines — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
LES DÉFINITIONS

    Affine   : f(x) = ax + b
    Linéaire : f(x) = ax        (cas où b = 0)

    a = coefficient directeur
    b = ordonnée à l’origine, et b = f(0)


LE SENS DE VARIATION

    a > 0   →   croissante   (la droite monte)
    a < 0   →   décroissante (la droite descend)
    a = 0   →   constante    (droite horizontale)


IMAGE ET ANTÉCÉDENT

    IMAGE de x        : on calcule f(x)
    ANTÉCÉDENT de y   : on résout l’équation f(x) = y


TROUVER a ET b AVEC DEUX POINTS

    a = (y₂ - y₁) / (x₂ - x₁)

Puis on remplace dans f(x) = ax + b pour trouver b.
Et on vérifie avec le second point.


LA REPRÉSENTATION GRAPHIQUE

C’est une DROITE.
    affine   → coupe l’axe des ordonnées en b
    linéaire → passe par l’origine

Pour tracer : place (0 ; b), puis avance de 1 et monte de a.


PROPORTIONNALITÉ

Seule une application LINÉAIRE traduit une proportionnalité.
Dès qu’il y a une part fixe b ≠ 0, il n’y a plus proportionnalité.


LA LECTURE CONCRÈTE

Dans un tarif :
    b = la part fixe, payée même sans consommer
    a = le prix de chaque unité consommée

Le point d’intersection de deux droites donne le SEUIL à partir duquel
une offre devient plus avantageuse que l’autre.


LES PIÈGES

- confondre image et antécédent
- inverser le rapport dans le calcul de a
- oublier le signe négatif de a quand la droite descend
- croire qu’une affine est toujours proportionnelle
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : les applications affines',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'af1',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Soit f(x) = 5x - 8. Calcule f(3). Écris seulement le nombre.',
            reponseAttendue: '7',
            explication: 'f(3) = 5×3 - 8 = 15 - 8 = 7.',
          ),
          QuestionQuiz(
            id: 'af2',
            type: TypeQuestion.qcm,
            enonce:
                'L\'application définie par g(x) = -4x + 9 est-elle croissante '
                'ou décroissante ?',
            choix: [
              'Croissante, car 9 est positif',
              'Décroissante, car le coefficient directeur -4 est négatif',
              'Constante',
              'On ne peut pas savoir sans graphique',
            ],
            bonnesReponses: [1],
            explication:
                'Seul le signe du coefficient directeur a compte. Ici a = -4, '
                'donc la droite descend : g est décroissante. L\'ordonnée à '
                'l\'origine n\'a aucune influence sur les variations.',
          ),
          QuestionQuiz(
            id: 'af3',
            type: TypeQuestion.vraiFaux,
            enonce:
                'La représentation graphique de f(x) = 3x + 2 passe par '
                'l\'origine du repère.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [1],
            explication:
                'f(0) = 2, donc la droite coupe l\'axe des ordonnées au point '
                '(0 ; 2), pas à l\'origine. Seules les applications LINÉAIRES, '
                'où b = 0, passent par l\'origine.',
          ),
          QuestionQuiz(
            id: 'af4',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Une application affine vérifie f(1) = 4 et f(3) = 10. '
                'Combien vaut son coefficient directeur a ?',
            reponseAttendue: '3',
            explication:
                'a = (10 - 4) / (3 - 1) = 6 / 2 = 3. '
                'On trouve ensuite b = 1, donc f(x) = 3x + 1.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 7 : STATISTIQUE
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch10': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Statistique : effectifs, fréquences et médiane',
        ordre: 1,
        contenu: r'''
1. LE VOCABULAIRE

La POPULATION est l’ensemble étudié : les élèves d’une classe, les
habitants d’un village, les commerçants d’un marché.

Chaque élément de cette population est un INDIVIDU.

Le CARACTÈRE est ce que l’on observe : la note obtenue, l’âge, la taille,
le moyen de transport.

Un caractère est QUANTITATIF s’il se mesure par un nombre (une note, une
taille) et QUALITATIF sinon (une couleur, un moyen de transport).


2. EFFECTIF ET EFFECTIF TOTAL

L’EFFECTIF d’une valeur est le nombre d’individus qui possèdent cette
valeur.

L’EFFECTIF TOTAL, noté N, est le nombre total d’individus.

    N = somme de tous les effectifs


3. LA FRÉQUENCE

La fréquence d’une valeur est la part qu’elle représente dans l’ensemble.

    fréquence = effectif / effectif total

On l’exprime souvent en pourcentage :

    fréquence en % = (effectif / N) × 100

La somme de toutes les fréquences vaut toujours 1, soit 100 %.


4. EFFECTIFS CUMULÉS CROISSANTS

L’effectif cumulé croissant d’une valeur, c’est le nombre d’individus dont
la valeur est INFÉRIEURE OU ÉGALE à celle-ci.

On l’obtient en additionnant les effectifs de proche en proche.

Exemple :

    Valeur      8    10    12    14    16
    Effectif    4     7     9     6     4
    ECC         4    11    20    26    30

Lecture : 20 élèves ont une note inférieure ou égale à 12.

Le dernier effectif cumulé est toujours égal à l’effectif total.

On définit de la même façon les FRÉQUENCES CUMULÉES CROISSANTES.


5. LA MOYENNE

La moyenne est la valeur que chacun aurait si l’on partageait
équitablement.

    moyenne = (somme des valeurs × effectifs) / effectif total

Sur l’exemple précédent :

    (8×4 + 10×7 + 12×9 + 14×6 + 16×4) / 30
  = (32 + 70 + 108 + 84 + 64) / 30
  = 358 / 30
  ≈ 11,93


6. LA MÉDIANE

La médiane est la valeur qui PARTAGE la série en deux groupes de même
effectif : la moitié des individus est en dessous, la moitié au-dessus.

Méthode : on range les valeurs dans l’ordre croissant, puis :

    si N est IMPAIR  → la médiane est la valeur du milieu,
                       c’est-à-dire la (N+1)/2 ᵉ valeur
    si N est PAIR    → la médiane est la moyenne des deux valeurs
                       centrales, la N/2 ᵉ et la (N/2 + 1) ᵉ

Les effectifs cumulés croissants servent justement à repérer rapidement
ces valeurs centrales.

Sur l’exemple, N = 30 est pair. Il faut donc la 15ᵉ et la 16ᵉ valeur.
D’après les ECC, la 15ᵉ et la 16ᵉ se trouvent dans la colonne dont l’ECC
vaut 20, c’est-à-dire la valeur 12.

    Médiane = 12


7. MOYENNE OU MÉDIANE : LAQUELLE CHOISIR

La moyenne tient compte de toutes les valeurs, mais elle est sensible aux
valeurs extrêmes. Un seul 0 dans une classe fait chuter la moyenne.

La médiane n’est pas influencée par les extrêmes : elle décrit mieux le
« milieu réel » d’une série déséquilibrée.

C’est pourquoi on donne souvent les deux ensemble.


8. LE MODE ET LA CLASSE MODALE

Le MODE est la valeur qui a le plus grand effectif.

Quand les données sont regroupées en classes, on parle de CLASSE MODALE :
c’est la classe qui a le plus grand effectif.

Attention : si deux classes n’ont pas la même largeur, la comparaison
directe des effectifs n’a pas de sens.


9. LE DIAGRAMME CIRCULAIRE

Le disque entier représente l’effectif total, soit 360°.

L’angle d’un secteur se calcule par proportionnalité :

    angle = (effectif / effectif total) × 360°

ou, ce qui revient au même :

    angle = fréquence × 360°

Sur l’exemple, pour la valeur 12 :

    angle = (9 / 30) × 360 = 0,3 × 360 = 108°

La somme de tous les angles doit valoir 360°. C’est la vérification à
faire avant de tracer.


10. LES AUTRES REPRÉSENTATIONS

Le diagramme en bâtons ou en barres convient aux caractères quantitatifs
discrets. La hauteur est proportionnelle à l’effectif.

L’histogramme s’emploie pour des données regroupées en classes. C’est
l’AIRE du rectangle, et non sa hauteur, qui est proportionnelle à
l’effectif.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Tableaux, médiane et diagrammes, pas à pas',
        ordre: 1,
        contenu: r'''
CONSTRUIRE LE TABLEAU AVANT TOUT

Face à une liste de données brutes, ne calcule rien tout de suite.
Construis d’abord un tableau à quatre lignes :

    Valeur
    Effectif
    Effectif cumulé croissant
    Fréquence

Presque toutes les questions se répondent ensuite par simple lecture.


LES EFFECTIFS CUMULÉS : COMMENT NE PAS SE TROMPER

On additionne de proche en proche, de la gauche vers la droite.

    Effectif    4     7     9     6     4
    ECC         4    11    20    26    30
                ↑     ↑
                4   4+7  11+9  20+6  26+4

Contrôle immédiat : le DERNIER effectif cumulé doit être égal à
l’effectif total. Si ce n’est pas le cas, tu as fait une erreur d’addition.


TROUVER LA MÉDIANE SANS SE PERDRE

Étape 1 — compte l’effectif total N.

Étape 2 — N est-il pair ou impair ?
    IMPAIR : tu cherches UNE valeur, celle de rang (N+1)/2
    PAIR   : tu cherches DEUX valeurs, celles de rang N/2 et N/2 + 1,
             et tu en fais la moyenne

Étape 3 — utilise les effectifs cumulés pour situer ce rang.

Exemple avec N = 30, donc pair. Il faut les rangs 15 et 16.

    Valeur      8    10    12    14    16
    ECC         4    11    20    26    30

Le rang 15 : est-il ≤ 4 ? Non. ≤ 11 ? Non. ≤ 20 ? Oui.
Donc la 15ᵉ valeur est 12. Idem pour la 16ᵉ.

    Médiane = (12 + 12) / 2 = 12

L’astuce : cherche la PREMIÈRE colonne dont l’effectif cumulé atteint ou
dépasse le rang recherché.


MOYENNE ET MÉDIANE NE SONT PAS LA MÊME CHOSE

    Moyenne : on partage équitablement
    Médiane : on coupe la série en deux moitiés

Exemple parlant. Cinq élèves ont 2, 3, 3, 4 et 18.
    Moyenne = 30/5 = 6
    Médiane = 3

La moyenne de 6 donne l’impression d’une classe correcte. Pourtant quatre
élèves sur cinq sont en dessous de 4. C’est le 18 qui tire tout vers le
haut.

La médiane décrit mieux la réalité de cette classe.


LES ANGLES DU DIAGRAMME CIRCULAIRE

Le disque complet, c’est 360°. Le calcul est une simple proportionnalité.

    angle = (effectif / N) × 360

Astuce pratique : calcule d’abord le coefficient 360/N, une fois pour
toutes, puis multiplie chaque effectif par ce nombre.

    Si N = 30, alors 360/30 = 12.
    Chaque individu vaut donc 12°.
    Un effectif de 9 donne 9 × 12 = 108°.

VÉRIFICATION OBLIGATOIRE : la somme de tous tes angles doit faire 360°.
Si tu trouves 358° ou 362°, c’est un arrondi ; ajuste le plus grand
secteur. Si l’écart est plus grand, tu as une erreur de calcul.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : confondre la valeur et l’effectif. La médiane est une VALEUR du
caractère, pas un nombre d’individus.

Erreur 2 : oublier de ranger les valeurs dans l’ordre croissant avant de
chercher la médiane.

Erreur 3 : prendre la valeur du milieu du TABLEAU au lieu de la valeur de
rang (N+1)/2. Le milieu du tableau n’a rien à voir avec la médiane.

Erreur 4 : oublier de multiplier par les effectifs dans le calcul de la
moyenne.

Erreur 5 : ne pas vérifier que les angles totalisent 360°.


CONSEIL POUR LE BEPC

Recopie toujours le tableau complet sur ta copie, même si l’énoncé en
donne une partie. Un tableau bien tenu rapporte des points à lui seul, et
il t’évite la plupart des erreurs.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Les notes de la 3ᵉ B',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
Voici les notes obtenues par les 30 élèves de la classe de 3ᵉ B au dernier
devoir de mathématiques.

    Note        8    10    12    14    16
    Effectif    4     7     9     6     4

1) Recopie et complète le tableau avec les effectifs cumulés croissants.
2) Calcule la moyenne de la classe, arrondie au centième.
3) Détermine la médiane. Interprète le résultat.
4) Quel est le mode de cette série ?
5) Calcule l’angle du secteur correspondant à la note 12 dans un
   diagramme circulaire.
''',
        solution: r'''
1) EFFECTIFS CUMULÉS CROISSANTS

On additionne les effectifs de proche en proche.

    Note        8    10    12    14    16
    Effectif    4     7     9     6     4
    ECC         4    11    20    26    30

Contrôle : le dernier effectif cumulé vaut 30, ce qui correspond bien à
l’effectif total.


2) MOYENNE

    Moyenne = (8×4 + 10×7 + 12×9 + 14×6 + 16×4) / 30

Calculons le numérateur :
    8×4  = 32
    10×7 = 70
    12×9 = 108
    14×6 = 84
    16×4 = 64
    Somme = 32 + 70 + 108 + 84 + 64 = 358

Donc :
    Moyenne = 358 / 30 ≈ 11,9333...

    Moyenne ≈ 11,93


3) MÉDIANE

L’effectif total est N = 30, qui est PAIR.
La médiane est donc la moyenne des valeurs de rang 15 et 16.

On cherche dans les effectifs cumulés la première colonne qui atteint 15 :

    ECC = 4  → non
    ECC = 11 → non
    ECC = 20 → oui

Les 15ᵉ et 16ᵉ valeurs se trouvent donc dans la colonne de la note 12.

    Médiane = (12 + 12) / 2 = 12

INTERPRÉTATION : la moitié des élèves de la classe a obtenu une note
inférieure ou égale à 12, et l’autre moitié une note supérieure ou égale
à 12.


4) MODE

Le mode est la valeur ayant le plus grand effectif.

Le plus grand effectif est 9, obtenu pour la note 12.

    Le mode est 12.


5) ANGLE DU SECTEUR DE LA NOTE 12

Le disque entier représente les 30 élèves, soit 360°.

    angle = (effectif / N) × 360
    angle = (9 / 30) × 360
    angle = 0,3 × 360
    angle = 108°

    L’angle du secteur de la note 12 mesure 108°.


REMARQUE
Comme N = 30, chaque élève représente 360/30 = 12°. On peut donc calculer
tous les angles très vite :
    note 8  : 4 × 12 = 48°
    note 10 : 7 × 12 = 84°
    note 12 : 9 × 12 = 108°
    note 14 : 6 × 12 = 72°
    note 16 : 4 × 12 = 48°
Somme : 48 + 84 + 108 + 72 + 48 = 360°. La vérification est faite.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'L\'enquête du marché de Cocody',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''
Une enquête a été menée auprès de 200 clients du marché de Cocody sur leur
moyen de transport habituel pour s’y rendre.

    Moyen de transport        Effectif
    Marche à pied                60
    Gbaka                        70
    Taxi                         40
    Véhicule personnel           30

1) Calcule la fréquence de chaque moyen de transport, en pourcentage.
2) Calcule l’angle de chaque secteur pour un diagramme circulaire.
3) Vérifie que la somme des angles vaut bien 360°.
4) Le caractère étudié est-il quantitatif ou qualitatif ? Peut-on calculer
   une moyenne ? Justifie.
''',
        solution: r'''
1) FRÉQUENCES EN POURCENTAGE

L’effectif total est N = 60 + 70 + 40 + 30 = 200.

    fréquence en % = (effectif / 200) × 100

    Marche à pied      : (60 / 200) × 100 = 30 %
    Gbaka              : (70 / 200) × 100 = 35 %
    Taxi               : (40 / 200) × 100 = 20 %
    Véhicule personnel : (30 / 200) × 100 = 15 %

Contrôle : 30 + 35 + 20 + 15 = 100 %. Correct.


2) ANGLES DU DIAGRAMME CIRCULAIRE

    angle = (effectif / 200) × 360

Calculons d’abord le coefficient : 360 / 200 = 1,8.
Chaque client représente donc 1,8°.

    Marche à pied      : 60 × 1,8 = 108°
    Gbaka              : 70 × 1,8 = 126°
    Taxi               : 40 × 1,8 = 72°
    Véhicule personnel : 30 × 1,8 = 54°


3) VÉRIFICATION

    108 + 126 + 72 + 54 = 360°

La somme vaut bien 360°. Le diagramme peut être tracé.


4) NATURE DU CARACTÈRE

Le caractère étudié est le moyen de transport. Ce n’est pas un nombre :
c’est une catégorie.

    Le caractère est QUALITATIF.

On ne peut donc PAS calculer de moyenne. Additionner « marche à pied » et
« taxi » n’a aucun sens mathématique.

En revanche, on peut parfaitement déterminer le MODE : c’est la modalité
la plus fréquente, ici le gbaka, avec 70 clients sur 200.


CE QU’IL FAUT RETENIR
Moyenne et médiane n’existent que pour un caractère QUANTITATIF.
Pour un caractère qualitatif, on se limite aux effectifs, aux fréquences
et au mode.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Statistique — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
LE VOCABULAIRE

    Population : l’ensemble étudié
    Individu   : un élément de cet ensemble
    Caractère  : ce que l’on observe
        quantitatif → un nombre (note, taille)
        qualitatif  → une catégorie (couleur, transport)


LES FORMULES

    fréquence = effectif / N
    fréquence en % = (effectif / N) × 100
    moyenne = (somme des valeurs × effectifs) / N
    angle = (effectif / N) × 360


EFFECTIFS CUMULÉS CROISSANTS

On additionne de proche en proche, de gauche à droite.
Le dernier doit être égal à l’effectif total : c’est le contrôle.


LA MÉDIANE

Elle partage la série en deux moitiés égales.

    N IMPAIR → valeur de rang (N+1)/2
    N PAIR   → moyenne des valeurs de rang N/2 et N/2 + 1

On la repère grâce aux effectifs cumulés : on cherche la première colonne
dont l’ECC atteint le rang voulu.


MOYENNE OU MÉDIANE

    Moyenne : sensible aux valeurs extrêmes
    Médiane : insensible aux extrêmes, décrit mieux le milieu réel

Sur 2, 3, 3, 4, 18 : moyenne = 6, médiane = 3.


LE MODE

La valeur ayant le plus grand effectif.
Pour des données groupées, on parle de CLASSE MODALE.


LE DIAGRAMME CIRCULAIRE

Le disque entier = 360° = l’effectif total.
Astuce : calcule 360/N une seule fois, puis multiplie chaque effectif.
VÉRIFIE toujours que la somme des angles vaut 360°.


LES PIÈGES

- confondre valeur et effectif
- oublier de ranger dans l’ordre croissant
- prendre le milieu du tableau au lieu du rang (N+1)/2
- oublier les effectifs dans le calcul de la moyenne
- calculer une moyenne sur un caractère qualitatif
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : la statistique',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'st1',
            type: TypeQuestion.qcm,
            enonce: 'Que représente la médiane d\'une série statistique ?',
            choix: [
              'La valeur la plus fréquente',
              'La valeur qui partage la série en deux groupes de même effectif',
              'La moyenne de toutes les valeurs',
              'La différence entre la plus grande et la plus petite valeur',
            ],
            bonnesReponses: [1],
            explication:
                'La médiane coupe la série en deux moitiés. La valeur la plus '
                'fréquente est le MODE, et la moyenne est un autre indicateur.',
          ),
          QuestionQuiz(
            id: 'st2',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Dans une série de 40 individus, un caractère a un effectif de '
                '10. Quel est l\'angle de son secteur dans un diagramme '
                'circulaire ? (Écris seulement le nombre de degrés)',
            reponseAttendue: '90',
            explication:
                'angle = (10 / 40) × 360 = 0,25 × 360 = 90°. Ce secteur '
                'représente donc un quart du disque.',
          ),
          QuestionQuiz(
            id: 'st3',
            type: TypeQuestion.vraiFaux,
            enonce:
                'On peut calculer la moyenne d\'un caractère qualitatif, comme '
                'la couleur préférée des élèves.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [1],
            explication:
                'La moyenne suppose d\'additionner des nombres. Un caractère '
                'qualitatif désigne des catégories, qu\'on ne peut pas '
                'additionner. On peut seulement en donner le mode.',
          ),
          QuestionQuiz(
            id: 'st4',
            type: TypeQuestion.qcm,
            enonce:
                'Une série a 5 valeurs : 2, 3, 3, 4 et 18. Que valent sa '
                'moyenne et sa médiane ?',
            choix: [
              'moyenne 6 et médiane 3',
              'moyenne 3 et médiane 6',
              'moyenne 6 et médiane 4',
              'moyenne 3 et médiane 3',
            ],
            bonnesReponses: [0],
            explication:
                'Moyenne = (2+3+3+4+18)/5 = 30/5 = 6. Pour la médiane, N = 5 '
                'est impair : c\'est la 3ᵉ valeur, soit 3. L\'écart entre les '
                'deux vient du 18, qui tire la moyenne vers le haut.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 9 : PROPRIETES DE THALES
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch02': [
      // ---------- COURS ----------
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Les propriétés de Thalès dans un triangle',
        ordre: 1,
        contenu: r'''
1. LA CONFIGURATION DE THALÈS

On se place dans un triangle ABC.
Soit M un point de la droite (AB) et N un point de la droite (AC).

Si les droites (MN) et (BC) sont parallèles, on dit qu’on est dans une
configuration de Thalès.

Deux formes reviennent tout le temps :
- la forme « triangle » : M entre A et B, N entre A et C ;
- la forme « papillon » : M et N de l’autre côté du point A.

Dans les deux cas, la propriété s’applique de la même façon.


2. LA PROPRIÉTÉ DE THALÈS

Dans un triangle ABC, si M appartient à (AB), N appartient à (AC) et si
(MN) est parallèle à (BC), alors :

    AM / AB = AN / AC = MN / BC

Ces trois rapports sont égaux. On les appelle le rapport de réduction ou
d’agrandissement.

À quoi cela sert-il ?
À calculer une longueur inaccessible, à partir de longueurs mesurables.


3. LA RÉCIPROQUE DE LA PROPRIÉTÉ DE THALÈS

Dans un triangle ABC, si M appartient à (AB), N appartient à (AC), si les
points A, M, B et A, N, C sont placés dans le même ordre, et si :

    AM / AB = AN / AC

alors les droites (MN) et (BC) sont parallèles.

À quoi cela sert-il ?
À démontrer que deux droites sont parallèles, sans règle ni équerre.

ATTENTION : la condition sur l’ordre des points est indispensable. Sans
elle, la réciproque est fausse.


4. LA CONSÉQUENCE DE LA PROPRIÉTÉ

Si les rapports AM / AB et AN / AC ne sont PAS égaux, alors les droites
(MN) et (BC) ne sont pas parallèles.

C’est ce qu’on utilise pour démontrer qu’un dessin est faux, ou qu’une
construction n’est pas correcte.


5. PARTAGE D’UN SEGMENT

La propriété de Thalès permet de partager un segment en parts égales, sans
mesurer, uniquement avec une règle et un compas.

Méthode pour partager [AB] en n parts égales :
1. Tracer une demi-droite [Ax) quelconque, non alignée avec (AB).
2. Reporter n segments de même longueur sur [Ax) : A1, A2, ... An.
3. Tracer le segment [An B].
4. Tracer les parallèles à (An B) passant par A1, A2, ...
5. Ces parallèles coupent [AB] en n parts égales.


6. À QUOI CELA SERT DANS LA VIE COURANTE

Mesurer la largeur d’une lagune sans la traverser, la hauteur d’un arbre
avec son ombre, ou reproduire un plan à l’échelle : ce sont toutes des
applications directes de Thalès.
''',
      ),

      // ---------- RENFORCEMENT ----------
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Thalès expliqué autrement, pas à pas',
        ordre: 1,
        contenu: r'''
TU CONFONDS THALÈS ET PYTHAGORE ? ON CLARIFIE.

Pythagore parle de LONGUEURS dans un triangle RECTANGLE.
Thalès parle de PROPORTIONS quand deux droites sont PARALLÈLES.

Le repère le plus simple :
- Tu vois un angle droit → pense Pythagore.
- Tu vois des droites parallèles → pense Thalès.


ÉTAPE 1 — Repérer la configuration

Cherche le point de croisement : c’est le sommet commun, souvent appelé A.
Depuis ce point partent deux droites. Deux autres droites les coupent, et
elles sont parallèles entre elles.

Si tu ne trouves pas de parallèles dans l’énoncé, Thalès ne s’applique pas.


ÉTAPE 2 — Écrire les rapports dans le bon ordre

C’est là que la plupart des erreurs se produisent.

La règle : on part TOUJOURS du sommet commun, et on écrit le petit segment
au-dessus, le grand en dessous.

    AM / AB    →  AM part de A, AB part de A. Correct.
    MA / AB    →  incorrect, on a inversé.

Astuce : écris les trois rapports côte à côte, et vérifie que chaque
numérateur commence par la même lettre A.

    AM / AB = AN / AC = MN / BC


ÉTAPE 3 — Le produit en croix

Une fois les rapports écrits, on utilise le produit en croix.

    Exemple : AM / AB = AN / AC
    devient : AM × AC = AB × AN

Puis on isole la longueur cherchée.


ÉTAPE 4 — Vérifier que le résultat est logique

Si tu cherches un petit segment et que tu trouves une valeur plus grande
que le grand segment, tu t’es trompé quelque part. Reprends l’écriture des
rapports.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : appliquer Thalès sans parallèles.
Sans droites parallèles, la propriété est fausse. Vérifie que l’énoncé le
dit, ou démontre-le d’abord.

Erreur 2 : mélanger les rapports.
AM / AB = AC / AN est faux. Les deux numérateurs doivent partir du même
point.

Erreur 3 : confondre la propriété et la réciproque.
La propriété : on SAIT que c’est parallèle, on calcule une longueur.
La réciproque : on calcule des rapports, on DÉMONTRE que c’est parallèle.

Erreur 4 : oublier la condition d’ordre dans la réciproque.
En devoir, cette phrase rapporte des points. Ne la saute pas.

Erreur 5 : garder une fraction non simplifiée.
6/9 doit devenir 2/3. C’est plus propre et cela évite les erreurs de calcul.


CONSEIL POUR LE BEPC

Repasse les droites parallèles au crayon de couleur sur ta figure. Tu
verras immédiatement quel triangle est le petit et quel triangle est le
grand.
''',
      ),

      // ---------- EXERCICE 1 ----------
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'La largeur de la lagune',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
Pour mesurer la largeur d’une lagune à Grand-Bassam sans la traverser, un
géomètre a réalisé le relevé suivant.

Il note A un point sur la rive, B et C deux repères de l’autre côté.
Il place M sur [AB] et N sur [AC] de façon que (MN) soit parallèle à (BC).

Il mesure :
    AM = 12 m,  AB = 48 m,  MN = 9 m.

Quelle est la largeur BC de la lagune ?
''',
        solution: r'''
On sait que M appartient à [AB], N appartient à [AC] et que (MN) est
parallèle à (BC).

D’après la propriété de Thalès :

    AM / AB = AN / AC = MN / BC

On utilise les deux rapports qui contiennent les longueurs connues :

    AM / AB = MN / BC

On remplace :

    12 / 48 = 9 / BC

On simplifie la fraction de gauche :

    12 / 48 = 1 / 4

Donc :

    1 / 4 = 9 / BC

Par produit en croix :

    1 × BC = 4 × 9
    BC = 36


CONCLUSION : la lagune mesure 36 m de large.


VÉRIFICATION
Le rapport de réduction est 1/4 : le petit triangle est quatre fois plus
petit que le grand. MN = 9 et BC = 36, ce qui est bien quatre fois plus
grand. Le résultat est cohérent.
''',
      ),

      // ---------- EXERCICE 2 ----------
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Les poteaux du terrain',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''
Sur un terrain de sport à Bouaké, deux poteaux verticaux sont plantés le
long d’une même ligne droite partant d’un piquet A.

On note :
    B et C les pieds des deux poteaux, alignés avec A ;
    M et N les sommets des deux poteaux.

On mesure :
    AB = 5 m,  AC = 8 m,  BM = 3 m,  CN = 4,5 m.

Les deux poteaux sont verticaux, donc (BM) et (CN) sont parallèles.

Les points A, M et N sont-ils alignés ? Justifie ta réponse.
''',
        solution: r'''
Les poteaux sont verticaux, donc (BM) et (CN) sont parallèles.

Si A, M et N étaient alignés, on serait dans une configuration de Thalès
avec le sommet A, et on aurait :

    AB / AC = BM / CN


On calcule séparément les deux rapports.

D’une part :

    AB / AC = 5 / 8 = 0,625

D’autre part :

    BM / CN = 3 / 4,5 = 0,666...


Les deux rapports ne sont pas égaux :

    5 / 8 ≠ 3 / 4,5


CONCLUSION : les points A, M et N ne sont pas alignés.


REMARQUE IMPORTANTE
On a utilisé ici la CONSÉQUENCE de la propriété de Thalès : quand les
rapports ne sont pas égaux, la configuration de Thalès n’est pas vérifiée.

Concrètement, cela signifie que le sommet du deuxième poteau ne se trouve
pas exactement dans le prolongement de la ligne qui joint A au sommet du
premier. Le deuxième poteau est légèrement trop haut.
''',
      ),

      // ---------- EXERCICE 3 ----------
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Le partage du champ',
        ordre: 3,
        difficulte: Difficulte.examen,
        enonce: r'''
Un planteur de Daloa possède un champ triangulaire ABC.

Il mesure :
    AB = 60 m,  AC = 45 m,  BC = 50 m.

Il souhaite séparer une parcelle pour son fils. Pour cela, il place un
piquet M sur [AB] tel que AM = 24 m, puis un piquet N sur [AC] tel que
AN = 18 m. Il tend une corde entre M et N.

1) Démontre que la corde (MN) est parallèle au côté (BC).
2) Calcule la longueur de la corde MN.
3) Le fils reçoit la parcelle AMN. Quelle fraction du périmètre du champ
   représente le périmètre de sa parcelle ?
''',
        solution: r'''
1) LA CORDE EST-ELLE PARALLÈLE À (BC) ?

Les points A, M, B sont alignés dans cet ordre, ainsi que A, N, C.

On calcule séparément les deux rapports.

D’une part :

    AM / AB = 24 / 60 = 2 / 5

D’autre part :

    AN / AC = 18 / 45 = 2 / 5

On constate que :

    AM / AB = AN / AC

D’après la RÉCIPROQUE de la propriété de Thalès, les droites (MN) et (BC)
sont parallèles.


2) LONGUEUR DE LA CORDE

Puisque (MN) est parallèle à (BC), la propriété de Thalès s’applique :

    AM / AB = MN / BC

On remplace :

    2 / 5 = MN / 50

Par produit en croix :

    5 × MN = 2 × 50
    5 × MN = 100
    MN = 20

CONCLUSION : la corde mesure 20 m.


3) FRACTION DU PÉRIMÈTRE

Périmètre du champ ABC :

    60 + 45 + 50 = 155 m

Périmètre de la parcelle AMN :

    AM + AN + MN = 24 + 18 + 20 = 62 m

Fraction :

    62 / 155 = 2 / 5


CONCLUSION : le périmètre de la parcelle représente les 2/5 du périmètre
du champ.


CE QU’IL FAUT RETENIR
Le rapport de réduction est 2/5, et il se retrouve partout : sur chaque
côté, et donc sur le périmètre entier. C’est une propriété très utile en
devoir, et elle tombe régulièrement au BEPC.

Attention en revanche : cela ne marche PAS pour les aires. L’aire est
multipliée par le carré du rapport, soit ici (2/5)² = 4/25.
''',
      ),

      // ---------- FICHE ----------
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Thalès — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
QUAND UTILISER THALÈS

Deux droites parallèles coupées par deux sécantes qui se croisent en un
point. Pas de parallèles → pas de Thalès.


LA PROPRIÉTÉ (pour CALCULER une longueur)

Dans le triangle ABC, avec M sur (AB), N sur (AC) et (MN) // (BC) :

    AM / AB = AN / AC = MN / BC


LA RÉCIPROQUE (pour DÉMONTRER un parallélisme)

Si les points sont dans le même ordre et si :

    AM / AB = AN / AC

alors (MN) // (BC).


LA CONSÉQUENCE (pour DÉMONTRER un NON-parallélisme)

Si AM / AB ≠ AN / AC, alors (MN) et (BC) ne sont pas parallèles.


LA RÈGLE D’ÉCRITURE

Tous les numérateurs partent du sommet commun.
    AM / AB = AN / AC        correct
    MA / AB = AN / AC        faux


LE RAPPORT DE RÉDUCTION

Le rapport k se retrouve sur TOUS les côtés, et donc sur le périmètre.
Mais les aires sont multipliées par k², pas par k.


THALÈS OU PYTHAGORE ?

    Angle droit         → Pythagore
    Droites parallèles  → Thalès


LES PIÈGES

- Vérifier que les parallèles sont bien données ou démontrées.
- Ne jamais oublier la condition d’ordre des points dans la réciproque.
- Simplifier les fractions avant le produit en croix.
- Écrire l’unité dans la conclusion.


LA PHRASE TYPE À RECOPIER EN DEVOIR

« Les points A, M, B d’une part et A, N, C d’autre part sont alignés dans
le même ordre. De plus (MN) // (BC). D’après la propriété de Thalès :
AM / AB = AN / AC = MN / BC. »

« D’une part AM / AB = ... D’autre part AN / AC = ...
Donc AM / AB = AN / AC. Les points étant alignés dans le même ordre,
d’après la réciproque de la propriété de Thalès, (MN) // (BC). »
''',
      ),

      // ---------- QUIZ ----------
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : les propriétés de Thalès',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'th1',
            type: TypeQuestion.qcm,
            enonce:
                'Quelle condition est indispensable pour appliquer la propriété de Thalès ?',
            choix: [
              'Le triangle doit avoir un angle droit',
              'Deux droites de la figure doivent être parallèles',
              'Le triangle doit être isocèle',
              'Les trois côtés doivent être connus',
            ],
            bonnesReponses: [1],
            explication:
                'Thalès repose sur le parallélisme. Sans droites parallèles, '
                'la propriété ne s\'applique pas. L\'angle droit, lui, renvoie '
                'à Pythagore.',
          ),
          QuestionQuiz(
            id: 'th2',
            type: TypeQuestion.vraiFaux,
            enonce:
                'Dans un triangle ABC avec M sur [AB], N sur [AC] et (MN) parallèle '
                'à (BC), on peut écrire : AM / AB = AN / AC.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication:
                'C\'est exactement l\'écriture correcte : les deux numérateurs '
                'partent du sommet commun A, et les deux dénominateurs aussi.',
          ),
          QuestionQuiz(
            id: 'th3',
            type: TypeQuestion.qcm,
            enonce: 'À quoi sert la réciproque de la propriété de Thalès ?',
            choix: [
              'À calculer la longueur d\'un côté',
              'À démontrer que deux droites sont parallèles',
              'À calculer une aire',
              'À mesurer un angle',
            ],
            bonnesReponses: [1],
            explication:
                'La propriété calcule des longueurs quand on sait déjà que '
                'c\'est parallèle. La réciproque fait l\'inverse : elle démontre '
                'le parallélisme à partir de rapports égaux.',
          ),
          QuestionQuiz(
            id: 'th4',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Dans une configuration de Thalès, AM / AB = 1/3 et BC = 21 cm. '
                'Combien mesure MN, en centimètres ? (Écris seulement le nombre)',
            reponseAttendue: '7',
            explication:
                'MN / BC = AM / AB = 1/3, donc MN = 21 × 1/3 = 7 cm.',
          ),
          QuestionQuiz(
            id: 'th5',
            type: TypeQuestion.qcm,
            enonce:
                'Le rapport de réduction d\'une configuration de Thalès est 1/2. '
                'Par combien l\'aire du petit triangle est-elle multipliée par '
                'rapport au grand ?',
            choix: ['1/2', '1/4', '2', '1/8'],
            bonnesReponses: [1],
            explication:
                'Les longueurs sont multipliées par k, mais les aires par k². '
                'Ici k = 1/2, donc l\'aire est multipliée par (1/2)² = 1/4. '
                'C\'est un piège classique au BEPC.',
          ),
        ],
      ),
    ],
    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 10 : ANGLES INSCRITS
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch06': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Angles inscrits et angles au centre',
        ordre: 1,
        contenu: r'''
1. LE VOCABULAIRE DU CERCLE

Une CORDE est un segment dont les deux extrémités sont sur le cercle.

Une corde partage le cercle en deux ARCS : le petit et le grand.

Le rayon relie le centre à un point du cercle. Le diamètre est une corde
qui passe par le centre.


2. L’ANGLE AU CENTRE

Un angle au centre a son SOMMET AU CENTRE du cercle.

L’angle au centre AOB, où O est le centre, INTERCEPTE l’arc AB.


3. L’ANGLE INSCRIT

Un angle inscrit a son SOMMET SUR LE CERCLE, et ses deux côtés coupent le
cercle en deux autres points.

L’angle AMB, avec M sur le cercle, intercepte l’arc AB qui ne contient
pas M.

Pour reconnaître un angle inscrit, deux conditions :
    le sommet est SUR le cercle
    les deux côtés recoupent le cercle


4. LA PROPRIÉTÉ FONDAMENTALE

Dans un cercle, l’angle au centre est le DOUBLE de tout angle inscrit qui
intercepte le même arc.

    mes AOB = 2 × mes AMB

Autrement dit, l’angle inscrit vaut la MOITIÉ de l’angle au centre :

    mes AMB = mes AOB / 2

Exemple : si l’angle au centre AOB mesure 80°, alors tout angle inscrit
interceptant l’arc AB mesure 40°.


5. CONSÉQUENCE : DEUX ANGLES INSCRITS ÉGAUX

Deux angles inscrits qui interceptent le MÊME ARC ont la même mesure.

C’est logique : ils valent tous les deux la moitié du même angle au
centre.

    si M et N sont sur le cercle, du même côté de la corde [AB],
    alors mes AMB = mes ANB

C’est une propriété très utile : peu importe où l’on place le sommet sur
l’arc, l’angle ne change pas.


6. CAS PARTICULIER : L’ANGLE DROIT

Si [AB] est un DIAMÈTRE du cercle, alors l’angle au centre AOB est un
angle plat, donc il mesure 180°.

Tout angle inscrit interceptant ce diamètre mesure donc 180 / 2 = 90°.

PROPRIÉTÉ : si M est un point d’un cercle de diamètre [AB], distinct de A
et de B, alors le triangle AMB est RECTANGLE en M.

La réciproque est vraie aussi : si un triangle AMB est rectangle en M,
alors M appartient au cercle de diamètre [AB].

C’est le lien entre ce chapitre et le triangle rectangle.


7. À QUOI CELA SERT

Ces propriétés permettent de calculer des angles sans rapporteur, de
démontrer qu’un triangle est rectangle, ou de prouver que quatre points
appartiennent à un même cercle.

Elles reviennent très régulièrement au BEPC, souvent combinées avec la
propriété de Pythagore ou celle de Thalès.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Reconnaître les angles sur un cercle',
        ordre: 1,
        contenu: r'''
LA QUESTION À SE POSER DEVANT LA FIGURE

Où est le SOMMET de l’angle ?

    au CENTRE du cercle  →  angle au centre
    SUR le cercle        →  angle inscrit
    ailleurs             →  ni l’un ni l’autre, la propriété ne s’applique
                            pas

C’est la première chose à vérifier, avant tout calcul.


REPÉRER L’ARC INTERCEPTÉ

L’arc intercepté est celui qui se trouve « à l’intérieur » de l’angle,
entre ses deux côtés.

Astuce : place ton doigt au sommet de l’angle, suis les deux côtés jusqu’au
cercle. L’arc situé en face, entre les deux points d’arrivée et sans
passer par ton doigt, c’est l’arc intercepté.


LA PROPRIÉTÉ, DANS LE BON SENS

    angle au centre = 2 × angle inscrit
    angle inscrit = angle au centre ÷ 2

Le CENTRE voit toujours plus GRAND. Retiens cela et tu ne te tromperas
jamais de sens.

    Angle au centre de 100° → angle inscrit de 50°
    Angle inscrit de 35°    → angle au centre de 70°

Si tu trouves un angle inscrit plus grand que l’angle au centre, tu as
divisé au lieu de multiplier, ou l’inverse.


DEUX ANGLES INSCRITS SUR LE MÊME ARC

Si tu vois plusieurs sommets sur le cercle, mais que les côtés aboutissent
aux MÊMES deux points, tous ces angles sont ÉGAUX.

    mes AMB = mes ANB = mes APB

C’est souvent la clé d’un exercice : un angle qu’on ne connaît pas est
égal à un angle qu’on connaît, parce qu’ils interceptent le même arc.


LE RÉFLEXE DU DIAMÈTRE

Dès que tu vois un DIAMÈTRE dans un exercice avec un cercle, pense
immédiatement : ANGLE DROIT.

    M sur le cercle de diamètre [AB]  →  triangle AMB rectangle en M

Et une fois que tu sais que le triangle est rectangle, tu peux utiliser
Pythagore et la trigonométrie. C’est très souvent le but caché de
l’exercice.

La réciproque sert dans l’autre sens : pour démontrer qu’un point est sur
un cercle, il suffit de montrer qu’il voit le diamètre sous un angle droit.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : appliquer la propriété à un angle dont le sommet n’est ni au
centre ni sur le cercle. Vérifie toujours la position du sommet.

Erreur 2 : multiplier au lieu de diviser. Le centre voit plus grand.

Erreur 3 : comparer deux angles inscrits qui n’interceptent PAS le même
arc. Ils n’ont alors aucune raison d’être égaux.

Erreur 4 : oublier de citer la propriété dans la rédaction. En géométrie,
la justification vaut autant que le résultat.


CONSEIL POUR LE BEPC

Sur ta figure, repasse en couleur l’arc intercepté. Tu verras
immédiatement quels angles se rapportent au même arc, et l’exercice se
déroulera tout seul.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Angles dans un cercle',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
Sur un cercle de centre O, on place trois points A, B et M.

L’angle au centre AOB mesure 76°, et le point M appartient au grand arc AB.

1) Quelle est la nature de l’angle AMB ? Justifie.
2) Calcule la mesure de l’angle AMB.
3) On place un quatrième point N sur le grand arc AB, distinct de M.
   Que peut-on dire de l’angle ANB ? Justifie.
''',
        solution: r'''
1) NATURE DE L’ANGLE AMB

Le point M appartient au cercle, et les deux côtés [MA) et [MB) de l’angle
recoupent le cercle en A et en B.

    L’angle AMB est un ANGLE INSCRIT dans le cercle.

Il intercepte l’arc AB qui ne contient pas M, c’est-à-dire le petit arc,
celui-là même qu’intercepte l’angle au centre AOB.


2) MESURE DE L’ANGLE AMB

L’angle au centre AOB et l’angle inscrit AMB interceptent le même arc AB.

D’après la propriété de l’angle inscrit, l’angle au centre est le double
de l’angle inscrit :

    mes AOB = 2 × mes AMB

Donc :

    mes AMB = mes AOB / 2
    mes AMB = 76 / 2
    mes AMB = 38°

    L’angle AMB mesure 38°.


3) L’ANGLE ANB

Le point N appartient lui aussi au cercle, sur le même arc que M. L’angle
ANB est donc également un angle inscrit, et il intercepte le MÊME arc AB
que l’angle AMB.

Deux angles inscrits qui interceptent le même arc ont la même mesure.

    mes ANB = mes AMB = 38°

    L’angle ANB mesure également 38°.


CE QU’IL FAUT RETENIR
La position exacte du sommet sur l’arc n’a aucune importance : tant qu’il
reste sur le même arc, l’angle inscrit garde la même mesure. C’est ce qui
rend cette propriété si puissante.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Le triangle caché dans le cercle',
        ordre: 2,
        difficulte: Difficulte.difficile,
        enonce: r'''
Soit un cercle de centre O et de diamètre [AB] tel que AB = 10 cm.

M est un point du cercle, distinct de A et de B, tel que AM = 6 cm.

1) Démontre que le triangle AMB est rectangle en M.
2) Calcule la longueur MB.
3) Calcule la mesure de l’angle MAB, arrondie au degré.
   On donne : cos 53° ≈ 0,6.
''',
        solution: r'''
1) LE TRIANGLE EST-IL RECTANGLE ?

Le point M appartient au cercle de diamètre [AB], et il est distinct de A
et de B.

D’après la propriété de l’angle inscrit dans un demi-cercle :

    si M est un point d’un cercle de diamètre [AB], distinct de A et B,
    alors le triangle AMB est rectangle en M.

    Le triangle AMB est donc RECTANGLE EN M.

On peut aussi le justifier autrement : [AB] étant un diamètre, l’angle au
centre AOB est un angle plat, il mesure 180°. L’angle inscrit AMB, qui
intercepte le même arc, mesure donc 180 / 2 = 90°.


2) LONGUEUR MB

Le triangle AMB est rectangle en M. D’après la propriété de Pythagore :

    AB² = AM² + MB²

On remplace par les valeurs connues :

    10² = 6² + MB²
    100 = 36 + MB²

On isole MB² :

    MB² = 100 - 36
    MB² = 64

Donc :

    MB = √64 = 8

    MB mesure 8 cm.

On reconnaît d’ailleurs le triplet 6 — 8 — 10, qui est un multiple du
triplet 3 — 4 — 5.


3) MESURE DE L’ANGLE MAB

Plaçons-nous dans le triangle AMB, rectangle en M, et considérons l’angle
en A.

    [AM] est le côté ADJACENT à cet angle
    [AB] est l’HYPOTÉNUSE

On utilise donc le cosinus :

    cos(MAB) = AM / AB
    cos(MAB) = 6 / 10
    cos(MAB) = 0,6

Or l’énoncé donne cos 53° ≈ 0,6.

    L’angle MAB mesure environ 53°.


VÉRIFICATION
La somme des angles d’un triangle vaut 180°. Ici :
    90° (en M) + 53° (en A) = 143°
Il reste 37° pour l’angle en B, ce qui est cohérent avec un triangle
rectangle dont les deux angles aigus sont complémentaires.


MÉTHODE À RETENIR POUR LE BEPC
Cet exercice enchaîne trois chapitres : angle inscrit pour établir l’angle
droit, Pythagore pour la longueur, trigonométrie pour l’angle. C’est la
structure typique d’un exercice de géométrie au BEPC. Dès que vous voyez
un diamètre, cherchez l’angle droit : il ouvre tout le reste.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Angles inscrits — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
RECONNAÎTRE LES ANGLES

    sommet AU CENTRE  →  angle au centre
    sommet SUR le cercle, côtés recoupant le cercle  →  angle inscrit


LA PROPRIÉTÉ FONDAMENTALE

Pour un même arc intercepté :

    angle au centre = 2 × angle inscrit
    angle inscrit = angle au centre ÷ 2

Le CENTRE voit toujours plus GRAND.


DEUX ANGLES INSCRITS SUR LE MÊME ARC

Ils ont la même mesure.

    mes AMB = mes ANB   si M et N sont sur le même arc

La position du sommet sur l’arc n’a pas d’importance.


LE CAS DU DIAMÈTRE

Si [AB] est un diamètre et M un point du cercle distinct de A et B :

    le triangle AMB est RECTANGLE EN M

Réciproque : si AMB est rectangle en M, alors M appartient au cercle de
diamètre [AB].


LE RÉFLEXE

Diamètre dans un exercice  →  angle droit  →  Pythagore et trigonométrie
deviennent utilisables.


LA PHRASE TYPE À RECOPIER

« Les angles AOB et AMB interceptent le même arc AB. D’après la propriété
de l’angle inscrit, mes AOB = 2 × mes AMB. »

« M appartient au cercle de diamètre [AB] et est distinct de A et de B.
Donc le triangle AMB est rectangle en M. »


LES PIÈGES

- appliquer la propriété à un sommet qui n’est ni au centre ni sur le
  cercle
- multiplier au lieu de diviser
- comparer deux angles inscrits qui n’interceptent pas le même arc
- oublier de justifier : en géométrie, la propriété citée vaut des points
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : les angles inscrits',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'ai1',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Dans un cercle, un angle au centre mesure 110°. Combien mesure '
                'un angle inscrit interceptant le même arc ? (Écris seulement '
                'le nombre de degrés)',
            reponseAttendue: '55',
            explication:
                'L\'angle inscrit vaut la moitié de l\'angle au centre : '
                '110 / 2 = 55°.',
          ),
          QuestionQuiz(
            id: 'ai2',
            type: TypeQuestion.qcm,
            enonce:
                'À quoi reconnaît-on un angle inscrit dans un cercle ?',
            choix: [
              'Son sommet est au centre du cercle',
              'Son sommet est sur le cercle et ses côtés recoupent le cercle',
              'Ses côtés sont deux rayons',
              'Il mesure toujours 90°',
            ],
            bonnesReponses: [1],
            explication:
                'Deux conditions : le sommet est SUR le cercle, et les deux '
                'côtés le recoupent. Si le sommet est au centre, c\'est un '
                'angle au centre.',
          ),
          QuestionQuiz(
            id: 'ai3',
            type: TypeQuestion.vraiFaux,
            enonce:
                'Si M est un point d\'un cercle de diamètre [AB], distinct de A '
                'et de B, alors le triangle AMB est rectangle en M.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication:
                'Le diamètre correspond à un angle au centre de 180°. L\'angle '
                'inscrit vaut donc 180 / 2 = 90°. C\'est une propriété très '
                'utilisée au BEPC.',
          ),
          QuestionQuiz(
            id: 'ai4',
            type: TypeQuestion.qcm,
            enonce:
                'Deux angles inscrits interceptent le même arc d\'un cercle. '
                'Que peut-on dire de leurs mesures ?',
            choix: [
              'Elles sont égales',
              'L\'une est le double de l\'autre',
              'Leur somme vaut 180°',
              'On ne peut rien dire',
            ],
            bonnesReponses: [0],
            explication:
                'Chacun vaut la moitié du même angle au centre : ils sont donc '
                'égaux, quelle que soit la position de leur sommet sur l\'arc.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 11 : VECTEURS
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch07': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Les vecteurs du plan',
        ordre: 1,
        contenu: r'''
1. QU’EST-CE QU’UN VECTEUR

Un vecteur représente un DÉPLACEMENT. Il est défini par trois éléments :

    sa DIRECTION   : la droite selon laquelle on se déplace
    son SENS       : dans quel sens on parcourt cette droite
    sa NORME       : la longueur du déplacement

Le vecteur qui va du point A au point B se note AB, avec une flèche.
Sa norme est la longueur AB.


2. ÉGALITÉ DE DEUX VECTEURS

Deux vecteurs sont ÉGAUX s’ils ont la même direction, le même sens et la
même norme.

Un vecteur ne dépend PAS de l’endroit où on le dessine. On peut le
déplacer librement dans le plan : il reste le même.

Propriété très utile :

    AB = DC   équivaut à dire que ABCD est un PARALLÉLOGRAMME

Attention à l’ordre des lettres : AB = DC, et non AB = CD.


3. LE VECTEUR NUL ET LE VECTEUR OPPOSÉ

Le vecteur nul, noté 0, est le vecteur AA : on ne se déplace pas.

L’opposé du vecteur AB est le vecteur BA : même direction, même norme,
mais SENS CONTRAIRE.

    BA = -AB


4. LA SOMME DE DEUX VECTEURS

Additionner deux vecteurs, c’est enchaîner deux déplacements.

LA RELATION DE CHASLES :

    AB + BC = AC

On part de A, on passe par B, on arrive en C. Le point intermédiaire
disparaît.

C’est la règle la plus utilisée du chapitre. Repérez-la : la lettre de fin
du premier vecteur doit être la lettre de début du second.

Autre méthode, la règle du parallélogramme : si les deux vecteurs partent
du même point, leur somme est la diagonale du parallélogramme qu’ils
forment.


5. LA DIFFÉRENCE DE DEUX VECTEURS

Soustraire un vecteur, c’est additionner son opposé :

    u - v = u + (-v)

Cas fréquent :

    AB - AC = AB + CA = CA + AB = CB


6. LE PRODUIT D’UN VECTEUR PAR UN NOMBRE RÉEL

Multiplier un vecteur u par un nombre réel k donne le vecteur ku.

    la DIRECTION reste la même
    la NORME est multipliée par |k|
    le SENS est conservé si k > 0, inversé si k < 0

Exemples :
    2u  : même sens, deux fois plus long
    -u  : sens contraire, même longueur
    0,5u : même sens, deux fois plus court


7. VECTEURS COLINÉAIRES

Deux vecteurs non nuls sont COLINÉAIRES s’ils ont la même DIRECTION,
autrement dit s’ils sont portés par des droites parallèles.

Traduction mathématique :

    u et v sont colinéaires   s’il existe un réel k tel que   v = ku

À quoi cela sert :

    AB et AC colinéaires  →  les points A, B et C sont ALIGNÉS
    AB et CD colinéaires  →  les droites (AB) et (CD) sont PARALLÈLES

C’est l’outil pour démontrer un alignement ou un parallélisme.


8. VECTEURS ORTHOGONAUX

Deux vecteurs sont ORTHOGONAUX si leurs directions sont perpendiculaires.

    AB et CD orthogonaux  →  les droites (AB) et (CD) sont
                             PERPENDICULAIRES


9. LE MILIEU D’UN SEGMENT

I est le milieu de [AB] si et seulement si :

    AI = IB

ou encore :

    IA + IB = 0

Cette dernière écriture est souvent la plus pratique dans les
démonstrations.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Chasles et colinéarité, pas à pas',
        ordre: 1,
        contenu: r'''
UN VECTEUR N’EST PAS UN POINT

C’est l’obstacle numéro un. Un vecteur, ce n’est pas un endroit : c’est un
DÉPLACEMENT, une instruction du type « avance de 3 vers la droite et de 2
vers le haut ».

Conséquence : le même vecteur peut être dessiné à des endroits différents
du plan. Deux flèches parallèles, de même longueur et de même sens,
représentent le MÊME vecteur.


LA RELATION DE CHASLES : L’IMAGE DU VOYAGE

    AB + BC = AC

Tu vas d’Abidjan à Yamoussoukro, puis de Yamoussoukro à Bouaké. Au total,
tu es allé d’Abidjan à Bouaké. Le point de passage disparaît.

LA RÈGLE DE RECONNAISSANCE : la lettre de FIN du premier vecteur doit être
la lettre de DÉBUT du second.

    AB + BC   →  le B se touche, ça marche  →  AC
    AB + CD   →  B et C ne se touchent pas  →  on ne peut pas simplifier

CHASLES DANS L’AUTRE SENS
On peut aussi COUPER un vecteur en insérant un point de passage :

    AC = AB + BC

C’est très utile quand on veut faire apparaître un point particulier dans
une démonstration.


LA DIFFÉRENCE : TRANSFORMER EN ADDITION

Ne cherche jamais à soustraire directement. Transforme d’abord.

    AB - AC

Remplace -AC par CA, son opposé :

    AB - AC = AB + CA

Puis réorganise pour que les lettres se touchent :

    = CA + AB = CB

Retiens ce résultat, il revient souvent : AB - AC = CB.


LE PRODUIT PAR UN RÉEL

    2u    deux fois plus long, même sens
    -u    même longueur, sens opposé
    -3u   trois fois plus long, sens opposé
    0,5u  moitié moins long, même sens

Le SIGNE gère le sens, la VALEUR ABSOLUE gère la longueur.


DÉMONTRER UN ALIGNEMENT

C’est l’exercice type. Pour montrer que A, B et C sont alignés :

Étape 1 — exprime les vecteurs AB et AC.
Étape 2 — cherche un réel k tel que AC = k AB.
Étape 3 — s’il existe, les vecteurs sont colinéaires, donc les points sont
alignés.

    Si AC = 3 AB, alors A, B et C sont alignés.

ATTENTION : les deux vecteurs doivent partir du MÊME point. AB et AC, ou
BA et BC, mais pas AB et CD.


DÉMONTRER UN PARALLÉLISME

Même principe, mais avec deux vecteurs qui ne partagent pas de point.

    Si CD = 2 AB, alors (AB) et (CD) sont parallèles.


DÉMONTRER QU’UN QUADRILATÈRE EST UN PARALLÉLOGRAMME

Il suffit de montrer que deux côtés opposés sont représentés par des
vecteurs égaux.

    AB = DC   →   ABCD est un parallélogramme

ATTENTION À L’ORDRE DES LETTRES. Pour ABCD, c’est AB = DC. Écrire AB = CD
donnerait un quadrilatère croisé, ce qui est faux.

Le moyen de contrôle : parcours le quadrilatère dans l’ordre A, B, C, D.
Les côtés [AB] et [DC] sont bien opposés et parcourus dans le même sens.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : appliquer Chasles quand les lettres ne se touchent pas.
Erreur 2 : écrire AB = CD au lieu de AB = DC pour un parallélogramme.
Erreur 3 : confondre le vecteur AB et la longueur AB. Le vecteur a une
flèche, la longueur est un nombre positif.
Erreur 4 : oublier que les vecteurs doivent partir du même point pour
conclure à un alignement.


CONSEIL POUR LE BEPC

Quand tu bloques, écris tous les vecteurs de l’énoncé en fonction de deux
vecteurs de base, souvent AB et AC. Presque tous les exercices se
débloquent ainsi.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Relation de Chasles et parallélogramme',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
1) Simplifie les expressions vectorielles suivantes :
   a) AB + BC
   b) MN + NP + PQ
   c) AB - AC

2) ABCD est un parallélogramme.
   a) Cite deux vecteurs égaux dans cette figure.
   b) Que vaut AB + AD ? Justifie.

3) Soit I le milieu du segment [AB].
   Écris une égalité vectorielle traduisant cette situation.
''',
        solution: r'''
1) SIMPLIFICATIONS

a) AB + BC

La lettre de fin du premier vecteur est B, et c’est aussi la lettre de
début du second. La relation de Chasles s’applique :

    AB + BC = AC


b) MN + NP + PQ

On applique Chasles deux fois de suite :

    MN + NP = MP
    puis MP + PQ = MQ

    MN + NP + PQ = MQ

Tous les points intermédiaires disparaissent : il ne reste que le premier
et le dernier.


c) AB - AC

On transforme la soustraction en addition, en remplaçant -AC par CA :

    AB - AC = AB + CA

On réorganise pour que les lettres se touchent :

    = CA + AB
    = CB

    AB - AC = CB


2) LE PARALLÉLOGRAMME ABCD

a) Dans un parallélogramme ABCD, les côtés opposés sont parallèles et de
même longueur, et parcourus dans le même sens :

    AB = DC        et        AD = BC

Attention à l’ordre des lettres : c’est bien AB = DC, et non AB = CD.


b) Calculons AB + AD.

D’après la question précédente, AD = BC. Remplaçons :

    AB + AD = AB + BC

Les lettres se touchent, on applique Chasles :

    AB + AD = AC

    La somme AB + AD est égale au vecteur AC, c’est-à-dire à la DIAGONALE
    du parallélogramme issue de A.

C’est la règle du parallélogramme : la somme de deux vecteurs issus d’un
même point est la diagonale du parallélogramme qu’ils construisent.


3) LE MILIEU

I est le milieu de [AB] signifie que le déplacement de A vers I est
exactement le même que celui de I vers B :

    AI = IB

On peut aussi l’écrire sous la forme :

    IA + IB = 0

Les deux écritures sont acceptées. La seconde est souvent plus commode
dans les démonstrations.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Démontrer un alignement',
        ordre: 2,
        difficulte: Difficulte.difficile,
        enonce: r'''
Soient A, B et C trois points non alignés du plan.

On définit les points M et N par :

    AM = 2 AB
    AN = 2 AC

1) Exprime le vecteur MN en fonction de AB et AC.
2) Exprime le vecteur BC en fonction de AB et AC.
3) Démontre que les droites (MN) et (BC) sont parallèles.
4) Quelle relation existe-t-il entre les longueurs MN et BC ?
''',
        solution: r'''
1) EXPRESSION DE MN

Pour faire apparaître le point A, dont on connaît les relations, on
utilise la relation de Chasles en insérant A comme point de passage :

    MN = MA + AN

Or MA est l’opposé de AM :

    MA = -AM = -2 AB

Et par hypothèse :

    AN = 2 AC

Donc :

    MN = -2 AB + 2 AC

On peut factoriser par 2 :

    MN = 2(AC - AB)


2) EXPRESSION DE BC

Même méthode, on insère le point A :

    BC = BA + AC

Or BA = -AB, donc :

    BC = -AB + AC
    BC = AC - AB


3) PARALLÉLISME DES DROITES (MN) ET (BC)

Comparons les deux résultats.

    MN = 2(AC - AB)
    BC = AC - AB

On en déduit immédiatement :

    MN = 2 BC

Il existe donc un réel k, ici k = 2, tel que MN = k BC.

Les vecteurs MN et BC sont donc COLINÉAIRES.

Deux vecteurs colinéaires ont la même direction, ce qui signifie que leurs
droites supports sont parallèles.

    CONCLUSION : les droites (MN) et (BC) sont parallèles.


4) RELATION ENTRE LES LONGUEURS

L’égalité MN = 2 BC porte sur les vecteurs. En passant aux normes,
c’est-à-dire aux longueurs :

    MN = 2 × BC

    La longueur MN est le DOUBLE de la longueur BC.


REMARQUE IMPORTANTE
On aurait pu obtenir le même résultat avec la propriété de Thalès : les
points M et N sont les images de B et C dans un agrandissement de rapport
2 de centre A. La méthode vectorielle est souvent plus rapide et se rédige
en moins de lignes.

MÉTHODE À RETENIR
Pour démontrer un parallélisme ou un alignement, exprimez toujours les
vecteurs en fonction de DEUX vecteurs de base, ici AB et AC. La relation
entre eux apparaît alors d’elle-même.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Vecteurs — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
DÉFINITION

Un vecteur est un DÉPLACEMENT, défini par :
    une direction, un sens, une norme

Il ne dépend pas de l’endroit où on le dessine.


LA RELATION DE CHASLES

    AB + BC = AC

La lettre de fin du premier doit être la lettre de début du second.
On peut aussi couper : AC = AB + BC, pour faire apparaître un point.


LA DIFFÉRENCE

    AB - AC = AB + CA = CB

On transforme toujours la soustraction en addition.


LE VECTEUR OPPOSÉ

    BA = -AB


LE PRODUIT PAR UN RÉEL

    ku : même direction
         norme multipliée par |k|
         même sens si k > 0, sens opposé si k < 0


COLINÉARITÉ

    u et v colinéaires  ⟺  il existe k tel que v = ku

    AB et AC colinéaires  →  A, B, C ALIGNÉS
    AB et CD colinéaires  →  (AB) // (CD)


PARALLÉLOGRAMME

    ABCD est un parallélogramme  ⟺  AB = DC

ATTENTION À L’ORDRE : AB = DC, jamais AB = CD.


MILIEU

    I milieu de [AB]  ⟺  AI = IB  ⟺  IA + IB = 0


RÈGLE DU PARALLÉLOGRAMME

    AB + AD = AC   dans le parallélogramme ABCD

La somme de deux vecteurs issus d’un même point est la diagonale.


LES PIÈGES

- appliquer Chasles quand les lettres ne se touchent pas
- écrire AB = CD au lieu de AB = DC
- confondre le vecteur AB et la longueur AB
- comparer des vecteurs qui ne partent pas du même point pour un
  alignement
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : les vecteurs',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'vec1',
            type: TypeQuestion.qcm,
            enonce: 'Que vaut la somme MN + NP ?',
            choix: ['MP', 'NP', 'PM', 'On ne peut pas simplifier'],
            bonnesReponses: [0],
            explication:
                'Relation de Chasles : la lettre de fin du premier vecteur (N) '
                'est la lettre de début du second. Le point intermédiaire '
                'disparaît, il reste MP.',
          ),
          QuestionQuiz(
            id: 'vec2',
            type: TypeQuestion.qcm,
            enonce:
                'ABCD est un parallélogramme. Quelle égalité vectorielle est '
                'correcte ?',
            choix: ['AB = CD', 'AB = DC', 'AB = BC', 'AC = BD'],
            bonnesReponses: [1],
            explication:
                'Dans le parallélogramme ABCD, les côtés [AB] et [DC] sont '
                'opposés et parcourus dans le même sens : AB = DC. Écrire '
                'AB = CD décrirait un quadrilatère croisé.',
          ),
          QuestionQuiz(
            id: 'vec3',
            type: TypeQuestion.vraiFaux,
            enonce:
                'Si AC = 3 AB, alors les points A, B et C sont alignés.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication:
                'Les vecteurs AC et AB sont colinéaires, et ils partent du même '
                'point A. Les trois points sont donc bien alignés.',
          ),
          QuestionQuiz(
            id: 'vec4',
            type: TypeQuestion.qcm,
            enonce: 'À quoi est égal le vecteur AB - AC ?',
            choix: ['BC', 'CB', 'AA', 'BA'],
            bonnesReponses: [1],
            explication:
                'AB - AC = AB + CA = CA + AB = CB. Un résultat à mémoriser : '
                'il revient très souvent dans les exercices.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 12 : COORDONNEES D’UN VECTEUR
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch11': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Coordonnées dans un repère',
        ordre: 1,
        contenu: r'''
1. LE REPÈRE DU PLAN

Un repère du plan est constitué d’un point O appelé ORIGINE et de deux
axes gradués sécants en O.

    l’axe horizontal est l’axe des ABSCISSES
    l’axe vertical est l’axe des ORDONNÉES

Tout point M du plan est alors repéré par un couple de nombres (x ; y)
appelé ses COORDONNÉES.

    x est l’abscisse, y est l’ordonnée

On écrit M(x ; y), avec un point-virgule.

Un repère est ORTHOGONAL si les deux axes sont perpendiculaires, et
ORTHONORMÉ s’ils sont de plus gradués avec la même unité.


2. COORDONNÉES D’UN VECTEUR

Soient A(xA ; yA) et B(xB ; yB) deux points du plan.

Les coordonnées du vecteur AB sont :

    AB (xB - xA ; yB - yA)

On soustrait TOUJOURS les coordonnées du point de DÉPART à celles du point
d’ARRIVÉE. L’ordre compte.

Exemple : A(1 ; 2) et B(5 ; 4).

    AB (5 - 1 ; 4 - 2) = AB (4 ; 2)

Lecture concrète : pour aller de A à B, on avance de 4 vers la droite et
de 2 vers le haut.


3. ÉGALITÉ DE DEUX VECTEURS

Deux vecteurs sont égaux si et seulement si leurs coordonnées sont égales,
une à une.

    u (x ; y) = v (x' ; y')   ⟺   x = x'  et  y = y'


4. OPÉRATIONS SUR LES COORDONNÉES

Soient u (x ; y) et v (x' ; y') deux vecteurs, et k un réel.

    u + v  a pour coordonnées  (x + x' ; y + y')
    u - v  a pour coordonnées  (x - x' ; y - y')
    ku     a pour coordonnées  (kx ; ky)

Tout se fait coordonnée par coordonnée : les abscisses ensemble, les
ordonnées ensemble.


5. COORDONNÉES DU MILIEU D’UN SEGMENT

Si I est le milieu de [AB], alors :

    xI = (xA + xB) / 2
    yI = (yA + yB) / 2

Le milieu a pour coordonnées la MOYENNE des coordonnées des extrémités.

Exemple : A(1 ; 2) et B(5 ; 4).

    xI = (1 + 5)/2 = 3
    yI = (2 + 4)/2 = 3

    I(3 ; 3)


6. DISTANCE DE DEUX POINTS

Dans un repère ORTHONORMÉ, la distance entre A(xA ; yA) et B(xB ; yB) est :

    AB = √[(xB - xA)² + (yB - yA)²]

Cette formule n’est rien d’autre que la propriété de Pythagore appliquée
au triangle rectangle dont [AB] est l’hypoténuse.

Exemple : A(1 ; 2) et B(5 ; 4).

    AB = √[(5-1)² + (4-2)²]
    AB = √[16 + 4]
    AB = √20 = 2√5

ATTENTION : cette formule n’est valable que dans un repère ORTHONORMÉ.


7. NORME D’UN VECTEUR

La norme d’un vecteur u (x ; y), notée ‖u‖, est sa longueur :

    ‖u‖ = √(x² + y²)


8. COLINÉARITÉ ET DÉTERMINANT

Soient u (x ; y) et v (x' ; y').

Le DÉTERMINANT de ces deux vecteurs est le nombre :

    det(u ; v) = xy' - yx'

PROPRIÉTÉ :

    u et v sont colinéaires   ⟺   xy' - yx' = 0

C’est le critère le plus rapide pour tester une colinéarité, donc un
alignement ou un parallélisme.

Exemple : u(2 ; 3) et v(4 ; 6).

    det = 2×6 - 3×4 = 12 - 12 = 0

Les vecteurs sont colinéaires. On vérifie d’ailleurs que v = 2u.

Moyen mnémotechnique : on multiplie en CROIX, puis on soustrait.


9. À QUOI CELA SERT

Avec les coordonnées, la géométrie devient du calcul :

    démontrer un alignement    →  déterminant nul
    démontrer un parallélisme  →  déterminant nul
    trouver un milieu          →  moyenne des coordonnées
    calculer une longueur      →  formule de la distance
    reconnaître un
    parallélogramme            →  égalité de deux vecteurs
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Calculer avec les coordonnées',
        ordre: 1,
        contenu: r'''
LE SENS DE LA SOUSTRACTION

    AB (xB - xA ; yB - yA)

ARRIVÉE moins DÉPART. Toujours dans cet ordre.

Le moyen de ne jamais se tromper : dans le nom du vecteur AB, la SECONDE
lettre est celle d’arrivée, et c’est elle qui vient EN PREMIER dans le
calcul.

Si tu inverses, tu obtiens le vecteur opposé, et tous tes résultats
suivants seront faux d’un signe.

Vérification rapide : regarde ta figure. Si B est à droite de A, l’abscisse
de AB doit être POSITIVE. Si B est plus haut, l’ordonnée doit être
positive.


MILIEU OU VECTEUR : NE PAS CONFONDRE

C’est l’erreur la plus fréquente du chapitre.

    Coordonnées du VECTEUR AB   →  on SOUSTRAIT :  (xB - xA ; yB - yA)
    Coordonnées du MILIEU de [AB] →  on ADDITIONNE et on DIVISE PAR 2 :
                                     ((xA + xB)/2 ; (yA + yB)/2)

Un vecteur peut avoir des coordonnées négatives. Un milieu est un POINT
situé entre A et B : ses coordonnées sont comprises entre celles de A et
celles de B. Si ce n’est pas le cas, tu as confondu les deux formules.


LA DISTANCE, C’EST PYTHAGORE DÉGUISÉ

    AB = √[(xB - xA)² + (yB - yA)²]

Pourquoi ? Parce qu’on construit un triangle rectangle : on avance
horizontalement de (xB - xA), puis verticalement de (yB - yA). Le segment
[AB] en est l’hypoténuse.

Deux remarques :
    les carrés rendent le résultat positif, donc l’ordre de soustraction
    n’a AUCUNE importance ici
    n’oublie jamais la racine carrée à la fin


LE DÉTERMINANT : LA MULTIPLICATION EN CROIX

Pour u(x ; y) et v(x' ; y') :

    det = xy' - yx'

Écris les coordonnées en colonnes :

    x    x'
    y    y'

Puis multiplie en croix : x × y' d’abord, moins y × x'.

    Si det = 0  →  les vecteurs sont COLINÉAIRES
    Si det ≠ 0  →  ils ne le sont pas

C’est plus rapide que de chercher le coefficient k, surtout avec des
nombres qui ne tombent pas juste.


LES TROIS DÉMONSTRATIONS TYPES

Démontrer que A, B, C sont ALIGNÉS :
    1. calcule les coordonnées de AB et AC
    2. calcule le déterminant
    3. s’il est nul, les vecteurs sont colinéaires, donc les points sont
       alignés

Démontrer que (AB) et (CD) sont PARALLÈLES :
    même méthode, avec les vecteurs AB et CD

Démontrer que ABCD est un PARALLÉLOGRAMME :
    1. calcule les coordonnées de AB et de DC
    2. si elles sont égales, alors AB = DC
    3. donc ABCD est un parallélogramme

    Autre méthode, souvent plus rapide : montre que [AC] et [BD] ont le
    MÊME MILIEU. Les diagonales d’un parallélogramme se coupent en leur
    milieu.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : soustraire dans le mauvais sens pour un vecteur.
Erreur 2 : appliquer la formule du milieu pour un vecteur, ou l’inverse.
Erreur 3 : oublier la racine carrée dans le calcul d’une distance.
Erreur 4 : utiliser la formule de distance dans un repère qui n’est pas
orthonormé. L’énoncé le précise toujours : lisez-le.
Erreur 5 : oublier de simplifier le radical final. √20 doit devenir 2√5.


CONSEIL POUR LE BEPC

Trace toujours la figure dans le repère, même si l’énoncé ne le demande
pas. Elle te permet de vérifier tous tes résultats d’un coup d'œil : un
milieu mal placé ou un vecteur qui pointe dans le mauvais sens se voit
immédiatement.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Vecteurs, milieu et distance',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
Le plan est muni d’un repère orthonormé.

On donne les points A(-2 ; 1), B(4 ; 3) et C(6 ; -1).

1) Calcule les coordonnées des vecteurs AB et AC.
2) Calcule les coordonnées du milieu I du segment [AB].
3) Calcule la distance AB. Donne le résultat sous la forme la plus simple.
4) Les points A, B et C sont-ils alignés ? Justifie par un calcul.
''',
        solution: r'''
1) COORDONNÉES DES VECTEURS

Rappel : AB (xB - xA ; yB - yA), soit arrivée moins départ.

Pour AB, avec A(-2 ; 1) et B(4 ; 3) :

    xAB = 4 - (-2) = 4 + 2 = 6
    yAB = 3 - 1 = 2

    AB (6 ; 2)

Pour AC, avec A(-2 ; 1) et C(6 ; -1) :

    xAC = 6 - (-2) = 8
    yAC = -1 - 1 = -2

    AC (8 ; -2)


2) MILIEU DE [AB]

Pour un milieu, on additionne et on divise par 2 :

    xI = (xA + xB) / 2 = (-2 + 4) / 2 = 2 / 2 = 1
    yI = (yA + yB) / 2 = (1 + 3) / 2 = 4 / 2 = 2

    I(1 ; 2)

Contrôle : les coordonnées de I sont bien comprises entre celles de A et
celles de B. C’est cohérent.


3) DISTANCE AB

Le repère est orthonormé, on peut donc appliquer la formule :

    AB = √[(xB - xA)² + (yB - yA)²]
    AB = √[6² + 2²]
    AB = √[36 + 4]
    AB = √40

On simplifie le radical : 40 = 4 × 10, et 4 est un carré parfait.

    AB = √4 × √10 = 2√10

    AB = 2√10   (soit environ 6,32)


4) ALIGNEMENT DE A, B ET C

Les points A, B et C sont alignés si et seulement si les vecteurs AB et AC
sont colinéaires.

On calcule le déterminant :

    det(AB ; AC) = xAB × yAC - yAB × xAC
    det = 6 × (-2) - 2 × 8
    det = -12 - 16
    det = -28

Le déterminant n’est pas nul.

    CONCLUSION : les vecteurs AB et AC ne sont pas colinéaires, donc les
    points A, B et C ne sont PAS alignés.

Ils forment donc un vrai triangle.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Le parallélogramme du géomètre',
        ordre: 2,
        difficulte: Difficulte.difficile,
        enonce: r'''
Le plan est muni d’un repère orthonormé, l’unité étant le mètre.

Un géomètre relève quatre bornes d’un terrain à Abobo :

    A(1 ; 2)    B(7 ; 4)    C(9 ; 8)    D(3 ; 6)

1) Démontre que le quadrilatère ABCD est un parallélogramme.
2) Calcule les coordonnées du point d’intersection de ses diagonales.
3) Calcule les longueurs AB et AD.
4) Le terrain est-il un losange ? Justifie.
''',
        solution: r'''
1) ABCD EST-IL UN PARALLÉLOGRAMME ?

Un quadrilatère ABCD est un parallélogramme si et seulement si AB = DC.

Calculons les coordonnées de ces deux vecteurs.

    AB (xB - xA ; yB - yA) = (7 - 1 ; 4 - 2) = AB (6 ; 2)

    DC (xC - xD ; yC - yD) = (9 - 3 ; 8 - 6) = DC (6 ; 2)

Les deux vecteurs ont exactement les mêmes coordonnées :

    AB = DC

    CONCLUSION : le quadrilatère ABCD est un PARALLÉLOGRAMME.

Attention à l’ordre des lettres : on compare bien AB et DC, pas AB et CD.


2) INTERSECTION DES DIAGONALES

Dans un parallélogramme, les diagonales se coupent en leur milieu. Le
point d’intersection est donc le milieu de [AC], qui est aussi celui de
[BD].

Milieu de [AC], avec A(1 ; 2) et C(9 ; 8) :

    x = (1 + 9) / 2 = 5
    y = (2 + 8) / 2 = 5

    Le point d’intersection est (5 ; 5).

Vérifions avec la diagonale [BD], B(7 ; 4) et D(3 ; 6) :

    x = (7 + 3) / 2 = 5
    y = (4 + 6) / 2 = 5

On retrouve bien (5 ; 5). Le résultat est confirmé, et cela valide aussi
la question 1.


3) LONGUEURS AB ET AD

Le repère est orthonormé.

    AB = √[(7-1)² + (4-2)²]
    AB = √[36 + 4]
    AB = √40 = 2√10

    AD = √[(3-1)² + (6-2)²]
    AD = √[4 + 16]
    AD = √20 = 2√5

    AB = 2√10 m   (environ 6,32 m)
    AD = 2√5 m    (environ 4,47 m)


4) LE TERRAIN EST-IL UN LOSANGE ?

Un losange est un parallélogramme dont tous les côtés ont la même
longueur. Il suffit donc de comparer deux côtés consécutifs.

    AB = 2√10 ≈ 6,32
    AD = 2√5  ≈ 4,47

Ces deux longueurs sont différentes.

    CONCLUSION : le terrain n’est PAS un losange. C’est un
    parallélogramme quelconque.


CE QU’IL FAUT RETENIR
Pour identifier précisément un quadrilatère :
    parallélogramme  →  AB = DC
    losange          →  parallélogramme + deux côtés consécutifs égaux
    rectangle        →  parallélogramme + diagonales de même longueur
    carré            →  les deux conditions à la fois
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Coordonnées — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
COORDONNÉES D’UN VECTEUR

    AB (xB - xA ; yB - yA)

ARRIVÉE moins DÉPART. La seconde lettre du nom vient en premier.


MILIEU D’UN SEGMENT

    I ((xA + xB)/2 ; (yA + yB)/2)

On ADDITIONNE et on divise par 2. À ne pas confondre avec le vecteur, où
l’on soustrait.


DISTANCE (repère ORTHONORMÉ uniquement)

    AB = √[(xB - xA)² + (yB - yA)²]

C’est Pythagore. Les carrés rendent l’ordre indifférent.
Ne pas oublier la racine, ni de simplifier le radical.


NORME D’UN VECTEUR

    ‖u‖ = √(x² + y²)


OPÉRATIONS

    u + v  →  (x + x' ; y + y')
    ku     →  (kx ; ky)

Coordonnée par coordonnée.


COLINÉARITÉ : LE DÉTERMINANT

    det(u ; v) = xy' - yx'

    det = 0  →  colinéaires
    det ≠ 0  →  non colinéaires

Multiplication en croix, puis soustraction.


LES TROIS DÉMONSTRATIONS TYPES

    A, B, C alignés      →  det(AB ; AC) = 0
    (AB) // (CD)         →  det(AB ; CD) = 0
    ABCD parallélogramme →  AB = DC
                            ou [AC] et [BD] ont le même milieu


IDENTIFIER UN QUADRILATÈRE

    parallélogramme  →  AB = DC
    losange          →  + deux côtés consécutifs égaux
    rectangle        →  + diagonales de même longueur
    carré            →  les deux


LES PIÈGES

- soustraire dans le mauvais sens
- confondre formule du vecteur et formule du milieu
- oublier la racine carrée dans une distance
- utiliser la distance dans un repère non orthonormé
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : les coordonnées',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'co1',
            type: TypeQuestion.qcm,
            enonce:
                'Soient A(2 ; 5) et B(7 ; 1). Quelles sont les coordonnées du '
                'vecteur AB ?',
            choix: ['(5 ; -4)', '(-5 ; 4)', '(9 ; 6)', '(4,5 ; 3)'],
            bonnesReponses: [0],
            explication:
                'AB (xB - xA ; yB - yA) = (7 - 2 ; 1 - 5) = (5 ; -4). '
                'La réponse (4,5 ; 3) correspondrait au MILIEU, pas au vecteur.',
          ),
          QuestionQuiz(
            id: 'co2',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Soient A(0 ; 0) et B(6 ; 8) dans un repère orthonormé. '
                'Combien vaut la distance AB ? (Écris seulement le nombre)',
            reponseAttendue: '10',
            explication:
                'AB = √(6² + 8²) = √(36 + 64) = √100 = 10. On reconnaît le '
                'triplet 6 — 8 — 10.',
          ),
          QuestionQuiz(
            id: 'co3',
            type: TypeQuestion.qcm,
            enonce:
                'Les vecteurs u(3 ; 6) et v(2 ; 4) sont-ils colinéaires ?',
            choix: [
              'Oui, car le déterminant vaut 0',
              'Non, car leurs coordonnées sont différentes',
              'Oui, car ils ont la même norme',
              'On ne peut pas le savoir',
            ],
            bonnesReponses: [0],
            explication:
                'det = 3×4 - 6×2 = 12 - 12 = 0, donc les vecteurs sont '
                'colinéaires. On vérifie d\'ailleurs que u = 1,5 v.',
          ),
          QuestionQuiz(
            id: 'co4',
            type: TypeQuestion.vraiFaux,
            enonce:
                'Le milieu du segment [AB] avec A(1 ; 3) et B(5 ; 7) a pour '
                'coordonnées (3 ; 5).',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication:
                'x = (1+5)/2 = 3 et y = (3+7)/2 = 5. Les coordonnées du milieu '
                'sont bien comprises entre celles de A et celles de B.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 13 : EQUATIONS DE DROITES
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch12': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Équations de droites',
        ordre: 1,
        contenu: r'''
1. LES DEUX FORMES D’ÉQUATION

Dans un repère du plan, toute droite admet une équation.

Cas général — la droite n’est pas verticale :

    y = ax + b

    a est le COEFFICIENT DIRECTEUR
    b est l’ORDONNÉE À L’ORIGINE

Cas particulier — la droite est VERTICALE :

    x = c

Une droite verticale n’a pas de coefficient directeur : elle ne peut pas
s’écrire sous la forme y = ax + b.

Cas particulier — la droite est HORIZONTALE :

    y = b       (c’est-à-dire a = 0)


2. CALCULER LE COEFFICIENT DIRECTEUR

Si la droite passe par deux points A(xA ; yA) et B(xB ; yB) avec
xA ≠ xB :

    a = (yB - yA) / (xB - xA)

C’est la variation des ordonnées divisée par la variation des abscisses.

Exemple : A(1 ; 3) et B(4 ; 9).

    a = (9 - 3) / (4 - 1) = 6 / 3 = 2


3. TROUVER L’ORDONNÉE À L’ORIGINE

Une fois a connu, on remplace les coordonnées d’un point dans l’équation.

Avec A(1 ; 3) et a = 2 :

    3 = 2 × 1 + b
    3 = 2 + b
    b = 1

    L’équation de la droite (AB) est   y = 2x + 1

VÉRIFICATION : on teste avec l’AUTRE point.
    Pour x = 4 : y = 2×4 + 1 = 9. C’est bien l’ordonnée de B.


4. SIGNIFICATION GRAPHIQUE

b est l’ordonnée du point où la droite coupe l’axe des ordonnées : le
point (0 ; b).

a indique la pente : quand on avance de 1 vers la droite, on monte de a.

    a > 0  →  la droite monte
    a < 0  →  la droite descend
    a = 0  →  la droite est horizontale


5. APPARTENANCE D’UN POINT À UNE DROITE

Un point M(x ; y) appartient à la droite d’équation y = ax + b si et
seulement si ses coordonnées VÉRIFIENT l’équation.

Exemple : le point M(3 ; 7) appartient-il à la droite y = 2x + 1 ?

    2 × 3 + 1 = 7

Oui, l’égalité est vérifiée : M appartient à la droite.

Pour N(5 ; 10) :
    2 × 5 + 1 = 11 ≠ 10
Non, N n’appartient pas à la droite.


6. DROITES PARALLÈLES

Deux droites non verticales sont PARALLÈLES si et seulement si elles ont
le MÊME COEFFICIENT DIRECTEUR.

    y = ax + b   et   y = a’x + b'   sont parallèles  ⟺  a = a'

Si de plus b = b', les droites sont confondues.

Exemple : y = 3x + 2 et y = 3x - 5 sont parallèles, mais distinctes.


7. DROITES PERPENDICULAIRES

Dans un repère ORTHONORMÉ, deux droites non verticales sont
PERPENDICULAIRES si et seulement si le produit de leurs coefficients
directeurs vaut -1 :

    a × a' = -1

Autrement dit :

    a' = -1 / a

Exemple : la perpendiculaire à y = 2x + 3 a pour coefficient directeur
-1/2, soit -0,5.

Moyen mnémotechnique : on prend l’INVERSE et on change le SIGNE.

    a = 3     →  a' = -1/3
    a = -1/4  →  a' = 4
    a = 1     →  a' = -1


8. POSITIONS RELATIVES DE DEUX DROITES

    a ≠ a'              →  les droites sont SÉCANTES, en un point unique
    a = a' et b ≠ b'    →  elles sont PARALLÈLES et distinctes
    a = a' et b = b'    →  elles sont CONFONDUES

Pour trouver le point d’intersection de deux droites sécantes, on résout
le système formé par leurs deux équations. C’est exactement ce qu’on a vu
au chapitre des systèmes.


9. TRACER UNE DROITE

Deux points suffisent.

Le plus rapide : partir de (0 ; b), puis avancer de 1 vers la droite et
monter de a. On obtient (1 ; a + b).

Pour une droite verticale x = c, on trace la parallèle à l’axe des
ordonnées passant par le point (c ; 0).
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Trouver et comparer des équations de droites',
        ordre: 1,
        contenu: r'''
LA MÉTHODE EN DEUX TEMPS

Trouver l’équation d’une droite passant par deux points, c’est toujours la
même chose.

    Temps 1 : calculer a
    Temps 2 : trouver b

Rien d’autre. Prenons A(2 ; 1) et B(5 ; 7).

Temps 1 :
    a = (7 - 1) / (5 - 2) = 6 / 3 = 2

Temps 2 : je remplace avec le point A.
    1 = 2 × 2 + b
    1 = 4 + b
    b = -3

    L’équation est y = 2x - 3

Temps 3, facultatif mais vivement conseillé : vérifie avec B.
    2 × 5 - 3 = 7. C’est bien l’ordonnée de B. Parfait.


LE PIÈGE DU CALCUL DE a

    a = (yB - yA) / (xB - xA)

Les y EN HAUT, les x EN BAS. Beaucoup d’élèves inversent.

Le moyen de retenir : a représente « de combien on MONTE quand on avance
de 1 ». La montée, ce sont les y ; l’avancée, ce sont les x. Montée
divisée par avancée.

Autre point de vigilance : garde le MÊME ordre en haut et en bas. Si tu
écris yB - yA au numérateur, tu dois écrire xB - xA au dénominateur, pas
l’inverse. Sinon tu obtiens l’opposé du bon résultat.

Vérification visuelle : si la droite monte, a doit être positif.


PARALLÈLES OU PERPENDICULAIRES : LE RÉFLEXE

    PARALLÈLES        →  a = a'          (même pente)
    PERPENDICULAIRES  →  a × a' = -1     (inverse et signe changé)

Pour trouver le coefficient d’une perpendiculaire, deux gestes :
    1. je retourne la fraction
    2. je change le signe

    a = 4      →  1/4  →  a' = -1/4
    a = -2/3   →  -3/2 →  a' = 3/2
    a = -1     →  -1   →  a' = 1

Contrôle : multiplie les deux, tu dois trouver exactement -1.


UN POINT APPARTIENT-IL À LA DROITE ?

Ne réfléchis pas, calcule. Remplace x par l’abscisse du point dans
l’équation, et compare le résultat à l’ordonnée.

    Droite y = 3x - 4, point M(2 ; 2)
    3 × 2 - 4 = 2
    L’ordonnée de M est 2. Donc M appartient à la droite.

Si les deux nombres diffèrent, le point n’y est pas. C’est aussi simple
que cela.


TROUVER LE POINT D’INTERSECTION DE DEUX DROITES

C’est un système à deux équations. Le plus rapide : égaler les deux
expressions de y.

    y = 2x + 1   et   y = -x + 7

    2x + 1 = -x + 7
    3x = 6
    x = 2

Puis on remplace dans l’une des deux équations :
    y = 2 × 2 + 1 = 5

    Le point d’intersection est (2 ; 5).

Vérifie dans la SECONDE équation : -2 + 7 = 5. Correct.


LA DROITE VERTICALE, LE CAS OUBLIÉ

Si xA = xB, la droite est VERTICALE. Le calcul de a donnerait une division
par zéro : impossible.

Son équation est simplement x = c, où c est l’abscisse commune.

    A(3 ; 1) et B(3 ; 8)  →  la droite (AB) a pour équation x = 3

Si dans un exercice tu obtiens une division par zéro, ne cherche pas
l’erreur : c’est que la droite est verticale.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : inverser les y et les x dans le calcul de a.
Erreur 2 : oublier de vérifier avec le second point.
Erreur 3 : pour une perpendiculaire, changer le signe sans inverser la
fraction, ou l’inverse.
Erreur 4 : appliquer la règle a × a' = -1 dans un repère non orthonormé.
Erreur 5 : oublier le cas de la droite verticale.


CONSEIL POUR LE BEPC

Après avoir trouvé une équation, teste-la toujours avec les deux points de
l’énoncé. Cette vérification prend vingt secondes et te garantit tous les
points de la question.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Déterminer une équation de droite',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
Le plan est muni d’un repère orthonormé.

1) Détermine l’équation de la droite (AB) passant par A(1 ; 4) et
   B(3 ; 10).

2) Le point M(5 ; 15) appartient-il à cette droite ? Justifie.

3) Les droites d’équations y = 3x - 2 et y = 3x + 7 sont-elles parallèles ?
   Justifie.

4) Donne le coefficient directeur d’une droite perpendiculaire à la droite
   d’équation y = -4x + 1.
''',
        solution: r'''
1) ÉQUATION DE LA DROITE (AB)

Étape 1 — le coefficient directeur.

    a = (yB - yA) / (xB - xA)
    a = (10 - 4) / (3 - 1)
    a = 6 / 2
    a = 3

Étape 2 — l’ordonnée à l’origine. On remplace avec le point A(1 ; 4) dans
l’équation y = 3x + b :

    4 = 3 × 1 + b
    4 = 3 + b
    b = 1

    L’équation de la droite (AB) est   y = 3x + 1

Vérification avec le point B :
    3 × 3 + 1 = 10. C’est bien l’ordonnée de B. ✓


2) LE POINT M APPARTIENT-IL À LA DROITE ?

On remplace x par 5 dans l’équation de la droite :

    y = 3 × 5 + 1 = 15 + 1 = 16

Or l’ordonnée de M est 15, et non 16.

    CONCLUSION : le point M(5 ; 15) n’appartient PAS à la droite (AB).


3) LES DROITES SONT-ELLES PARALLÈLES ?

    Pour y = 3x - 2, le coefficient directeur est a = 3.
    Pour y = 3x + 7, le coefficient directeur est a' = 3.

Les deux coefficients directeurs sont égaux.

    CONCLUSION : les deux droites sont PARALLÈLES.

Elles sont de plus distinctes, puisque leurs ordonnées à l’origine
diffèrent : -2 et 7.


4) COEFFICIENT DIRECTEUR D’UNE PERPENDICULAIRE

Le repère étant orthonormé, deux droites sont perpendiculaires si le
produit de leurs coefficients directeurs vaut -1 :

    a × a' = -1

Ici a = -4, donc :

    -4 × a' = -1
    a' = -1 / (-4)
    a' = 1/4

    Le coefficient directeur cherché est 1/4, soit 0,25.

Vérification : -4 × 1/4 = -1. ✓
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Le tracé de la route',
        ordre: 2,
        difficulte: Difficulte.examen,
        enonce: r'''
Le plan est muni d’un repère orthonormé, l’unité représentant 100 mètres.

Un ingénieur étudie le tracé de deux routes à Grand-Bassam.

    La route (D1) passe par les points A(-2 ; 1) et B(2 ; 9).
    La route (D2) a pour équation y = -0,5x + 6.

1) Détermine l’équation de la droite (D1).
2) Ces deux routes se croisent-elles ? Justifie.
3) Détermine les coordonnées du carrefour, c’est-à-dire du point
   d’intersection.
4) Les deux routes se coupent-elles à angle droit ? Justifie.
5) Un rond-point doit être construit sur (D1), à l’endroit où la route
   coupe l’axe des ordonnées. Donne ses coordonnées.
''',
        solution: r'''
1) ÉQUATION DE LA DROITE (D1)

Coefficient directeur, avec A(-2 ; 1) et B(2 ; 9) :

    a = (9 - 1) / (2 - (-2))
    a = 8 / 4
    a = 2

Ordonnée à l’origine, en remplaçant avec A(-2 ; 1) :

    1 = 2 × (-2) + b
    1 = -4 + b
    b = 5

    L’équation de (D1) est   y = 2x + 5

Vérification avec B : 2 × 2 + 5 = 9. ✓


2) LES ROUTES SE CROISENT-ELLES ?

    Coefficient directeur de (D1) : a = 2
    Coefficient directeur de (D2) : a' = -0,5

Comme 2 ≠ -0,5, les coefficients directeurs sont différents.

    CONCLUSION : les droites ne sont pas parallèles, elles sont donc
    SÉCANTES. Les deux routes se croisent bien, en un unique point.


3) COORDONNÉES DU CARREFOUR

Au point d’intersection, les deux équations donnent la même ordonnée. On
égale donc les deux expressions de y :

    2x + 5 = -0,5x + 6

On regroupe les x à gauche et les nombres à droite :

    2x + 0,5x = 6 - 5
    2,5x = 1
    x = 1 / 2,5
    x = 0,4

On remplace dans l’équation de (D1) :

    y = 2 × 0,4 + 5
    y = 0,8 + 5
    y = 5,8

    Le carrefour se situe au point de coordonnées (0,4 ; 5,8).

Vérification avec (D2) :
    -0,5 × 0,4 + 6 = -0,2 + 6 = 5,8 ✓

En unités réelles, le carrefour se trouve à 40 m et 580 m de l’origine.


4) LES ROUTES SE COUPENT-ELLES À ANGLE DROIT ?

Le repère est orthonormé. Deux droites sont perpendiculaires si et
seulement si le produit de leurs coefficients directeurs vaut -1.

    a × a' = 2 × (-0,5) = -1

Le produit vaut exactement -1.

    CONCLUSION : les deux routes se coupent bien À ANGLE DROIT.


5) POSITION DU ROND-POINT

Le rond-point est situé à l’intersection de (D1) avec l’axe des ordonnées.
Sur cet axe, l’abscisse est nulle : x = 0.

    y = 2 × 0 + 5 = 5

    Le rond-point se situe au point de coordonnées (0 ; 5).

On retrouve simplement l’ordonnée à l’origine b = 5, ce qui est logique :
b est par définition l’ordonnée du point où la droite coupe l’axe des
ordonnées.

En unités réelles, le rond-point se trouve à 500 m de l’origine sur l’axe
vertical.


CE QU’IL FAUT RETENIR POUR LE BEPC
Cet exercice enchaîne toutes les compétences du chapitre : déterminer une
équation, comparer des coefficients directeurs, résoudre un système par
égalisation, tester la perpendicularité, interpréter l’ordonnée à
l’origine. C’est la structure typique du dernier exercice du sujet.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Équations de droites — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
LES FORMES D’ÉQUATION

    y = ax + b     droite non verticale
    x = c          droite VERTICALE (pas de coefficient directeur)
    y = b          droite horizontale (a = 0)


LE COEFFICIENT DIRECTEUR

    a = (yB - yA) / (xB - xA)

Les y en HAUT, les x en BAS. Même ordre des deux côtés.

    a > 0  →  la droite monte
    a < 0  →  la droite descend
    a = 0  →  droite horizontale


TROUVER L’ÉQUATION EN DEUX TEMPS

    1. calculer a
    2. remplacer les coordonnées d’un point pour trouver b
    3. VÉRIFIER avec le second point


UN POINT APPARTIENT-IL À LA DROITE ?

Remplacer x dans l’équation et comparer le résultat à l’ordonnée du point.


PARALLÈLES

    a = a'                → parallèles
    a = a' et b = b'      → confondues
    a ≠ a'                → sécantes


PERPENDICULAIRES (repère orthonormé)

    a × a' = -1      soit      a' = -1/a

On INVERSE la fraction et on CHANGE le signe.

    a = 3     →  a' = -1/3
    a = -0,5  →  a' = 2


POINT D’INTERSECTION

On égale les deux expressions de y, on résout, puis on remplace pour
trouver y. On vérifie dans la seconde équation.


SIGNIFICATION DE b

b est l’ordonnée du point où la droite coupe l’axe des ordonnées : (0 ; b).


LES PIÈGES

- inverser les x et les y dans le calcul de a
- oublier de vérifier avec le second point
- changer le signe sans inverser la fraction pour une perpendiculaire
- oublier le cas de la droite verticale, quand xA = xB
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Teste-toi : les équations de droites',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'dr1',
            type: TypeQuestion.reponseCourte,
            enonce:
                'Une droite passe par A(0 ; 1) et B(2 ; 7). Quel est son '
                'coefficient directeur ? (Écris seulement le nombre)',
            reponseAttendue: '3',
            explication:
                'a = (7 - 1) / (2 - 0) = 6 / 2 = 3. Comme A a pour abscisse 0, '
                'on lit directement b = 1 : l\'équation est y = 3x + 1.',
          ),
          QuestionQuiz(
            id: 'dr2',
            type: TypeQuestion.qcm,
            enonce:
                'Quel est le coefficient directeur d\'une droite '
                'perpendiculaire à la droite d\'équation y = 5x - 2 ?',
            choix: ['-5', '5', '-1/5', '1/5'],
            bonnesReponses: [2],
            explication:
                'On inverse la fraction et on change le signe : a\' = -1/5. '
                'Vérification : 5 × (-1/5) = -1. ✓',
          ),
          QuestionQuiz(
            id: 'dr3',
            type: TypeQuestion.vraiFaux,
            enonce:
                'Les droites d\'équations y = -2x + 3 et y = -2x - 8 sont '
                'parallèles.',
            choix: ['Vrai', 'Faux'],
            bonnesReponses: [0],
            explication:
                'Elles ont le même coefficient directeur, -2. Elles sont donc '
                'parallèles, et distinctes puisque leurs ordonnées à l\'origine '
                'diffèrent.',
          ),
          QuestionQuiz(
            id: 'dr4',
            type: TypeQuestion.qcm,
            enonce:
                'Deux points A et B ont la même abscisse : A(4 ; 1) et B(4 ; 9). '
                'Quelle est l\'équation de la droite (AB) ?',
            choix: ['y = 4', 'x = 4', 'y = 4x', 'y = 2x + 1'],
            bonnesReponses: [1],
            explication:
                'Les deux points ont la même abscisse : la droite est '
                'VERTICALE. Elle n\'a pas de coefficient directeur et son '
                'équation est x = 4.',
          ),
        ],
      ),
    ],
    
    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 4 : TRIANGLE RECTANGLE
    //  ════════════════════════════════════════════════════════════════════
    '3e_math_ch04': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Triangle rectangle : Pythagore et trigonométrie',
        ordre: 1,
        contenu: r'''
1. LE THÉORÈME DE PYTHAGORE

Dans un triangle rectangle, le carré de la longueur de l’hypoténuse est
égal à la somme des carrés des longueurs des deux autres côtés.

Si ABC est rectangle en A, alors l’hypoténuse est [BC] et :

    BC² = AB² + AC²

L’hypoténuse est toujours le côté opposé à l’angle droit.


2. CALCULER UNE LONGUEUR

Si l’hypoténuse est connue et qu’un seul côté de l’angle droit est inconnu :

    AB² = BC² - AC²
    AB = √(BC² - AC²)

Exemple :
BC = 13 cm et AC = 5 cm.

    AB² = 13² - 5² = 169 - 25 = 144
    AB = 12 cm


3. LA RÉCIPROQUE DE PYTHAGORE

Pour démontrer qu’un triangle est rectangle, on compare le carré du plus
grand côté à la somme des carrés des deux autres.

Si BC est le plus grand côté et si :

    BC² = AB² + AC²

alors le triangle ABC est rectangle en A.


4. SINUS, COSINUS ET TANGENTE

Dans un triangle rectangle, pour un angle aigu α :

    sin(α) = côté opposé / hypoténuse
    cos(α) = côté adjacent / hypoténuse
    tan(α) = côté opposé / côté adjacent

Méthode :
1. repérer l’angle étudié ;
2. identifier le côté opposé, le côté adjacent et l’hypoténuse ;
3. choisir la relation qui contient les données et l’inconnue.


5. CALCULER UN ANGLE

Avec une calculatrice en mode degré :

    α = sin⁻¹(opposé / hypoténuse)
    α = cos⁻¹(adjacent / hypoténuse)
    α = tan⁻¹(opposé / adjacent)

Toujours vérifier que la calculatrice est en degrés.


6. CONTRÔLE DE COHÉRENCE

L’hypoténuse est le plus grand côté du triangle rectangle.
Une longueur ne peut pas être négative.
Pour un angle aigu, une mesure est comprise entre 0° et 90°.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Choisir entre Pythagore, sinus, cosinus et tangente',
        ordre: 1,
        contenu: r'''
LE BON RÉFLEXE

Tu dois d’abord regarder ce que l’exercice demande.

• On connaît deux côtés et on cherche le troisième → pense Pythagore.
• On cherche à prouver qu’un triangle est rectangle → pense réciproque de
  Pythagore.
• On connaît un angle aigu et un côté, et on cherche une autre longueur →
  pense trigonométrie.
• On connaît des longueurs et on cherche un angle → utilise une relation
  trigonométrique puis la touche inverse de la calculatrice.

ATTENTION AUX CÔTÉS

L’hypoténuse est toujours opposée à l’angle droit.
Le côté adjacent est celui qui touche l’angle étudié, mais qui n’est pas
l’hypoténuse.
Le côté opposé ne touche pas l’angle étudié.

ASTUCE

Écris toujours le petit tableau mental :

    sin = opposé / hypoténuse
    cos = adjacent / hypoténuse
    tan = opposé / adjacent

Puis choisis la formule qui contient les deux informations disponibles.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'La diagonale d’une cour',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
Une cour rectangulaire mesure 12 m de longueur et 5 m de largeur.

1) Modélise la diagonale par un triangle rectangle.
2) Calcule la longueur de la diagonale.
3) Donne une valeur au dixième près.
''',
        solution: r'''
La diagonale est l’hypoténuse du triangle rectangle formé par la longueur
et la largeur.

D’après Pythagore :

    d² = 12² + 5²
       = 144 + 25
       = 169

Donc :

    d = √169 = 13 m

La diagonale mesure exactement 13 m, donc au dixième près : 13,0 m.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Une rampe pour l’accessibilité',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''
Une rampe forme un triangle rectangle. Elle mesure 5 m de longueur et
permet de franchir une hauteur verticale de 1,2 m.

On note α l’angle entre la rampe et le sol.

1) Identifie l’hypoténuse et le côté opposé à α.
2) Choisis la relation trigonométrique adaptée.
3) Calcule α au degré près.
''',
        solution: r'''
L’hypoténuse est la rampe : 5 m.
Le côté opposé à α est la hauteur : 1,2 m.

On utilise le sinus :

    sin(α) = opposé / hypoténuse
           = 1,2 / 5
           = 0,24

Donc :

    α = sin⁻¹(0,24)
    α ≈ 13,9°

Au degré près :

    α ≈ 14°
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Fiche express — Triangle rectangle',
        ordre: 1,
        contenu: r'''
PYTHAGORE
Triangle rectangle en A :
    BC² = AB² + AC²

RÉCIPROQUE
Si BC est le plus grand côté et
    BC² = AB² + AC²
alors le triangle est rectangle en A.

TRIGONOMÉTRIE
    sin = opposé / hypoténuse
    cos = adjacent / hypoténuse
    tan = opposé / adjacent

AVANT DE CALCULER
• identifier l’angle droit ;
• repérer l’hypoténuse ;
• repérer l’angle étudié ;
• choisir la formule ;
• vérifier le mode degré de la calculatrice.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Quiz — Triangle rectangle',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'tr01',
            type: TypeQuestion.qcm,
            enonce: 'Dans un triangle rectangle, comment appelle-t-on le côté opposé à l’angle droit ?',
            choix: ['La médiane', 'L’hypoténuse', 'La hauteur', 'La bissectrice'],
            bonnesReponses: [1],
            explication: 'L’hypoténuse est le côté opposé à l’angle droit.',
          ),
          QuestionQuiz(
            id: 'tr02',
            type: TypeQuestion.qcm,
            enonce: 'Si BC est l’hypoténuse, quelle relation est correcte pour un triangle rectangle en A ?',
            choix: ['BC = AB + AC', 'BC² = AB² + AC²', 'AB² = BC² + AC²', 'BC² = AB² - AC²'],
            bonnesReponses: [1],
            explication: 'C’est le théorème de Pythagore.',
          ),
          QuestionQuiz(
            id: 'tr03',
            type: TypeQuestion.qcm,
            enonce: 'Pour un angle α, le sinus est égal à :',
            choix: ['adjacent / hypoténuse', 'opposé / hypoténuse', 'opposé / adjacent', 'hypoténuse / opposé'],
            bonnesReponses: [1],
            explication: 'sin(α) = côté opposé / hypoténuse.',
          ),
          QuestionQuiz(
            id: 'tr04',
            type: TypeQuestion.qcm,
            enonce: 'Avec AB = 6 cm et AC = 8 cm dans un triangle rectangle en A, BC vaut :',
            choix: ['10 cm', '12 cm', '14 cm', '2 cm'],
            bonnesReponses: [0],
            explication: 'BC² = 6² + 8² = 100, donc BC = 10 cm.',
          ),
        ],
      ),
    ],

    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 9 : PYRAMIDES ET CÔNES
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch09': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Pyramides et cônes',
        ordre: 1,
        contenu: r'''
1. LA PYRAMIDE

Une pyramide est un solide dont une face est un polygone appelé base et dont
les autres faces sont des triangles ayant un sommet commun : le sommet de
la pyramide.

Une pyramide régulière possède une base régulière et un sommet placé sur la
perpendiculaire passant par le centre de la base.


2. PATRON D’UNE PYRAMIDE

Un patron permet de déplier le solide sur le plan.
Il comprend la base et les faces latérales.

Pour construire un patron, il faut respecter les longueurs des arêtes et
les dimensions des faces.


3. VOLUME D’UNE PYRAMIDE

Le volume d’une pyramide est :

    V = (1/3) × Aire de la base × hauteur

La hauteur est la distance perpendiculaire entre le sommet et le plan de
la base.


4. LE CÔNE DE RÉVOLUTION

Un cône de révolution possède un disque comme base et un sommet situé sur
la perpendiculaire au centre de ce disque.

On distingue :
• r : rayon de la base ;
• h : hauteur ;
• g : génératrice.


5. VOLUME DU CÔNE

L’aire de la base vaut πr².

Donc :

    V = (1/3)πr²h


6. UNITÉS

Si les longueurs sont en cm, le volume est en cm³.
Si elles sont en m, le volume est en m³.

Avant d’utiliser une formule, convertis toutes les longueurs dans une même
unité.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Bien distinguer hauteur, rayon et génératrice',
        ordre: 1,
        contenu: r'''
NE CONFONDS PAS LES LONGUEURS

Dans un cône :
• le rayon va du centre du disque au bord du disque ;
• la hauteur est perpendiculaire à la base ;
• la génératrice relie le sommet à un point du cercle.

La génératrice n’est pas la hauteur.

POUR LE VOLUME

Pyramide :
    V = (1/3) × B × h

Cône :
    V = (1/3) × π × r² × h

Le facteur 1/3 est commun aux deux solides.

PIÈGE CLASSIQUE

Si le rayon est donné en cm et la hauteur en m, ne remplace pas directement
dans la formule. Convertis d’abord les deux longueurs dans la même unité.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Une pyramide à base carrée',
        ordre: 1,
        difficulte: Difficulte.facile,
        enonce: r'''
Une pyramide possède une base carrée de côté 6 cm et une hauteur de 10 cm.

Calcule son volume.
''',
        solution: r'''
Aire de la base :

    B = 6 × 6 = 36 cm²

Volume :

    V = (1/3) × 36 × 10
      = 120 cm³

Le volume de la pyramide est donc 120 cm³.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: 'Le volume d’un cône',
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''
Un cône de révolution a un rayon de base de 3 cm et une hauteur de 8 cm.

1) Écris la formule de son volume.
2) Calcule une valeur exacte en fonction de π.
3) Donne une valeur approchée au dixième près.
''',
        solution: r'''
La formule est :

    V = (1/3)πr²h

Avec r = 3 et h = 8 :

    V = (1/3) × π × 3² × 8
      = (1/3) × π × 9 × 8
      = 24π cm³

Avec π ≈ 3,14159 :

    V ≈ 75,4 cm³
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Fiche express — Pyramides et cônes',
        ordre: 1,
        contenu: r'''
PYRAMIDE
    V = (1/3) × aire de la base × hauteur

CÔNE
    V = (1/3)πr²h

À RETENIR
• hauteur = distance perpendiculaire à la base ;
• rayon = centre du disque vers le cercle ;
• génératrice ≠ hauteur ;
• utiliser des unités cohérentes ;
• conserver π dans une valeur exacte avant l’approximation.
''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: 'Quiz — Pyramides et cônes',
        ordre: 1,
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: 'pc01',
            type: TypeQuestion.qcm,
            enonce: 'Quelle est la formule du volume d’une pyramide ?',
            choix: ['B × h', '(1/2) × B × h', '(1/3) × B × h', '3 × B × h'],
            bonnesReponses: [2],
            explication: 'Le volume d’une pyramide vaut un tiers de l’aire de sa base multipliée par sa hauteur.',
          ),
          QuestionQuiz(
            id: 'pc02',
            type: TypeQuestion.qcm,
            enonce: 'Le volume d’un cône de rayon r et de hauteur h est :',
            choix: ['πrh', '(1/3)πr²h', '2πrh', 'πr²h'],
            bonnesReponses: [1],
            explication: 'La formule est V = (1/3)πr²h.',
          ),
          QuestionQuiz(
            id: 'pc03',
            type: TypeQuestion.qcm,
            enonce: 'Dans un cône, la hauteur est :',
            choix: ['toujours la génératrice', 'perpendiculaire à la base', 'le diamètre', 'le rayon'],
            bonnesReponses: [1],
            explication: 'La hauteur est la distance perpendiculaire du sommet au plan de la base.',
          ),
          QuestionQuiz(
            id: 'pc04',
            type: TypeQuestion.qcm,
            enonce: 'Une base carrée de côté 4 cm a quelle aire ?',
            choix: ['8 cm²', '12 cm²', '16 cm²', '20 cm²'],
            bonnesReponses: [2],
            explication: '4 × 4 = 16 cm².',
          ),
        ],
      ),
    ],
    '6e_math_ch01': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Nombres entiers naturels — cours",
        contenu: r'''Décomposer, comparer, ordonner et calculer avec les nombres entiers naturels. Dans une division euclidienne, dividende = diviseur × quotient + reste, avec un reste strictement inférieur au diviseur.

À RETENIR
Exemple : 248 = 12 × 20 + 8. Le quotient est 20 et le reste 8.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Nombres entiers naturels — comprendre facilement",
        contenu: r'''Exemple : 248 = 12 × 20 + 8. Le quotient est 20 et le reste 8.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Nombres entiers naturels — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''248 + 375''',
        solution: r'''248 = 12 × 20 + 8''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Nombres entiers naturels — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Nombres entiers naturels. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Nombres entiers naturels — fiche de révision",
        contenu: r'''MOTS-CLÉS : entiers • comparaison • opérations • division euclidienne

FORMULE / MÉTHODE : Exemple : 248 = 12 × 20 + 8. Le quotient est 20 et le reste 8.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Nombres entiers naturels — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e1q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Nombres entiers naturels ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e1q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Nombres entiers naturels permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e1q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch02': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Droites et points — cours",
        contenu: r'''Reconnaître et utiliser point, droite, segment et demi-droite. Deux points distincts déterminent une unique droite. Trois points sont alignés lorsqu’ils appartiennent à une même droite.

À RETENIR
La notation (AB) désigne une droite ; [AB] un segment ; [AB) une demi-droite d’origine A passant par B.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Droites et points — comprendre facilement",
        contenu: r'''La notation (AB) désigne une droite ; [AB] un segment ; [AB) une demi-droite d’origine A passant par B.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Droites et points — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''Deux points A et B déterminent combien de droites ?''',
        solution: r'''Une seule droite : (AB).''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Droites et points — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Droites et points. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Droites et points — fiche de révision",
        contenu: r'''MOTS-CLÉS : point • droite • segment • demi-droite

FORMULE / MÉTHODE : La notation (AB) désigne une droite ; [AB] un segment ; [AB) une demi-droite d’origine A passant par B.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Droites et points — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e2q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Droites et points ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e2q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Droites et points permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e2q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch03': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Nombres décimaux relatifs — cours",
        contenu: r'''Repérer, comparer et calculer avec les nombres décimaux relatifs. La valeur absolue |a| est la distance de a à zéro. Pour soustraire, on ajoute l’opposé.

À RETENIR
Pour comparer des nombres négatifs, le plus proche de zéro est le plus grand. Exemple : −3 > −8.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Nombres décimaux relatifs — comprendre facilement",
        contenu: r'''Pour comparer des nombres négatifs, le plus proche de zéro est le plus grand. Exemple : −3 > −8.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Nombres décimaux relatifs — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''−7 + 12 − 5''',
        solution: r'''0''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Nombres décimaux relatifs — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Nombres décimaux relatifs. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Nombres décimaux relatifs — fiche de révision",
        contenu: r'''MOTS-CLÉS : relatifs • opposé • valeur absolue • droite graduée

FORMULE / MÉTHODE : Pour comparer des nombres négatifs, le plus proche de zéro est le plus grand. Exemple : −3 > −8.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Nombres décimaux relatifs — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e3q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Nombres décimaux relatifs ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e3q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Nombres décimaux relatifs permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e3q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch04': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Segments — cours",
        contenu: r'''Connaître la longueur d’un segment, son milieu et sa médiatrice. Le milieu M vérifie AM = MB. La médiatrice est perpendiculaire au segment en son milieu.

À RETENIR
Tout point de la médiatrice d’un segment est à égale distance des deux extrémités.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Segments — comprendre facilement",
        contenu: r'''Tout point de la médiatrice d’un segment est à égale distance des deux extrémités.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Segments — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''AB = 10 cm, M milieu : AM = ?''',
        solution: r'''5 cm''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Segments — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Segments. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Segments — fiche de révision",
        contenu: r'''MOTS-CLÉS : segment • milieu • médiatrice • distance

FORMULE / MÉTHODE : Tout point de la médiatrice d’un segment est à égale distance des deux extrémités.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Segments — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e4q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Segments ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e4q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Segments permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e4q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch05': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Pavés droits et cylindres droits — cours",
        contenu: r'''Calculer le volume d’un pavé droit V = L×l×h et d’un cylindre V = πr²h. Pour un cylindre, le diamètre vaut 2r. Les unités doivent être cohérentes.

À RETENIR
Exemple : un pavé 8×5×3 a un volume de 120 cm³. Un cylindre de r=2 et h=10 a un volume de 40π cm³.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Pavés droits et cylindres droits — comprendre facilement",
        contenu: r'''Exemple : un pavé 8×5×3 a un volume de 120 cm³. Un cylindre de r=2 et h=10 a un volume de 40π cm³.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Pavés droits et cylindres droits — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''Volume d’un pavé 8×5×3''',
        solution: r'''120 cm³''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Pavés droits et cylindres droits — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Pavés droits et cylindres droits. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Pavés droits et cylindres droits — fiche de révision",
        contenu: r'''MOTS-CLÉS : pavé • cylindre • volume • rayon

FORMULE / MÉTHODE : Exemple : un pavé 8×5×3 a un volume de 120 cm³. Un cylindre de r=2 et h=10 a un volume de 40π cm³.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Pavés droits et cylindres droits — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e5q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Pavés droits et cylindres droits ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e5q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Pavés droits et cylindres droits permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e5q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch06': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Fractions — cours",
        contenu: r'''Lire, simplifier, comparer et additionner des fractions. Pour une addition, mettre au même dénominateur si nécessaire. Pour multiplier, multiplier numérateurs et dénominateurs.

À RETENIR
Exemple : 18/24 = 3/4. Pour 2/3 + 1/6, on obtient 4/6 + 1/6 = 5/6.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Fractions — comprendre facilement",
        contenu: r'''Exemple : 18/24 = 3/4. Pour 2/3 + 1/6, on obtient 4/6 + 1/6 = 5/6.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Fractions — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''Simplifie 18/24''',
        solution: r'''3/4''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Fractions — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Fractions. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Fractions — fiche de révision",
        contenu: r'''MOTS-CLÉS : numérateur • dénominateur • simplification • fractions équivalentes

FORMULE / MÉTHODE : Exemple : 18/24 = 3/4. Pour 2/3 + 1/6, on obtient 4/6 + 1/6 = 5/6.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Fractions — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e6q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Fractions ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e6q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Fractions permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e6q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch07': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Cercles et disques — cours",
        contenu: r'''Identifier centre, rayon, diamètre et disque. Le diamètre d=2r. La longueur du cercle vaut 2πr et l’aire du disque πr².

À RETENIR
Ne confonds pas périmètre et aire : la longueur du cercle est en unités de longueur, l’aire du disque en unités carrées.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Cercles et disques — comprendre facilement",
        contenu: r'''Ne confonds pas périmètre et aire : la longueur du cercle est en unités de longueur, l’aire du disque en unités carrées.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Cercles et disques — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''Rayon 5 cm : aire du disque ?''',
        solution: r'''25π cm²''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Cercles et disques — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Cercles et disques. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Cercles et disques — fiche de révision",
        contenu: r'''MOTS-CLÉS : centre • rayon • diamètre • aire • longueur

FORMULE / MÉTHODE : Ne confonds pas périmètre et aire : la longueur du cercle est en unités de longueur, l’aire du disque en unités carrées.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Cercles et disques — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e7q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Cercles et disques ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e7q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Cercles et disques permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e7q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch08': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Angles — cours",
        contenu: r'''Mesurer et construire des angles en degrés. Aigu <90°, droit =90°, obtus entre 90° et 180°, plat =180°. Deux angles complémentaires totalisent 90° et deux supplémentaires 180°.

À RETENIR
Avec un rapporteur, place son centre sur le sommet et une graduation zéro sur un côté de l’angle.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Angles — comprendre facilement",
        contenu: r'''Avec un rapporteur, place son centre sur le sommet et une graduation zéro sur un côté de l’angle.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Angles — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''Complément de 28° ?''',
        solution: r'''62°''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Angles — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Angles. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Angles — fiche de révision",
        contenu: r'''MOTS-CLÉS : aigu • droit • obtus • complémentaire • supplémentaire

FORMULE / MÉTHODE : Avec un rapporteur, place son centre sur le sommet et une graduation zéro sur un côté de l’angle.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Angles — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e8q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Angles ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e8q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Angles permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e8q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch09': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Triangles — cours",
        contenu: r'''Un triangle a trois angles dont la somme est 180°. Un équilatéral a trois côtés égaux, un isocèle au moins deux, un rectangle possède un angle droit.

À RETENIR
Dans un triangle, l’angle inconnu vaut 180° moins la somme des deux angles connus. Dans un isocèle, les angles à la base sont égaux.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Triangles — comprendre facilement",
        contenu: r'''Dans un triangle, l’angle inconnu vaut 180° moins la somme des deux angles connus. Dans un isocèle, les angles à la base sont égaux.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Triangles — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''Angles 48° et 67° : troisième angle ?''',
        solution: r'''65°''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Triangles — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Triangles. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Triangles — fiche de révision",
        contenu: r'''MOTS-CLÉS : triangle • équilatéral • isocèle • rectangle

FORMULE / MÉTHODE : Dans un triangle, l’angle inconnu vaut 180° moins la somme des deux angles connus. Dans un isocèle, les angles à la base sont égaux.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Triangles — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e9q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Triangles ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e9q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Triangles permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e9q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch10': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Proportionnalité — cours",
        contenu: r'''Deux grandeurs sont proportionnelles si un même coefficient permet de passer de l’une à l’autre. On peut utiliser passage à l’unité, tableau ou produit en croix.

À RETENIR
Exemple : 4 kg coûtent 2 400 F ; 1 kg coûte 600 F et 7 kg coûtent 4 200 F.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Proportionnalité — comprendre facilement",
        contenu: r'''Exemple : 4 kg coûtent 2 400 F ; 1 kg coûte 600 F et 7 kg coûtent 4 200 F.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Proportionnalité — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''4 kg = 2 400 F ; 7 kg = ?''',
        solution: r'''4 200 F''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Proportionnalité — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Proportionnalité. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Proportionnalité — fiche de révision",
        contenu: r'''MOTS-CLÉS : coefficient • tableau • pourcentage • produit en croix

FORMULE / MÉTHODE : Exemple : 4 kg coûtent 2 400 F ; 1 kg coûte 600 F et 7 kg coûtent 4 200 F.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Proportionnalité — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e10q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Proportionnalité ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e10q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Proportionnalité permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e10q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch11': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Figures symétriques par rapport à un point — cours",
        contenu: r'''Dans une symétrie centrale de centre O, A devient A' avec O milieu de [AA']. La transformation conserve longueurs, angles et parallélisme.

À RETENIR
Pour construire A', trace (AO) puis reporte OA de l’autre côté de O. Ainsi OA = OA'.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Figures symétriques par rapport à un point — comprendre facilement",
        contenu: r'''Pour construire A', trace (AO) puis reporte OA de l’autre côté de O. Ainsi OA = OA'.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Figures symétriques par rapport à un point — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''OA = 4 cm : où placer A' ?''',
        solution: r'''À 4 cm de O sur la droite (AO), de l’autre côté de O.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Figures symétriques par rapport à un point — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Figures symétriques par rapport à un point. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Figures symétriques par rapport à un point — fiche de révision",
        contenu: r'''MOTS-CLÉS : symétrie centrale • centre • image • milieu

FORMULE / MÉTHODE : Pour construire A', trace (AO) puis reporte OA de l’autre côté de O. Ainsi OA = OA'.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Figures symétriques par rapport à un point — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e11q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Figures symétriques par rapport à un point ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e11q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Figures symétriques par rapport à un point permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e11q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch12': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Statistique — cours",
        contenu: r'''Une série statistique contient une population, un caractère et des effectifs. L’effectif total est la somme des effectifs. La fréquence est effectif ÷ effectif total.

À RETENIR
Exemple : 12 élèves sur 30 viennent à pied. Fréquence = 12/30 = 40 %.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Statistique — comprendre facilement",
        contenu: r'''Exemple : 12 élèves sur 30 viennent à pied. Fréquence = 12/30 = 40 %.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Statistique — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''12 élèves sur 30 : fréquence ?''',
        solution: r'''40 %''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Statistique — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Statistique. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Statistique — fiche de révision",
        contenu: r'''MOTS-CLÉS : population • caractère • effectif • fréquence

FORMULE / MÉTHODE : Exemple : 12 élèves sur 30 viennent à pied. Fréquence = 12/30 = 40 %.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Statistique — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e12q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Statistique ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e12q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Statistique permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e12q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],
    '6e_math_ch13': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: "Parallélogramme — cours",
        contenu: r'''Un parallélogramme est un quadrilatère dont les côtés opposés sont parallèles. Les côtés opposés ont même longueur et les diagonales se coupent en leur milieu.

À RETENIR
Deux angles consécutifs sont supplémentaires. Rectangle, losange et carré sont des parallélogrammes particuliers.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: "Parallélogramme — comprendre facilement",
        contenu: r'''Deux angles consécutifs sont supplémentaires. Rectangle, losange et carré sont des parallélogrammes particuliers.

Réflexe : lis les données, choisis la propriété adaptée, calcule proprement puis vérifie.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Parallélogramme — exercice guidé",
        difficulte: Difficulte.facile,
        enonce: r'''ABCD parallélogramme, AB=7 cm : CD = ?''',
        solution: r'''7 cm''',
      ),
      RessourceOfficielle(
        type: TypeRessource.exercice,
        titre: "Parallélogramme — exercice d’application",
        ordre: 2,
        difficulte: Difficulte.moyen,
        enonce: r'''Explique avec une propriété du chapitre comment résoudre cette situation de Parallélogramme. Donne les étapes de calcul et une conclusion.''',
        solution: r'''On identifie les données, on choisit la propriété étudiée dans le cours, on effectue le calcul étape par étape puis on vérifie que le résultat est cohérent avec les données.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: "Parallélogramme — fiche de révision",
        contenu: r'''MOTS-CLÉS : côtés opposés • diagonales • parallélisme • angles

FORMULE / MÉTHODE : Deux angles consécutifs sont supplémentaires. Rectangle, losange et carré sont des parallélogrammes particuliers.

RÉFLEXE : identifier les données → choisir la propriété → calculer → vérifier.''',
      ),
      RessourceOfficielle(
        type: TypeRessource.quiz,
        titre: "Parallélogramme — quiz",
        dureeMinutes: 5,
        questions: [
          QuestionQuiz(
            id: '6e13q1',
            type: TypeQuestion.qcm,
            enonce: "Quelle affirmation est correcte à propos de Parallélogramme ?",
            choix: ["Elle respecte les propriétés étudiées","Elle n’a aucune propriété","Elle est toujours impossible","Elle ne se calcule jamais"],
            bonnesReponses: [0],
            explication: "La première proposition correspond aux propriétés essentielles du chapitre.",
          ),
          QuestionQuiz(
            id: '6e13q2',
            type: TypeQuestion.vraiFaux,
            enonce: "Les règles et propriétés de Parallélogramme permettent de justifier un calcul.",
            choix: ["Vrai","Faux"],
            bonnesReponses: [0],
            explication: "Une réponse mathématique doit être justifiée par une propriété ou une méthode.",
          ),
          QuestionQuiz(
            id: '6e13q3',
            type: TypeQuestion.qcm,
            enonce: "Quelle démarche faut-il privilégier ?",
            choix: ["Identifier les données puis choisir la propriété adaptée","Répondre au hasard","Ignorer les unités","Ne jamais vérifier"],
            bonnesReponses: [0],
            explication: "On identifie les données, choisit une méthode puis vérifie le résultat.",
          ),
        ],
      ),
    ],


    'Tle_A2_math_ch01': _mathTleA2Chapitre(
      code:'ch01', titre:'Étude de fonctions polynômes et de fonctions rationnelles',
      cours:r'''Une fonction polynôme est définie sur ℝ par une expression polynomiale. Une fonction rationnelle est un quotient de polynômes et son domaine exclut les zéros du dénominateur. L’étude porte notamment sur le domaine, les limites, le signe, les dérivées et les variations.''',
      renforcement:r'''Pour une fonction rationnelle, commence par déterminer les valeurs interdites. Pour l’étude d’une fonction, organise les calculs : domaine → limites → dérivée → signe → variations → représentation graphique.''',
      enonce1:r'''Détermine le domaine de f(x)=(2x+1)/(x−3).''', solution1:r'''D_f=ℝ\{3}, car le dénominateur ne doit pas être nul.''',
      enonce2:r'''Dérive f(x)=x³−2x²+4x−1.''', solution2:r'''f’(x)=3x²−4x+4.''',
      motsCles:'polynôme • rationnelle • domaine • limite • dérivée • signe • variation',
      quiz1:'Que faut-il déterminer en priorité pour une fonction rationnelle ?', quizBonne:'Les valeurs qui annulent le dénominateur',
    ),
    'Tle_A2_math_ch02': _mathTleA2Chapitre(
      code:'ch02', titre:'Probabilité',
      cours:r'''Une expérience aléatoire possède des issues auxquelles sont associées des probabilités. La somme des probabilités de toutes les issues vaut 1. On utilise les événements, l’union, l’intersection et, selon les situations, les probabilités conditionnelles.''',
      renforcement:r'''Commence par identifier l’univers et les événements. Vérifie que les probabilités sont comprises entre 0 et 1 et que la somme des probabilités des issues élémentaires vaut 1.''',
      enonce1:r'''Une urne contient 3 boules rouges et 2 boules bleues. On tire une boule au hasard. Probabilité d’obtenir une rouge ?''', solution1:r'''P(R)=3/5.''',
      enonce2:r'''Deux événements A et B sont incompatibles avec P(A)=0,4 et P(B)=0,3. Calcule P(A∪B).''', solution2:r'''Comme A et B sont incompatibles, P(A∪B)=P(A)+P(B)=0,7.''',
      motsCles:'expérience aléatoire • issue • événement • probabilité • union • intersection',
      quiz1:'Quelle valeur doit avoir la somme des probabilités de toutes les issues ?', quizBonne:'1',
    ),
    'Tle_A2_math_ch03': _mathTleA2Chapitre(
      code:'ch03', titre:'Fonction logarithme népérien',
      cours:r'''La fonction logarithme népérien, notée ln, est définie sur ]0;+∞[. Elle vérifie notamment ln(ab)=ln(a)+ln(b), ln(a/b)=ln(a)−ln(b) et ln(a^n)=n ln(a) pour a>0. Elle est strictement croissante.''',
      renforcement:r'''Avant tout calcul avec ln, vérifie que chaque argument est strictement positif. Pour une équation logarithmique, utilise les propriétés de ln puis contrôle les conditions de définition.''',
      enonce1:r'''Calcule ln(e³).''', solution1:r'''ln(e³)=3.''',
      enonce2:r'''Résous ln(x)=2.''', solution2:r'''Par définition de l’exponentielle, x=e², avec x>0.''',
      motsCles:'ln • logarithme népérien • domaine • propriétés • équation',
      quiz1:'Sur quel ensemble la fonction ln est-elle définie ?', quizBonne:']0;+∞[',
    ),
    'Tle_A2_math_ch04': _mathTleA2Chapitre(
      code:'ch04', titre:'Fonction exponentielle népérienne',
      cours:r'''La fonction exponentielle, notée exp ou e^x, est définie sur ℝ, strictement positive et strictement croissante. Elle vérifie e^(a+b)=e^a e^b et est la fonction réciproque du logarithme népérien.''',
      renforcement:r'''Utilise e^(a+b)=e^a e^b et e^(−a)=1/e^a. Pour résoudre une équation exponentielle, cherche à écrire les deux membres avec une même base ou applique ln lorsque les deux membres sont positifs.''',
      enonce1:r'''Simplifie e²×e⁵.''', solution1:r'''e²×e⁵=e⁷.''',
      enonce2:r'''Résous e^x=5.''', solution2:r'''x=ln(5).''',
      motsCles:'exponentielle • e^x • croissance • ln • propriétés',
      quiz1:'Quelle propriété est correcte ?', quizBonne:'e^(a+b)=e^a×e^b',
    ),
    'Tle_A2_math_ch05': _mathTleA2Chapitre(
      code:'ch05', titre:'Statistique à deux variables',
      cours:r'''Une série statistique à deux variables étudie deux caractères observés sur une même population. Le nuage de points permet de visualiser une relation. On peut utiliser la covariance, le coefficient de corrélation et une droite d’ajustement pour décrire une tendance.''',
      renforcement:r'''Commence par organiser les couples de données. Observe le nuage de points puis interprète la tendance. Le coefficient de corrélation mesure la force d’une liaison linéaire, sans prouver à lui seul une causalité.''',
      enonce1:r'''Une série comporte les couples (1,2), (2,4), (3,6). Quelle relation simple semble relier x et y ?''', solution1:r'''Les points sont alignés sur y=2x.''',
      enonce2:r'''Que signifie un nuage de points fortement proche d’une droite croissante ?''', solution2:r'''Il indique une liaison linéaire positive forte entre les deux variables.''',
      motsCles:'deux variables • nuage de points • corrélation • ajustement • droite',
      quiz1:'Que représente un nuage de points en statistique à deux variables ?', quizBonne:'Les couples de valeurs observés',
    ),
    'Tle_A2_math_ch06': _mathTleA2Chapitre(
      code:'ch06', titre:'Suites numériques',
      cours:r'''Une suite numérique associe à chaque entier naturel un nombre réel. Une suite peut être définie explicitement ou par récurrence. On étudie notamment ses variations et sa convergence. Les suites arithmétiques et géométriques constituent des modèles fondamentaux.''',
      renforcement:r'''Identifie d’abord le mode de définition. Pour une suite arithmétique, la différence entre deux termes consécutifs est constante. Pour une suite géométrique, le quotient de deux termes consécutifs est constant lorsque les termes concernés sont non nuls.''',
      enonce1:r'''Soit u_n=3n+2. Calcule u_5.''', solution1:r'''u_5=3×5+2=17.''',
      enonce2:r'''Une suite arithmétique vérifie u_1=4 et r=3. Calcule u_6.''', solution2:r'''u_6=u_1+5r=4+15=19.''',
      motsCles:'suite • terme • récurrence • arithmétique • géométrique • convergence',
      quiz1:'Dans une suite arithmétique, quelle grandeur reste constante ?', quizBonne:'La différence entre deux termes consécutifs',
    ),
    'Tle_A2_math_ch07': _mathTleA2Chapitre(
      code:'ch07', titre:'Systèmes d’équations linéaires dans ℝ × ℝ',
      cours:r'''Un système linéaire à deux inconnues cherche les couples (x,y) satisfaisant simultanément deux équations. On peut utiliser la substitution, la combinaison linéaire ou une interprétation graphique par deux droites.''',
      renforcement:r'''Choisis la méthode qui réduit le plus simplement le système. Après résolution, remplace le couple obtenu dans les deux équations pour vérifier.''',
      enonce1:r'''Résous x+y=7 et x−y=1.''', solution1:r'''En additionnant les deux équations, 2x=8 donc x=4 et y=3.''',
      enonce2:r'''Résous 2x+y=8 et x−y=1.''', solution2:r'''De x−y=1, y=x−1. Donc 2x+x−1=8, soit x=3 et y=2.''',
      motsCles:'système • équation linéaire • substitution • combinaison • solution',
      quiz1:'Graphiquement, que représente la solution d’un système de deux droites sécantes ?', quizBonne:'Le point d’intersection',
    ),


    'Tle_C_math_ch01': _mathTleCChapitre(
      code:'ch01', titre:'Barycentre et lignes de niveaux',
      cours:r'''Le barycentre permet de définir un point associé à des points pondérés. Dans le plan, il généralise le milieu et permet d’étudier des relations vectorielles. Les lignes de niveaux sont des ensembles de points vérifiant une condition donnée, souvent exprimée à l’aide de distances ou de produits scalaires.''',
      renforcement:r'''Traduis la condition géométrique sous forme vectorielle ou algébrique. Identifie les coefficients du barycentre, puis simplifie l’expression pour caractériser l’ensemble des points recherchés.''',
      enonce1:r'''Soient A et B et des coefficients 2 et 1. Écris le vecteur position du barycentre G dans un repère.''', solution1:r'''Si les vecteurs sont définis par rapport à O, on a OG=(2OA+OB)/3.''',
      enonce2:r'''Caractérise l’ensemble des points M tels que MA²−MB²=0.''', solution2:r'''MA=MB, donc M appartient à la médiatrice de [AB].''',
      motsCles:'barycentre • coefficients • vecteurs • ligne de niveau • distances',
      quiz1:'Quel point généralise le milieu de deux points pondérés ?', quizBonne:'Le barycentre',
    ),
    'Tle_C_math_ch02': _mathTleCChapitre(
      code:'ch02', titre:'Limites et continuité',
      cours:r'''La limite décrit le comportement d’une fonction lorsqu’une variable se rapproche d’un nombre ou tend vers l’infini. Une fonction est continue en a lorsque sa limite en a existe et vaut f(a). Les théorèmes de comparaison, les opérations sur les limites et les formes indéterminées permettent de conduire une étude rigoureuse.''',
      renforcement:r'''Commence par identifier le domaine et le point étudié. En présence d’une forme indéterminée, transforme l’expression : factorisation, mise au même dénominateur ou utilisation d’une expression conjuguée selon le cas.''',
      enonce1:r'''Calcule lim(x→2)(3x+1).''', solution1:r'''La fonction est continue, donc la limite vaut 7.''',
      enonce2:r'''Calcule lim(x→+∞)(5x²−1)/x².''', solution2:r'''En divisant par x², la limite vaut 5.''',
      motsCles:'limite • continuité • voisinage • infini • forme indéterminée',
      quiz1:'Que signifie qu’une fonction f est continue en a ?', quizBonne:'La limite de f(x) quand x tend vers a est égale à f(a)',
    ),
    'Tle_C_math_ch03': _mathTleCChapitre(
      code:'ch03', titre:'Divisibilité dans ℤ',
      cours:r'''Dans l’ensemble des entiers relatifs, a divise b s’il existe un entier k tel que b=ak. La divisibilité permet d’étudier les multiples, diviseurs, nombres premiers et congruences. Les propriétés du PGCD et de l’algorithme d’Euclide sont fondamentales.''',
      renforcement:r'''Pour montrer que a divise b, cherche à écrire b=ak avec k entier. Pour calculer un PGCD, applique l’algorithme d’Euclide en répétant les divisions euclidiennes.''',
      enonce1:r'''Le nombre 7 divise-t-il 84 ?''', solution1:r'''Oui, car 84=7×12.''',
      enonce2:r'''Calcule PGCD(84,30).''', solution2:r'''84=2×30+24 ; 30=1×24+6 ; 24=4×6, donc PGCD(84,30)=6.''',
      motsCles:'divisibilité • diviseur • multiple • entier • PGCD • Euclide',
      quiz1:'Que signifie a divise b dans ℤ ?', quizBonne:'Il existe un entier k tel que b=ak',
    ),
    'Tle_C_math_ch04': _mathTleCChapitre(
      code:'ch04', titre:'Dérivabilité et étude de fonctions',
      cours:r'''La dérivée mesure le taux de variation local d’une fonction. Elle permet d’étudier les variations, les extrema et les tangentes. Une étude complète associe domaine de définition, limites, dérivée, signe de la dérivée, tableau de variations et représentation graphique.''',
      renforcement:r'''Détermine d’abord le domaine. Calcule ensuite la dérivée et étudie son signe. Complète avec les limites pour construire un tableau de variations cohérent.''',
      enonce1:r'''Dérive f(x)=x³−3x+2.''', solution1:r'''f’(x)=3x²−3.''',
      enonce2:r'''Étudie le signe de f’(x)=2x−4.''', solution2:r'''f’(x)<0 si x<2, f’(2)=0 et f’(x)>0 si x>2.''',
      motsCles:'dérivée • taux de variation • tangente • extrema • variations',
      quiz1:'Que permet principalement le signe de f\'(x) ?', quizBonne:'D’étudier les variations de f',
    ),
    'Tle_C_math_ch05': _mathTleCChapitre(
      code:'ch05', titre:'Géométrie analytique de l’espace',
      cours:r'''Dans l’espace, un repère permet de représenter les points par trois coordonnées. Les vecteurs sont décrits par leurs composantes. Les équations de droites et de plans s’obtiennent à partir de vecteurs directeurs, de vecteurs normaux et de systèmes de coordonnées.''',
      renforcement:r'''Écris les coordonnées des vecteurs en soustrayant les coordonnées des points. Pour caractériser un plan, recherche une équation cartésienne ou une représentation paramétrique adaptée.''',
      enonce1:r'''A(1,2,3) et B(4,0,5). Donne les coordonnées de AB.''', solution1:r'''AB=(3,−2,2).''',
      enonce2:r'''Donne une équation cartésienne du plan x+2y−z=3 et indique un vecteur normal.''', solution2:r'''L’équation est déjà donnée ; un vecteur normal est n=(1,2,−1).''',
      motsCles:'espace • coordonnées • vecteur • droite • plan • vecteur normal',
      quiz1:'Combien de coordonnées faut-il pour repérer un point dans l’espace ?', quizBonne:'Trois',
    ),
    'Tle_C_math_ch06': _mathTleCChapitre(
      code:'ch06', titre:'Primitives',
      cours:r'''Une primitive F d’une fonction f sur un intervalle vérifie F’=f. Les primitives s’obtiennent à partir des formes usuelles et des règles de calcul. Elles sont utilisées pour calculer des intégrales et résoudre certaines équations différentielles.''',
      renforcement:r'''Reconnais d’abord la forme de la fonction. Propose une primitive puis vérifie-la systématiquement en dérivant ton résultat.''',
      enonce1:r'''Donne une primitive de f(x)=4x³.''', solution1:r'''F(x)=x⁴+C.''',
      enonce2:r'''Donne une primitive de f(x)=1/x sur ]0;+∞[.''', solution2:r'''F(x)=ln(x)+C.''',
      motsCles:'primitive • dérivée • constante • intégrale • fonction',
      quiz1:'Quelle relation vérifie une primitive F de f ?', quizBonne:'F\'=f',
    ),
    'Tle_C_math_ch07': _mathTleCChapitre(
      code:'ch07', titre:'Fonctions logarithmes',
      cours:r'''La fonction logarithme népérien ln est définie sur ]0;+∞[, strictement croissante et dérivable. Elle transforme les produits en sommes et les puissances en multiples. Ses propriétés permettent de résoudre des équations et inéquations.''',
      renforcement:r'''Vérifie toujours que les arguments des logarithmes sont positifs. Utilise ln(ab)=ln(a)+ln(b) et ln(a/b)=ln(a)−ln(b) pour simplifier les expressions.''',
      enonce1:r'''Calcule ln(e⁴).''', solution1:r'''ln(e⁴)=4.''',
      enonce2:r'''Résous ln(x)=3.''', solution2:r'''x=e³, avec x>0.''',
      motsCles:'ln • logarithme • domaine • croissance • équation • inéquation',
      quiz1:'Quel est le domaine de définition de ln ?', quizBonne:']0;+∞[',
    ),
    'Tle_C_math_ch08': _mathTleCChapitre(
      code:'ch08', titre:'Coniques',
      cours:r'''Les coniques regroupent notamment cercle, ellipse, parabole et hyperbole. Elles peuvent être étudiées par leurs équations cartésiennes, leurs foyers, directrices, axes et propriétés géométriques. Un changement de repère peut simplifier certaines équations.''',
      renforcement:r'''Commence par identifier la forme de l’équation. Compare-la aux formes canoniques connues afin d’identifier la conique et ses paramètres.''',
      enonce1:r'''Identifie la conique d’équation x²+y²=25.''', solution1:r'''C’est un cercle de centre O(0,0) et de rayon 5.''',
      enonce2:r'''Identifie la conique d’équation y²=4x.''', solution2:r'''C’est une parabole de sommet O, d’axe (Ox).''',
      motsCles:'conique • cercle • ellipse • parabole • hyperbole • équation',
      quiz1:'Quelle conique possède une équation de type y²=2px dans un repère adapté ?', quizBonne:'La parabole',
    ),
    'Tle_C_math_ch09': _mathTleCChapitre(
      code:'ch09', titre:'Fonctions exponentielles et fonctions puissances',
      cours:r'''La fonction exponentielle est définie sur ℝ, positive, strictement croissante et vérifie e^(a+b)=e^a e^b. Les fonctions puissances prolongent l’étude de x^a sur les domaines où elles sont définies. Ces fonctions interviennent dans les phénomènes de croissance et de décroissance.''',
      renforcement:r'''Utilise les propriétés de l’exponentielle pour transformer les produits et puissances. Pour une fonction puissance, commence par déterminer son domaine avant d’étudier ses variations.''',
      enonce1:r'''Simplifie e²×e³.''', solution1:r'''e⁵.''',
      enonce2:r'''Résous e^x=7.''', solution2:r'''x=ln(7).''',
      motsCles:'exponentielle • puissance • croissance • ln • domaine',
      quiz1:'Quelle relation est vraie pour l’exponentielle ?', quizBonne:'e^(a+b)=e^a×e^b',
    ),
    'Tle_C_math_ch10': _mathTleCChapitre(
      code:'ch10', titre:'Nombres complexes',
      cours:r'''Un nombre complexe s’écrit z=a+ib avec a,b réels et i²=−1. On distingue partie réelle, partie imaginaire, conjugué et module. Les opérations algébriques et la forme trigonométrique permettent de résoudre des problèmes de géométrie et d’équations.''',
      renforcement:r'''Pour calculer avec les complexes, regroupe séparément les parties réelle et imaginaire. Utilise le conjugué pour simplifier certains quotients et le module pour les interprétations géométriques.''',
      enonce1:r'''Calcule (2+3i)+(1−5i).''', solution1:r'''3−2i.''',
      enonce2:r'''Calcule le module de z=3+4i.''', solution2:r'''|z|=√(3²+4²)=5.''',
      motsCles:'complexe • partie réelle • partie imaginaire • conjugué • module',
      quiz1:'Que vaut i² ?', quizBonne:'−1',
    ),
    'Tle_C_math_ch11': _mathTleCChapitre(
      code:'ch11', titre:'PPCM et PGCD de deux entiers relatifs',
      cours:r'''Le PGCD de deux entiers est leur plus grand diviseur commun. Le PPCM est leur plus petit multiple commun strictement positif. L’algorithme d’Euclide permet de calculer efficacement le PGCD et la relation |ab|=PGCD(a,b)×PPCM(a,b) permet d’obtenir le PPCM.''',
      renforcement:r'''Calcule d’abord le PGCD avec l’algorithme d’Euclide. Si les deux entiers sont non nuls, utilise ensuite PPCM(a,b)=|ab|/PGCD(a,b).''',
      enonce1:r'''Calcule PGCD(18,30).''', solution1:r'''PGCD(18,30)=6.''',
      enonce2:r'''Déduis PPCM(18,30).''', solution2:r'''PPCM=18×30/6=90.''',
      motsCles:'PGCD • PPCM • diviseur • multiple • Euclide',
      quiz1:'Quelle relation relie PGCD et PPCM de deux entiers non nuls ?', quizBonne:'|ab|=PGCD(a,b)×PPCM(a,b)',
    ),
    'Tle_C_math_ch12': _mathTleCChapitre(
      code:'ch12', titre:'Suites numériques',
      cours:r'''Une suite est une fonction définie sur les entiers naturels. On étudie ses termes, ses variations et sa convergence. Les suites arithmétiques et géométriques offrent des modèles simples et leurs limites peuvent être déterminées à partir de leurs propriétés.''',
      renforcement:r'''Identifie la relation entre deux termes consécutifs. Pour une suite arithmétique, étudie la raison ; pour une suite géométrique, étudie le quotient et sa valeur absolue.''',
      enonce1:r'''Soit u_n=2n+1. Calcule u_5.''', solution1:r'''u_5=11.''',
      enonce2:r'''Une suite géométrique vérifie u_0=3 et q=2. Calcule u_4.''', solution2:r'''u_4=3×2⁴=48.''',
      motsCles:'suite • terme • arithmétique • géométrique • variation • convergence',
      quiz1:'Dans une suite géométrique, quelle grandeur est constante ?', quizBonne:'Le quotient de deux termes consécutifs non nuls',
    ),
    'Tle_C_math_ch13': _mathTleCChapitre(
      code:'ch13', titre:'Isométries du plan',
      cours:r'''Une isométrie du plan conserve les distances. Les translations, rotations, symétries axiales et symétries centrales sont des isométries. Elles conservent également les angles et la forme des figures.''',
      renforcement:r'''Identifie la transformation à partir de ses éléments caractéristiques : vecteur pour une translation, centre et angle pour une rotation, axe pour une symétrie axiale.''',
      enonce1:r'''Quelle transformation envoie chaque point M sur M' avec MM' égal à un même vecteur ?''', solution1:r'''Une translation de vecteur constant.''',
      enonce2:r'''Quel est le centre d’une symétrie centrale qui échange A et A' ?''', solution2:r'''Le milieu de [AA'].''',
      motsCles:'isométrie • translation • rotation • symétrie • distance',
      quiz1:'Quelle propriété fondamentale une isométrie conserve-t-elle ?', quizBonne:'Les distances',
    ),
    'Tle_C_math_ch14': _mathTleCChapitre(
      code:'ch14', titre:'Calcul intégral',
      cours:r'''L’intégrale définie de f sur [a,b] peut être calculée à l’aide d’une primitive F par ∫a^b f(x)dx=F(b)−F(a). Elle permet notamment de déterminer des aires algébriques et des quantités cumulées.''',
      renforcement:r'''Cherche une primitive de la fonction puis applique la formule aux bornes. Pour une aire géométrique, vérifie le signe de la fonction sur l’intervalle avant d’interpréter l’intégrale comme une aire positive.''',
      enonce1:r'''Calcule ∫₀² x dx.''', solution1:r'''Une primitive est x²/2, donc l’intégrale vaut 2.''',
      enonce2:r'''Calcule ∫₁³ 2x dx.''', solution2:r'''Une primitive est x², donc 9−1=8.''',
      motsCles:'intégrale • primitive • bornes • aire • fonction',
      quiz1:'Quelle formule permet de calculer ∫a^b f(x)dx avec une primitive F ?', quizBonne:'F(b)−F(a)',
    ),
    'Tle_C_math_ch15': _mathTleCChapitre(
      code:'ch15', titre:'Similitudes directes du plan',
      cours:r'''Une similitude directe conserve les angles orientés et multiplie toutes les longueurs par un même rapport positif. Elle peut être décrite par une homothétie suivie d’une rotation et s’exprime efficacement avec les nombres complexes.''',
      renforcement:r'''Identifie le rapport de similitude et l’angle de rotation. Dans le plan complexe, une transformation de la forme z’=az+b avec a complexe non nul représente une similitude directe.''',
      enonce1:r'''Une similitude directe multiplie les longueurs par 3. Quel est son rapport ?''', solution1:r'''Le rapport de similitude est 3.''',
      enonce2:r'''Dans z’=2z+1, quel est le coefficient complexe de la partie linéaire ?''', solution2:r'''Le coefficient est 2 ; le rapport est |2|=2 et l’angle est 0 modulo 2π.''',
      motsCles:'similitude • rapport • angle • rotation • homothétie • complexe',
      quiz1:'Que conserve une similitude directe ?', quizBonne:'Les angles orientés',
    ),
    'Tle_C_math_ch16': _mathTleCChapitre(
      code:'ch16', titre:'Probabilité conditionnelle et variable aléatoire',
      cours:r'''La probabilité conditionnelle de A sachant B est définie par P_B(A)=P(A∩B)/P(B) lorsque P(B) est non nulle. Une variable aléatoire associe une valeur numérique aux issues d’une expérience aléatoire et possède une loi de probabilité.''',
      renforcement:r'''Identifie clairement l’événement conditionnant. Pour une variable aléatoire, construis la loi puis vérifie que la somme des probabilités vaut 1 avant de calculer espérance ou variance.''',
      enonce1:r'''P(A∩B)=0,2 et P(B)=0,5. Calcule P_B(A).''', solution1:r'''P_B(A)=0,2/0,5=0,4.''',
      enonce2:r'''Une variable X vaut 0 avec probabilité 0,3 et 2 avec probabilité 0,7. Calcule E(X).''', solution2:r'''E(X)=0×0,3+2×0,7=1,4.''',
      motsCles:'conditionnelle • intersection • variable aléatoire • loi • espérance',
      quiz1:'Quelle formule définit P_B(A) ?', quizBonne:'P(A∩B)/P(B)',
    ),
    'Tle_C_math_ch17': _mathTleCChapitre(
      code:'ch17', titre:'Nombres complexes et géométrie du plan',
      cours:r'''Les nombres complexes permettent de représenter les points et vecteurs du plan. Le module représente une distance et l’argument décrit une direction. Les formes algébrique, trigonométrique et exponentielle facilitent l’étude des transformations et configurations géométriques.''',
      renforcement:r'''Associe à un point M d’affixe z son module |z| pour la distance à l’origine et son argument pour une direction. Utilise les quotients de complexes pour comparer des directions et des rapports de longueurs.''',
      enonce1:r'''Pour z=3+4i, que représente |z| ?''', solution1:r'''|z|=5, c’est la distance du point d’affixe z à l’origine.''',
      enonce2:r'''Quel nombre complexe représente le vecteur allant du point d’affixe 1+i au point d’affixe 4+3i ?''', solution2:r'''(4+3i)−(1+i)=3+2i.''',
      motsCles:'affixe • module • argument • vecteur • distance • complexe',
      quiz1:'Que représente géométriquement le module d’une affixe z ?', quizBonne:'La distance du point à l’origine',
    ),
    'Tle_C_math_ch18': _mathTleCChapitre(
      code:'ch18', titre:'Statistique à deux variables',
      cours:r'''Une statistique à deux variables étudie des couples de valeurs observés sur une population. Le nuage de points, la covariance, le coefficient de corrélation et les méthodes d’ajustement permettent de décrire une liaison entre les deux variables.''',
      renforcement:r'''Organise les couples puis représente-les. Observe la tendance et utilise un ajustement linéaire lorsque le nuage s’y prête. Une corrélation décrit une association linéaire mais ne suffit pas à établir une causalité.''',
      enonce1:r'''Les points (1,2), (2,4), (3,6) sont-ils alignés ?''', solution1:r'''Oui, ils vérifient tous y=2x.''',
      enonce2:r'''Que suggère une corrélation linéaire proche de 1 ?''', solution2:r'''Une liaison linéaire positive forte entre les deux variables.''',
      motsCles:'statistique • deux variables • nuage • corrélation • ajustement',
      quiz1:'Que représente chaque point d’un nuage de points ?', quizBonne:'Un couple de valeurs observées',
    ),
    'Tle_C_math_ch19': _mathTleCChapitre(
      code:'ch19', titre:'Équations différentielles',
      cours:r'''Une équation différentielle relie une fonction inconnue à ses dérivées. Les équations différentielles linéaires du premier ordre et les équations du type y’=ay se résolvent à partir de formes générales, puis une condition initiale permet de déterminer la constante.''',
      renforcement:r'''Identifie l’ordre et la forme de l’équation. Pour y’=ay, la solution générale est y=Ce^(ax). Utilise ensuite la condition initiale pour déterminer C.''',
      enonce1:r'''Résous y’=2y.''', solution1:r'''La solution générale est y=Ce^(2x), où C est une constante réelle.''',
      enonce2:r'''Résous y’=3y avec y(0)=5.''', solution2:r'''y=Ce^(3x). Comme y(0)=C=5, donc y=5e^(3x).''',
      motsCles:'équation différentielle • dérivée • solution générale • condition initiale • exponentielle',
      quiz1:'Quelle est la forme générale d’une solution de y’=ay ?', quizBonne:'y=Ce^(ax)',
    ),

  };
}


// ============================================================================
// CONTENU GENERE PAR L’AGENT — toujours en brouillon dans Firestore.
// ============================================================================
final Map<String, List<RessourceOfficielle>> _catalogueAgent = <String, List<RessourceOfficielle>>{
};

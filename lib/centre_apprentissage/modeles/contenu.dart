// ============================================================================
//  SENTINEL CI — CENTRE D'APPRENTISSAGE
//  Modèles de données du contenu pédagogique
//  Fichier : lib/centre_apprentissage/modeles/contenu.dart
//
//  Ce fichier ne dépend d'aucun autre fichier du projet.
//  Il peut être ajouté sans risque : rien de l'existant n'est modifié.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
//  1. NIVEAUX SCOLAIRES (Côte d'Ivoire)
// ============================================================================

class NiveauxCI {
  static const List<String> tous = [
    '6e', '5e', '4e', '3e', '2nde', '1ere', 'Tle',
  ];

  /// Libellé affiché à l'écran.
  static String libelle(String code) {
    switch (code) {
      case '6e':
        return '6ᵉ';
      case '5e':
        return '5ᵉ';
      case '4e':
        return '4ᵉ';
      case '3e':
        return '3ᵉ';
      case '2nde':
        return '2ⁿᵈᵉ';
      case '1ere':
        return '1ᵉʳᵉ';
      case 'Tle':
        return 'Terminale';
      default:
        return code;
    }
  }

  /// Niveaux concernés par le BEPC / le BAC (utile pour les sujets d'examen).
  static const List<String> cycleBEPC = ['6e', '5e', '4e', '3e'];
  static const List<String> cycleBAC = ['2nde', '1ere', 'Tle'];
}

// ============================================================================
//  2. TYPES DE RESSOURCES
// ============================================================================

enum TypeRessource {
  cours, // 📚 Cours officiel
  renforcement, // 💡 Explication simplifiée
  exercice, // 📝 Exercice corrigé
  quiz, // 🎯 Quiz interactif
  sujet, // 📄 Sujet d'examen (BEPC / BAC)
  corrige, // ✅ Corrigé détaillé
  video, // 🎥 Vidéo YouTube
  fiche, // 📑 Fiche de révision
  orientation, // 🎓 Contenu d'orientation
}

extension TypeRessourceX on TypeRessource {
  /// Code stocké dans Firestore. Ne jamais le modifier une fois en production.
  String get code => name;

  String get libelle {
    switch (this) {
      case TypeRessource.cours:
        return 'Cours officiel';
      case TypeRessource.renforcement:
        return 'Renforcement';
      case TypeRessource.exercice:
        return 'Exercice';
      case TypeRessource.quiz:
        return 'Quiz';
      case TypeRessource.sujet:
        return "Sujet d'examen";
      case TypeRessource.corrige:
        return 'Corrigé';
      case TypeRessource.video:
        return 'Vidéo';
      case TypeRessource.fiche:
        return 'Fiche de révision';
      case TypeRessource.orientation:
        return 'Orientation';
    }
  }

  String get emoji {
    switch (this) {
      case TypeRessource.cours:
        return '📚';
      case TypeRessource.renforcement:
        return '💡';
      case TypeRessource.exercice:
        return '📝';
      case TypeRessource.quiz:
        return '🎯';
      case TypeRessource.sujet:
        return '📄';
      case TypeRessource.corrige:
        return '✅';
      case TypeRessource.video:
        return '🎥';
      case TypeRessource.fiche:
        return '📑';
      case TypeRessource.orientation:
        return '🎓';
    }
  }

  static TypeRessource depuisCode(String? code) {
    return TypeRessource.values.firstWhere(
      (t) => t.name == code,
      orElse: () => TypeRessource.cours,
    );
  }
}

// ============================================================================
//  3. NIVEAUX DE DIFFICULTÉ
// ============================================================================

class Difficulte {
  static const int facile = 1;
  static const int moyen = 2;
  static const int difficile = 3;
  static const int examen = 4;

  static String libelle(int niveau) {
    switch (niveau) {
      case facile:
        return 'Facile';
      case moyen:
        return 'Moyen';
      case difficile:
        return 'Difficile';
      case examen:
        return "Niveau examen";
      default:
        return 'Moyen';
    }
  }

  /// Rendu en étoiles : ⭐, ⭐⭐, ⭐⭐⭐, ⭐⭐⭐⭐
  static String etoiles(int niveau) => '⭐' * niveau.clamp(1, 4);
}

// ============================================================================
//  4. MATIÈRE
//  Collection Firestore : /matieres/{matiereId}
//  Exemple d'identifiant : "math", "franc", "pc", "svt", "hg", "angl"
// ============================================================================

class Matiere {
  final String id;
  final String nom;
  final String couleurHex; // ex. "FF6B35" — sans le "#"
  final int ordre; // ordre d'affichage
  final List<String> niveaux; // niveaux où la matière est enseignée
  final bool actif;

  const Matiere({
    required this.id,
    required this.nom,
    this.couleurHex = '1B5E20',
    this.ordre = 0,
    this.niveaux = const [],
    this.actif = true,
  });

  factory Matiere.depuisDoc(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    return Matiere(
      id: doc.id,
      nom: d['nom'] as String? ?? '',
      couleurHex: d['couleurHex'] as String? ?? '1B5E20',
      ordre: (d['ordre'] as num?)?.toInt() ?? 0,
      niveaux: List<String>.from(d['niveaux'] as List? ?? const []),
      actif: d['actif'] as bool? ?? true,
    );
  }

  Map<String, dynamic> versMap() => {
        'nom': nom,
        'couleurHex': couleurHex,
        'ordre': ordre,
        'niveaux': niveaux,
        'actif': actif,
      };

  Matiere copierAvec({
    String? nom,
    String? couleurHex,
    int? ordre,
    List<String>? niveaux,
    bool? actif,
  }) {
    return Matiere(
      id: id,
      nom: nom ?? this.nom,
      couleurHex: couleurHex ?? this.couleurHex,
      ordre: ordre ?? this.ordre,
      niveaux: niveaux ?? this.niveaux,
      actif: actif ?? this.actif,
    );
  }
}

// ============================================================================
//  5. CHAPITRE
//  Collection Firestore : /chapitres/{chapitreId}
//  Identifiant lisible : "6e_math_ch03"  →  niveau_matiere_chapitre
// ============================================================================

class Chapitre {
  final String id;
  final String niveau; // '6e', '3e', 'Tle'...
  final String matiereId; // 'math', 'franc'...
  final String titre;
  final String description;
  final int ordre; // position dans le programme
  final bool actif;
  final DateTime? dateMaj;

  const Chapitre({
    required this.id,
    required this.niveau,
    required this.matiereId,
    required this.titre,
    this.description = '',
    this.ordre = 0,
    this.actif = true,
    this.dateMaj,
  });

  /// Fabrique l'identifiant lisible du chapitre.
  /// Exemple : Chapitre.construireId('6e', 'math', 3) → "6e_math_ch03"
  static String construireId(String niveau, String matiereId, int ordre) {
    final n = ordre.toString().padLeft(2, '0');
    return '${niveau}_${matiereId}_ch$n';
  }

  factory Chapitre.depuisDoc(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    return Chapitre(
      id: doc.id,
      niveau: d['niveau'] as String? ?? '',
      matiereId: d['matiereId'] as String? ?? '',
      titre: d['titre'] as String? ?? '',
      description: d['description'] as String? ?? '',
      ordre: (d['ordre'] as num?)?.toInt() ?? 0,
      actif: d['actif'] as bool? ?? true,
      dateMaj: (d['dateMaj'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> versMap() => {
        'niveau': niveau,
        'matiereId': matiereId,
        'titre': titre,
        'description': description,
        'ordre': ordre,
        'actif': actif,
        'dateMaj': FieldValue.serverTimestamp(),
      };

  Chapitre copierAvec({
    String? niveau,
    String? matiereId,
    String? titre,
    String? description,
    int? ordre,
    bool? actif,
  }) {
    return Chapitre(
      id: id,
      niveau: niveau ?? this.niveau,
      matiereId: matiereId ?? this.matiereId,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      ordre: ordre ?? this.ordre,
      actif: actif ?? this.actif,
      dateMaj: dateMaj,
    );
  }
}

// ============================================================================
//  6. QUESTION DE QUIZ
//  Stockée en tableau à l'intérieur du document Ressource (pas de collection
//  séparée : un quiz se lit ainsi en UNE seule lecture Firestore).
// ============================================================================

enum TypeQuestion { qcm, vraiFaux, reponseCourte }

class QuestionQuiz {
  final String id;
  final TypeQuestion type;
  final String enonce;
  final List<String> choix; // vide pour reponseCourte
  final List<int> bonnesReponses; // index des bonnes réponses (QCM / V-F)
  final String reponseAttendue; // pour reponseCourte
  final String explication; // affichée après correction
  final int points;
  final String? imageUrl; // illustration facultative

  const QuestionQuiz({
    required this.id,
    required this.type,
    required this.enonce,
    this.choix = const [],
    this.bonnesReponses = const [],
    this.reponseAttendue = '',
    this.explication = '',
    this.points = 1,
    this.imageUrl,
  });

  factory QuestionQuiz.depuisMap(Map<String, dynamic> d) {
    return QuestionQuiz(
      id: d['id'] as String? ?? '',
      type: TypeQuestion.values.firstWhere(
        (t) => t.name == d['type'],
        orElse: () => TypeQuestion.qcm,
      ),
      enonce: d['enonce'] as String? ?? '',
      choix: List<String>.from(d['choix'] as List? ?? const []),
      bonnesReponses: List<int>.from(d['bonnesReponses'] as List? ?? const []),
      reponseAttendue: d['reponseAttendue'] as String? ?? '',
      explication: d['explication'] as String? ?? '',
      points: (d['points'] as num?)?.toInt() ?? 1,
      imageUrl: d['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> versMap() => {
        'id': id,
        'type': type.name,
        'enonce': enonce,
        'choix': choix,
        'bonnesReponses': bonnesReponses,
        'reponseAttendue': reponseAttendue,
        'explication': explication,
        'points': points,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  /// Vérifie une réponse d'élève.
  /// [indexChoisis] pour QCM / Vrai-Faux, [texte] pour réponse courte.
  bool estCorrecte({List<int>? indexChoisis, String? texte}) {
    if (type == TypeQuestion.reponseCourte) {
      final saisie = (texte ?? '').trim().toLowerCase();
      return saisie.isNotEmpty &&
          saisie == reponseAttendue.trim().toLowerCase();
    }
    final choisis = List<int>.from(indexChoisis ?? const <int>[])..sort();
    final attendus = List<int>.from(bonnesReponses)..sort();
    if (choisis.length != attendus.length) return false;
    for (var i = 0; i < choisis.length; i++) {
      if (choisis[i] != attendus[i]) return false;
    }
    return true;
  }
}

// ============================================================================
//  7. RESSOURCE — le cœur du module
//  Collection Firestore : /ressources/{ressourceId}
//
//  UNE seule collection pour les 9 types de contenu.
//  Les champs non pertinents pour un type restent simplement vides.
// ============================================================================

class Ressource {
  // --- Identification ---
  final String id;
  final TypeRessource type;
  final String titre;
  final int ordre;

  // --- Rattachement (dénormalisé pour requêter sans jointure) ---
  final String chapitreId; // vide pour les sujets d'examen et l'orientation
  final String niveau;
  final String matiereId;

  // --- Contenu principal ---
  final String contenu; // texte de la leçon / fiche / explication
  final List<String> imagesUrls; // schémas, illustrations (Firebase Storage)
  final String pdfUrl; // PDF téléchargeable
  final String videoYoutubeId; // ID YouTube seul — ex. "dQw4w9WgXcQ"

  // --- Exercices et corrigés ---
  final String enonce;
  final String solution; // solution détaillée
  final int difficulte; // 1 à 4 (voir classe Difficulte)
  final String ressourceLieeId; // ex. un corrigé pointant vers son sujet

  // --- Quiz ---
  final List<QuestionQuiz> questions;
  final int dureeMinutes; // durée conseillée / limite de temps

  // --- Sujets d'examen ---
  final String examen; // 'BEPC' ou 'BAC'
  final int annee; // 2024, 2025...
  final String serie; // 'A', 'C', 'D' pour le BAC

  // --- Métadonnées ---
  final bool actif; // brouillon (false) / publié (true)
  final String auteur; // uid de l'agent qui a publié
  final DateTime? dateCreation;
  final DateTime? dateMaj;

  const Ressource({
    required this.id,
    required this.type,
    required this.titre,
    this.ordre = 0,
    this.chapitreId = '',
    this.niveau = '',
    this.matiereId = '',
    this.contenu = '',
    this.imagesUrls = const [],
    this.pdfUrl = '',
    this.videoYoutubeId = '',
    this.enonce = '',
    this.solution = '',
    this.difficulte = Difficulte.moyen,
    this.ressourceLieeId = '',
    this.questions = const [],
    this.dureeMinutes = 0,
    this.examen = '',
    this.annee = 0,
    this.serie = '',
    this.actif = false,
    this.auteur = '',
    this.dateCreation,
    this.dateMaj,
  });

  factory Ressource.depuisDoc(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    return Ressource(
      id: doc.id,
      type: TypeRessourceX.depuisCode(d['type'] as String?),
      titre: d['titre'] as String? ?? '',
      ordre: (d['ordre'] as num?)?.toInt() ?? 0,
      chapitreId: d['chapitreId'] as String? ?? '',
      niveau: d['niveau'] as String? ?? '',
      matiereId: d['matiereId'] as String? ?? '',
      contenu: d['contenu'] as String? ?? '',
      imagesUrls: List<String>.from(d['imagesUrls'] as List? ?? const []),
      pdfUrl: d['pdfUrl'] as String? ?? '',
      videoYoutubeId: d['videoYoutubeId'] as String? ?? '',
      enonce: d['enonce'] as String? ?? '',
      solution: d['solution'] as String? ?? '',
      difficulte: (d['difficulte'] as num?)?.toInt() ?? Difficulte.moyen,
      ressourceLieeId: d['ressourceLieeId'] as String? ?? '',
      questions: (d['questions'] as List? ?? const [])
          .map((q) => QuestionQuiz.depuisMap(Map<String, dynamic>.from(q)))
          .toList(),
      dureeMinutes: (d['dureeMinutes'] as num?)?.toInt() ?? 0,
      examen: d['examen'] as String? ?? '',
      annee: (d['annee'] as num?)?.toInt() ?? 0,
      serie: d['serie'] as String? ?? '',
      actif: d['actif'] as bool? ?? false,
      auteur: d['auteur'] as String? ?? '',
      dateCreation: (d['dateCreation'] as Timestamp?)?.toDate(),
      dateMaj: (d['dateMaj'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> versMap({bool creation = false}) => {
        'type': type.code,
        'titre': titre,
        'ordre': ordre,
        'chapitreId': chapitreId,
        'niveau': niveau,
        'matiereId': matiereId,
        'contenu': contenu,
        'imagesUrls': imagesUrls,
        'pdfUrl': pdfUrl,
        'videoYoutubeId': videoYoutubeId,
        'enonce': enonce,
        'solution': solution,
        'difficulte': difficulte,
        'ressourceLieeId': ressourceLieeId,
        'questions': questions.map((q) => q.versMap()).toList(),
        'dureeMinutes': dureeMinutes,
        'examen': examen,
        'annee': annee,
        'serie': serie,
        'actif': actif,
        'auteur': auteur,
        if (creation) 'dateCreation': FieldValue.serverTimestamp(),
        'dateMaj': FieldValue.serverTimestamp(),
      };

  /// Total des points d'un quiz.
  int get totalPoints =>
      questions.fold<int>(0, (somme, q) => somme + q.points);

  /// URL de la miniature YouTube (aucun appel réseau à l'API nécessaire).
  String get miniatureVideo => videoYoutubeId.isEmpty
      ? ''
      : 'https://img.youtube.com/vi/$videoYoutubeId/hqdefault.jpg';

  /// Extrait l'ID YouTube d'une URL collée par l'agent.
  /// Accepte : youtu.be/XXX, youtube.com/watch?v=XXX, /embed/XXX, /shorts/XXX,
  /// ou directement l'ID brut.
  static String extraireIdYoutube(String saisie) {
    final texte = saisie.trim();
    if (texte.isEmpty) return '';
    final motifs = [
      RegExp(r'youtu\.be/([A-Za-z0-9_-]{11})'),
      RegExp(r'[?&]v=([A-Za-z0-9_-]{11})'),
      RegExp(r'/embed/([A-Za-z0-9_-]{11})'),
      RegExp(r'/shorts/([A-Za-z0-9_-]{11})'),
    ];
    for (final motif in motifs) {
      final m = motif.firstMatch(texte);
      if (m != null) return m.group(1)!;
    }
    // Saisie déjà sous forme d'ID brut
    if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(texte)) return texte;
    return '';
  }

  Ressource copierAvec({
    TypeRessource? type,
    String? titre,
    int? ordre,
    String? chapitreId,
    String? niveau,
    String? matiereId,
    String? contenu,
    List<String>? imagesUrls,
    String? pdfUrl,
    String? videoYoutubeId,
    String? enonce,
    String? solution,
    int? difficulte,
    String? ressourceLieeId,
    List<QuestionQuiz>? questions,
    int? dureeMinutes,
    String? examen,
    int? annee,
    String? serie,
    bool? actif,
    String? auteur,
  }) {
    return Ressource(
      id: id,
      type: type ?? this.type,
      titre: titre ?? this.titre,
      ordre: ordre ?? this.ordre,
      chapitreId: chapitreId ?? this.chapitreId,
      niveau: niveau ?? this.niveau,
      matiereId: matiereId ?? this.matiereId,
      contenu: contenu ?? this.contenu,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      videoYoutubeId: videoYoutubeId ?? this.videoYoutubeId,
      enonce: enonce ?? this.enonce,
      solution: solution ?? this.solution,
      difficulte: difficulte ?? this.difficulte,
      ressourceLieeId: ressourceLieeId ?? this.ressourceLieeId,
      questions: questions ?? this.questions,
      dureeMinutes: dureeMinutes ?? this.dureeMinutes,
      examen: examen ?? this.examen,
      annee: annee ?? this.annee,
      serie: serie ?? this.serie,
      actif: actif ?? this.actif,
      auteur: auteur ?? this.auteur,
      dateCreation: dateCreation,
      dateMaj: dateMaj,
    );
  }
}

// ============================================================================
//  8. VERSION DU CATALOGUE (horloge du cache)
//  Document Firestore unique : /parametres_contenu/version
//
//  À chaque publication, le back-office incrémente ce numéro.
//  L'application ne retélécharge le catalogue que si le numéro a changé,
//  ce qui divise les lectures Firestore par 10 à 50 selon l'usage.
// ============================================================================

class VersionContenu {
  final int version;
  final DateTime? dateMaj;

  const VersionContenu({this.version = 0, this.dateMaj});

  factory VersionContenu.depuisDoc(DocumentSnapshot doc) {
    final d = (doc.data() as Map<String, dynamic>?) ?? {};
    return VersionContenu(
      version: (d['version'] as num?)?.toInt() ?? 0,
      dateMaj: (d['dateMaj'] as Timestamp?)?.toDate(),
    );
  }
}

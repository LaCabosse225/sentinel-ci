// ============================================================================
//  SENTINEL CI — CENTRE D'APPRENTISSAGE
//  Programmes officiels de la Cote d'Ivoire (source : DPFC, Ministere de
//  l'Education Nationale et de l'Alphabetisation)
//  Fichier : lib/centre_apprentissage/donnees/programme_officiel.dart
//
//  Ce fichier ne contient que des donnees : la liste des lecons de chaque
//  couple (niveau, matiere), dans l'ordre du programme educatif.
//  Un bouton du back-office cree tous les chapitres d'un coup a partir d'ici.
//
//  Pour ajouter une matiere ou un niveau : ajouter une entree dans la carte
//  _programmes, en respectant la cle "<niveau>_<matiereId>".
// ============================================================================

import '../modeles/contenu.dart';
import '../services/contenu_service.dart';

/// Une lecon du programme officiel, avant creation dans Firestore.
class ChapitreOfficiel {
  final int ordre;
  final String titre;
  final String description;
  final String theme;

  const ChapitreOfficiel(
    this.ordre,
    this.titre,
    this.description, {
    this.theme = '',
  });
}

class ProgrammeOfficiel {
  ProgrammeOfficiel._();

  // ==========================================================================
  //  IDENTITE DU PROGRAMME
  //
  //  Un meme niveau/matiere peut changer de programme au fil des annees.
  //  La cle interne reste lisible, mais les metadonnees sont maintenant
  //  explicites afin de pouvoir conserver plusieurs versions cote Firestore.
  // ==========================================================================

  static const String anneeCourante = '2026-2027';
  static const String programmeCourant = 'dpfc';

  /// Niveaux secondaires pris en charge par Sentinelle CI.
  static const List<String> niveauxSecondaire = NiveauxCI.tous;

  /// Series utilisees au lycee dans l'architecture actuelle.
  static const List<String> seriesLycee = ProgrammesCI.seriesLycee;

  /// Retourne vrai si le niveau est concerne par une serie.
  static bool niveauAUneSerie(String niveau) =>
      ProgrammesCI.niveauAUneSerie(niveau);

  /// Series attendues pour un niveau.
  static List<String> seriesPour(String niveau) =>
      ProgrammesCI.seriesPour(niveau);

  // ==========================================================================
  //  CATALOGUE
  //
  //  IMPORTANT :
  //  Le catalogue ci-dessous contient uniquement les donnees deja presentes
  //  dans le fichier d'origine. Les nouveaux niveaux/matieres seront ajoutes
  //  apres verification des documents DPFC correspondants.
  // ==========================================================================

  static const Map<String, List<ChapitreOfficiel>> _programmes = {
    '3e_math': [
      ChapitreOfficiel(1, 'Calcul littéral',
          'Développement, réduction, factorisation, identités remarquables et calcul avec des expressions littérales.'),
      ChapitreOfficiel(2, 'Propriétés de Thalès dans un triangle',
          'Propriété de Thalès, réciproque, conséquence et partage d’un segment.'),
      ChapitreOfficiel(3, 'Racines carrées',
          'Racine carrée, produits et quotients de radicaux, simplification et comparaison.'),
      ChapitreOfficiel(4, 'Triangle rectangle',
          'Théorème de Pythagore et sa réciproque, sinus, cosinus et tangente d’un angle aigu.'),
      ChapitreOfficiel(5, 'Calcul numérique',
          'Nombres réels, intervalles, encadrements, valeurs approchées et calculs numériques.'),
      ChapitreOfficiel(6, 'Angles inscrits',
          'Angles inscrits, angles au centre et relations entre leurs mesures.'),
      ChapitreOfficiel(7, 'Vecteurs',
          'Égalité, somme, différence, multiplication par un réel et colinéarité des vecteurs.'),
      ChapitreOfficiel(8, 'Équations et inéquations dans ℝ',
          'Résolution d’équations et d’inéquations du premier degré dans ℝ et résolution de problèmes.'),
      ChapitreOfficiel(9, 'Pyramides et cônes',
          'Patrons, volumes et aires de pyramides et de cônes.'),
      ChapitreOfficiel(10, 'Statistique',
          'Effectifs, fréquences, effectifs cumulés, médiane et représentation de données.'),
      ChapitreOfficiel(11, 'Coordonnées de vecteurs',
          'Coordonnées dans un repère, opérations sur les vecteurs, milieu et distance.'),
      ChapitreOfficiel(12, 'Équations de droites',
          'Coefficient directeur, équation d’une droite, parallélisme et perpendicularité.'),
      ChapitreOfficiel(13, 'Applications affines',
          'Applications affines et linéaires, représentations graphiques et variations.'),
      ChapitreOfficiel(14, 'Équations et inéquations dans ℝ × ℝ',
          'Systèmes de deux équations et d’inéquations à deux inconnues, méthodes algébriques et graphiques.'),
    ],
  };
  // ==========================================================================
  //  CLES ET ACCES
  // ==========================================================================

  static String _cle(
    String niveau,
    String matiereId, {
    String anneeScolaire = anneeCourante,
    String programmeVersion = programmeCourant,
    String serie = '',
  }) {
    return '${anneeScolaire}_${programmeVersion}_${niveau}_${serie}_$matiereId';
  }

  /// Compatibilite avec l'ancien format de cle du catalogue.
  static String _ancienneCle(String niveau, String matiereId) =>
      '${niveau}_$matiereId';

  static bool existe(
    String niveau,
    String matiereId, {
    String anneeScolaire = anneeCourante,
    String programmeVersion = programmeCourant,
    String serie = '',
  }) {
    return _programmes.containsKey(_cle(
          niveau,
          matiereId,
          anneeScolaire: anneeScolaire,
          programmeVersion: programmeVersion,
          serie: serie,
        )) ||
        _programmes.containsKey(_ancienneCle(niveau, matiereId));
  }

  /// Les lecons du programme.
  ///
  /// La recherche utilise d'abord la cle versionnee. Si le catalogue
  /// historique n'a pas encore ete migre, l'ancienne cle est conservee.
  static List<ChapitreOfficiel> chapitres(
    String niveau,
    String matiereId, {
    String anneeScolaire = anneeCourante,
    String programmeVersion = programmeCourant,
    String serie = '',
  }) {
    return _programmes[_cle(
          niveau,
          matiereId,
          anneeScolaire: anneeScolaire,
          programmeVersion: programmeVersion,
          serie: serie,
        )] ??
        _programmes[_ancienneCle(niveau, matiereId)] ??
        const [];
  }

  /// Toutes les combinaisons programme/niveau/matiere actuellement
  /// renseignees dans le catalogue.
  static List<String> programmesDisponibles() {
    final cles = <String>[];
    for (final cle in _programmes.keys) {
      cles.add(cle);
    }
    cles.sort();
    return cles;
  }

  /// Liste des matieres disponibles pour un niveau dans le catalogue.
  static List<String> matieresDisponibles(
    String niveau, {
    String anneeScolaire = anneeCourante,
    String programmeVersion = programmeCourant,
    String serie = '',
  }) {
    final prefixe =
        '${anneeScolaire}_${programmeVersion}_${niveau}_${serie}_';
    final resultat = <String>[];

    for (final cle in _programmes.keys) {
      if (cle.startsWith(prefixe)) {
        resultat.add(cle.substring(prefixe.length));
      }
    }

    // Compatibilite avec les anciennes cles.
    if (resultat.isEmpty) {
      final ancienPrefixe = '${niveau}_';
      for (final cle in _programmes.keys) {
        if (cle.startsWith(ancienPrefixe)) {
          resultat.add(cle.substring(ancienPrefixe.length));
        }
      }
    }

    resultat.sort();
    return resultat;
  }

  // ==========================================================================
  //  INSTALLATION
  // ==========================================================================

  /// Cree dans Firestore tous les chapitres du programme officiel.
  ///
  /// Les metadonnees annee/programme/serie/theme sont ecrites dans chaque
  /// chapitre. Cela permet de conserver plusieurs versions d'un programme
  /// sans detruire l'historique.
  ///
  /// Le catalogue existant reste installable sans migration destructive.
  static Future<({int crees, int ignores})> installer(
    String niveau,
    String matiereId, {
    String anneeScolaire = anneeCourante,
    String programmeVersion = programmeCourant,
    String serie = '',
  }) async {
    int crees = 0;
    int ignores = 0;

    for (final c in chapitres(
      niveau,
      matiereId,
      anneeScolaire: anneeScolaire,
      programmeVersion: programmeVersion,
      serie: serie,
    )) {
      final res = await ContenuService.creerChapitre(
        Chapitre(
          id: '',
          code: Chapitre.construireCode(
            niveau,
            matiereId,
            c.ordre,
            anneeScolaire: anneeScolaire,
            programmeVersion: programmeVersion,
            serie: serie,
          ),
          niveau: niveau,
          matiereId: matiereId,
          titre: c.titre,
          description: c.description,
          ordre: c.ordre,
          anneeScolaire: anneeScolaire,
          programmeVersion: programmeVersion,
          serie: serie,
          theme: c.theme,
        ),
      );

      if (res.startsWith('!')) {
        ignores++;
      } else {
        crees++;
      }
    }

    return (crees: crees, ignores: ignores);
  }
}

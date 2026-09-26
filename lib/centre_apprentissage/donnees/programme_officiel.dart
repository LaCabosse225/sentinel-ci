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
    '6e_math': [
      ChapitreOfficiel(1, 'Nombres entiers naturels', 'Écriture, comparaison, opérations et propriétés des nombres entiers naturels.'),
      ChapitreOfficiel(2, 'Droites et points', 'Points, droites, demi-droites, segments, alignement et constructions.'),
      ChapitreOfficiel(3, 'Nombres décimaux relatifs', 'Repérage, comparaison et opérations sur les nombres décimaux relatifs.'),
      ChapitreOfficiel(4, 'Segments', 'Longueur, milieu, médiatrice et constructions de segments.'),
      ChapitreOfficiel(5, 'Pavés droits et cylindres droits', 'Patrons, aires et volumes des pavés droits et cylindres droits.'),
      ChapitreOfficiel(6, 'Fractions', 'Écriture, comparaison, opérations et problèmes avec les fractions.'),
      ChapitreOfficiel(7, 'Cercles et disques', 'Vocabulaire, constructions, périmètre et aire du disque.'),
      ChapitreOfficiel(8, 'Angles', 'Mesure, construction, angles particuliers et relations simples.'),
      ChapitreOfficiel(9, 'Triangles', 'Construction et propriétés des triangles.'),
      ChapitreOfficiel(10, 'Proportionnalité', 'Situations de proportionnalité, tableaux et calculs.'),
      ChapitreOfficiel(11, 'Figures symétriques par rapport à un point', 'Symétrie centrale et propriétés des figures.'),
      ChapitreOfficiel(12, 'Statistique', 'Collecte, organisation et représentation de données.'),
      ChapitreOfficiel(13, 'Parallélogramme', 'Construction et propriétés du parallélogramme.'),
    ],
    '5e_math': [
      ChapitreOfficiel(1, 'Nombres premiers', 'Nombres premiers, divisibilité, décomposition et critères.'),
      ChapitreOfficiel(2, 'Segments', 'Propriétés et constructions relatives aux segments.'),
      ChapitreOfficiel(3, 'Angles', 'Mesure, angles complémentaires, supplémentaires et configurations.'),
      ChapitreOfficiel(4, 'Nombres décimaux relatifs', 'Calcul et problèmes sur les nombres décimaux relatifs.'),
      ChapitreOfficiel(5, 'Figures symétriques par rapport à une droite', 'Symétrie axiale et propriétés des figures.'),
      ChapitreOfficiel(6, 'Fractions', 'Comparaison, opérations et résolution de problèmes.'),
      ChapitreOfficiel(7, 'Prismes droits', 'Patrons, aires et volumes des prismes droits.'),
      ChapitreOfficiel(8, 'Triangles', 'Propriétés, constructions et configurations de triangles.'),
      ChapitreOfficiel(9, 'Proportionnalité', 'Proportionnalité et applications.'),
      ChapitreOfficiel(10, 'Cercles', 'Cercle, constructions et propriétés.'),
      ChapitreOfficiel(11, 'Statistique', 'Organisation, représentation et interprétation des données.'),
      ChapitreOfficiel(12, 'Parallélogrammes particuliers', 'Rectangle, losange, carré et propriétés.'),
    ],
    '4e_math': [
      ChapitreOfficiel(1, 'Nombres décimaux relatifs', 'Calcul et problèmes avec les nombres décimaux relatifs.'),
      ChapitreOfficiel(2, 'Angles', 'Configurations et relations entre angles.'),
      ChapitreOfficiel(3, 'Nombres rationnels', 'Écritures, opérations et problèmes dans les rationnels.'),
      ChapitreOfficiel(4, 'Distances', 'Distance entre points et propriétés géométriques.'),
      ChapitreOfficiel(5, 'Perspective cavalière', 'Représentation plane des solides en perspective cavalière.'),
      ChapitreOfficiel(6, 'Calcul littéral', 'Expressions littérales, développement, réduction et factorisation.'),
      ChapitreOfficiel(7, 'Cercles et triangles', 'Propriétés et constructions de configurations géométriques.'),
      ChapitreOfficiel(8, 'Équations et inéquations dans ℚ', 'Résolution et problèmes.'),
      ChapitreOfficiel(9, 'Vecteurs', 'Égalité, opérations et applications géométriques des vecteurs.'),
      ChapitreOfficiel(10, 'Statistique', 'Organisation, représentation et analyse de données.'),
      ChapitreOfficiel(11, 'Symétries et translations', 'Transformations du plan et propriétés.'),
    ],
    '2nde_A_math': [
      ChapitreOfficiel(1, 'Calcul numérique', 'Ensembles de nombres et calculs numériques.'),
      ChapitreOfficiel(2, 'Dénombrement', 'Principes de dénombrement et problèmes.'),
      ChapitreOfficiel(3, 'Calcul littéral', 'Expressions algébriques et transformations.'),
      ChapitreOfficiel(4, 'Équations et inéquations dans ℝ', 'Résolution et problèmes.'),
      ChapitreOfficiel(5, 'Généralités sur les fonctions', 'Vocabulaire, représentations et variations.'),
      ChapitreOfficiel(6, 'Étude de fonctions élémentaires', 'Fonctions usuelles et lecture graphique.'),
      ChapitreOfficiel(7, 'Statistique', 'Séries statistiques et indicateurs.'),
      ChapitreOfficiel(8, 'Systèmes d’équations linéaires dans ℝ × ℝ', 'Résolution algébrique et graphique.'),
    ],
    '2nde_C_math': [
      ChapitreOfficiel(1, 'Vecteurs et points du plan', 'Vecteurs, repérage et opérations.'),
      ChapitreOfficiel(2, 'Ensemble des nombres réels', 'Ensembles numériques et calculs.'),
      ChapitreOfficiel(3, 'Utilisation des symétries et translations', 'Transformations et propriétés.'),
      ChapitreOfficiel(4, 'Généralités sur les fonctions', 'Notion de fonction et représentations.'),
      ChapitreOfficiel(5, 'Droites et plans de l’espace', 'Géométrie de l’espace.'),
      ChapitreOfficiel(6, 'Fonctions polynômes et fractions rationnelles', 'Expressions, fonctions et propriétés.'),
      ChapitreOfficiel(7, 'Angles inscrits', 'Configurations et mesures d’angles.'),
      ChapitreOfficiel(8, 'Angles orientés et trigonométrie', 'Angles orientés et relations trigonométriques.'),
      ChapitreOfficiel(9, 'Statistique à une variable', 'Séries statistiques et indicateurs.'),
      ChapitreOfficiel(10, 'Produit scalaire', 'Produit scalaire et applications.'),
      ChapitreOfficiel(11, 'Équations et inéquations dans ℝ', 'Résolution et problèmes.'),
      ChapitreOfficiel(12, 'Homothéties', 'Homothéties et configurations.'),
      ChapitreOfficiel(13, 'Étude de fonctions élémentaires', 'Étude et représentation graphique.'),
      ChapitreOfficiel(14, 'Rotations', 'Rotation et propriétés.'),
      ChapitreOfficiel(15, 'Inéquations dans ℝ × ℝ', 'Résolution et représentation graphique.'),
    ],
    '1ere_A1_math': [
      ChapitreOfficiel(1, 'Équations et inéquations', 'Résolution d’équations et d’inéquations.'),
      ChapitreOfficiel(2, 'Dénombrement', 'Techniques de dénombrement.'),
      ChapitreOfficiel(3, 'Généralités sur les fonctions', 'Notion de fonction et représentations.'),
      ChapitreOfficiel(4, 'Dérivabilité et étude de fonctions', 'Dérivée et étude des variations.'),
      ChapitreOfficiel(5, 'Suites numériques', 'Suites et propriétés.'),
      ChapitreOfficiel(6, 'Statistique', 'Séries statistiques.'),
      ChapitreOfficiel(7, 'Systèmes d’équations dans ℝ × ℝ', 'Systèmes linéaires.'),
    ],
    '1ere_A2_math': [
      ChapitreOfficiel(1, 'Équations et inéquations dans ℝ', 'Résolution et problèmes.'),
      ChapitreOfficiel(2, 'Dénombrement', 'Techniques de dénombrement.'),
      ChapitreOfficiel(3, 'Généralités sur les fonctions', 'Fonctions et représentations.'),
      ChapitreOfficiel(4, 'Dérivabilité et étude de fonctions', 'Dérivée, variations et optimisation.'),
      ChapitreOfficiel(5, 'Suites numériques', 'Suites et propriétés.'),
      ChapitreOfficiel(6, 'Statistique', 'Séries statistiques.'),
      ChapitreOfficiel(7, 'Systèmes d’équations linéaires dans ℝ × ℝ', 'Systèmes linéaires.'),
    ],
    '1ere_C_math': [
      ChapitreOfficiel(1, 'Équations et inéquations dans ℝ', 'Résolution d’équations et d’inéquations.'),
      ChapitreOfficiel(2, 'Angles orientés et trigonométrie', 'Angles orientés et trigonométrie.'),
      ChapitreOfficiel(3, 'Généralités sur les fonctions', 'Fonctions et représentations.'),
      ChapitreOfficiel(4, 'Barycentre', 'Barycentre et applications.'),
      ChapitreOfficiel(5, 'Limites et continuité', 'Limites et continuité.'),
      ChapitreOfficiel(6, 'Dénombrement', 'Principes de dénombrement.'),
      ChapitreOfficiel(7, 'Extension de la notion de limite', 'Approfondissement des limites.'),
      ChapitreOfficiel(8, 'Composées de transformations du plan', 'Compositions de transformations.'),
      ChapitreOfficiel(9, 'Dérivation', 'Dérivation et applications.'),
      ChapitreOfficiel(10, 'Orthogonalité de l’espace', 'Géométrie et orthogonalité.'),
      ChapitreOfficiel(11, 'Étude et représentation graphique d’une fonction', 'Étude complète et représentation.'),
      ChapitreOfficiel(12, 'Probabilité', 'Probabilités.'),
      ChapitreOfficiel(13, 'Systèmes d’équations linéaires dans ℝ² et ℝ³', 'Systèmes linéaires.'),
      ChapitreOfficiel(14, 'Géométrie analytique du plan', 'Repérage et géométrie analytique.'),
      ChapitreOfficiel(15, 'Suites numériques', 'Suites et propriétés.'),
      ChapitreOfficiel(16, 'Vecteurs de l’espace', 'Vecteurs dans l’espace.'),
      ChapitreOfficiel(17, 'Statistique à une variable', 'Statistique.'),
    ],
    '1ere_D_math': [
      ChapitreOfficiel(1, 'Équations et inéquations du second degré dans ℝ', 'Équations et inéquations du second degré.'),
      ChapitreOfficiel(2, 'Angles orientés et trigonométrie', 'Angles orientés et trigonométrie.'),
      ChapitreOfficiel(3, 'Généralités sur les fonctions', 'Fonctions et représentations.'),
      ChapitreOfficiel(4, 'Limites et continuité', 'Limites et continuité.'),
      ChapitreOfficiel(5, 'Dénombrement', 'Principes de dénombrement.'),
      ChapitreOfficiel(6, 'Dérivation', 'Dérivation et applications.'),
      ChapitreOfficiel(7, 'Extension de la notion de limite', 'Approfondissement des limites.'),
      ChapitreOfficiel(8, 'Barycentre', 'Barycentre et applications.'),
      ChapitreOfficiel(9, 'Étude et représentation graphique d’une fonction', 'Étude complète de fonctions.'),
      ChapitreOfficiel(10, 'Probabilité', 'Probabilités.'),
      ChapitreOfficiel(11, 'Suites numériques', 'Suites et propriétés.'),
      ChapitreOfficiel(12, 'Composées de transformations du plan', 'Compositions de transformations.'),
      ChapitreOfficiel(13, 'Statistique à une variable', 'Statistique.'),
      ChapitreOfficiel(14, 'Systèmes d’équations linéaires dans ℝ² et ℝ³', 'Systèmes linéaires.'),
      ChapitreOfficiel(15, 'Orthogonalité dans l’espace', 'Géométrie de l’espace.'),
    ],
    'Tle_A1_math': [
      ChapitreOfficiel(1, 'Étude de fonctions polynômes et de fonctions rationnelles', 'Étude des fonctions polynômes et rationnelles.'),
      ChapitreOfficiel(2, 'Probabilité et variable aléatoire', 'Probabilités et variables aléatoires.'),
      ChapitreOfficiel(3, 'Primitives et calcul intégral', 'Primitives et intégrales.'),
      ChapitreOfficiel(4, 'Fonction logarithme népérien', 'Fonction logarithme népérien.'),
      ChapitreOfficiel(5, 'Fonction exponentielle népérienne', 'Fonction exponentielle népérienne.'),
      ChapitreOfficiel(6, 'Statistique à deux variables', 'Statistique à deux variables.'),
      ChapitreOfficiel(7, 'Suites numériques', 'Suites numériques.'),
      ChapitreOfficiel(8, 'Systèmes d’équations linéaires dans ℝ × ℝ', 'Systèmes linéaires.'),
    ],
    'Tle_A2_math': [
      ChapitreOfficiel(1, 'Étude de fonctions polynômes et de fonctions rationnelles', 'Étude des fonctions polynômes et rationnelles.'),
      ChapitreOfficiel(2, 'Probabilité', 'Probabilités.'),
      ChapitreOfficiel(3, 'Fonction logarithme népérien', 'Fonction logarithme népérien.'),
      ChapitreOfficiel(4, 'Fonction exponentielle népérienne', 'Fonction exponentielle népérienne.'),
      ChapitreOfficiel(5, 'Statistique à deux variables', 'Statistique à deux variables.'),
      ChapitreOfficiel(6, 'Suites numériques', 'Suites numériques.'),
      ChapitreOfficiel(7, 'Systèmes d’équations linéaires dans ℝ × ℝ', 'Systèmes linéaires.'),
    ],
    'Tle_C_math': [
      ChapitreOfficiel(1, 'Barycentre et lignes de niveaux', 'Barycentre et lignes de niveaux.'),
      ChapitreOfficiel(2, 'Limites et continuité', 'Limites et continuité.'),
      ChapitreOfficiel(3, 'Divisibilité dans ℤ', 'Divisibilité dans les entiers relatifs.'),
      ChapitreOfficiel(4, 'Dérivabilité et étude de fonctions', 'Dérivation et étude de fonctions.'),
      ChapitreOfficiel(5, 'Géométrie analytique de l’espace', 'Géométrie analytique de l’espace.'),
      ChapitreOfficiel(6, 'Primitives', 'Primitives.'),
      ChapitreOfficiel(7, 'Fonctions logarithmes', 'Fonctions logarithmes.'),
      ChapitreOfficiel(8, 'Coniques', 'Coniques.'),
      ChapitreOfficiel(9, 'Fonctions exponentielles et fonctions puissances', 'Fonctions exponentielles et puissances.'),
      ChapitreOfficiel(10, 'Nombres complexes', 'Nombres complexes.'),
      ChapitreOfficiel(11, 'PPCM et PGCD de deux entiers relatifs', 'PPCM et PGCD.'),
      ChapitreOfficiel(12, 'Suites numériques', 'Suites numériques.'),
      ChapitreOfficiel(13, 'Isométries du plan', 'Isométries.'),
      ChapitreOfficiel(14, 'Calcul intégral', 'Calcul intégral.'),
      ChapitreOfficiel(15, 'Similitudes directes du plan', 'Similitudes directes.'),
      ChapitreOfficiel(16, 'Probabilité conditionnelle et variable aléatoire', 'Probabilités conditionnelles et variables aléatoires.'),
      ChapitreOfficiel(17, 'Nombres complexes et géométrie du plan', 'Applications géométriques des complexes.'),
      ChapitreOfficiel(18, 'Statistique à deux variables', 'Statistique à deux variables.'),
      ChapitreOfficiel(19, 'Équations différentielles', 'Équations différentielles.'),
    ],
    'Tle_D_math': [
      ChapitreOfficiel(1, 'Limites et continuité', 'Limites et continuité.'),
      ChapitreOfficiel(2, 'Probabilité conditionnelle et variable aléatoire', 'Probabilités conditionnelles et variables aléatoires.'),
      ChapitreOfficiel(3, 'Dérivabilité et étude de fonctions', 'Dérivation et étude de fonctions.'),
      ChapitreOfficiel(4, 'Primitives', 'Primitives.'),
      ChapitreOfficiel(5, 'Fonctions logarithmes', 'Fonctions logarithmes.'),
      ChapitreOfficiel(6, 'Fonctions exponentielles et puissances', 'Fonctions exponentielles et puissances.'),
      ChapitreOfficiel(7, 'Suites numériques', 'Suites numériques.'),
      ChapitreOfficiel(8, 'Nombres complexes', 'Nombres complexes.'),
      ChapitreOfficiel(9, 'Calcul intégral', 'Calcul intégral.'),
      ChapitreOfficiel(10, 'Nombres complexes et géométrie du plan', 'Applications géométriques des complexes.'),
      ChapitreOfficiel(11, 'Statistiques à deux variables', 'Statistique à deux variables.'),
      ChapitreOfficiel(12, 'Équations différentielles', 'Équations différentielles.'),
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

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
  const ChapitreOfficiel(this.ordre, this.titre, this.description);
}

class ProgrammeOfficiel {
  ProgrammeOfficiel._();

  // --------------------------------------------------------------------------
  //  CATALOGUE
  // --------------------------------------------------------------------------

  static const Map<String, List<ChapitreOfficiel>> _programmes = {
    // ════════════════════════════════════════════════════════════════════
    //  MATHEMATIQUES — 3e  (13 lecons, 4 h/semaine, 128 h/an)
    //  Ordre choisi pour respecter la dependance signalee par le guide
    //  d'execution : « Triangle rectangle » vient apres « Racines carrees ».
    // ════════════════════════════════════════════════════════════════════
    '3e_math': [
      ChapitreOfficiel(1, 'Calcul litteral',
          'Polynomes, fractions rationnelles, puissances d exposant entier relatif, developpement, reduction, factorisation.'),
      ChapitreOfficiel(2, 'Racines carrees',
          'Nombres reels, valeur absolue, expression conjuguee, operations avec les radicaux.'),
      ChapitreOfficiel(3, 'Calcul numerique',
          'Intervalles, encadrements, comparaison de nombres, arrondis d ordre 1, 2 ou 3.'),
      ChapitreOfficiel(4, 'Equations et inequations du premier degre dans R',
          'Resolution des equations et inequations, systemes de deux inequations, problemes du premier degre.'),
      ChapitreOfficiel(5, 'Equations et inequations du premier degre dans R x R',
          'Systemes de deux equations : substitution, combinaison, resolution graphique.'),
      ChapitreOfficiel(6, 'Applications affines',
          'Applications affines et lineaires, representation graphique, sens de variation, proportionnalite.'),
      ChapitreOfficiel(7, 'Statistique',
          'Effectifs et frequences cumules croissants, mediane, classe modale, diagramme circulaire.'),
      ChapitreOfficiel(8, 'Triangle rectangle',
          'Propriete de Pythagore et sa reciproque, sinus, cosinus et tangente d un angle aigu.'),
      ChapitreOfficiel(9, 'Proprietes de Thales dans un triangle',
          'Propriete de Thales, sa reciproque, sa consequence, partage d un segment.'),
      ChapitreOfficiel(10, 'Angles inscrits',
          'Angle inscrit, arc intercepte, angle au centre associe, egalite de mesures.'),
      ChapitreOfficiel(11, 'Vecteurs',
          'Somme, difference, produit d un vecteur par un reel, colinearite, orthogonalite.'),
      ChapitreOfficiel(12, 'Coordonnees d un vecteur',
          'Reperes du plan, coordonnees, milieu d un segment, distance de deux points.'),
      ChapitreOfficiel(13, 'Equations de droites',
          'Equation d une droite, coefficient directeur, droites paralleles et perpendiculaires.'),
    ],

    // Prochains programmes a ajouter ici : '3e_pc', '3e_svt', '3e_franc',
    // 'Tle_math', etc. Meme structure, rien d autre a modifier dans le code.
  };

  // --------------------------------------------------------------------------
  //  ACCES
  // --------------------------------------------------------------------------

  static String _cle(String niveau, String matiereId) => '${niveau}_$matiereId';

  /// Vrai si un programme officiel est disponible pour ce couple.
  static bool existe(String niveau, String matiereId) =>
      _programmes.containsKey(_cle(niveau, matiereId));

  /// Les lecons du programme, ou une liste vide s il n y en a pas.
  static List<ChapitreOfficiel> chapitres(String niveau, String matiereId) =>
      _programmes[_cle(niveau, matiereId)] ?? const [];

  // --------------------------------------------------------------------------
  //  INSTALLATION
  // --------------------------------------------------------------------------

  /// Cree dans Firestore tous les chapitres du programme officiel.
  /// Les chapitres deja presents ne sont ni ecrases ni dupliques.
  /// Renvoie le nombre de chapitres crees et le nombre ignores.
  static Future<({int crees, int ignores})> installer(
      String niveau, String matiereId) async {
    int crees = 0;
    int ignores = 0;
    for (final c in chapitres(niveau, matiereId)) {
      final res = await ContenuService.creerChapitre(Chapitre(
        id: '', // fabrique automatiquement : "3e_math_ch08"
        niveau: niveau,
        matiereId: matiereId,
        titre: c.titre,
        description: c.description,
        ordre: c.ordre,
      ));
      if (res.startsWith('!')) {
        ignores++; // le chapitre existe deja
      } else {
        crees++;
      }
    }
    return (crees: crees, ignores: ignores);
  }
}

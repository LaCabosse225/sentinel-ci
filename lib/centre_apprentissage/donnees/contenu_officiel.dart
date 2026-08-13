// ============================================================================
//  SENTINEL CI — CENTRE D'APPRENTISSAGE
//  Contenu pedagogique pret a installer
//  Fichier : lib/centre_apprentissage/donnees/contenu_officiel.dart
//
//  Meme principe que programme_officiel.dart, mais pour le CONTENU des
//  chapitres : cours, renforcement, exercices, fiche et quiz.
//  Un bouton du back-office installe tout un chapitre d'un seul geste.
//
//  POUR AJOUTER UN CHAPITRE
//  Ajouter une entree dans _catalogue, avec pour cle l'identifiant du
//  chapitre ("3e_math_ch09"). Rien d'autre a modifier dans le code.
//
//  Les ressources sont installees en BROUILLON : elles restent invisibles
//  pour les eleves jusqu'a relecture et publication par un adulte.
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

  static bool existe(String chapitreId) => _catalogue.containsKey(chapitreId);

  static List<RessourceOfficielle> ressources(String chapitreId) =>
      _catalogue[chapitreId] ?? const [];

  /// Cree toutes les ressources du chapitre, en brouillon.
  /// Renvoie le nombre de ressources creees.
  static Future<int> installer(Chapitre chapitre, String auteurUid) async {
    int crees = 0;
    for (final r in ressources(chapitre.id)) {
      final res = await ContenuService.creerRessource(Ressource(
        id: '',
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
      ));
      if (!res.startsWith('!')) crees++;
    }
    return crees;
  }

  // ==========================================================================
  //  CATALOGUE
  // ==========================================================================

  static final Map<String, List<RessourceOfficielle>> _catalogue = {
    // ════════════════════════════════════════════════════════════════════
    //  3e MATHEMATIQUES — CHAPITRE 9 : PROPRIETES DE THALES
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch09': [
      // ---------- COURS ----------
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Les propriétés de Thalès dans un triangle',
        ordre: 1,
        contenu: r'''
1. LA CONFIGURATION DE THALÈS

On se place dans un triangle ABC.
Soit M un point de la droite (AB) et N un point de la droite (AC).

Si les droites (MN) et (BC) sont parallèles, on dit qu'on est dans une
configuration de Thalès.

Deux formes reviennent tout le temps :
- la forme « triangle » : M entre A et B, N entre A et C ;
- la forme « papillon » : M et N de l'autre côté du point A.

Dans les deux cas, la propriété s'applique de la même façon.


2. LA PROPRIÉTÉ DE THALÈS

Dans un triangle ABC, si M appartient à (AB), N appartient à (AC) et si
(MN) est parallèle à (BC), alors :

    AM / AB = AN / AC = MN / BC

Ces trois rapports sont égaux. On les appelle le rapport de réduction ou
d'agrandissement.

À quoi cela sert-il ?
À calculer une longueur inaccessible, à partir de longueurs mesurables.


3. LA RÉCIPROQUE DE LA PROPRIÉTÉ DE THALÈS

Dans un triangle ABC, si M appartient à (AB), N appartient à (AC), si les
points A, M, B et A, N, C sont placés dans le même ordre, et si :

    AM / AB = AN / AC

alors les droites (MN) et (BC) sont parallèles.

À quoi cela sert-il ?
À démontrer que deux droites sont parallèles, sans règle ni équerre.

ATTENTION : la condition sur l'ordre des points est indispensable. Sans
elle, la réciproque est fausse.


4. LA CONSÉQUENCE DE LA PROPRIÉTÉ

Si les rapports AM / AB et AN / AC ne sont PAS égaux, alors les droites
(MN) et (BC) ne sont pas parallèles.

C'est ce qu'on utilise pour démontrer qu'un dessin est faux, ou qu'une
construction n'est pas correcte.


5. PARTAGE D'UN SEGMENT

La propriété de Thalès permet de partager un segment en parts égales, sans
mesurer, uniquement avec une règle et un compas.

Méthode pour partager [AB] en n parts égales :
1. Tracer une demi-droite [Ax) quelconque, non alignée avec (AB).
2. Reporter n segments de même longueur sur [Ax) : A1, A2, ... An.
3. Tracer le segment [An B].
4. Tracer les parallèles à (An B) passant par A1, A2, ...
5. Ces parallèles coupent [AB] en n parts égales.


6. À QUOI CELA SERT DANS LA VIE COURANTE

Mesurer la largeur d'une lagune sans la traverser, la hauteur d'un arbre
avec son ombre, ou reproduire un plan à l'échelle : ce sont toutes des
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

Cherche le point de croisement : c'est le sommet commun, souvent appelé A.
Depuis ce point partent deux droites. Deux autres droites les coupent, et
elles sont parallèles entre elles.

Si tu ne trouves pas de parallèles dans l'énoncé, Thalès ne s'applique pas.


ÉTAPE 2 — Écrire les rapports dans le bon ordre

C'est là que la plupart des erreurs se produisent.

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
que le grand segment, tu t'es trompé quelque part. Reprends l'écriture des
rapports.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : appliquer Thalès sans parallèles.
Sans droites parallèles, la propriété est fausse. Vérifie que l'énoncé le
dit, ou démontre-le d'abord.

Erreur 2 : mélanger les rapports.
AM / AB = AC / AN est faux. Les deux numérateurs doivent partir du même
point.

Erreur 3 : confondre la propriété et la réciproque.
La propriété : on SAIT que c'est parallèle, on calcule une longueur.
La réciproque : on calcule des rapports, on DÉMONTRE que c'est parallèle.

Erreur 4 : oublier la condition d'ordre dans la réciproque.
En devoir, cette phrase rapporte des points. Ne la saute pas.

Erreur 5 : garder une fraction non simplifiée.
6/9 doit devenir 2/3. C'est plus propre et cela évite les erreurs de calcul.


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
Pour mesurer la largeur d'une lagune à Grand-Bassam sans la traverser, un
géomètre a réalisé le relevé suivant.

Il note A un point sur la rive, B et C deux repères de l'autre côté.
Il place M sur [AB] et N sur [AC] de façon que (MN) soit parallèle à (BC).

Il mesure :
    AM = 12 m,  AB = 48 m,  MN = 9 m.

Quelle est la largeur BC de la lagune ?
''',
        solution: r'''
On sait que M appartient à [AB], N appartient à [AC] et que (MN) est
parallèle à (BC).

D'après la propriété de Thalès :

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
long d'une même ligne droite partant d'un piquet A.

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

D'une part :

    AB / AC = 5 / 8 = 0,625

D'autre part :

    BM / CN = 3 / 4,5 = 0,666...


Les deux rapports ne sont pas égaux :

    5 / 8 ≠ 3 / 4,5


CONCLUSION : les points A, M et N ne sont pas alignés.


REMARQUE IMPORTANTE
On a utilisé ici la CONSÉQUENCE de la propriété de Thalès : quand les
rapports ne sont pas égaux, la configuration de Thalès n'est pas vérifiée.

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

D'une part :

    AM / AB = 24 / 60 = 2 / 5

D'autre part :

    AN / AC = 18 / 45 = 2 / 5

On constate que :

    AM / AB = AN / AC

D'après la RÉCIPROQUE de la propriété de Thalès, les droites (MN) et (BC)
sont parallèles.


2) LONGUEUR DE LA CORDE

Puisque (MN) est parallèle à (BC), la propriété de Thalès s'applique :

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


CE QU'IL FAUT RETENIR
Le rapport de réduction est 2/5, et il se retrouve partout : sur chaque
côté, et donc sur le périmètre entier. C'est une propriété très utile en
devoir, et elle tombe régulièrement au BEPC.

Attention en revanche : cela ne marche PAS pour les aires. L'aire est
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


LA RÈGLE D'ÉCRITURE

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
- Ne jamais oublier la condition d'ordre des points dans la réciproque.
- Simplifier les fractions avant le produit en croix.
- Écrire l'unité dans la conclusion.


LA PHRASE TYPE À RECOPIER EN DEVOIR

« Les points A, M, B d'une part et A, N, C d'autre part sont alignés dans
le même ordre. De plus (MN) // (BC). D'après la propriété de Thalès :
AM / AB = AN / AC = MN / BC. »

« D'une part AM / AB = ... D'autre part AN / AC = ...
Donc AM / AB = AN / AC. Les points étant alignés dans le même ordre,
d'après la réciproque de la propriété de Thalès, (MN) // (BC). »
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
  };
}

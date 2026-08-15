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
    //  3e MATHEMATIQUES — CHAPITRE 1 : CALCUL LITTERAL
    // ════════════════════════════════════════════════════════════════════
    '3e_math_ch01': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Le calcul littéral',
        ordre: 1,
        contenu: r'''
1. POURQUOI CALCULER AVEC DES LETTRES

Une lettre remplace un nombre que l'on ne connaît pas encore, ou qui peut
changer. Écrire une formule avec des lettres permet de la réutiliser autant
de fois qu'on veut, avec n'importe quelle valeur.

Exemple : le périmètre d'un rectangle s'écrit P = 2(L + l).
Cette seule ligne remplace une infinité de calculs.


2. VOCABULAIRE DES POLYNÔMES

Un monôme est un produit d'un nombre et d'une ou plusieurs lettres :
    5x²    -3xy    7

Un polynôme est une somme de monômes :
    3x² - 5x + 2

Chaque monôme s'appelle un terme. Le nombre placé devant la lettre est le
coefficient. Dans 3x², le coefficient est 3 et le degré est 2.

Le degré d'un polynôme est le plus grand degré de ses termes.
    3x² - 5x + 2  est de degré 2.


3. RÉDUIRE UN POLYNÔME

Réduire, c'est regrouper les termes semblables, c'est-à-dire ceux qui ont
exactement la même partie littérale.

    5x + 3x = 8x            (on peut regrouper)
    5x + 3x² : impossible   (x et x² sont différents)

Exemple complet :
    2x² + 5x - 3x² + x - 4
  = (2x² - 3x²) + (5x + x) - 4
  = -x² + 6x - 4


4. DÉVELOPPER

Développer, c'est transformer un produit en somme.

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
Tous les signes à l'intérieur changent.


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

Factoriser, c'est l'opération inverse : transformer une somme en produit.

Méthode 1 — le facteur commun :
    6x² + 9x = 3x(2x + 3)

Méthode 2 — une identité remarquable lue de droite à gauche :
    x² - 16 = x² - 4² = (x + 4)(x - 4)
    x² + 6x + 9 = (x + 3)²

Méthode 3 — le facteur commun est une parenthèse :
    (x + 1)(x - 2) + (x + 1)(3x) = (x + 1)(x - 2 + 3x) = (x + 1)(4x - 2)


7. LES PUISSANCES D'EXPOSANT ENTIER RELATIF

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

Condition d'existence : le dénominateur ne doit jamais être nul.
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

C'est l'erreur la plus fréquente au BEPC, et elle coûte cher.

    A = 5x - (2x - 3)

Beaucoup écrivent : 5x - 2x - 3 = 3x - 3. C'est FAUX.

Le moins devant la parenthèse change TOUS les signes à l'intérieur :
    A = 5x - 2x + 3 = 3x + 3

L'astuce : imagine que le moins est un -1 qui multiplie tout.
    -(2x - 3) = -1 × 2x + (-1) × (-3) = -2x + 3


RECONNAÎTRE UNE IDENTITÉ REMARQUABLE

Trois questions dans l'ordre :

1. Y a-t-il DEUX termes séparés par un moins, tous deux des carrés ?
   → c'est a² - b² = (a + b)(a - b)
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

Étape 4 : n'oublie pas de réduire ce qui reste dans la parenthèse.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : (a + b)² = a² + b². FAUX.
Il manque le double produit. (a + b)² = a² + 2ab + b².
Vérifie toi-même avec a = 3 et b = 2 : (3+2)² = 25, mais 9 + 4 = 13.

Erreur 2 : oublier de réduire après avoir développé.
Un développement non réduit vaut rarement tous les points.

Erreur 3 : simplifier une fraction avant de factoriser.
    (x + 3)/(x + 6) ne se simplifie PAS en 3/6.
On ne simplifie que des FACTEURS, jamais des termes d'une somme.

Erreur 4 : oublier la condition d'existence d'une fraction.
Le dénominateur ne doit jamais être nul. Écris-le, cela rapporte des points.


CONSEIL POUR LE BEPC

Vérifie toujours ton résultat en remplaçant x par un nombre simple, par
exemple x = 1 ou x = 2, dans l'expression de départ et dans ton résultat.
Si tu trouves deux valeurs différentes, tu t'es trompé quelque part.
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

On vérifie le double produit : 2 × x × 4 = 8x. C'est bien le terme du
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

Il décide de l'agrandir : il ajoute 5 m sur la longueur et 5 m sur la
largeur, de façon à obtenir un nouveau carré.

1) Exprime l'aire du terrain de départ en fonction de x.
2) Exprime l'aire du nouveau terrain en fonction de x, sous forme
   développée et réduite.
3) Exprime, en fonction de x, l'aire gagnée par cet agrandissement.
4) Le terrain de départ mesurait 20 m de côté. Calcule l'aire gagnée.
''',
        solution: r'''
1) AIRE DU TERRAIN DE DÉPART

C'est un carré de côté x :

    Aire₁ = x²   (en m²)


2) AIRE DU NOUVEAU TERRAIN

Le nouveau côté mesure x + 5 mètres. C'est encore un carré :

    Aire₂ = (x + 5)²

On développe avec l'identité remarquable (a + b)² = a² + 2ab + b² :

    Aire₂ = x² + 2 × x × 5 + 5²
    Aire₂ = x² + 10x + 25   (en m²)


3) AIRE GAGNÉE

L'aire gagnée est la différence entre le nouveau terrain et l'ancien :

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


CE QU'IL FAUT RETENIR
Le gain n'est PAS égal à 5² = 25 m², comme on pourrait le croire.
Agrandir un carré de 5 m de côté ajoute deux bandes rectangulaires de
10x m² au total, plus un petit carré de 25 m². C'est exactement ce que dit
l'identité remarquable.
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

Tous les signes changent. C'est l'erreur la plus fréquente.


LES PUISSANCES

    a⁰ = 1
    a⁻ⁿ = 1/aⁿ
    aᵐ × aⁿ = aᵐ⁺ⁿ
    aᵐ / aⁿ = aᵐ⁻ⁿ
    (aᵐ)ⁿ = aᵐˣⁿ


FACTORISER : L'ORDRE DES RÉFLEXES

1. Un facteur commun ?
2. Une identité remarquable ?
3. Une parenthèse en commun ?
4. Réduire ce qui reste dans la parenthèse.


LES FRACTIONS RATIONNELLES

Condition d'existence : dénominateur ≠ 0. À écrire toujours.
On ne simplifie que des FACTEURS, jamais des termes d'une somme.


LES CARRÉS À RECONNAÎTRE AU PREMIER COUP D'ŒIL

    1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144


LA VÉRIFICATION QUI SAUVE

Remplace x par 1 ou par 2 dans l'expression de départ et dans ton
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
    '3e_math_ch02': [
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

ATTENTION : √a n'existe pas si a est négatif. √(-4) n'a pas de sens.


2. LES CARRÉS PARFAITS À CONNAÎTRE

    √1 = 1     √4 = 2     √9 = 3      √16 = 4    √25 = 5
    √36 = 6    √49 = 7    √64 = 8     √81 = 9    √100 = 10
    √121 = 11  √144 = 12  √169 = 13   √196 = 14  √225 = 15


3. LES NOMBRES RÉELS

L'ensemble des nombres réels, noté ℝ, contient :
    les entiers naturels (0, 1, 2, ...)
    les entiers relatifs (..., -2, -1, 0, 1, ...)
    les nombres décimaux et les fractions
    les nombres irrationnels comme √2 ou π

√2 est irrationnel : il ne peut pas s'écrire comme une fraction, et son
écriture décimale ne s'arrête jamais et ne se répète jamais.
√2 ≈ 1,414 213 56...


4. LA VALEUR ABSOLUE

La valeur absolue d'un nombre a, notée |a|, est sa distance à zéro.

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

Astuce : simplifie d'abord chaque racine, des termes semblables peuvent
apparaître.

    √8 + √18 = 2√2 + 3√2 = 5√2


8. L'EXPRESSION CONJUGUÉE

Rendre un dénominateur rationnel, c'est le débarrasser de sa racine.

Cas simple :
    3/√2 = 3√2/(√2 × √2) = 3√2/2

Cas avec une somme : on multiplie par l'expression conjuguée.
L'expression conjuguée de (a + √b) est (a - √b), et inversement.

    1/(√3 - 1)
  = (√3 + 1) / [(√3 - 1)(√3 + 1)]
  = (√3 + 1) / (3 - 1)
  = (√3 + 1) / 2

Cela fonctionne grâce à l'identité (a + b)(a - b) = a² - b², qui fait
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

Si tu ne retiens qu'une chose, retiens celle-là.


SIMPLIFIER UNE RACINE, PAS À PAS

Objectif : sortir le plus grand carré parfait possible.

Étape 1 — décompose le nombre en cherchant un carré parfait.
    Pour √48 : est-ce divisible par 4 ? par 9 ? par 16 ?
    48 = 16 × 3, et 16 est un carré parfait.

Étape 2 — sépare la racine.
    √48 = √16 × √3

Étape 3 — calcule la partie qui sort.
    √48 = 4√3

Si tu ne trouves pas le plus grand carré du premier coup, ce n'est pas
grave : recommence sur ce qui reste.
    √48 = √(4 × 12) = 2√12 = 2 × √(4 × 3) = 2 × 2√3 = 4√3
Même résultat, en deux temps.


COMMENT SAVOIR SI ON PEUT ADDITIONNER

Traite les radicaux comme des lettres en calcul littéral.

    3√5 + 2√5 = 5√5        comme 3x + 2x = 5x
    3√5 + 2√7 : impossible  comme 3x + 2y

Mais attention : simplifie TOUJOURS d'abord. Deux radicaux qui semblent
différents peuvent devenir identiques.

    √27 + √12 = 3√3 + 2√3 = 5√3


L'EXPRESSION CONJUGUÉE : POURQUOI ÇA MARCHE

Tu veux enlever la racine du dénominateur de 1/(√5 - 2).

L'idée : utiliser (a + b)(a - b) = a² - b², qui transforme les racines en
nombres entiers.

Multiplie en haut et en bas par le conjugué, c'est-à-dire la même
expression avec le signe opposé au milieu :

    1/(√5 - 2)
  = (√5 + 2) / [(√5 - 2)(√5 + 2)]
  = (√5 + 2) / (5 - 4)
  = (√5 + 2) / 1
  = √5 + 2

Le dénominateur devient un entier : c'est gagné.

Retiens le conjugué :
    de (√a + b), c'est (√a - b)
    de (√a - b), c'est (√a + b)


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : √(a + b) = √a + √b. FAUX, on l'a vu.

Erreur 2 : écrire √(-9) = -3. La racine d'un nombre négatif n'existe pas,
et une racine carrée n'est jamais négative.

Erreur 3 : oublier la valeur absolue.
√(x²) = |x|, pas x. Si x = -3, alors √((-3)²) = 3, pas -3.

Erreur 4 : laisser une racine au dénominateur.
En devoir, un résultat comme 1/√2 doit être écrit √2/2.

Erreur 5 : ne pas simplifier le résultat final.
√8 n'est pas une réponse aboutie : écris 2√2.


CONSEIL POUR LE BEPC

Apprends par cœur les carrés parfaits jusqu'à 225. Tu repéreras
instantanément qu'il faut sortir 12 de √144, et tu gagneras du temps sur
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

2) Réduis l'expression :
       A = √18 + √50 - √8

3) Calcule et simplifie :
       B = √3 × √12
''',
        solution: r'''
1) SIMPLIFICATION DES RACINES

√32 : on cherche le plus grand carré parfait qui divise 32. C'est 16.
    √32 = √(16 × 2) = √16 × √2 = 4√2

√75 : le plus grand carré parfait qui divise 75 est 25.
    √75 = √(25 × 3) = √25 × √3 = 5√3

√200 : le plus grand carré parfait qui divise 200 est 100.
    √200 = √(100 × 2) = √100 × √2 = 10√2


2) RÉDUCTION DE A

On simplifie d'abord chaque racine séparément :

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
On aurait aussi pu simplifier d'abord :
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

Numérateur — c'est une identité remarquable (a + b)² :

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
Simplifie toujours AVANT de conclure que c'est impossible.


L'EXPRESSION CONJUGUÉE

    conjugué de (√a + b)  →  (√a - b)
    conjugué de (√a - b)  →  (√a + b)

On multiplie en haut et en bas, et (a + b)(a - b) = a² - b² fait
disparaître la racine.

    1/(√3 - 1) = (√3 + 1)/2


LA VALEUR ABSOLUE

    |a| = a si a ≥ 0        |a| = -a si a < 0
    √(x²) = |x|, jamais x tout court


LES PIÈGES

- Une racine carrée n'est jamais négative.
- √(nombre négatif) n'existe pas.
- Ne jamais laisser de racine au dénominateur d'un résultat final.
- √8 n'est pas une réponse : écris 2√2.
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
    '3e_math_ch03': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Intervalles, encadrements et arrondis',
        ordre: 1,
        contenu: r'''
1. COMPARER DEUX NOMBRES

Comparer a et b, c'est déterminer lequel est le plus grand.

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
    [2 ; 5]  est l'ensemble des x tels que 2 ≤ x ≤ 5
    Les bornes 2 et 5 sont incluses.

Intervalle ouvert :
    ]2 ; 5[  est l'ensemble des x tels que 2 < x < 5
    Les bornes sont exclues.

Intervalles semi-ouverts :
    [2 ; 5[  signifie 2 ≤ x < 5
    ]2 ; 5]  signifie 2 < x ≤ 5

Intervalles non bornés :
    [3 ; +∞[  signifie x ≥ 3
    ]-∞ ; 4]  signifie x ≤ 4

Le crochet est TOURNÉ VERS LE NOMBRE quand la borne est incluse.
Vers l'infini, le crochet est toujours ouvert.


3. RÉUNION ET INTERSECTION

L'intersection de deux intervalles, notée ∩, est l'ensemble des nombres
qui appartiennent aux DEUX.

    [1 ; 6] ∩ [4 ; 9] = [4 ; 6]

La réunion, notée ∪, est l'ensemble des nombres qui appartiennent à l'UN
ou à l'AUTRE.

    [1 ; 3] ∪ [5 ; 8] : les deux morceaux, sans les nombres entre 3 et 5.


4. ENCADRER UN NOMBRE

Encadrer x, c'est trouver deux nombres a et b tels que a ≤ x ≤ b.

L'amplitude de l'encadrement est la différence b - a. Plus elle est
petite, plus l'encadrement est précis.

Exemple : 3,14 < π < 3,15 est un encadrement de π d'amplitude 0,01.


5. OPÉRATIONS SUR LES ENCADREMENTS

Addition — on additionne membre à membre :
    si  2 < x < 5  et  1 < y < 3
    alors  3 < x + y < 8

Multiplication par un nombre POSITIF — on multiplie tout :
    si  2 < x < 5   alors  6 < 3x < 15

Multiplication par un nombre NÉGATIF — l'ordre s'INVERSE :
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

L'ARRONDI est la valeur approchée la plus proche.

Règle : on regarde le chiffre qui suit le rang demandé.
    s'il vaut 0, 1, 2, 3 ou 4 → on garde le chiffre
    s'il vaut 5, 6, 7, 8 ou 9 → on ajoute 1 au chiffre

Exemples pour 7,3846 :
    arrondi d'ordre 1 (au dixième)    : 7,4
    arrondi d'ordre 2 (au centième)   : 7,38
    arrondi d'ordre 3 (au millième)   : 7,385


7. TRONCATURE

Tronquer, c'est couper sans arrondir.

Pour 7,3846 :
    troncature d'ordre 2 : 7,38   (on coupe, sans regarder la suite)
    arrondi d'ordre 2    : 7,38   (identique ici)

Pour 7,3876 :
    troncature d'ordre 2 : 7,38
    arrondi d'ordre 2    : 7,39   (différent)
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.renforcement,
        titre: 'Encadrements et intervalles, pas à pas',
        ordre: 1,
        contenu: r'''
LE CROCHET : COMMENT NE PLUS SE TROMPER

Imagine que le crochet est une main qui attrape le nombre.

    [2      la main est tournée vers 2 : elle l'attrape, 2 est INCLUS
    ]2      la main est tournée vers l'extérieur : 2 est EXCLU

Même logique à droite :
    5]      5 est inclus
    5[      5 est exclu

Vers l'infini, on ne peut jamais attraper : le crochet est toujours ouvert.
    [3 ; +∞[


TRADUIRE UNE PHRASE EN INTERVALLE

    « x est compris entre 2 et 7, bornes comprises »  →  [2 ; 7]
    « x est strictement supérieur à 4 »               →  ]4 ; +∞[
    « x est au plus égal à 10 »                       →  ]-∞ ; 10]
    « x est positif ou nul »                          →  [0 ; +∞[

Le mot « strictement » signifie toujours un crochet ouvert.


LA RÈGLE QUI PIÈGE TOUT LE MONDE

Multiplier un encadrement par un nombre NÉGATIF inverse l'ordre.

    Si  2 < x < 5

Multiplions par -1 :
    Faux : -2 < -x < -5   (impossible, -2 n'est pas inférieur à -5)
    Juste : -5 < -x < -2

Pourquoi ? Parce que sur la droite des nombres, multiplier par un négatif
retourne tout comme un miroir. Le plus grand devient le plus petit.

Le réflexe : après avoir multiplié par un négatif, RELIS ton encadrement.
Le nombre de gauche doit être le plus petit. Si ce n'est pas le cas,
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
Geste 2 — regarde le PREMIER chiffre après la barre : c'est 7.
          7 ≥ 5, donc on ajoute 1 à la dernière décimale gardée.

    Arrondi = 12,46

On ne regarde QUE le chiffre juste après. Pas les suivants.


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : oublier d'inverser l'encadrement après multiplication par un
négatif.

Erreur 2 : confondre arrondi et troncature. Tronquer, c'est couper.
Arrondir, c'est prendre le plus proche.

Erreur 3 : écrire l'intersection au lieu de la réunion.
∩ signifie « les deux à la fois », ∪ signifie « l'un ou l'autre ».

Erreur 4 : oublier de préciser l'amplitude quand elle est demandée.
L'amplitude est la différence entre les deux bornes.


CONSEIL POUR LE BEPC

Trace une droite graduée dès que tu manipules des intervalles. Hachure la
zone concernée. Beaucoup d'erreurs disparaissent quand on voit la
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

2) Détermine l'intersection [1 ; 8] ∩ [5 ; 12].

3) On sait que 3 < x < 7 et 2 < y < 4.
   Encadre x + y, puis 2x.

4) Donne l'arrondi d'ordre 2 du nombre 5,2748.
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

L'intersection est l'ensemble des nombres appartenant aux DEUX
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

Encadrement de 2x — on multiplie par 2, qui est positif, donc l'ordre est
conservé :

    3 < x < 7
    3 × 2 < 2x < 7 × 2
    6 < 2x < 14


4) ARRONDI D'ORDRE 2

Le nombre est 5,2748.
L'ordre 2 signifie deux chiffres après la virgule : 5,27

On regarde le chiffre suivant : c'est 4.
Comme 4 < 5, on garde le 7 sans le modifier.

    Arrondi d'ordre 2 : 5,27


ATTENTION
On ne regarde QUE le chiffre juste après le rang demandé. Le 8 final ne
doit pas être pris en compte, même s'il est grand.
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
2) Encadre l'aire du champ.
3) Donne l'amplitude de l'encadrement de l'aire, puis un arrondi d'ordre 0
   de l'aire moyenne.
''',
        solution: r'''
1) ENCADREMENT DU PÉRIMÈTRE

Le périmètre d'un rectangle est P = 2(L + l), soit P = 2L + 2l.

Encadrons d'abord 2L. On multiplie par 2, qui est positif : l'ordre est
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


2) ENCADREMENT DE L'AIRE

L'aire d'un rectangle est A = L × l.

Toutes les valeurs étant positives, on peut multiplier membre à membre :

    24,5 × 17,5 < L × l < 25,5 × 18,5

Calculons les deux produits.

    24,5 × 17,5 = 428,75
    25,5 × 18,5 = 471,75

Donc :

    428,75 < A < 471,75

CONCLUSION : l'aire est comprise entre 428,75 m² et 471,75 m².


3) AMPLITUDE ET ARRONDI

Amplitude de l'encadrement :

    471,75 - 428,75 = 43

L'amplitude vaut 43 m². L'incertitude est donc importante : une erreur de
50 cm sur chaque dimension entraîne une incertitude de 43 m² sur l'aire.

Aire moyenne — on prend le milieu de l'encadrement :

    (428,75 + 471,75) / 2 = 900,5 / 2 = 450,25

Arrondi d'ordre 0, c'est-à-dire à l'unité : le chiffre après la virgule
est 2, donc inférieur à 5. On garde 450.

    Aire moyenne ≈ 450 m²


CE QU'IL FAUT RETENIR
Une petite imprécision sur les mesures se traduit par une imprécision
beaucoup plus grande sur l'aire. C'est pour cela qu'un géomètre mesure au
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
Vers l'infini, le crochet est toujours ouvert.


INTERSECTION ET RÉUNION

    ∩  les deux à la fois
    ∪  l'un ou l'autre


COMPARER DEUX NOMBRES

Étudier le signe de la différence a - b.
    a - b > 0  →  a > b


OPÉRATIONS SUR LES ENCADREMENTS

Addition : on additionne membre à membre.
    2 < x < 5  et  1 < y < 3   →   3 < x + y < 8

Multiplication par un POSITIF : l'ordre est conservé.
    2 < x < 5   →   6 < 3x < 15

Multiplication par un NÉGATIF : l'ordre s'INVERSE.
    2 < x < 5   →   -15 < -3x < -6

Soustraction : encadrer -y, puis additionner.


AMPLITUDE

    amplitude = borne supérieure - borne inférieure

Plus elle est petite, plus l'encadrement est précis.


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

Pour 7,3876 : troncature d'ordre 2 = 7,38, arrondi d'ordre 2 = 7,39.


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
    '3e_math_ch04': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Équations et inéquations du premier degré dans ℝ',
        ordre: 1,
        contenu: r'''
1. QU'EST-CE QU'UNE ÉQUATION

Une équation est une égalité qui contient une inconnue, généralement notée x.

Résoudre l'équation, c'est trouver toutes les valeurs de x qui rendent
l'égalité vraie. Ces valeurs s'appellent les solutions.

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

Étape 1 : développer et réduire chaque membre s'il y a des parenthèses.
Étape 2 : regrouper les x d'un côté, les nombres de l'autre.
Étape 3 : diviser par le coefficient de x.
Étape 4 : vérifier en remplaçant dans l'équation de départ.

Exemple :

    5(x - 2) = 3x + 4
    5x - 10 = 3x + 4
    5x - 3x = 4 + 10
    2x = 14
    x = 7

Vérification : 5(7-2) = 25 et 3×7 + 4 = 25. C'est juste.


4. ÉQUATION-PRODUIT

Un produit de facteurs est nul si et seulement si l'un au moins des
facteurs est nul.

    A × B = 0   équivaut à   A = 0  ou  B = 0

Exemple :

    (x - 3)(2x + 8) = 0
    x - 3 = 0   ou   2x + 8 = 0
    x = 3       ou   x = -4

Les solutions sont 3 et -4.

C'est pour cela que la factorisation est si utile : elle transforme une
équation compliquée en deux équations simples.


5. LES INÉQUATIONS

Une inéquation utilise un des symboles <, >, ≤ ou ≥.

Les solutions ne sont plus un ou deux nombres, mais tout un INTERVALLE.

LA RÈGLE ESSENTIELLE :
Quand on multiplie ou divise les deux membres par un nombre NÉGATIF, le
sens de l'inégalité s'INVERSE.

    -2x < 6
    x > -3        (on a divisé par -2, donc < devient >)

Avec un nombre positif, rien ne change :

    3x < 12
    x < 4


6. ÉCRIRE L'ENSEMBLE DES SOLUTIONS

On peut l'écrire de trois façons :

    x > -3
    x ∈ ]-3 ; +∞[
    ou par une représentation sur une droite graduée, la zone hachurée.

Rappel : le crochet est fermé si la borne est incluse (≤ ou ≥), ouvert
sinon (< ou >).


7. SYSTÈME DE DEUX INÉQUATIONS

Résoudre un système, c'est chercher les nombres qui vérifient les DEUX
inéquations en même temps. On résout chacune séparément, puis on prend
l'INTERSECTION.

Exemple :

    2x - 1 ≥ 3        et        x + 4 < 10
    2x ≥ 4                      x < 6
    x ≥ 2                       x < 6

Intersection : 2 ≤ x < 6, soit x ∈ [2 ; 6[.


8. RÉSOUDRE UN PROBLÈME

Étape 1 : choisir l'inconnue et écrire ce qu'elle représente.
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
L'IMAGE DE LA BALANCE

Une équation, c'est une balance en équilibre. Le signe égal est le point
d'appui.

Tu peux faire ce que tu veux, à UNE condition : faire exactement la même
chose des deux côtés. Sinon la balance penche et l'égalité est fausse.

    Tu retires 5 à gauche ? Retire 5 à droite.
    Tu divises par 3 à gauche ? Divise par 3 à droite.


L'ORDRE DES OPÉRATIONS

Beaucoup d'élèves s'emmêlent parce qu'ils font tout en même temps. Fais-le
en trois temps, toujours dans le même ordre.

    7x - 4 = 3x + 12

Temps 1 — les x à gauche. Je retire 3x des deux côtés.
    7x - 3x - 4 = 12
    4x - 4 = 12

Temps 2 — les nombres à droite. J'ajoute 4 des deux côtés.
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
    -3 × (-10) = 30, et 30 ≥ 12. C'est vrai.
Or -10 ≤ -4. Donc c'est bien x ≤ -4.

LE RÉFLEXE : dès que tu divises par un négatif, entoure le symbole et
retourne-le. Fais-le systématiquement, même quand tu es sûr de toi.


COMMENT ÉVITER DE DIVISER PAR UN NÉGATIF

Astuce : range les x du côté où le coefficient est positif.

    5 - 2x < 3x + 20

Au lieu de tout mettre à gauche, mets les x à DROITE :
    5 - 20 < 3x + 2x
    -15 < 5x
    -3 < x

Aucune division par un négatif, donc aucun risque d'oublier d'inverser.


L'ÉQUATION-PRODUIT

Si tu vois (quelque chose)(quelque chose) = 0, ne développe surtout pas.

Un produit est nul quand l'un des facteurs est nul. Traite chaque
parenthèse séparément :

    (2x - 6)(x + 1) = 0
    2x - 6 = 0  ou  x + 1 = 0
    x = 3       ou  x = -1

Deux solutions. Développer t'aurait donné une équation du second degré,
que tu ne sais pas encore résoudre en 3e.


METTRE UN PROBLÈME EN ÉQUATION

Écris toujours cette phrase en premier :
    « Soit x le nombre de ... » ou « Soit x le prix de ... »

Puis traduis chaque phrase de l'énoncé en langage mathématique.

    « le double de »        →  2x
    « augmenté de 5 »       →  + 5
    « diminué de 5 »        →  - 5
    « le triple, moins 4 »  →  3x - 4
    « la somme vaut 30 »    →  ... = 30


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : oublier d'inverser le sens dans une inéquation.
Erreur 2 : développer une équation-produit au lieu de l'utiliser.
Erreur 3 : ne pas vérifier sa solution. La vérification prend dix secondes.
Erreur 4 : oublier la phrase de conclusion dans un problème.
Erreur 5 : garder une solution négative pour un prix ou un âge.


CONSEIL POUR LE BEPC

Vérifie TOUJOURS ta solution en la remplaçant dans l'équation de départ.
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
1) Résous l'équation :   4x - 9 = x + 6

2) Résous l'équation-produit :   (3x - 12)(x + 5) = 0

3) Résous l'inéquation :   -5x + 3 ≤ 18
   Donne l'ensemble des solutions sous forme d'intervalle.

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

Un produit est nul si l'un au moins de ses facteurs est nul :

    3x - 12 = 0        ou        x + 5 = 0
    3x = 12                     x = -5
    x = 4

    Les solutions sont 4 et -5.


3) INÉQUATION -5x + 3 ≤ 18

On isole le terme en x :

    -5x ≤ 18 - 3
    -5x ≤ 15

On divise par -5. ATTENTION : -5 est négatif, donc le sens de l'inégalité
s'inverse.

    x ≥ 15 / (-5)
    x ≥ -3

    L'ensemble des solutions est [-3 ; +∞[.

Vérification avec x = 0 : -5×0 + 3 = 3, et 3 ≤ 18. C'est vrai, et 0
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
conditions : c'est l'intersection.

    3 ≤ x < 7

    L'ensemble des solutions est [3 ; 7[.
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

On note x le nombre d'élèves participant à la sortie.

1) Exprime en fonction de x le prix payé avec chaque formule.
2) Pour quel nombre d'élèves les deux formules coûtent-elles le même prix ?
3) À partir de combien d'élèves la formule B devient-elle plus avantageuse ?
4) Le collège inscrit 45 élèves. Quelle formule doit-il choisir, et
   combien économise-t-il ?
''',
        solution: r'''
1) EXPRESSION DES DEUX PRIX

Soit x le nombre d'élèves.

Formule A : 5 000 F par élève, sans frais fixes.
    Prix A = 5000x

Formule B : 60 000 F fixes, plus 3 000 F par élève.
    Prix B = 3000x + 60000


2) ÉGALITÉ DES DEUX FORMULES

On résout l'équation Prix A = Prix B :

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

Le nombre d'élèves étant un entier, on ne peut pas s'arrêter à « x > 30 » :
il faut préciser 31.


4) CAS DE 45 ÉLÈVES

    Formule A : 5000 × 45 = 225 000 F
    Formule B : 3000 × 45 + 60000 = 135 000 + 60 000 = 195 000 F

Comme 45 > 30, la formule B est bien la plus avantageuse, ce qui confirme
la question 3.

Économie réalisée :

    225 000 - 195 000 = 30 000 F

CONCLUSION : le collège doit choisir la formule B et économise 30 000 F.


CE QU'IL FAUT RETENIR
Les frais fixes sont pénalisants quand le groupe est petit, mais deviennent
négligeables quand il grandit. C'est le raisonnement que fait tout
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
2. les x d'un côté, les nombres de l'autre
3. diviser par le coefficient de x
4. vérifier


LES DEUX RÈGLES

On peut ajouter ou retrancher le même nombre aux deux membres.
On peut multiplier ou diviser par un même nombre NON NUL.


ÉQUATION-PRODUIT

    A × B = 0    équivaut à    A = 0  ou  B = 0

Ne jamais développer une équation-produit : c'est un cadeau, on la garde
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

On résout chacune, puis on prend l'INTERSECTION.

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
- Toujours vérifier la solution dans l'équation de départ
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
    '3e_math_ch05': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Systèmes de deux équations à deux inconnues',
        ordre: 1,
        contenu: r'''
1. QU'EST-CE QU'UN SYSTÈME

Un système de deux équations du premier degré à deux inconnues s'écrit :

    ax + by = c
    a'x + b'y = c'

Résoudre le système, c'est trouver le COUPLE (x ; y) qui vérifie les deux
équations en même temps.

La solution n'est pas un nombre, mais un couple de nombres. On l'écrit
entre parenthèses, avec un point-virgule : (3 ; 5).


2. MÉTHODE 1 — LA SUBSTITUTION

On isole une inconnue dans une équation, puis on la remplace dans l'autre.

Exemple :

    x + 2y = 11        (1)
    3x - y = 5         (2)

Étape 1 — j'isole x dans (1) :
    x = 11 - 2y

Étape 2 — je remplace x par cette expression dans (2) :
    3(11 - 2y) - y = 5
    33 - 6y - y = 5
    33 - 7y = 5
    -7y = -28
    y = 4

Étape 3 — je remplace y par 4 dans l'expression de x :
    x = 11 - 2×4 = 11 - 8 = 3

    La solution est le couple (3 ; 4).

Quand choisir la substitution ? Quand une inconnue a pour coefficient 1
ou -1 : elle s'isole sans fraction.


3. MÉTHODE 2 — LA COMBINAISON

On multiplie les équations pour faire disparaître une inconnue par
addition ou soustraction.

Exemple :

    2x + 3y = 19       (1)
    5x - 2y = 4        (2)

Étape 1 — je veux éliminer y. Je multiplie (1) par 2 et (2) par 3 :
    4x + 6y = 38
    15x - 6y = 12

Étape 2 — j'additionne les deux lignes : les termes en y s'annulent.
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

Quand choisir la combinaison ? Quand aucune inconnue n'a un coefficient
égal à 1, ou quand des coefficients sont déjà opposés.


4. MÉTHODE 3 — LA RÉSOLUTION GRAPHIQUE

Chaque équation représente une DROITE dans un repère.

La solution du système correspond au POINT D'INTERSECTION des deux droites.

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
vérifie qu'une seule équation n'est pas une solution du système.


6. RÉSOUDRE UN PROBLÈME

Étape 1 : nommer les deux inconnues.
    « Soit x le prix d'un cahier et y le prix d'un stylo. »
Étape 2 : traduire chaque information en une équation.
Étape 3 : résoudre le système.
Étape 4 : vérifier dans l'énoncé, pas seulement dans les équations.
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
    OUI  → substitution : l'inconnue s'isole sans fraction
    NON  → combinaison : plus rapide et sans dénominateur

Y a-t-il déjà deux coefficients opposés, comme +2y et -2y ?
    OUI  → combinaison, il suffit d'additionner


LA SUBSTITUTION, PAS À PAS

    x + 3y = 14
    2x - y = 7

Le x de la première a pour coefficient 1 : c'est lui qu'on isole.

    x = 14 - 3y

Maintenant, dans la SECONDE équation, partout où il y a x, j'écris
(14 - 3y). Les parenthèses sont obligatoires.

    2(14 - 3y) - y = 7
    28 - 6y - y = 7
    28 - 7y = 7
    -7y = -21
    y = 3

Je reviens à mon expression de x :
    x = 14 - 3×3 = 14 - 9 = 5

    Solution : (5 ; 3)

L'erreur classique : remplacer dans la MÊME équation que celle utilisée
pour isoler. Cela donne 0 = 0, ce qui n'apprend rien. Il faut remplacer
dans l'AUTRE équation.


LA COMBINAISON, PAS À PAS

    4x + 3y = 27
    2x - 5y = -19

Objectif : faire disparaître une inconnue.

Je choisis d'éliminer x. Le coefficient de x est 4 dans la première et 2
dans la seconde. Si je multiplie la seconde par 2, j'obtiendrai 4x aussi.

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

Deux inconnues, donc deux phrases à traduire. Cherche dans l'énoncé les
deux informations chiffrées.

    « 3 cahiers et 5 stylos coûtent 2 400 F »   →   3x + 5y = 2400
    « 2 cahiers et 3 stylos coûtent 1 550 F »   →   2x + 3y = 1550

Nomme toujours tes inconnues AVANT d'écrire les équations. Sans cette
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

3) Vérifie chacune de tes solutions dans les deux équations d'origine.
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

On revient à l'expression de x :

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

1) Choisis les inconnues et mets le problème en système d'équations.
2) Résous le système.
3) Combien coûtent un cahier et un stylo ?
4) Une troisième famille veut acheter 6 cahiers et 4 stylos. Combien
   devra-t-elle payer ?
''',
        solution: r'''
1) MISE EN ÉQUATION

Soit x le prix d'un cahier, en francs CFA.
Soit y le prix d'un stylo, en francs CFA.

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

Vérification dans l'énoncé, pas seulement dans les équations :
    Famille Koné : 3×550 + 5×150 = 1650 + 750 = 2400 F ✓
    Famille Diallo : 2×550 + 3×150 = 1100 + 450 = 1550 F ✓

Les prix sont positifs et réalistes : la solution a du sens.


4) TROISIÈME FAMILLE

6 cahiers et 4 stylos :

    6 × 550 + 4 × 150
  = 3300 + 600
  = 3900

CONCLUSION : la troisième famille devra payer 3 900 F.


CE QU'IL FAUT RETENIR
Deux informations chiffrées dans l'énoncé donnent deux équations. C'est la
règle : autant d'équations que d'inconnues, sinon le problème n'a pas de
solution unique.
''',
      ),

      RessourceOfficielle(
        type: TypeRessource.fiche,
        titre: 'Systèmes — l\'essentiel en 5 minutes',
        ordre: 1,
        contenu: r'''
LA FORME D'UN SYSTÈME

    ax + by = c
    a'x + b'y = c'

La solution est un COUPLE, noté (x ; y) avec un point-virgule.


CHOISIR SA MÉTHODE

Un coefficient vaut 1 ou -1        →  SUBSTITUTION
Aucun coefficient simple           →  COMBINAISON
Des coefficients déjà opposés      →  COMBINAISON, on additionne


LA SUBSTITUTION

1. isoler une inconnue dans une équation
2. remplacer dans l'AUTRE équation, avec des parenthèses
3. résoudre
4. revenir à l'expression pour trouver la seconde inconnue


LA COMBINAISON

1. multiplier pour obtenir des coefficients égaux ou opposés
2. coefficients IDENTIQUES → on SOUSTRAIT
   coefficients OPPOSÉS    → on ADDITIONNE
3. résoudre l'équation à une inconnue obtenue
4. remplacer pour trouver la seconde


LA RÉSOLUTION GRAPHIQUE

Chaque équation est une droite. La solution est leur point d'intersection.

    droites sécantes      →  une solution
    parallèles distinctes →  aucune solution
    droites confondues    →  une infinité

La lecture graphique donne une valeur APPROCHÉE.


METTRE UN PROBLÈME EN SYSTÈME

1. « Soit x le ... et y le ... » — obligatoire
2. une phrase chiffrée = une équation
3. résoudre
4. vérifier dans l'ÉNONCÉ
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
    '3e_math_ch06': [
      RessourceOfficielle(
        type: TypeRessource.cours,
        titre: 'Applications affines et linéaires',
        ordre: 1,
        contenu: r'''
1. DÉFINITIONS

Une application affine est une application f qui, à tout nombre réel x,
associe le nombre ax + b, où a et b sont deux nombres fixés.

    f(x) = ax + b

    a s'appelle le COEFFICIENT DIRECTEUR
    b s'appelle l'ORDONNÉE À L'ORIGINE

Une application LINÉAIRE est le cas particulier où b = 0 :

    f(x) = ax

Toute application linéaire est affine, mais l'inverse est faux.


2. CALCULER UNE IMAGE

L'image de x par f, c'est f(x). On remplace simplement x par sa valeur.

Pour f(x) = 3x - 5 :
    f(2) = 3×2 - 5 = 1
    f(0) = -5
    f(-1) = -3 - 5 = -8

Remarque : f(0) = b. L'ordonnée à l'origine se lit donc immédiatement.


3. CALCULER UN ANTÉCÉDENT

Chercher l'antécédent de y, c'est résoudre l'équation f(x) = y.

Pour f(x) = 3x - 5, quel est l'antécédent de 7 ?

    3x - 5 = 7
    3x = 12
    x = 4

L'antécédent de 7 est 4.


4. REPRÉSENTATION GRAPHIQUE

La représentation graphique d'une application affine est une DROITE.

    f(x) = ax + b   →   droite d'équation y = ax + b

Celle d'une application linéaire est une droite qui PASSE PAR L'ORIGINE
du repère, puisque f(0) = 0.

Pour tracer, il suffit de deux points. Le plus simple :
    le point (0 ; b), qui est l'intersection avec l'axe des ordonnées
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

Si l'on connaît deux images, f(x₁) = y₁ et f(x₂) = y₂, alors :

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

a représente l'accroissement de y quand x augmente de 1.

Concrètement : depuis un point de la droite, on avance de 1 vers la
droite, puis on compte de combien on monte (a > 0) ou on descend (a < 0).


8. PROPORTIONNALITÉ

Une application LINÉAIRE traduit une situation de PROPORTIONNALITÉ.

    f(x) = ax   →   y est proportionnel à x, de coefficient a

Une application affine avec b ≠ 0 n'est PAS une situation de
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

    Linéaire : f(x) = ax        la droite passe par l'origine
    Affine   : f(x) = ax + b    la droite coupe l'axe des y en b

Toute linéaire est affine. Une affine n'est linéaire que si b = 0.


CE QUE SIGNIFIENT a ET b, CONCRÈTEMENT

Imagine une facture de taxi : f(x) = 500x + 1000.

    b = 1000  →  ce que tu paies AVANT de rouler, la prise en charge
    a = 500   →  ce que tu paies pour CHAQUE kilomètre supplémentaire

b est le point de départ, a est le rythme.

C'est vrai partout : un abonnement téléphonique, un tarif d'électricité,
un contrat de transport.


TRACER UNE DROITE EN 30 SECONDES

    f(x) = 2x - 3

Étape 1 — place le point (0 ; -3). C'est b, il se lit directement.

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

    IMAGE      : on te donne x, tu calcules f(x). C'est un CALCUL.
    ANTÉCÉDENT : on te donne f(x), tu cherches x. C'est une ÉQUATION.

Sur le graphique :
    image de 3      → je pars de 3 sur l'axe horizontal, je monte
                      jusqu'à la droite, je lis à gauche
    antécédent de 5 → je pars de 5 sur l'axe vertical, je vais
                      horizontalement jusqu'à la droite, je lis en bas


TROUVER a ET b À PARTIR DE DEUX POINTS

C'est un exercice très fréquent au BEPC.

    f(1) = 5   et   f(4) = 14

Étape 1 — le coefficient directeur :
    a = (14 - 5) / (4 - 1) = 9 / 3 = 3

Étape 2 — l'ordonnée à l'origine, avec l'un des deux points :
    f(1) = 5, donc 3×1 + b = 5, donc b = 2

    f(x) = 3x + 2

Étape 3 — vérifie avec l'AUTRE point :
    f(4) = 3×4 + 2 = 14 ✓


LES ERREURS QUI COÛTENT DES POINTS

Erreur 1 : inverser image et antécédent.
Erreur 2 : calculer a en inversant le rapport. C'est bien la différence
des y DIVISÉE PAR la différence des x, jamais l'inverse.
Erreur 3 : oublier le signe de a quand la droite descend.
Erreur 4 : dire qu'une application affine traduit une proportionnalité.
Ce n'est vrai que si b = 0.
Erreur 5 : tracer la droite à partir d'un seul point.


CONSEIL POUR LE BEPC

Après avoir trouvé f(x), vérifie toujours avec le second point de
l'énoncé. Si ça ne tombe pas juste, tu as fait une erreur de calcul sur a
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
2) Détermine l'antécédent de 10 par f.
3) Précise le sens de variation de f et celui de g. Justifie.
4) Laquelle de ces deux applications est linéaire ? Justifie.
''',
        solution: r'''
1) CALCUL D'IMAGES

    f(3) = 4×3 - 6 = 12 - 6 = 6
    f(0) = 4×0 - 6 = -6
    f(-2) = 4×(-2) - 6 = -8 - 6 = -14

Remarque : f(0) = -6, ce qui correspond bien à l'ordonnée à l'origine.


2) ANTÉCÉDENT DE 10 PAR f

Chercher l'antécédent de 10, c'est résoudre l'équation f(x) = 10.

    4x - 6 = 10
    4x = 16
    x = 4

Vérification : f(4) = 4×4 - 6 = 10 ✓

    L'antécédent de 10 par f est 4.


3) SENS DE VARIATION

Pour f(x) = 4x - 6, le coefficient directeur est a = 4.
Comme 4 > 0, l'application f est CROISSANTE.

Pour g(x) = -2x + 5, le coefficient directeur est a = -2.
Comme -2 < 0, l'application g est DÉCROISSANTE.


4) APPLICATION LINÉAIRE

Une application est linéaire lorsqu'elle s'écrit f(x) = ax, c'est-à-dire
lorsque b = 0.

    Pour f : b = -6, donc f n'est pas linéaire.
    Pour g : b = 5, donc g n'est pas linéaire.

CONCLUSION : aucune de ces deux applications n'est linéaire. Elles sont
toutes les deux affines, avec une ordonnée à l'origine non nulle.

Leurs représentations graphiques ne passent donc pas par l'origine du
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

    Forfait Liberté : 2 000 F par mois, puis 25 F par minute d'appel.
    Forfait Confort : 6 000 F par mois, puis 5 F par minute d'appel.

On note x le nombre de minutes d'appel dans le mois.

1) Exprime le prix de chaque forfait par une application affine, notée
   respectivement L(x) et C(x).
2) Précise, pour chacune, le coefficient directeur et l'ordonnée à
   l'origine, et donne leur signification concrète.
3) Calcule L(100) et C(100). Quel forfait est le plus avantageux pour
   100 minutes ?
4) À partir de combien de minutes le forfait Confort devient-il plus
   avantageux ?
''',
        solution: r'''
1) LES DEUX APPLICATIONS

Soit x le nombre de minutes d'appel dans le mois.

Forfait Liberté : 2 000 F fixes, plus 25 F par minute.
    L(x) = 25x + 2000

Forfait Confort : 6 000 F fixes, plus 5 F par minute.
    C(x) = 5x + 6000


2) COEFFICIENTS ET SIGNIFICATIONS

Pour L(x) = 25x + 2000 :
    coefficient directeur a = 25 → le prix de CHAQUE minute
    ordonnée à l'origine  b = 2000 → l'abonnement mensuel, payé même sans
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

On divise par 20, qui est positif : le sens de l'inégalité ne change pas.

CONCLUSION : le forfait Confort devient plus avantageux à partir de
201 minutes d'appel par mois.

Vérification au point d'équilibre, pour x = 200 :
    L(200) = 25×200 + 2000 = 5000 + 2000 = 7000
    C(200) = 5×200 + 6000 = 1000 + 6000 = 7000
Les deux forfaits coûtent exactement 7 000 F : c'est bien le seuil.


INTERPRÉTATION GRAPHIQUE
Les deux droites se coupent au point de coordonnées (200 ; 7000). Avant ce
point, la droite de Liberté est en dessous ; après, c'est celle de Confort.
Le point d'intersection donne toujours le seuil de basculement.
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
    b = ordonnée à l'origine, et b = f(0)


LE SENS DE VARIATION

    a > 0   →   croissante   (la droite monte)
    a < 0   →   décroissante (la droite descend)
    a = 0   →   constante    (droite horizontale)


IMAGE ET ANTÉCÉDENT

    IMAGE de x        : on calcule f(x)
    ANTÉCÉDENT de y   : on résout l'équation f(x) = y


TROUVER a ET b AVEC DEUX POINTS

    a = (y₂ - y₁) / (x₂ - x₁)

Puis on remplace dans f(x) = ax + b pour trouver b.
Et on vérifie avec le second point.


LA REPRÉSENTATION GRAPHIQUE

C'est une DROITE.
    affine   → coupe l'axe des ordonnées en b
    linéaire → passe par l'origine

Pour tracer : place (0 ; b), puis avance de 1 et monte de a.


PROPORTIONNALITÉ

Seule une application LINÉAIRE traduit une proportionnalité.
Dès qu'il y a une part fixe b ≠ 0, il n'y a plus proportionnalité.


LA LECTURE CONCRÈTE

Dans un tarif :
    b = la part fixe, payée même sans consommer
    a = le prix de chaque unité consommée

Le point d'intersection de deux droites donne le SEUIL à partir duquel
une offre devient plus avantageuse que l'autre.


LES PIÈGES

- confondre image et antécédent
- inverser le rapport dans le calcul de a
- oublier le signe négatif de a quand la droite descend
- croire qu'une affine est toujours proportionnelle
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

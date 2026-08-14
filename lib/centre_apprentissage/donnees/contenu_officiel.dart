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

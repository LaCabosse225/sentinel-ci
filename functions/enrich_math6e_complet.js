const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const niveau = '6e';
const matiereId = 'math';

const lecons = [
  {
    ch: 1,
    titre: 'Nombres entiers naturels',
    cours: \`# Nombres entiers naturels

Les nombres entiers naturels servent à compter et à dénombrer. On les note généralement 0, 1, 2, 3, 4, 5, … Chaque chiffre occupe une position qui donne sa valeur.

## 1. Lire et écrire un nombre

Dans 4 582, le chiffre 4 représente 4 milliers, le chiffre 5 représente 5 centaines, le chiffre 8 représente 8 dizaines et le chiffre 2 représente 2 unités.

On peut donc écrire :

4 582 = 4 000 + 500 + 80 + 2.

Cette décomposition permet de comprendre la valeur de chaque chiffre.

## 2. Comparer et ranger

Pour comparer deux entiers, on regarde d’abord le nombre de chiffres. Un nombre de quatre chiffres est plus grand qu’un nombre de trois chiffres.

Lorsque les deux nombres ont le même nombre de chiffres, on compare de gauche à droite jusqu’à trouver le premier chiffre différent.

Exemple : 7 405 et 7 450 ont les mêmes milliers et les mêmes centaines. On compare ensuite les dizaines : 0 < 5. Donc 7 405 < 7 450.

Pour ranger une liste dans l’ordre croissant, on place d’abord le plus petit nombre, puis les suivants.

## 3. Les opérations

L’addition réunit des quantités. La soustraction permet de calculer une différence. La multiplication correspond à des additions répétées. La division peut servir à partager ou à rechercher combien de fois une quantité est contenue dans une autre.

Exemple :
24 + 18 = 42
30 - 12 = 18
6 × 7 = 42
42 ÷ 6 = 7

Dans une division euclidienne, on peut écrire : dividende = diviseur × quotient + reste, avec un reste inférieur au diviseur.

## 4. Priorités et vérification

À ce niveau, il faut surtout respecter l’ordre des calculs indiqué dans la consigne et poser soigneusement les opérations. Après un calcul, une estimation permet de vérifier si le résultat est raisonnable.

### Exemple guidé

Pour 245 + 378 :
245 + 300 = 545 puis 545 + 78 = 623.

La réponse est donc 623.

## À retenir

Un entier naturel est positif ou nul. La valeur d’un chiffre dépend de son rang. Pour comparer deux nombres de même longueur, on lit les chiffres de gauche à droite. Une opération doit toujours être choisie en fonction de la situation.\`,
    methode: \`# Méthode — comparer et calculer

1. Recopie les nombres sans oublier les chiffres importants.
2. Aligne correctement les unités, dizaines, centaines et milliers.
3. Pour comparer, commence toujours par la gauche.
4. Pour calculer, choisis l'opération correspondant à la situation.
5. Vérifie le résultat par une estimation ou l'opération inverse.\`,
    exercice: \`Calcule :
A = 2 458 + 3 729
B = 8 000 - 3 645
C = 36 × 24
D = 936 ÷ 12

Puis range dans l'ordre croissant : 5 032 ; 4 980 ; 5 230 ; 4 999.\`,
    correction: \`A = 6 187.
B = 4 355.
C = 864.
D = 78.

Ordre croissant : 4 980 < 4 999 < 5 032 < 5 230.\`,
    quiz: [
      ['Quel est le plus grand ?', ['3 205', '3 250', '3 025'], 1, '3 250 est le plus grand car les milliers sont égaux puis 2 centaines sont comparées à 0.'],
      ['Dans 5 482, quelle est la valeur du chiffre 4 ?', ['4 unités', '4 dizaines', '4 centaines'], 2, 'Le chiffre 4 est à la place des centaines : sa valeur est 400.'],
      ['Combien font 8 × 7 ?', ['54', '56', '64'], 1, '8 groupes de 7 donnent 56.'],
    ],
  },
  {
    ch: 2,
    titre: 'Droites et points',
    cours: \`# Droites et points

La géométrie permet de décrire précisément des objets et leurs positions.

## 1. Le point

Un point est représenté par une petite marque et se désigne par une lettre majuscule : A, B, C…

## 2. La droite, la demi-droite et le segment

La droite (AB) passe par A et B et se prolonge indéfiniment dans les deux directions.

La demi-droite [AB) commence en A, passe par B et se prolonge au-delà de B.

Le segment [AB] est limité par ses deux extrémités A et B. Sa longueur est notée AB.

## 3. L’alignement

Des points A, B et C sont alignés lorsqu’ils appartiennent à une même droite.

Dire « C appartient à (AB) » signifie que C est situé sur la droite passant par A et B.

## 4. Construire correctement

Pour tracer une droite passant par deux points, on place la règle sur les deux points et on prolonge le trait dans les deux directions.

Pour construire un segment de 6 cm, on place une extrémité, on mesure exactement 6 cm avec la règle graduée, puis on marque la seconde extrémité.\`,
    methode: \`# Méthode — reconnaître un objet géométrique

Demande-toi d’abord si l’objet est limité ou non.

- illimité des deux côtés : droite ;
- une seule extrémité : demi-droite ;
- deux extrémités : segment.

Pour prouver que trois points sont alignés, montre qu’ils appartiennent à une même droite.\`,
    exercice: \`Trace un segment [DE] de 6 cm. Place F sur [DE] tel que DF = 2 cm. Calcule FE.

Puis explique la différence entre (DE) et [DE].\`,
    correction: \`Comme DE = 6 cm et DF = 2 cm, on a FE = DE - DF = 6 - 2 = 4 cm.

La droite (DE) est illimitée dans les deux directions. Le segment [DE] est limité par D et E.\`,
    quiz: [
      ['Quel objet possède deux extrémités ?', ['Une droite', 'Une demi-droite', 'Un segment'], 2, 'Le segment est limité par deux extrémités.'],
      ['Que signifie A, B et C alignés ?', ['Ils sont sur une même droite', 'Ils ont la même longueur', 'Ils sont sur le même cercle'], 0, 'Des points alignés appartiennent à une même droite.'],
      ['La notation (AB) désigne…', ['un segment', 'une droite', 'un angle'], 1, 'Les parenthèses désignent la droite passant par A et B.'],
    ],
  },
  {
    ch: 3,
    titre: 'Nombres décimaux relatifs',
    cours: \`# Nombres décimaux relatifs

Un nombre décimal relatif peut être positif, nul ou négatif. Les nombres négatifs sont placés à gauche de 0 sur une droite graduée.

## 1. Opposé et distance à zéro

L’opposé de +4,2 est -4,2. L’opposé de -7 est +7.

La distance à zéro d’un nombre est sa distance par rapport à 0. La distance à zéro de -5 est donc 5.

## 2. Comparer

Sur une droite graduée, le plus grand nombre est celui qui est le plus à droite.

Ainsi :
- -2,3 > -4,1 ;
- 0 > -0,7 ;
- 3,5 > -3,5.

Attention : parmi deux nombres négatifs, celui dont la distance à zéro est la plus petite est le plus grand.

## 3. Additionner et soustraire

Pour des nombres de même signe, on additionne les distances à zéro et on conserve le signe.

Exemple : -3,2 + (-1,8) = -5.

Pour des signes différents, on soustrait les distances à zéro et on garde le signe du nombre qui a la plus grande distance à zéro.

Exemple : -7 + 12 = 5.

## 4. Une bonne stratégie

Quand le calcul contient plusieurs signes, écris chaque étape. Pour une soustraction, transforme-la en addition de l’opposé lorsque cela facilite le calcul.\`,
    methode: \`# Méthode — calcul avec des relatifs

1. Repère les signes.
2. Transforme une soustraction en addition de l’opposé si nécessaire.
3. Compare les distances à zéro.
4. Fais le calcul numérique.
5. Place éventuellement le résultat sur une droite graduée pour vérifier son signe.\`,
    exercice: \`Calcule :
A = -7 + 12
B = 4,5 - 8
C = -3,2 - (-1,8)
D = -2,5 + (-4)\`,
    correction: \`A = 5.
B = -3,5.
C = -3,2 + 1,8 = -1,4.
D = -6,5.\`,
    quiz: [
      ['Quel nombre est le plus grand ?', ['-4,2', '-1,9', '-6,1'], 1, '-1,9 est le plus à droite sur la droite graduée.'],
      ['Quel est l’opposé de -6,3 ?', ['-6,3', '0', '+6,3'], 2, 'L’opposé d’un nombre change son signe.'],
      ['Quelle distance à zéro pour -8 ?', ['-8', '0', '8'], 2, 'Une distance est toujours positive ou nulle.'],
    ],
  },
  {
    ch: 4,
    titre: 'Segments',
    cours: \`# Segments

Un segment est une portion de droite comprise entre deux extrémités.

## 1. Longueur d’un segment

Le segment [AB] a pour longueur AB. Pour mesurer un segment, on place le zéro de la règle sur une extrémité puis on lit la mesure à l’autre extrémité.

## 2. Milieu d’un segment

M est le milieu de [AB] lorsque M appartient à [AB] et AM = MB.

Si AB = 10 cm, alors AM = MB = 5 cm.

## 3. Médiatrice

La médiatrice de [AB] est la droite perpendiculaire à [AB] qui passe par son milieu.

Une propriété essentielle est la suivante : tout point situé sur la médiatrice de [AB] est à égale distance de A et de B.

Réciproquement, si un point P vérifie PA = PB, alors P appartient à la médiatrice de [AB].

## 4. Construction

Avec une règle et une équerre, on peut tracer la médiatrice. Avec un compas, on peut aussi construire les arcs de même rayon centrés en A et B puis relier leurs points d’intersection.\`,
    methode: \`# Méthode — construire un milieu

Pour trouver le milieu d’un segment de 10 cm :
1. mesure le segment ;
2. divise sa longueur par 2 ;
3. reporte cette distance depuis une extrémité ;
4. vérifie que les deux morceaux ont la même longueur.\`,
    exercice: \`AB = 10 cm et M est le milieu de [AB].

1. Calcule AM et MB.
2. Un point P est sur la médiatrice de [AB]. Compare PA et PB.
3. Construis une médiatrice sur une feuille graduée.\`,
    correction: \`1. AM = MB = 10 ÷ 2 = 5 cm.
2. Comme P est sur la médiatrice, PA = PB.
3. La médiatrice doit être perpendiculaire à [AB] et passer exactement par son milieu.\`,
    quiz: [
      ['Si AB = 12 cm et M est son milieu, AM vaut…', ['4 cm', '6 cm', '12 cm'], 1, 'Le milieu partage le segment en deux longueurs égales.'],
      ['La médiatrice est…', ['parallèle au segment', 'perpendiculaire au segment et passe par son milieu', 'un cercle'], 1, 'C’est la définition de la médiatrice.'],
      ['Sur la médiatrice de [AB], on a toujours…', ['PA = PB', 'PA = 0', 'PB = 0'], 0, 'Tout point de la médiatrice est équidistant de A et B.'],
    ],
  },
  {
    ch: 5,
    titre: 'Pavés droits et cylindres droits',
    cours: \`# Pavés droits et cylindres droits

Les solides ont un volume qui mesure l’espace qu’ils occupent.

## 1. Le pavé droit

Un pavé droit possède six faces rectangulaires. Si sa longueur est L, sa largeur l et sa hauteur h, alors :

V = L × l × h.

Exemple : pour L = 8 cm, l = 4 cm et h = 3 cm,

V = 8 × 4 × 3 = 96 cm³.

## 2. Le cylindre droit

Un cylindre droit possède deux bases circulaires identiques. Son volume est :

V = π × r² × h.

Ici r est le rayon de la base et h la hauteur.

Pour r = 2 cm et h = 5 cm, avec π ≈ 3,14 :

V ≈ 3,14 × 2² × 5 = 62,8 cm³.

## 3. Les unités de volume

1 dm³ = 1 L.
1 cm³ = 1 mL.

Il faut toujours vérifier que les longueurs sont dans des unités compatibles avant d’appliquer une formule.\`,
    methode: \`# Méthode — calculer un volume

1. Écris les dimensions connues.
2. Vérifie les unités.
3. Choisis la bonne formule.
4. Remplace les lettres par les valeurs.
5. Calcule puis ajoute l’unité de volume : cm³, dm³, m³…\`,
    exercice: \`1. Calcule le volume d’un pavé droit de dimensions 8 cm, 4 cm et 3 cm.
2. Calcule le volume d’un cylindre de rayon 2 cm et de hauteur 5 cm avec π = 3,14.
3. Convertis 250 cm³ en mL.\`,
    correction: \`1. V = 8 × 4 × 3 = 96 cm³.
2. V = 3,14 × 2² × 5 = 62,8 cm³.
3. 250 cm³ = 250 mL.\`,
    quiz: [
      ['Le volume d’un pavé droit est…', ['L + l + h', 'L × l × h', '2(L + l + h)'], 1, 'Le volume est le produit des trois dimensions.'],
      ['Pour un cylindre, la formule du volume est…', ['πr²h', '2πr', 'r + h'], 0, 'Le volume du cylindre est l’aire de la base multipliée par la hauteur.'],
      ['1 dm³ correspond à…', ['1 L', '10 L', '100 L'], 0, '1 dm³ = 1 litre.'],
    ],
  },
  {
    ch: 6,
    titre: 'Fractions',
    cours: \`# Fractions

Une fraction permet d’écrire une quantité qui n’est pas nécessairement entière.

Dans la fraction a/b, a est le numérateur et b le dénominateur. Le dénominateur ne doit pas être nul.

## 1. Sens d’une fraction

La fraction 3/5 signifie trois parts lorsque l’unité est partagée en cinq parts égales.

Une fraction peut aussi exprimer une proportion. Par exemple, 1/2 signifie une moitié et 3/4 signifie trois quarts.

## 2. Fractions équivalentes

On obtient une fraction équivalente en multipliant ou en divisant le numérateur et le dénominateur par un même nombre non nul.

Exemple :

2/6 = 1/3

car on a divisé 2 et 6 par 2.

## 3. Addition et soustraction

Avec un même dénominateur, on conserve le dénominateur et on additionne ou soustrait les numérateurs.

2/7 + 3/7 = 5/7.

Pour des dénominateurs différents, il faut d’abord chercher un dénominateur commun.

## 4. Fraction d’une quantité

Pour calculer 3/5 de 20, on peut calculer :

20 × 3/5 = 12.

On peut aussi calculer d’abord 20 ÷ 5 = 4 puis 4 × 3 = 12.\`,
    methode: \`# Méthode — calculer une fraction d’une quantité

Pour calculer a/b d’une quantité N :
1. partage N en b parts égales ;
2. prends a parts ;
3. ou calcule directement N × a/b ;
4. vérifie que le résultat est cohérent avec la proportion.\`,
    exercice: \`Calcule :
A = 2/9 + 4/9
B = 7/8 - 3/8
C = 3/5 de 40
D = 2/3 de 27\`,
    correction: \`A = 6/9 = 2/3.
B = 4/8 = 1/2.
C = 40 × 3/5 = 24.
D = 27 × 2/3 = 18.\`,
    quiz: [
      ['Dans 5/8, le dénominateur est…', ['5', '8', '13'], 1, 'Le nombre du bas est le dénominateur.'],
      ['2/6 est égal à…', ['1/3', '1/6', '2/3'], 0, 'On divise le numérateur et le dénominateur par 2.'],
      ['3/4 de 20 vaut…', ['5', '15', '17'], 1, '20 ÷ 4 = 5 puis 5 × 3 = 15.'],
    ],
  },
  {
    ch: 7,
    titre: 'Cercles et disques',
    cours: \`# Cercles et disques

Le cercle est une ligne fermée. Le disque est la surface située à l’intérieur du cercle.

## 1. Vocabulaire

Le centre du cercle est souvent noté O.

Le rayon r est un segment qui relie le centre à un point du cercle.

Le diamètre d passe par le centre et relie deux points du cercle.

On a toujours :

d = 2r.

## 2. Longueur du cercle

La longueur du cercle, parfois appelée périmètre du cercle, se calcule par :

P = 2 × π × r.

Avec π ≈ 3,14 et r = 5 cm :

P ≈ 31,4 cm.

## 3. Aire du disque

L’aire du disque est :

A = π × r².

Pour r = 5 cm :

A ≈ 3,14 × 25 = 78,5 cm².

Attention à ne pas confondre longueur du cercle et aire du disque : les unités ne sont pas les mêmes.\`,
    methode: \`# Méthode — cercle ou disque ?

La question parle d’une longueur autour de la figure : utilise P = 2πr.

La question parle de la surface intérieure : utilise A = πr².

Pense à écrire l’unité adaptée : cm pour une longueur et cm² pour une aire.\`,
    exercice: \`Un disque a un rayon de 4 cm. Calcule :
1. son diamètre ;
2. la longueur de son cercle ;
3. son aire.
Prends π = 3,14.\`,
    correction: \`1. d = 2 × 4 = 8 cm.
2. P = 2 × 3,14 × 4 = 25,12 cm.
3. A = 3,14 × 4² = 50,24 cm².\`,
    quiz: [
      ['Le diamètre vaut…', ['r', '2r', 'r²'], 1, 'Le diamètre est deux fois le rayon.'],
      ['L’aire d’un disque est…', ['2πr', 'πr²', 'πd'], 1, 'La formule de l’aire utilise le carré du rayon.'],
      ['L’unité d’une aire est par exemple…', ['cm', 'cm²', 'cm³'], 1, 'Une aire s’exprime en unités carrées.'],
    ],
  },
  {
    ch: 8,
    titre: 'Angles',
    cours: \`# Angles

Un angle est formé par deux demi-droites ayant la même origine.

## 1. Mesurer un angle

Pour mesurer un angle, place le centre du rapporteur sur le sommet de l’angle. Aligne ensuite le zéro du rapporteur sur l’un des côtés de l’angle, puis lis la graduation du côté opposé.

Il faut choisir la bonne échelle du rapporteur : celle qui commence à 0° sur le côté placé contre le zéro.

## 2. Nature des angles

- angle aigu : moins de 90° ;
- angle droit : 90° ;
- angle obtus : entre 90° et 180° ;
- angle plat : 180°.

## 3. Complémentaires et supplémentaires

Deux angles complémentaires ont une somme de 90°.

Deux angles supplémentaires ont une somme de 180°.

Exemple : le complémentaire de 28° vaut 90° - 28° = 62°.\`,
    methode: \`# Méthode — mesurer avec un rapporteur

1. Pose le centre du rapporteur sur le sommet.
2. Aligne la ligne de base sur un côté.
3. Repère la graduation qui commence à 0° sur ce côté.
4. Lis la mesure au niveau de l’autre côté.
5. Donne la nature de l’angle à partir de sa mesure.\`,
    exercice: \`Donne la nature de :
35°, 90°, 125°, 180°.

Puis calcule le complémentaire de 28° et le supplémentaire de 65°.\`,
    correction: \`35° : aigu.
90° : droit.
125° : obtus.
180° : plat.

Complémentaire de 28° : 90° - 28° = 62°.
Supplémentaire de 65° : 180° - 65° = 115°.\`,
    quiz: [
      ['Un angle droit mesure…', ['45°', '90°', '180°'], 1, 'Par définition, un angle droit mesure 90°.'],
      ['Un angle de 125° est…', ['aigu', 'droit', 'obtus'], 2, '125° est compris entre 90° et 180°.'],
      ['Deux angles complémentaires ont une somme de…', ['90°', '180°', '360°'], 0, 'Complémentaire signifie que la somme vaut 90°.'],
    ],
  },
  {
    ch: 9,
    titre: 'Triangles',
    cours: \`# Triangles

Un triangle possède trois côtés, trois sommets et trois angles.

## 1. Somme des angles

Dans tout triangle, la somme des trois angles est égale à 180°.

Ainsi, si A = 45° et B = 65°, alors :

C = 180° - 45° - 65° = 70°.

## 2. Triangles particuliers

Un triangle équilatéral a trois côtés égaux et trois angles de 60°.

Un triangle isocèle possède deux côtés égaux. Les angles opposés à ces côtés sont également égaux.

Un triangle rectangle possède un angle droit de 90°.

## 3. Construire un triangle

Pour construire un triangle à partir de longueurs données, on peut utiliser une règle et un compas. Il faut vérifier que les longueurs choisies permettent réellement de fermer le triangle.\`,
    methode: \`# Méthode — trouver un angle d’un triangle

1. Écris la propriété : somme des angles = 180°.
2. Additionne les angles connus.
3. Soustrais cette somme à 180°.
4. Vérifie que l’angle trouvé est positif et cohérent.\`,
    exercice: \`Dans ABC, A = 45° et B = 65°.

1. Calcule C.
2. Le triangle est-il équilatéral ?
3. Peut-il être rectangle ?\`,
    correction: \`C = 180° - 45° - 65° = 70°.

Le triangle n’est pas équilatéral car ses trois angles ne valent pas 60°.

Il n’est pas rectangle car aucun angle ne vaut 90°.\`,
    quiz: [
      ['La somme des angles d’un triangle est…', ['90°', '180°', '360°'], 1, 'C’est une propriété fondamentale des triangles.'],
      ['Un triangle équilatéral possède…', ['3 côtés égaux', '2 côtés égaux', 'aucun côté égal'], 0, 'Équilatéral signifie que les trois côtés sont égaux.'],
      ['Un triangle rectangle possède…', ['un angle de 45°', 'un angle de 90°', 'un angle de 180°'], 1, 'Son angle droit mesure 90°.'],
    ],
  },
  {
    ch: 10,
    titre: 'Proportionnalité',
    cours: \`# Proportionnalité

Deux grandeurs sont proportionnelles lorsqu’on peut passer d’une grandeur à l’autre en multipliant toujours par le même nombre.

## 1. Le coefficient de proportionnalité

Si 1 kg de riz coûte 800 F, alors le prix est obtenu en multipliant la masse par 800.

1 kg → 800 F
2 kg → 1 600 F
5 kg → 4 000 F.

Le nombre 800 est le coefficient de proportionnalité.

## 2. Tableau de proportionnalité

On peut organiser les données dans un tableau pour faciliter les calculs.

| Masse | 1 | 5 | 8 |
| Prix | 800 | 4 000 | 6 400 |

Chaque prix est obtenu en multipliant la masse par 800.

## 3. Pourcentages

Un pourcentage est une proportion sur 100.

10 % = 10/100 = 0,10.

Ainsi 10 % de 8 000 F = 800 F.

## 4. Produits en croix

Lorsque trois valeurs d’un tableau proportionnel sont connues, on peut trouver la quatrième en utilisant les produits en croix.\`,
    methode: \`# Méthode — résoudre une situation de proportionnalité

1. Cherche le coefficient de proportionnalité quand il est facile à déterminer.
2. Sinon, construis un tableau.
3. Vérifie que le passage d’une ligne à l’autre utilise toujours le même facteur.
4. Pour un pourcentage, rappelle-toi que « x % » signifie « x sur 100 ».\`,
    exercice: \`5 kg de riz coûtent 4 000 F.

1. Quel est le prix de 1 kg ?
2. Quel est le prix de 8 kg ?
3. Calcule 10 % de 8 000 F.
4. 3 cahiers coûtent 1 500 F. Combien coûtent 7 cahiers au même prix unitaire ?\`,
    correction: \`1. 4 000 ÷ 5 = 800 F par kg.
2. 8 × 800 = 6 400 F.
3. 10 % de 8 000 = 800 F.
4. Un cahier coûte 500 F, donc 7 cahiers coûtent 3 500 F.\`,
    quiz: [
      ['Si 1 objet coûte 500 F, 3 objets coûtent…', ['1 000 F', '1 500 F', '2 000 F'], 1, 'On multiplie le prix unitaire par 3.'],
      ['25 % de 200 vaut…', ['25', '50', '100'], 1, '25 % = 1/4, et 200 ÷ 4 = 50.'],
      ['En proportionnalité, on utilise un…', ['coefficient de proportionnalité', 'angle droit', 'rayon'], 0, 'Le coefficient permet de passer d’une ligne à l’autre.'],
    ],
  },
  {
    ch: 11,
    titre: 'Figures symétriques par rapport à un point',
    cours: \`# Figures symétriques par rapport à un point

La symétrie centrale correspond à un demi-tour de 180° autour d’un point appelé centre de symétrie.

## 1. Symétrie de deux points

A et A’ sont symétriques par rapport à O lorsque O est le milieu du segment [AA’].

Cela signifie que A, O et A’ sont alignés et que OA = OA’.

## 2. Construire le symétrique

Pour construire A’ :
1. trace la droite AO ;
2. prolonge-la de l’autre côté de O ;
3. reporte la longueur OA pour placer A’.

## 3. Propriétés

La symétrie centrale conserve les longueurs, les angles et l’alignement. Elle transforme donc une figure en une figure de même forme et de même taille, tournée d’un demi-tour.

Dans un parallélogramme, le point d’intersection des diagonales est le centre de symétrie.\`,
    methode: \`# Méthode — construire le symétrique d’un point

1. Trace la droite passant par A et le centre O.
2. Mesure OA.
3. Reporte exactement la même distance de l’autre côté de O.
4. Vérifie que O est le milieu de [AA’].\`,
    exercice: \`O est le milieu de [AA’] et OA = 3,5 cm.

1. Calcule OA’.
2. Les longueurs sont-elles conservées par symétrie centrale ?
3. Quel rôle joue O dans la symétrie du parallélogramme ?\`,
    correction: \`1. OA’ = 3,5 cm.
2. Oui, les longueurs sont conservées.
3. Dans un parallélogramme, O est le centre de symétrie : les diagonales se coupent en leur milieu en O.\`,
    quiz: [
      ['Dans une symétrie centrale, O est…', ['le milieu de [AA’]', 'un sommet', 'un rayon'], 0, 'Le centre de symétrie est le milieu des segments reliant les points correspondants.'],
      ['La symétrie centrale correspond à…', ['un quart de tour', 'un demi-tour', 'un tour complet'], 1, 'Elle correspond à une rotation de 180°.'],
      ['La symétrie centrale conserve les longueurs.', ['Vrai', 'Faux'], 0, 'Une symétrie centrale est une isométrie : les longueurs sont conservées.'],
    ],
  },
  {
    ch: 12,
    titre: 'Statistique',
    cours: \`# Statistique

La statistique permet d’organiser et de décrire des données recueillies sur une population.

## 1. Vocabulaire

La population est l’ensemble étudié.

Un caractère est l’information observée.

L’effectif d’une valeur est le nombre de fois où cette valeur apparaît.

L’effectif total est la somme de tous les effectifs.

## 2. Fréquence

La fréquence d’une valeur se calcule par :

fréquence = effectif / effectif total.

On peut ensuite multiplier par 100 pour obtenir un pourcentage.

## 3. Moyenne

Pour une série de nombres, la moyenne est :

somme des valeurs / nombre de valeurs.

Exemple avec 8, 10, 10, 12, 15 :

somme = 55 et il y a 5 valeurs.

Moyenne = 55 ÷ 5 = 11.

La fréquence de 10 est 2/5 = 40 %.

## 4. Lire un tableau

Avant de calculer, il faut vérifier ce que représentent les lignes et les colonnes. Une erreur de lecture du tableau peut produire un résultat correct pour un mauvais calcul.\`,
    methode: \`# Méthode — traiter une petite série statistique

1. Compte le nombre total de données.
2. Compte combien de fois apparaît la valeur recherchée.
3. Pour la moyenne, additionne toutes les valeurs puis divise par leur nombre.
4. Pour une fréquence, divise l’effectif de la valeur par l’effectif total.
5. Convertis en pourcentage si nécessaire.\`,
    exercice: \`Notes : 8, 10, 10, 12, 15.

1. Donne l’effectif total.
2. Calcule la moyenne.
3. Détermine la fréquence de 10.
4. Donne cette fréquence en pourcentage.\`,
    correction: \`1. Effectif total = 5.
2. Moyenne = (8 + 10 + 10 + 12 + 15) ÷ 5 = 55 ÷ 5 = 11.
3. Fréquence de 10 = 2/5.
4. 2/5 = 0,4 = 40 %.\`,
    quiz: [
      ['L’effectif total est…', ['le plus grand nombre', 'le nombre total de données', 'la moyenne'], 1, 'Il compte toutes les observations de la série.'],
      ['La moyenne de 4, 6 et 8 vaut…', ['6', '7', '18'], 0, '(4 + 6 + 8) ÷ 3 = 18 ÷ 3 = 6.'],
      ['2/5 en pourcentage vaut…', ['20 %', '40 %', '50 %'], 1, '2 ÷ 5 = 0,4, soit 40 %.'],
    ],
  },
  {
    ch: 13,
    titre: 'Parallélogramme',
    cours: \`# Parallélogramme

Un parallélogramme est un quadrilatère dont les côtés opposés sont parallèles deux à deux.

## 1. Propriétés

Dans un parallélogramme :
- les côtés opposés ont la même longueur ;
- les angles opposés ont la même mesure ;
- les diagonales se coupent en leur milieu.

Si ABCD est un parallélogramme, alors AB = CD et BC = AD.

## 2. Périmètre

Si les côtés mesurent a et b, le périmètre est :

P = 2(a + b).

Exemple : pour 8 cm et 5 cm,

P = 2 × (8 + 5) = 26 cm.

## 3. Reconnaître un parallélogramme

Plusieurs propriétés permettent de le reconnaître, notamment lorsque les côtés opposés sont parallèles ou lorsqu’ils ont deux à deux la même longueur.

## 4. Diagonales

Les diagonales d’un parallélogramme se coupent en leur milieu. Leur point d’intersection est aussi un centre de symétrie du parallélogramme.\`,
    methode: \`# Méthode — exploiter une propriété du parallélogramme

Repère d’abord ce que la figure te donne.

- côtés opposés : pense égalité des longueurs ;
- côtés opposés parallèles : pense parallélogramme ;
- diagonales : pense « elles se coupent en leur milieu » ;
- périmètre : additionne les quatre côtés, ou utilise 2(a+b).\`,
    exercice: \`ABCD est un parallélogramme avec AB = 8 cm et BC = 5 cm.

1. Donne CD et AD.
2. Calcule le périmètre.
3. Les diagonales se coupent en O. Que peux-tu dire de AO et OC ?\`,
    correction: \`1. CD = 8 cm et AD = 5 cm.
2. P = 2 × (8 + 5) = 26 cm.
3. O est le milieu de chaque diagonale, donc AO = OC et BO = OD.\`,
    quiz: [
      ['Dans un parallélogramme, les côtés opposés sont…', ['égaux en longueur', 'toujours perpendiculaires', 'toujours de longueurs différentes'], 0, 'Les côtés opposés d’un parallélogramme ont la même longueur.'],
      ['Les diagonales d’un parallélogramme…', ['ne se coupent jamais', 'se coupent en leur milieu', 'sont toujours égales'], 1, 'C’est une propriété générale du parallélogramme.'],
      ['Le périmètre de côtés 6 cm et 4 cm vaut…', ['10 cm', '20 cm', '24 cm'], 1, 'P = 2 × (6 + 4) = 20 cm.'],
    ],
  },
];

function baseRessource(chapitreId, data) {
  return {
    chapitreId,
    niveau,
    matiereId,
    ecoleId: '',
    imagesUrls: [],
    pdfUrl: '',
    videoYoutubeId: '',
    enonce: '',
    solution: '',
    difficulte: 1,
    ressourceLieeId: '',
    questions: [],
    dureeMinutes: 0,
    examen: '',
    annee: 0,
    serie: '',
    actif: true,
    auteur: 'sentinel-enrich-math6e-2026',
    dateMaj: FieldValue.serverTimestamp(),
    ...data,
  };
}

async function upsert(ref, data) {
  const snap = await ref.get();
  if (snap.exists) {
    await ref.set(data, { merge: true });
    return 'updated';
  }
  await ref.set({ ...data, dateCreation: FieldValue.serverTimestamp() });
  return 'created';
}

async function main() {
  let created = 0;
  let updated = 0;

  for (const l of lecons) {
    const chapitreId = \`6e_math_ch\${String(l.ch).padStart(2, '0')}\`;
    const chapRef = db.collection('ca_chapitres').doc(chapitreId);
    const chapSnap = await chapRef.get();

    if (!chapSnap.exists) {
      await chapRef.set({
        code: \`2026-2027_dpfc_6e_math_ch\${String(l.ch).padStart(2, '0')}\`,
        niveau,
        matiereId,
        anneeScolaire: '2026-2027',
        programmeVersion: 'dpfc',
        serie: '',
        theme: '',
        titre: l.titre,
        description: l.titre,
        ordre: l.ch,
        actif: true,
        dateMaj: FieldValue.serverTimestamp(),
      });
      created++;
    }

    const docs = [
      {
        id: \`\${chapitreId}_cours_complet\`,
        type: 'cours',
        titre: \`Cours complet — \${l.titre}\`,
        ordre: 1,
        contenu: l.cours,
      },
      {
        id: \`\${chapitreId}_methode\`,
        type: 'renforcement',
        titre: \`Méthode pas à pas — \${l.titre}\`,
        ordre: 2,
        contenu: l.methode,
      },
      {
        id: \`\${chapitreId}_exercices_corriges\`,
        type: 'exercice',
        titre: \`Exercice guidé et correction — \${l.titre}\`,
        ordre: 3,
        contenu: 'Essaie d’abord sans regarder la correction.',
        enonce: l.exercice,
        solution: l.correction,
        difficulte: 1,
      },
      {
        id: \`\${chapitreId}_quiz\`,
        type: 'quiz',
        titre: \`Quiz de vérification — \${l.titre}\`,
        ordre: 4,
        questions: l.quiz.map((q, i) => ({
          id: \`q\${i + 1}\`,
          type: 'qcm',
          enonce: q[0],
          choix: q[1],
          bonnesReponses: [q[2]],
          reponseAttendue: '',
          explication: q[3],
          points: 1,
        })),
        dureeMinutes: 5,
      },
      {
        id: \`\${chapitreId}_fiche_revision\`,
        type: 'fiche',
        titre: \`Fiche de révision — \${l.titre}\`,
        ordre: 5,
        contenu: l.methode + '\\n\\n## Les notions à retenir\\n\\n' + l.correction,
      },
    ];

    for (const d of docs) {
      const status = await upsert(
        db.collection('ca_ressources').doc(d.id),
        baseRessource(chapitreId, d)
      );
      if (status === 'created') created++;
      else updated++;
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    dateMaj: FieldValue.serverTimestamp(),
  }, { merge: true });

  console.log(JSON.stringify({
    ok: true,
    programme: 'Mathématiques 6e',
    chapitres: lecons.length,
    ressourcesCreees: created,
    ressourcesMisesAJour: updated,
    message: 'Enrichissement pédagogique 6e Maths terminé.'
  }, null, 2));
}

main().catch((err) => {
  console.error('ENRICH_MATH6E_ERROR');
  console.error(err && err.stack ? err.stack : err);
  process.exit(1);
});

const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const lessons = [
  {
    n: 1, title: 'Nombres premiers',
    description: 'Puissances à exposant entier naturel, division dans N, nombres premiers et décomposition en produit de facteurs premiers.',
    course: [
      'Une puissance a^n est le produit de n facteurs égaux à a. Par exemple 3^4 = 3×3×3×3 = 81.',
      'Dans une suite de calculs, une puissance est calculée avant une multiplication ou une addition, sauf présence de parenthèses.',
      'Un nombre premier est un entier naturel supérieur à 1 qui possède exactement deux diviseurs positifs : 1 et lui-même. 2, 3, 5, 7, 11 et 13 sont premiers ; 1 ne l’est pas.',
      'Pour décomposer un entier inférieur à 1000 en facteurs premiers, on divise successivement par les plus petits nombres premiers possibles jusqu’à obtenir 1.'
    ].join('\\n\\n'),
    situation: 'La coopérative d’un collège produit 30 cartons de 30 plaquettes contenant chacune 30 œufs. Elle vend les œufs 30 F l’unité. Les élèves utilisent les puissances et les facteurs premiers pour vérifier leurs calculs.',
    exercises: [
      ['Calcule 2^5 + 3^2.', '2^5 = 32 et 3^2 = 9, donc le résultat est 41.'],
      ['Décompose 180 en produit de facteurs premiers.', '180 = 18×10 = 2×3^2×2×5 = 2^2×3^2×5.'],
      ['Le nombre 97 est-il premier ?', 'Oui. Aucun nombre premier inférieur ou égal à √97, soit environ 9,8, ne le divise : 2, 3, 5 et 7 ne divisent pas 97.']
    ]
  },
  {
    n: 2, title: 'Nombres décimaux relatifs',
    description: 'Comparaison, rangement, différence, somme algébrique, produit de nombres décimaux relatifs et équation du type x + b = a.',
    course: [
      'Sur une droite graduée, le nombre le plus à droite est le plus grand. Parmi les nombres négatifs, celui dont la distance à zéro est la plus petite est le plus grand.',
      'Soustraire un nombre revient à ajouter son opposé : a - b = a + (-b).',
      'Pour additionner deux nombres de même signe, on additionne leurs distances à zéro et on conserve le signe. Pour des signes différents, on soustrait les distances et on garde le signe du nombre de plus grande distance à zéro.',
      'Pour résoudre x + b = a, on ajoute -b aux deux membres : x = a - b.',
      'Le produit de deux nombres de même signe est positif ; le produit de deux nombres de signes différents est négatif.'
    ].join('\\n\\n'),
    situation: 'Un club étudie une température historique exprimée avec des nombres relatifs et cherche à comparer des valeurs avant et après une date de référence.',
    exercises: [
      ['Range -3,5 ; 2,1 ; -1,8 ; 0 ; 4 dans l’ordre croissant.', '-3,5 < -1,8 < 0 < 2,1 < 4.'],
      ['Calcule A = -7,5 + 3,2 - (-1,5).', 'A = -7,5 + 3,2 + 1,5 = -2,8.'],
      ['Résous x - 4,5 = -2.', 'x = -2 + 4,5 = 2,5.']
    ]
  },
  {
    n: 3, title: 'Fractions',
    description: 'Différence de fractions, produits, puissances entières de fractions et encadrement d’une fraction par des décimaux.',
    course: [
      'Pour soustraire deux fractions, on les met au même dénominateur puis on soustrait les numérateurs.',
      'Pour multiplier une fraction par un entier, on multiplie le numérateur par cet entier. Pour multiplier deux fractions, on multiplie les numérateurs entre eux et les dénominateurs entre eux.',
      'Pour une fraction non nulle a/b, (a/b)^n = a^n/b^n pour un entier naturel n.',
      'Pour encadrer une fraction, on peut rechercher son écriture décimale ou comparer des produits en croix.'
    ].join('\\n\\n'),
    situation: 'Une tablette de chocolat est partagée entre plusieurs enfants. Les élèves expriment les parts sous forme de fractions et vérifient si le partage totalise bien une unité.',
    exercises: [
      ['Calcule 7/8 - 3/8.', 'Les dénominateurs sont identiques : 7/8 - 3/8 = 4/8 = 1/2.'],
      ['Calcule 3/5 × 10/9 et simplifie.', '30/45 = 2/3.'],
      ['Encadre 5/8 entre deux dixièmes consécutifs.', '5/8 = 0,625, donc 0,6 < 5/8 < 0,7.']
    ]
  },
  {
    n: 4, title: 'Proportionnalité',
    description: 'Coefficient de proportionnalité, représentation graphique, vitesse moyenne, débit moyen et masse volumique.',
    course: [
      'Deux grandeurs sont proportionnelles si l’une s’obtient en multipliant l’autre par un même coefficient.',
      'Dans une représentation graphique d’une situation de proportionnalité, les points sont alignés avec l’origine du repère.',
      'Vitesse moyenne = distance parcourue / durée. Les unités doivent être compatibles.',
      'Débit moyen = quantité écoulée / durée. Masse volumique = masse / volume.',
      'Dans un tableau de proportionnalité, le coefficient permet de passer d’une ligne à l’autre.'
    ].join('\\n\\n'),
    situation: 'Un véhicule parcourt une distance régulièrement liée à la durée du trajet. Les élèves vérifient graphiquement la proportionnalité et calculent sa vitesse moyenne.',
    exercises: [
      ['Un véhicule parcourt 150 km en 3 h. Calcule sa vitesse moyenne.', 'v = 150/3 = 50 km/h.'],
      ['Un robinet délivre 18 L en 3 min. Quel est son débit moyen ?', 'D = 18/3 = 6 L/min.'],
      ['Un objet de masse 540 g occupe 200 cm³. Calcule sa masse volumique.', 'rho = 540/200 = 2,7 g/cm³.']
    ]
  },
  {
    n: 5, title: 'Statistique',
    description: 'Population, caractère qualitatif ou quantitatif, modalités, effectifs, fréquences et diagrammes à bandes ou en bâtons.',
    course: [
      'Une population est l’ensemble étudié. Le caractère est la propriété observée. Une modalité est une valeur possible du caractère.',
      'L’effectif d’une modalité est le nombre d’individus qui la présentent. L’effectif total est la somme des effectifs.',
      'La fréquence d’une modalité est effectif / effectif total. Elle peut être exprimée en pourcentage.',
      'Un diagramme en bâtons convient notamment à des valeurs quantitatives discrètes ; un diagramme à bandes représente efficacement des catégories.'
    ].join('\\n\\n'),
    situation: 'Une classe de 60 élèves enquête sur les loisirs préférés : lecture 25 %, musique 40 %, cinéma 15 %, sport 20 %. Les élèves construisent et interprètent les diagrammes.',
    exercises: [
      ['Dans une classe de 40 élèves, 12 préfèrent le football. Donne l’effectif et la fréquence.', 'Effectif = 12 ; fréquence = 12/40 = 0,30 = 30 %.'],
      ['Une modalité a une fréquence de 25 % dans une population de 80 personnes. Quel est son effectif ?', '80 × 25/100 = 20.'],
      ['Pourquoi la somme des fréquences vaut-elle 100 % ?', 'Parce que les modalités couvrent l’ensemble de la population étudiée.']
    ]
  },
  {
    n: 6, title: 'Angles',
    description: 'Angles adjacents, complémentaires, supplémentaires, opposés par le sommet et somme des angles d’un triangle.',
    course: [
      'Deux angles sont adjacents lorsqu’ils ont un sommet et un côté communs et des intérieurs disjoints.',
      'Deux angles sont complémentaires si leur somme vaut 90°. Ils sont supplémentaires si leur somme vaut 180°.',
      'Deux angles opposés par le sommet ont la même mesure.',
      'La somme des mesures des angles d’un triangle vaut 180°. Cette propriété permet de calculer un angle inconnu.'
    ].join('\\n\\n'),
    situation: 'Les élèves mesurent les angles d’un plan de terrain afin de vérifier les indications d’un plan cadastral.',
    exercises: [
      ['Quel est le complémentaire de 37° ?', '90° - 37° = 53°.'],
      ['Quel est le supplémentaire de 128° ?', '180° - 128° = 52°.'],
      ['Dans un triangle, deux angles mesurent 48° et 67°. Calcule le troisième.', '180° - 48° - 67° = 65°.']
    ]
  },
  {
    n: 7, title: 'Segments',
    description: 'Segment, milieu, médiatrice, alignement et appartenance à un segment ou à sa médiatrice.',
    course: [
      'Le segment [AB] est limité par ses deux extrémités A et B. Sa longueur est notée AB.',
      'M est le milieu de [AB] si M appartient à [AB] et AM = MB.',
      'La médiatrice d’un segment est la droite perpendiculaire au segment en son milieu.',
      'Tout point de la médiatrice de [AB] est à égale distance de A et de B ; réciproquement, tout point équidistant de A et B appartient à cette médiatrice.'
    ].join('\\n\\n'),
    situation: 'Deux villages veulent installer une pompe à eau à égale distance de leurs centres. Les élèves cherchent le lieu géométrique des emplacements possibles.',
    exercises: [
      ['AB = 12 cm et M est le milieu de [AB]. Calcule AM.', 'AM = MB = 6 cm.'],
      ['P appartient à la médiatrice de [AB] et PA = 8 cm. Que vaut PB ?', 'PB = 8 cm.'],
      ['Décris la construction de la médiatrice de [AB] à la règle et au compas.', 'Tracer deux arcs de même rayon, supérieur à AB/2, centrés en A puis B. Relier leurs deux points d’intersection : cette droite est la médiatrice.']
    ]
  },
  {
    n: 8, title: 'Triangles',
    description: 'Triangles particuliers, axes de symétrie, droites particulières, inégalité triangulaire et constructions.',
    course: [
      'Un triangle isocèle possède deux côtés de même longueur et deux angles à la base de même mesure.',
      'Un triangle équilatéral possède trois côtés égaux et trois angles de 60°.',
      'Un triangle rectangle possède un angle droit.',
      'L’inégalité triangulaire impose que la longueur d’un côté soit strictement inférieure à la somme des longueurs des deux autres.',
      'Les principales droites particulières sont les médianes, hauteurs, médiatrices et bissectrices.'
    ].join('\\n\\n'),
    situation: 'Un projet de jardin scolaire est partagé en parcelles triangulaires. Les élèves identifient les triangles particuliers et leurs axes de symétrie.',
    exercises: [
      ['Peut-on construire un triangle de côtés 3 cm, 4 cm et 8 cm ?', 'Non, car 8 n’est pas inférieur à 3 + 4 = 7.'],
      ['Un triangle isocèle a un angle au sommet de 40°. Calcule chacun des angles à la base.', 'Les deux angles à la base sont égaux : (180° - 40°)/2 = 70°.'],
      ['Combien d’axes de symétrie possède un triangle équilatéral ?', 'Trois.']
    ]
  },
  {
    n: 9, title: 'Cercles',
    description: 'Position d’un point par rapport à un cercle ou un disque et cercle circonscrit à un triangle.',
    course: [
      'Pour un cercle de centre O et de rayon r, un point M est sur le cercle si OM = r, intérieur si OM < r et extérieur si OM > r.',
      'Le disque est l’ensemble des points dont la distance au centre est inférieure ou égale au rayon.',
      'Le cercle circonscrit à un triangle passe par ses trois sommets. Son centre est l’intersection des médiatrices des côtés.',
      'Dans un triangle rectangle, le centre du cercle circonscrit est le milieu de l’hypoténuse.'
    ].join('\\n\\n'),
    situation: 'Un technicien doit définir la zone de couverture circulaire d’un équipement installé à égale distance de trois villages.',
    exercises: [
      ['Un cercle a pour centre O et rayon 5 cm. M vérifie OM = 3 cm. Où se situe M ?', 'M est à l’intérieur du cercle et appartient au disque.'],
      ['Comment construire le cercle circonscrit à un triangle ?', 'Construire les médiatrices de deux côtés. Leur intersection est le centre du cercle circonscrit. Tracer ensuite le cercle passant par un sommet.'],
      ['Dans un triangle rectangle dont l’hypoténuse mesure 10 cm, où se trouve le centre du cercle circonscrit ?', 'Au milieu de l’hypoténuse.']
    ]
  },
  {
    n: 10, title: 'Parallélogrammes particuliers',
    description: 'Rectangle, losange, carré, propriétés des angles et diagonales, constructions, périmètre et aire du losange.',
    course: [
      'Un rectangle est un parallélogramme ayant quatre angles droits. Ses diagonales ont la même longueur et se coupent en leur milieu.',
      'Un losange est un parallélogramme dont les quatre côtés sont de même longueur. Ses diagonales sont perpendiculaires et se coupent en leur milieu.',
      'Un carré est à la fois un rectangle et un losange : il possède quatre côtés égaux et quatre angles droits.',
      'Le périmètre d’un losange de côté c est 4c. Son aire peut être calculée par A = (D × d)/2 avec D et d les diagonales.'
    ].join('\\n\\n'),
    situation: 'Des élèves reproduisent une frise composée de rectangles, losanges et carrés et doivent justifier la nature de chaque quadrilatère.',
    exercises: [
      ['Un losange a un côté de 7 cm. Calcule son périmètre.', 'P = 4 × 7 = 28 cm.'],
      ['Un losange a des diagonales de 10 cm et 6 cm. Calcule son aire.', 'A = (10 × 6)/2 = 30 cm².'],
      ['Quelle propriété permet de reconnaître un rectangle parmi les parallélogrammes ?', 'Un parallélogramme qui possède un angle droit est un rectangle.']
    ]
  },
  {
    n: 11, title: 'Prisme droit',
    description: 'Bases, faces latérales, arêtes, sommets, hauteur, patron, aire latérale, aire totale et volume.',
    course: [
      'Un prisme droit possède deux bases polygonales parallèles et superposables. Ses faces latérales sont des rectangles.',
      'La hauteur est la distance entre les deux plans des bases.',
      'Aire latérale = périmètre de la base × hauteur.',
      'Aire totale = aire latérale + 2 × aire de la base.',
      'Volume = aire de la base × hauteur.',
      'Un patron permet de représenter les faces du solide à plat afin de pouvoir le reconstituer.'
    ].join('\\n\\n'),
    situation: 'Une classe étudie un emballage en forme de prisme droit et doit déterminer la quantité de carton nécessaire et son volume.',
    exercises: [
      ['Un prisme possède une base d’aire 12 cm², un périmètre de base de 14 cm et une hauteur de 8 cm. Calcule son volume.', 'V = 12 × 8 = 96 cm³.'],
      ['Avec les mêmes données, calcule l’aire latérale.', 'A_l = 14 × 8 = 112 cm².'],
      ['Calcule l’aire totale du même prisme.', 'A_t = 112 + 2 × 12 = 136 cm².']
    ]
  },
  {
    n: 12, title: 'Figures symétriques par rapport à une droite',
    description: 'Symétrique d’un point, segment, droite, angle, cercle, milieu et propriétés conservées par symétrie orthogonale.',
    course: [
      'Deux points M et M’ sont symétriques par rapport à une droite (d) lorsque (d) est la médiatrice du segment [MM’].',
      'Pour construire le symétrique d’un point, on trace la perpendiculaire à l’axe passant par le point puis on reporte la même distance de l’autre côté.',
      'La symétrie orthogonale conserve les longueurs, les mesures des angles, l’alignement et le parallélisme.',
      'Un point situé sur l’axe de symétrie est son propre symétrique. Le symétrique d’un cercle est un cercle de même rayon.'
    ].join('\\n\\n'),
    situation: 'Un club scolaire crée un logo constitué d’un rectangle et de deux étoiles symétriques par rapport à un axe. Les élèves construisent la seconde étoile avec précision.',
    exercises: [
      ['Quelle condition permet de reconnaître deux points symétriques par rapport à une droite ?', 'La droite est la médiatrice du segment qui relie les deux points.'],
      ['Un segment mesure 7 cm. Quelle est la longueur de son symétrique ?', '7 cm : la symétrie conserve les longueurs.'],
      ['Un point appartient à l’axe de symétrie. Quelle est son image ?', 'Il est invariant : son image est lui-même.']
    ]
  }
];

function quizFor(lesson) {
  const e = lesson.exercises;
  return [
    { id: 'q1', type: 'qcm', enonce: 'Laquelle des affirmations suivantes correspond à la leçon ?', choix: [lesson.title, 'Une notion sans rapport', 'Aucune règle mathématique'], bonnesReponses: [0], reponseAttendue: '', explication: 'La question porte directement sur la leçon étudiée.', points: 1 },
    { id: 'q2', type: 'qcm', enonce: 'Quel est le bon résultat de l’exercice d’application ?', choix: [e[0][1], 'Un résultat obtenu sans calcul', 'Impossible à déterminer'], bonnesReponses: [0], reponseAttendue: '', explication: 'La correction détaillée est donnée dans la ressource.', points: 1 },
    { id: 'q3', type: 'qcm', enonce: 'Quelle démarche est recommandée ?', choix: ['Identifier les données puis choisir la propriété adaptée', 'Deviner le résultat', 'Ignorer les unités et les données'], bonnesReponses: [0], reponseAttendue: '', explication: 'Une résolution rigoureuse commence par l’identification des données et de la propriété utile.', points: 1 },
    { id: 'q4', type: 'qcm', enonce: 'Que faut-il faire après un calcul ?', choix: ['Vérifier la cohérence du résultat', 'Ne jamais relire', 'Changer les données'], bonnesReponses: [0], reponseAttendue: '', explication: 'La vérification permet de repérer les erreurs de signe, d’unité ou de calcul.', points: 1 }
  ];
}

async function main() {
  let chaptersCreated = 0;
  let resourcesCreated = 0;
  let chaptersExisting = 0;

  for (const lesson of lessons) {
    const chapterId = '5e_math_ch' + String(lesson.n).padStart(2, '0');
    const chapterRef = db.collection('ca_chapitres').doc(chapterId);
    const chapterSnap = await chapterRef.get();

    if (!chapterSnap.exists) {
      await chapterRef.set({
        code: '2026-2027_dpfc_5e_math_ch' + String(lesson.n).padStart(2, '0'),
        niveau: '5e',
        matiereId: 'math',
        anneeScolaire: '2026-2027',
        programmeVersion: 'dpfc',
        serie: '',
        theme: lesson.n <= 3 ? 'Calculs algébriques' : lesson.n <= 5 ? 'Organisation et traitement des données' : 'Géométrie du plan et de l’espace / transformations',
        titre: lesson.title,
        description: lesson.description,
        ordre: lesson.n,
        actif: true,
        ressourceNationale: true,
        sourceOfficielle: 'DPFC — Programme éducatif et guide d’exécution Mathématiques 5e',
        dateMaj: FieldValue.serverTimestamp()
      });
      chaptersCreated++;
    } else {
      chaptersExisting++;
    }

    const docs = [
      {
        id: chapterId + '_cours_complet',
        type: 'cours',
        titre: 'Cours complet — ' + lesson.title,
        ordre: 1,
        contenu: '# ' + lesson.title + '\\n\\n## Situation d’apprentissage\\n' + lesson.situation + '\\n\\n## Cours\\n' + lesson.course + '\\n\\n## Méthode\\n1. Lis la situation et relève les données utiles.\\n2. Identifie la propriété ou la formule adaptée.\\n3. Effectue les calculs en respectant les signes et les unités.\\n4. Rédige une conclusion et vérifie le résultat.'
      },
      {
        id: chapterId + '_exercices_corriges',
        type: 'exercice',
        titre: 'Exercices corrigés — ' + lesson.title,
        ordre: 2,
        contenu: lesson.exercises.map((x,i) => '### Exercice ' + (i+1) + '\\n' + x[0] + '\\n\\n**Correction :** ' + x[1]).join('\\n\\n'),
        enonce: lesson.exercises.map((x,i) => (i+1) + '. ' + x[0]).join('\\n'),
        solution: lesson.exercises.map((x,i) => (i+1) + '. ' + x[1]).join('\\n')
      },
      {
        id: chapterId + '_renforcement',
        type: 'renforcement',
        titre: 'Renforcement — ' + lesson.title,
        ordre: 3,
        contenu: '### Objectif\\nConsolider les automatismes de la leçon.\\n\\n### À faire sans regarder la correction\\n' +
          lesson.exercises.map((x,i) => (i+1) + '. Refaire : ' + x[0]).join('\\n') +
          '\\n\\n### Défi\\nExplique à voix haute la propriété utilisée dans chaque exercice et indique pourquoi elle convient.\\n\\n### Auto-évaluation\\n□ Je connais les définitions.\\n□ Je sais choisir la bonne formule ou propriété.\\n□ Je sais rédiger les étapes.\\n□ Je vérifie mon résultat.'
      },
      {
        id: chapterId + '_quiz',
        type: 'quiz',
        titre: 'Quiz — ' + lesson.title,
        ordre: 4,
        questions: quizFor(lesson),
        dureeMinutes: 8
      },
      {
        id: chapterId + '_fiche_revision',
        type: 'fiche',
        titre: 'Fiche de révision — ' + lesson.title,
        ordre: 5,
        contenu: '# Fiche de révision — ' + lesson.title + '\\n\\n## L’essentiel\\n' + lesson.course +
          '\\n\\n## Formules / propriétés à mémoriser\\n' + lesson.exercises.map(x => '• ' + x[1]).join('\\n') +
          '\\n\\n## Réflexes\\n• Identifier les données.\\n• Choisir la propriété adaptée.\\n• Poser les calculs clairement.\\n• Vérifier signe, unité et ordre de grandeur.'
      }
    ];

    for (const r of docs) {
      const ref = db.collection('ca_ressources').doc(r.id);
      if ((await ref.get()).exists) continue;
      await ref.set({
        type: r.type,
        titre: r.titre,
        ordre: r.ordre,
        chapitreId: chapterId,
        niveau: '5e',
        matiereId: 'math',
        ecoleId: '',
        contenu: r.contenu || '',
        imagesUrls: [],
        pdfUrl: '',
        videoYoutubeId: '',
        enonce: r.enonce || '',
        solution: r.solution || '',
        difficulte: 1,
        ressourceLieeId: '',
        questions: r.questions || [],
        dureeMinutes: r.dureeMinutes || 0,
        examen: '',
        annee: 0,
        serie: '',
        actif: true,
        ressourceNationale: true,
        auteur: 'sentinel-math5e-2026',
        dateCreation: FieldValue.serverTimestamp(),
        dateMaj: FieldValue.serverTimestamp()
      });
      resourcesCreated++;
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    dateMaj: FieldValue.serverTimestamp(),
    derniereRessourceNationale: '5e_math_2026_2027'
  }, { merge: true });

  console.log(JSON.stringify({
    ok: true,
    niveau: '5e',
    matiere: 'math',
    programmeVersion: 'dpfc',
    lecons: lessons.length,
    chapitresCrees: chaptersCreated,
    chapitresDejaPresents: chaptersExisting,
    ressourcesCreees: resourcesCreated
  }, null, 2));
}

main().catch(err => {
  console.error('SEED_5E_MATH_ERROR');
  console.error(err && err.stack ? err.stack : err);
  process.exit(1);
});

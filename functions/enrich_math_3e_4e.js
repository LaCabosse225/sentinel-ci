const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const programmes = {
  '4e': [
    ['Nombres décimaux relatifs',
     'Les nombres décimaux relatifs comprennent les positifs, les négatifs et zéro.',
     'Une puissance de 10 déplace la virgule : 10^3 = 1 000 et 10^-2 = 0,01. En notation scientifique, on écrit un nombre sous la forme a × 10^n avec 1 ≤ a < 10. Pour les opérations sur les relatifs, on respecte les règles de signes et on aligne les chiffres décimaux pour les additions et soustractions.',
     'Écris 0,00045 en notation scientifique puis calcule (-2,5) × 4.',
     '0,00045 = 4,5 × 10^-4 et (-2,5) × 4 = -10.'],
    ['Nombres rationnels',
     'Un nombre rationnel peut être écrit comme quotient de deux entiers avec un dénominateur non nul.',
     'Pour simplifier une fraction, on divise le numérateur et le dénominateur par un même diviseur commun. Le PGCD permet de trouver le plus grand de ces diviseurs. Pour additionner des fractions, on cherche un dénominateur commun. L’inverse de a/b non nul est b/a.',
     'Simplifie 18/24 puis calcule 2/3 + 1/6.',
     '18/24 = 3/4 et 2/3 = 4/6, donc 2/3 + 1/6 = 5/6.'],
    ['Équations et inéquations',
     'Une équation traduit une égalité contenant une inconnue ; une inéquation traduit une comparaison.',
     'Résoudre une équation consiste à trouver toutes les valeurs de l’inconnue qui rendent l’égalité vraie. On peut ajouter, soustraire, multiplier ou diviser les deux membres par un même nombre non nul. Pour une inéquation, attention : multiplier ou diviser par un nombre négatif inverse le sens de l’inégalité.',
     'Résous 3x + 5 = 17 puis 2x - 1 < 7.',
     '3x = 12 donc x = 4. Et 2x < 8 donc x < 4.'],
    ['Calcul littéral',
     'Le calcul littéral utilise des lettres pour représenter des nombres.',
     'Développer consiste à supprimer les parenthèses en utilisant la distributivité. Réduire consiste à regrouper les termes semblables. Factoriser consiste à mettre un facteur commun en évidence. Les produits remarquables permettent de développer ou factoriser certaines expressions plus rapidement.',
     'Développe 3(x + 2) puis factorise 5x + 10.',
     '3(x + 2) = 3x + 6. Pour 5x + 10, on met 5 en facteur : 5(x + 2).'],
    ['Statistique',
     'Une série statistique rassemble des données observées sur une population.',
     'L’effectif compte les occurrences d’une valeur. La moyenne utilise la somme des valeurs divisée par l’effectif total. Le mode est la valeur la plus fréquente. Un diagramme semi-circulaire représente 180°, donc l’angle d’une modalité de fréquence f est obtenu par 180 × f.',
     'Pour 8, 10, 10, 12, 15, calcule la moyenne et le mode.',
     'La somme vaut 55 et l’effectif est 5 : moyenne = 11. La valeur la plus fréquente est 10 : le mode est 10.'],
    ['Angles',
     'Les angles permettent de comparer et de démontrer des relations entre droites et figures.',
     'Deux angles complémentaires ont une somme de 90° ; deux angles supplémentaires, 180°. Des angles opposés par le sommet ont la même mesure. Lorsque deux droites parallèles sont coupées par une sécante, les angles correspondants sont égaux et les angles alternes-internes sont égaux.',
     'Deux droites parallèles sont coupées par une sécante. Un angle correspondant mesure 65°. Quelle est la mesure de l’autre angle correspondant ?',
     '65°. Des angles correspondants ont la même mesure lorsque les droites sont parallèles.'],
    ['Distances',
     'La distance d’un point à une droite est la plus courte longueur entre le point et la droite.',
     'Cette distance est portée par la perpendiculaire à la droite passant par le point. Pour deux droites parallèles, leur distance commune est la longueur d’un segment perpendiculaire aux deux droites. La bissectrice d’un angle est l’ensemble des points équidistants de ses deux côtés.',
     'Que représente la distance d’un point A à une droite d ?',
     'C’est la longueur du segment perpendiculaire à d reliant A à son pied sur d.'],
    ['Cercles et triangles',
     'Les cercles et les triangles possèdent des propriétés qui permettent de construire des figures et de démontrer des relations.',
     'La tangente à un cercle en un point est perpendiculaire au rayon qui aboutit à ce point. Dans un triangle, une médiane relie un sommet au milieu du côté opposé, une hauteur est perpendiculaire au côté opposé et une bissectrice partage un angle en deux angles égaux. Les points remarquables comprennent notamment le centre de gravité et l’orthocentre.',
     'Dans un triangle, cite trois droites particulières et trois points remarquables.',
     'Médianes, hauteurs et bissectrices. Parmi les points remarquables : centre de gravité, orthocentre et centre du cercle inscrit.'],
    ['Vecteurs',
     'Un vecteur décrit un déplacement par une direction, un sens et une longueur.',
     'Deux vecteurs sont égaux s’ils ont même direction, même sens et même longueur. Le vecteur opposé change le sens. La relation de Chasles permet d’écrire une chaîne de déplacements : vecteur AC = vecteur AB + vecteur BC.',
     'Si le vecteur AB est égal au vecteur BC, quelle relation peut-on écrire ?',
     'On peut écrire vecteur AC = vecteur AB + vecteur BC.'],
    ['Perspective cavalière',
     'La perspective cavalière est une façon de représenter un solide sur une feuille plane.',
     'Les faces avant sont généralement représentées sans déformation, tandis que les arêtes fuyantes sont tracées selon une même direction conventionnelle. Les arêtes parallèles dans le solide restent parallèles sur le dessin. Certaines arêtes cachées peuvent être représentées en pointillés.',
     'Cite un solide représentable en perspective cavalière et une règle importante.',
     'Un pavé droit convient. Une règle essentielle est de conserver le parallélisme des arêtes parallèles du solide.'],
    ['Symétries et translations',
     'Les transformations déplacent les figures tout en conservant certaines propriétés.',
     'Une symétrie centrale correspond à un demi-tour de 180°. Une symétrie orthogonale utilise un axe et conserve les distances. Une translation déplace tous les points selon le même vecteur. Ces transformations conservent les longueurs et les angles.',
     'Quelle transformation correspond à un demi-tour de 180° autour d’un point ?',
     'La symétrie centrale de centre ce point.']
  ],
  '3e': [
    ['Calcul littéral',
     'Le calcul littéral permet de généraliser un calcul en utilisant des lettres.',
     'Développer utilise la distributivité : a(b+c)=ab+ac. Réduire consiste à regrouper les termes de même nature. Factoriser est l’opération inverse du développement : on cherche un facteur commun ou une identité remarquable. Il faut conserver les signes de chaque terme.',
     'Développe 3(x+5), réduis 7x - 3 + 2x + 8 puis factorise 6x + 18.',
     '3x+15 ; 9x+5 ; 6(x+3).'],
    ['Équations du premier degré',
     'Une équation du premier degré permet de trouver une valeur inconnue.',
     'L’idée est de conserver l’égalité pendant toute la résolution. On effectue la même opération aux deux membres. À la fin, on remplace la valeur trouvée dans l’équation de départ pour vérifier.',
     'Résous 3x + 5 = 20 puis vérifie la solution.',
     '3x = 15 donc x = 5. Vérification : 3×5+5 = 20, l’égalité est vraie.'],
    ['Nombres rationnels',
     'Les fractions permettent de représenter exactement des quotients et des proportions.',
     'Pour additionner ou soustraire, il faut un dénominateur commun. Pour multiplier, on multiplie numérateurs et dénominateurs. Diviser par une fraction revient à multiplier par son inverse. Toujours simplifier lorsque c’est possible.',
     'Calcule 3/4 + 1/8, puis 5/6 × 3/10 et enfin 2/3 ÷ 4/5.',
     '3/4 = 6/8, donc 7/8. 5/6×3/10 = 15/60 = 1/4. 2/3×5/4 = 10/12 = 5/6.'],
    ['Puissances et écriture scientifique',
     'Les puissances de 10 permettent d’écrire rapidement de très grands ou très petits nombres.',
     '10^n signifie 10 multiplié n fois lorsque n est positif. Avec un exposant négatif, 10^-n = 1/10^n. En notation scientifique, le nombre s’écrit a×10^n avec 1 ≤ a < 10. Les puissances sont utiles pour comparer les ordres de grandeur.',
     'Écris 450000 et 0,00072 en notation scientifique.',
     '450000 = 4,5×10^5. 0,00072 = 7,2×10^-4.'],
    ['Racines carrées',
     'La racine carrée d’un nombre positif est le nombre positif dont le carré redonne ce nombre.',
     'Ainsi √49 = 7 car 7² = 49. Pour comparer √20 et √25, on peut comparer 20 et 25 car la fonction racine carrée est croissante sur les nombres positifs. Pour simplifier une racine, on cherche si le nombre contient un carré parfait comme facteur.',
     'Compare √20 et √25.',
     '20 < 25 donc √20 < √25 = 5.'],
    ['Théorème de Thalès',
     'Le théorème de Thalès relie des longueurs lorsque des droites parallèles coupent deux sécantes.',
     'Dans une configuration de Thalès, les rapports de longueurs correspondantes sont égaux. Il faut d’abord identifier les points alignés et les droites parallèles avant d’écrire les rapports. La réciproque permet de démontrer que deux droites sont parallèles lorsque les rapports correspondants sont égaux.',
     'AM/AB = 2/5 et AB = 15 cm. Calcule AM.',
     'AM = 15×2/5 = 6 cm.'],
    ['Théorème de Pythagore',
     'Dans un triangle rectangle, le carré de l’hypoténuse est égal à la somme des carrés des deux autres côtés.',
     'Si ABC est rectangle en A, alors BC² = AB² + AC². Pour calculer une longueur, remplace les valeurs puis prends éventuellement une racine carrée. La réciproque permet de prouver qu’un triangle est rectangle.',
     'Un triangle rectangle a des côtés de l’angle droit de 6 cm et 8 cm. Calcule l’hypoténuse.',
     'BC² = 6² + 8² = 36 + 64 = 100, donc BC = 10 cm.'],
    ['Trigonométrie',
     'Dans un triangle rectangle, sinus, cosinus et tangente relient les angles et les longueurs.',
     'Pour un angle aigu : cos = côté adjacent / hypoténuse ; sin = côté opposé / hypoténuse ; tan = côté opposé / côté adjacent. Avant d’utiliser une formule, identifie l’angle étudié et les côtés par rapport à cet angle.',
     'Dans un triangle rectangle, cos(A)=0,8 et l’hypoténuse vaut 10 cm. Calcule le côté adjacent à A.',
     'Côté adjacent = 0,8×10 = 8 cm.'],
    ['Statistique',
     'Les statistiques permettent de résumer une série de données.',
     'La moyenne donne une valeur centrale calculée. La médiane est la valeur qui partage une série ordonnée en deux groupes de même effectif. L’étendue est la différence entre la plus grande et la plus petite valeur. Toujours ordonner les données avant de chercher la médiane.',
     'Pour 8, 10, 12, 14, calcule la moyenne.',
     'Moyenne = (8+10+12+14)/4 = 44/4 = 11.'],
    ['Fonctions',
     'Une fonction associe à chaque valeur admissible x une unique image.',
     'Pour calculer une image, on remplace x par sa valeur dans l’expression. Une fonction affine s’écrit f(x)=ax+b. Le nombre a représente le coefficient directeur et b l’ordonnée à l’origine dans une représentation graphique.',
     'f(x)=2x+3. Calcule f(4).',
     'f(4)=2×4+3=11.'],
    ['Géométrie dans l’espace',
     'La géométrie dans l’espace étudie les solides et leurs mesures.',
     'Le volume d’un pavé droit est longueur × largeur × hauteur. Pour un prisme droit, volume = aire de la base × hauteur. Il faut respecter les unités : 1 dm³ = 1 L et 1 cm³ = 1 mL.',
     'Une base de prisme a une aire de 12 cm² et la hauteur vaut 7 cm. Calcule le volume.',
     'V = 12×7 = 84 cm³.'],
    ['Transformations et repérage',
     'Le repérage permet de décrire la position des points et les transformations permettent de déplacer les figures.',
     'Dans un repère, un point est défini par ses coordonnées. Une translation ajoute un même déplacement aux coordonnées. Une symétrie conserve les distances mais change la position de la figure. Une rotation fait tourner la figure autour d’un centre selon un angle donné.',
     'Le point A(2 ; 3) est translaté de 4 unités vers la droite. Donne ses nouvelles coordonnées.',
     'A’(6 ; 3).']
  ]
};

function base(chapitreId, niveau, type, data) {
  return {
    chapitreId,
    niveau,
    matiereId: 'math',
    ecoleId: '',
    imagesUrls: [],
    pdfUrl: '',
    videoYoutubeId: '',
    enonce: '',
    solution: '',
    difficulte: type === 'quiz' ? 2 : 1,
    ressourceLieeId: '',
    questions: [],
    dureeMinutes: type === 'cours' ? 30 : type === 'quiz' ? 8 : 20,
    examen: '',
    annee: 0,
    serie: '',
    actif: true,
    ressourceNationale: true,
    auteur: 'sentinel-pedagogie-math-2026',
    dateMaj: FieldValue.serverTimestamp(),
    ...data,
  };
}

function quiz(lesson) {
  return [
    {id:'q1',type:'qcm',enonce:'La leçon étudiée porte sur…',choix:[lesson[0],'une notion sans rapport','aucune notion'],bonnesReponses:[0],reponseAttendue:'',explication:'La question vérifie que l’élève identifie la notion travaillée.',points:1},
    {id:'q2',type:'qcm',enonce:'Quelle stratégie est correcte ?',choix:['Identifier les données et choisir la propriété adaptée','Deviner le résultat','Ignorer les unités'],bonnesReponses:[0],reponseAttendue:'',explication:'Une résolution rigoureuse commence par les données et la propriété utile.',points:1},
    {id:'q3',type:'qcm',enonce:'Que faut-il faire après le calcul ?',choix:['Vérifier le résultat','Ne pas relire','Modifier l’énoncé'],bonnesReponses:[0],reponseAttendue:'',explication:'La vérification permet de repérer les erreurs de signe, de calcul ou d’unité.',points:1}
  ];
}

async function enrichir(niveau, lessons) {
  let updated = 0;
  for (let i=0;i<lessons.length;i++) {
    const [titre, intro, cours, exemple, correction] = lessons[i];
    const chapitreId = niveau + '_math_ch' + String(i+1).padStart(2,'0');
    const chapRef = db.collection('ca_chapitres').doc(chapitreId);
    const chap = await chapRef.get();
    if (!chap.exists) continue;

    const coursComplet = [
      '# ' + titre,
      '',
      '## 1. Comprendre la notion',
      intro,
      '',
      '## 2. Le cours',
      cours,
      '',
      '## 3. Exemple guidé',
      exemple,
      '',
      '### Correction expliquée',
      correction,
      '',
      '## 4. Méthode de résolution',
      '1. Lis la consigne et relève les données utiles.',
      '2. Identifie la propriété, la définition ou la formule qui correspond.',
      '3. Écris les étapes du raisonnement.',
      '4. Effectue les calculs avec les unités et les signes corrects.',
      '5. Vérifie le résultat et formule une réponse complète.',
      '',
      '## 5. Erreurs à éviter',
      'Ne choisis pas une formule uniquement parce qu’elle contient les mêmes nombres que l’énoncé. Vérifie toujours ce que représentent les grandeurs et pourquoi la propriété choisie s’applique.',
      '',
      '## À retenir',
      'Une notion est vraiment maîtrisée lorsque tu peux la définir, expliquer à quoi elle sert et résoudre une situation simple sans regarder la correction.'
    ].join('\\n');

    const courseRef = db.collection('ca_ressources').doc(chapitreId+'_cours_complet');
    const exRef = db.collection('ca_ressources').doc(chapitreId+'_exercices_corriges');
    const renfRef = db.collection('ca_ressources').doc(chapitreId+'_renforcement');
    const quizRef = db.collection('ca_ressources').doc(chapitreId+'_quiz');
    const ficheRef = db.collection('ca_ressources').doc(chapitreId+'_fiche_revision');

    await courseRef.set(base(chapitreId,niveau,'cours',{
      type:'cours',titre:'Cours complet — '+titre,ordre:1,contenu:coursComplet
    }),{merge:true});

    await exRef.set(base(chapitreId,niveau,'exercice',{
      type:'exercice',titre:'Exercices corrigés — '+titre,ordre:2,
      contenu:'## Exercices d’application\\n\\n'+exemple+'\\n\\n## Correction détaillée\\n\\n'+correction,
      enonce:exemple,solution:correction
    }),{merge:true});

    await renfRef.set(base(chapitreId,niveau,'renforcement',{
      type:'renforcement',titre:'Entraînement et méthode — '+titre,ordre:3,
      contenu:'## Refaire sans aide\\n\\nReprends l’exemple de la leçon sans regarder sa correction.\\n\\n## Puis explique\\n\\nEn trois phrases, explique pourquoi la méthode utilisée fonctionne.\\n\\n## Auto-évaluation\\n□ Je connais la définition.\\n□ Je sais reconnaître la situation.\\n□ Je sais appliquer la méthode.\\n□ Je peux vérifier mon résultat.'
    }),{merge:true});

    await quizRef.set(base(chapitreId,niveau,'quiz',{
      type:'quiz',titre:'Quiz de vérification — '+titre,ordre:4,questions:quiz([titre,intro,cours,exemple,correction])
    }),{merge:true});

    await ficheRef.set(base(chapitreId,niveau,'fiche',{
      type:'fiche',titre:'Fiche de révision — '+titre,ordre:5,
      contenu:'# Fiche de révision — '+titre+'\\n\\n## Idée centrale\\n'+intro+'\\n\\n## Règle essentielle\\n'+cours+'\\n\\n## Exemple à connaître\\n'+exemple+'\\n\\n## Résultat\\n'+correction+'\\n\\n## Réflexes\\nDonnées → propriété → calcul → vérification.'
    }),{merge:true});

    updated += 5;
  }
  console.log(JSON.stringify({niveau,chapitres:lessons.length,ressourcesMisesAJour:updated},null,2));
}

(async()=>{
  await enrichir('4e',programmes['4e']);
  await enrichir('3e',programmes['3e']);
  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    dateMaj: FieldValue.serverTimestamp(),
    derniereRessourceNationale: 'math_3e_4e_enrichi'
  },{merge:true});
  console.log('ENRICHISSEMENT MATHS 3e-4e TERMINE');
})().catch(err=>{
  console.error('ENRICH_MATH_3E4E_ERROR');
  console.error(err && err.stack ? err.stack : err);
  process.exit(1);
});
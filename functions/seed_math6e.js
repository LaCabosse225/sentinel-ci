const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const chapitres = [
  [1, 'Nombres entiers naturels', 'Écriture, comparaison, opérations et propriétés des nombres entiers naturels.'],
  [2, 'Droites et points', 'Points, droites, demi-droites, segments, alignement et constructions.'],
  [3, 'Nombres décimaux relatifs', 'Repérage, comparaison et opérations sur les nombres décimaux relatifs.'],
  [4, 'Segments', 'Longueur, milieu, médiatrice et constructions de segments.'],
  [5, 'Pavés droits et cylindres droits', 'Patrons, aires et volumes des pavés droits et cylindres droits.'],
  [6, 'Fractions', 'Écriture, comparaison, opérations et problèmes avec les fractions.'],
  [7, 'Cercles et disques', 'Vocabulaire, constructions, périmètre et aire du disque.'],
  [8, 'Angles', 'Mesure, construction, angles particuliers et relations simples.'],
  [9, 'Triangles', 'Construction et propriétés des triangles.'],
  [10, 'Proportionnalité', 'Situations de proportionnalité, tableaux et calculs.'],
  [11, 'Figures symétriques par rapport à un point', 'Symétrie centrale et propriétés des figures.'],
  [12, 'Statistique', 'Collecte, organisation et représentation de données.'],
  [13, 'Parallélogramme', 'Construction et propriétés du parallélogramme.'],
];

async function main() {
  const chapRef = db.collection('ca_chapitres');
  const batch = db.batch();
  let created = 0;
  let existing = 0;

  for (const [ordre, titre, description] of chapitres) {
    const id = `6e_math_ch${String(ordre).padStart(2, '0')}`;
    const ref = chapRef.doc(id);
    const snap = await ref.get();
    if (snap.exists) {
      existing++;
      continue;
    }
    batch.set(ref, {
      code: `2026-2027_dpfc_6e_math_ch${String(ordre).padStart(2, '0')}`,
      niveau: '6e',
      matiereId: 'math',
      anneeScolaire: '2026-2027',
      programmeVersion: 'dpfc',
      serie: '',
      theme: '',
      titre,
      description,
      ordre,
      actif: true,
      dateMaj: FieldValue.serverTimestamp(),
    });
    created++;
  }

  if (created > 0) await batch.commit();

  // Un vrai mini-cours publié immédiatement pour la démonstration de demain.
  // On ne remplace jamais une ressource déjà existante.
  const ressources = [
    {
      id: '6e_math_ch01_cours_officiel',
      type: 'cours',
      titre: 'Cours — Nombres entiers naturels',
      ordre: 1,
      contenu: `# Nombres entiers naturels

Les nombres entiers naturels sont les nombres 0, 1, 2, 3, 4, ... Ils permettent de compter et de dénombrer.

## 1. Écriture et lecture
Un nombre entier peut être décomposé selon ses rangs : unités, dizaines, centaines, milliers, etc.

Exemple : 4 582 = 4 milliers + 5 centaines + 8 dizaines + 2 unités.

## 2. Comparer deux nombres
Pour comparer deux nombres, on compare d'abord leur nombre de chiffres. S'ils ont le même nombre de chiffres, on compare les chiffres de gauche à droite.

Exemple : 5 231 > 4 999.

## 3. Les quatre opérations
L'addition et la multiplication regroupent des quantités. La soustraction recherche une différence et la division permet notamment de partager une quantité.

Exemple : 24 + 18 = 42 ; 30 - 12 = 18 ; 6 × 7 = 42 ; 42 ÷ 6 = 7.

## À retenir
Un entier naturel est toujours positif ou nul. Pour résoudre un problème, lis attentivement les données, choisis l'opération adaptée puis vérifie que le résultat est cohérent.`,
      difficulte: 1,
      actif: true,
    },
    {
      id: '6e_math_ch01_renforcement',
      type: 'renforcement',
      titre: 'Renforcement — Lire et comparer les entiers',
      ordre: 2,
      contenu: `Pour comparer 7 405 et 7 450, les milliers puis les centaines sont identiques. On compare alors les dizaines : 0 < 5, donc 7 405 < 7 450.

Astuce : aligne toujours les nombres en colonnes avant de comparer ou de calculer.`,
      difficulte: 1,
      actif: true,
    },
    {
      id: '6e_math_ch01_exercice',
      type: 'exercice',
      titre: 'Exercice corrigé — Opérations sur les entiers',
      ordre: 3,
      enonce: 'Calcule : A = 245 + 378 ; B = 900 - 457 ; C = 24 × 15 ; D = 840 ÷ 12.',
      solution: 'A = 623 ; B = 443 ; C = 360 ; D = 70.',
      difficulte: 1,
      actif: true,
    },
    {
      id: '6e_math_ch01_quiz',
      type: 'quiz',
      titre: 'Quiz — Nombres entiers naturels',
      ordre: 4,
      questions: [
        {
          id: 'q1',
          type: 'qcm',
          enonce: 'Quel nombre est le plus grand ?',
          choix: ['3 205', '3 250', '3 025'],
          bonnesReponses: [1],
          reponseAttendue: '',
          explication: '3 250 est supérieur à 3 205 et à 3 025.',
          points: 1,
        },
        {
          id: 'q2',
          type: 'qcm',
          enonce: 'Combien font 8 × 7 ?',
          choix: ['54', '56', '64'],
          bonnesReponses: [1],
          reponseAttendue: '',
          explication: '8 × 7 = 56.',
          points: 1,
        },
      ],
      dureeMinutes: 5,
      difficulte: 1,
      actif: true,
    },
  ];

  let resourcesCreated = 0;
  for (const r of ressources) {
    const ref = db.collection('ca_ressources').doc(r.id);
    const snap = await ref.get();
    if (snap.exists) continue;
    const data = {
      type: r.type,
      titre: r.titre,
      ordre: r.ordre,
      chapitreId: '6e_math_ch01',
      niveau: '6e',
      matiereId: 'math',
      ecoleId: '',
      contenu: r.contenu || '',
      imagesUrls: [],
      pdfUrl: '',
      videoYoutubeId: '',
      enonce: r.enonce || '',
      solution: r.solution || '',
      difficulte: r.difficulte || 1,
      ressourceLieeId: '',
      questions: r.questions || [],
      dureeMinutes: r.dureeMinutes || 0,
      examen: '',
      annee: 0,
      serie: '',
      actif: true,
      auteur: 'sentinel-seed-2026',
      dateCreation: FieldValue.serverTimestamp(),
      dateMaj: FieldValue.serverTimestamp(),
    };
    await ref.set(data);
    resourcesCreated++;
  }

  // ========================================================================
  // CONTENU PEDAGOGIQUE MASSIF — MATH 6e
  // ========================================================================
  const leconsMath6e = [[2,"Droites et points","Un point se note par une lettre majuscule. La droite (AB) passe par A et B et est illimitee. La demi-droite [AB) a pour origine A. Le segment [AB] est limite par A et B. Des points sont alignes lorsqu ils appartiennent a une meme droite. Deux droites peuvent etre secantes ou paralleles.","Trace (AB), place C sur (AB), puis construis [DE] de 6 cm. Explique la difference entre une droite et un segment.","C appartient a (AB). (AB) est illimitee dans les deux directions, alors que [DE] est limite par D et E.",["Le symbole (AB) designe une droite.","Des points situes sur une meme droite sont alignes."]],[3,"Nombres decimaux relatifs","Un nombre decimal relatif peut etre positif, nul ou negatif. Sur une droite graduee, le plus grand nombre est le plus a droite. L oppose de +4,2 est -4,2 et la distance a zero de -5 est 5. Pour additionner des nombres de meme signe, on additionne les distances a zero et on conserve le signe. Pour des signes differents, on soustrait les distances et on garde le signe du plus grand en valeur absolue.","Calcule A=-7+12 ; B=4,5-8 ; C=-3,2-(-1,8) ; D=-2,5+(-4).","A=5 ; B=-3,5 ; C=-1,4 ; D=-6,5.",["Le plus grand entre -4,2 et -1,9 est -1,9.","L oppose de -6,3 est +6,3."]],[4,"Segments","Le segment [AB] possede deux extremites et sa longueur se note AB. M est le milieu de [AB] si M appartient au segment et AM=MB. La mediatrice est la droite perpendiculaire au segment qui passe par son milieu. Tout point de la mediatrice est a egale distance des deux extremites.","AB=10 cm et M est son milieu. Calcule AM. Que peut-on dire d un point P de la mediatrice de [AB] ?","AM=5 cm. Tout point P de la mediatrice verifie PA=PB.",["Si AB=12 cm et M est son milieu, AM=6 cm.","La mediatrice est perpendiculaire au segment en son milieu."]],[5,"Paves droits et cylindres droits","Un pave droit possede six faces rectangulaires. Son volume est V=L x l x h. Un patron permet de reconstituer le solide par pliage. Un cylindre droit possede deux bases circulaires identiques et son volume est V=pi x r² x h. On peut prendre pi=3,14 pour un calcul usuel. 1 dm³=1 L et 1 cm³=1 mL.","Calcule le volume d un pave 8 x 4 x 3 cm puis celui d un cylindre de rayon 2 cm et hauteur 5 cm avec pi=3,14.","Pave : 96 cm³. Cylindre : 62,8 cm³.",["Le volume d un pave 4 x 3 x 2 vaut 24 cm³.","Le volume d un cylindre est pi x r² x h."]],[6,"Fractions","Dans a/b, a est le numerateur et b le denominateur, avec b non nul. Une fraction represente notamment une partie d une unite. Multiplier ou diviser numerateur et denominateur par un meme nombre non nul donne une fraction equivalente. Avec un meme denominateur, on additionne ou soustrait les numerateurs. Pour des denominateurs differents, on cherche un denominateur commun. Pour calculer 3/5 de 20, on fait 20 x 3/5=12.","Calcule et simplifie A=2/9+4/9 ; B=7/8-3/8 ; C=3/5 de 40.","A=2/3 ; B=1/2 ; C=24.",["Dans 5/8, le denominateur est 8.","2/6 est egal a 1/3."]],[7,"Cercles et disques","Un cercle est l ensemble des points situes a une meme distance d un centre O. Cette distance est le rayon r. Le diametre d vaut 2r. Le disque est la surface interieure du cercle. La longueur du cercle est P=2pi r et l aire du disque est A=pi r². Avec pi=3,14, un rayon de 5 cm donne environ 31,4 cm de longueur et 78,5 cm² d aire.","Un disque a un rayon de 4 cm. Calcule son diametre et son aire avec pi=3,14.","Diametre=8 cm. Aire=50,24 cm².",["Si r=6 cm, le diametre vaut 12 cm.","L aire d un disque est pi x r²."]],[8,"Angles","Un angle est forme par deux demi-droites de meme origine. On le mesure avec un rapporteur. Un angle aigu mesure moins de 90°, un angle droit 90°, un angle obtus entre 90° et 180° et un angle plat 180°. Deux angles complementaires ont une somme de 90°. Deux angles supplementaires ont une somme de 180°.","Donne la nature de 35°, 90°, 125°, 180°. Puis calcule l angle complementaire de 28°.","35° aigu, 90° droit, 125° obtus, 180° plat. Complementaire de 28° : 62°.",["Un angle droit mesure 90°.","Deux angles supplementaires ont une somme de 180°."]],[9,"Triangles","Un triangle est un polygone a trois cotes, trois sommets et trois angles. La somme des angles d un triangle est 180°. Un triangle equilateral a trois cotes egaux et trois angles de 60°. Un triangle isocele a deux cotes egaux et deux angles a la base egaux. Un triangle rectangle possede un angle droit.","Dans ABC, A=45° et B=65°. Calcule C. Le triangle peut-il etre equilateral ?","C=70°. Non, un triangle equilateral a trois angles de 60°.",["La somme des angles d un triangle est 180°.","Un triangle a trois cotes egaux est equilateral."]],[10,"Proportionnalite","Deux grandeurs sont proportionnelles lorsqu on passe de l une a l autre en multipliant toujours par le meme coefficient. Dans un tableau de proportionnalite, ce coefficient permet de passer d une ligne a l autre. Pour une quatrieme proportionnelle, on peut utiliser les produits en croix. Un pourcentage est une proportion sur 100 : 20% de 50 = 10.","5 kg de riz coutent 4 000 F. Calcule le prix de 1 kg, de 8 kg puis 10% de 8 000 F.","1 kg coute 800 F ; 8 kg coutent 6 400 F ; 10% de 8 000 F vaut 800 F.",["Si 3 objets coutent 1 500 F, un objet coute 500 F.","25% de 200 vaut 50."]],[11,"Figures symetriques par rapport a un point","Deux points A et A' sont symetriques par rapport a O lorsque O est le milieu de [AA']. Pour construire A', on trace AO puis on reporte OA de l autre cote de O. La symetrie centrale conserve les longueurs, les angles et l alignement : c est un demi-tour de 180°. Un parallelogramme possede pour centre de symetrie le point d intersection de ses diagonales.","O est le milieu de [AA'] et OA=3,5 cm. Que vaut OA' ? La symetrie centrale conserve-t-elle les longueurs ?","OA'=3,5 cm. Oui, les longueurs sont conservees.",["Dans une symetrie centrale, O est le milieu de [AA'].","La symetrie centrale correspond a un demi-tour de 180°."]],[12,"Statistique","Une serie statistique rassemble des donnees recueillies sur une population. L effectif est le nombre d apparitions d une valeur et l effectif total est la somme des effectifs. La frequence est effectif/effectif total et peut etre exprimee en pourcentage. La moyenne d une serie simple est la somme des valeurs divisee par leur nombre. Les donnees peuvent etre representees par un tableau ou un diagramme.","Notes : 8, 10, 10, 12, 15. Donne l effectif total, la moyenne et la frequence de 10.","Effectif total=5. Moyenne=11. Frequence de 10=2/5=40%.",["La moyenne de 4, 6 et 8 est 6.","Une frequence peut etre exprimee en pourcentage."]],[13,"Parallelogramme","Un parallelogramme est un quadrilatere dont les cotes opposes sont paralleles deux a deux. Ses cotes opposes ont la meme longueur et ses angles opposes la meme mesure. Ses diagonales se coupent en leur milieu. Si ses cotes mesurent a et b, son perimetre est P=2(a+b). Ces proprietes permettent aussi de reconnaitre un parallelogramme.","ABCD est un parallelogramme. AB=8 cm et BC=5 cm. Donne CD et AD puis calcule le perimetre.","CD=8 cm, AD=5 cm et P=26 cm.",["Les diagonales d un parallelogramme se coupent en leur milieu.","Un parallelogramme de cotes 6 cm et 4 cm a un perimetre de 20 cm."]]];
  for (const l of leconsMath6e) {
    const chapitreId = '6e_math_ch' + String(l[0]).padStart(2, '0');
    const docs = [
      { id: chapitreId + '_cours_complet', type: 'cours', titre: 'Cours complet — ' + l[1], ordre: 1, contenu: '# ' + l[1] + '\\n\\n' + l[2] + '\\n\\n## A retenir\\n\\n' + l[3] },
      { id: chapitreId + '_exercices_corriges', type: 'exercice', titre: 'Exercices corriges — ' + l[1], ordre: 2, enonce: l[3], solution: l[4], contenu: 'Travail d entrainement et correction detaillee.' },
      { id: chapitreId + '_renforcement', type: 'renforcement', titre: 'Renforcement — ' + l[1], ordre: 3, contenu: 'Objectif : ' + l[3] + '\\n\\nMethode : lis le cours, identifie les donnees, choisis la propriete adaptee, calcule soigneusement puis verifie ton resultat.' },
      { id: chapitreId + '_quiz', type: 'quiz', titre: 'Quiz — ' + l[1], ordre: 4, questions: l[5].map((q,i)=>({id:'q'+(i+1),type:'qcm',enonce:q,choix:['Vrai','Faux'],bonnesReponses:[0],reponseAttendue:'',explication:'Cette affirmation correspond au cours du chapitre.',points:1})), dureeMinutes: 5 },
      { id: chapitreId + '_fiche_revision', type: 'fiche', titre: 'Fiche de revision — ' + l[1], ordre: 5, contenu: '# Fiche de revision\\n\\n' + l[2] + '\\n\\n### Methode\\n' + l[3] + '\\n\\n### Correction type\\n' + l[4] },
    ];
    for (const r of docs) {
      const ref = db.collection('ca_ressources').doc(r.id);
      if ((await ref.get()).exists) continue;
      await ref.set({type:r.type,titre:r.titre,ordre:r.ordre,chapitreId,niveau:'6e',matiereId:'math',ecoleId:'',contenu:r.contenu||'',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:r.enonce||'',solution:r.solution||'',difficulte:1,ressourceLieeId:'',questions:r.questions||[],dureeMinutes:r.dureeMinutes||0,examen:'',annee:0,serie:'',actif:true,auteur:'sentinel-math6e-2026',dateCreation:FieldValue.serverTimestamp(),dateMaj:FieldValue.serverTimestamp()});
      resourcesCreated++;
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    dateMaj: FieldValue.serverTimestamp(),
  }, { merge: true });

  console.log(JSON.stringify({
    ok: true,
    collection: 'ca_chapitres',
    chapitresCrees: created,
    chapitresDejaPresents: existing,
    ressourcesDemoCreees: resourcesCreated,
    message: 'Peuplement 6e Math termine.'
  }, null, 2));
}

main().catch((err) => {
  console.error('SEED_FIRESTORE_ERROR');
  console.error(err && err.stack ? err.stack : err);
  process.exit(1);
});

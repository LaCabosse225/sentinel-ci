const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();
const lessons = [["Nombres entiers naturels","Les nombres entiers naturels servent à compter. Chaque chiffre possède une valeur selon son rang : unités, dizaines, centaines, milliers. Pour comparer deux nombres, on compare d’abord leur nombre de chiffres puis les chiffres de gauche à droite.","4 582 = 4 000 + 500 + 80 + 2. Entre 7 405 et 7 450, les milliers et centaines sont identiques puis 0 < 5, donc 7 405 < 7 450.","Compare les nombres de gauche à droite, aligne les chiffres pour les opérations et vérifie le résultat par une estimation."],["Droites et points","Un point se désigne par une lettre majuscule. La droite est illimitée, la demi-droite possède une origine et le segment possède deux extrémités. Des points sont alignés lorsqu’ils appartiennent à une même droite.","La droite (AB) se prolonge des deux côtés. Le segment [AB] est limité par A et B. Si C appartient à (AB), A, B et C sont alignés.","Identifie d’abord si l’objet est illimité ou limité. Pour une construction, place précisément les points puis utilise règle, équerre ou compas selon la consigne."],["Nombres décimaux relatifs","Un nombre décimal relatif peut être positif, nul ou négatif. Sur une droite graduée, le plus grand nombre est le plus à droite. L’opposé change le signe et la distance à zéro est toujours positive ou nulle.","L’opposé de -6,3 est +6,3. Pour -7 + 12, les distances à zéro sont 7 et 12 : le résultat est 5.","Repère les signes, transforme si besoin une soustraction en addition de l’opposé, puis vérifie le signe du résultat."],["Segments","Le segment [AB] possède deux extrémités et sa longueur est notée AB. Le milieu partage un segment en deux longueurs égales. La médiatrice est perpendiculaire au segment en son milieu.","Si AB = 10 cm et M est le milieu, AM = MB = 5 cm. Tout point de la médiatrice de [AB] est à égale distance de A et B.","Pour construire un milieu, divise la longueur par deux. Pour la médiatrice, vérifie à la fois la perpendicularité et le passage par le milieu."],["Pavés droits et cylindres droits","Un pavé droit possède six faces rectangulaires. Son volume est V = L × l × h. Un cylindre possède deux bases circulaires et son volume est V = π × r² × h.","Un pavé de 8 cm × 4 cm × 3 cm a un volume de 96 cm³. Un cylindre de rayon 2 cm et de hauteur 5 cm a environ 62,8 cm³ avec π = 3,14.","Écris les dimensions, vérifie les unités, choisis la formule puis remplace les lettres par les valeurs avant de calculer."],["Fractions","Dans une fraction a/b, a est le numérateur et b le dénominateur. Une fraction peut représenter une partie d’une unité ou une proportion. Des fractions équivalentes ont la même valeur.","2/6 = 1/3. Pour 3/5 de 20, on peut calculer 20 ÷ 5 = 4 puis 4 × 3 = 12.","Pour additionner des fractions, cherche d’abord un dénominateur commun. Pour une fraction d’une quantité, commence par partager en parts correspondant au dénominateur."],["Cercles et disques","Le cercle est constitué des points situés à une même distance du centre. Le rayon r relie le centre au cercle et le diamètre vaut 2r. Le disque est la surface intérieure.","Pour r = 4 cm, le diamètre vaut 8 cm et l’aire du disque vaut 3,14 × 4² = 50,24 cm².","Distingue longueur du cercle et aire du disque. Utilise P = 2πr pour une longueur et A = πr² pour une aire."],["Angles","Un angle est formé par deux demi-droites de même origine. On le mesure avec un rapporteur. Les angles aigus mesurent moins de 90°, les angles droits 90° et les angles obtus entre 90° et 180°.","Le complémentaire de 28° vaut 90° - 28° = 62°. Un angle de 125° est obtus.","Place le centre du rapporteur sur le sommet et choisis la graduation qui commence à 0° sur le côté de départ."],["Triangles","Un triangle possède trois côtés et trois angles. La somme des mesures de ses angles est 180°. Il existe notamment des triangles équilatéraux, isocèles et rectangles.","Si A = 45° et B = 65°, alors C = 180° - 45° - 65° = 70°. Le triangle n’est donc pas équilatéral.","Écris la propriété 180°, additionne les angles connus puis soustrais cette somme à 180°. Vérifie que l’angle trouvé est cohérent."],["Proportionnalité","Deux grandeurs sont proportionnelles lorsqu’un même coefficient permet de passer de l’une à l’autre. Les tableaux de proportionnalité facilitent les calculs de prix, distances ou quantités.","Si 5 kg de riz coûtent 4 000 F, 1 kg coûte 800 F et 8 kg coûtent 6 400 F. Dix pour cent de 8 000 F valent 800 F.","Cherche le coefficient quand c’est possible. Sinon construis un tableau et vérifie que le même facteur est utilisé."],["Figures symétriques par rapport à un point","La symétrie centrale correspond à un demi-tour de 180°. Deux points A et A’ sont symétriques par rapport à O lorsque O est le milieu de [AA’].","Si OA = 3,5 cm, alors OA’ = 3,5 cm. La symétrie centrale conserve longueurs, angles et alignement.","Trace AO, prolonge la droite de l’autre côté de O et reporte exactement la distance OA."],["Statistique","Une série statistique rassemble des données. L’effectif compte les occurrences d’une valeur, la fréquence est l’effectif divisé par l’effectif total et la moyenne est la somme des valeurs divisée par leur nombre.","Pour 8, 10, 10, 12, 15, l’effectif total est 5, la moyenne est 11 et la fréquence de 10 est 2/5 = 40 %.","Compte d’abord les données, additionne-les pour la moyenne et utilise effectif/effectif total pour une fréquence."],["Parallélogramme","Un parallélogramme possède des côtés opposés parallèles et de même longueur. Ses diagonales se coupent en leur milieu. Le périmètre de côtés a et b est P = 2(a+b).","Avec AB = 8 cm et BC = 5 cm, CD = 8 cm, AD = 5 cm et P = 26 cm. Si les diagonales se coupent en O, alors O est le milieu de chacune.","Repère les propriétés données par la figure, choisis celle qui répond à la question et rédige la propriété avant le calcul."]];

async function main(){
  let resources=0;
  for(let i=0;i<lessons.length;i++){
    const [titre,notion,exemple,methode]=lessons[i];
    const chapitreId='6e_math_ch'+String(i+1).padStart(2,'0');
    const ch=db.collection('ca_chapitres').doc(chapitreId);
    const snap=await ch.get();
    if(!snap.exists){
      await ch.set({
        code:'2026-2027_dpfc_6e_math_ch'+String(i+1).padStart(2,'0'),
        niveau:'6e',matiereId:'math',anneeScolaire:'2026-2027',
        programmeVersion:'dpfc',serie:'',theme:'',titre,description:titre,
        ordre:i+1,actif:true,ressourceNationale:true,
        dateMaj:FieldValue.serverTimestamp()
      });
    }

    const cours=[
      '# '+titre,
      '',
      '## 1. Comprendre',
      notion,
      '',
      '## 2. Exemple guidé',
      exemple,
      '',
      '## 3. Méthode',
      methode,
      '',
      '1. Lis la consigne et relève les données utiles.',
      '2. Choisis la propriété, la formule ou la définition adaptée.',
      '3. Effectue les étapes proprement.',
      '4. Vérifie le résultat.',
      '',
      '## 4. Erreurs à éviter',
      'Ne mélange pas les unités, les signes ou les différentes notions. Une réponse mathématique doit montrer le raisonnement et pas seulement le résultat.',
      '',
      '## À retenir',
      'Tu dois pouvoir définir la notion, expliquer un exemple et refaire une application sans regarder la correction.'
    ].join('\n');

    const refs=[
      [chapitreId+'_cours_complet',{type:'cours',titre:'Cours complet — '+titre,ordre:1,contenu:cours,dureeMinutes:30}],
      [chapitreId+'_methode',{type:'renforcement',titre:'Méthode pas à pas — '+titre,ordre:2,contenu:'# Méthode — '+titre+'\n\n'+methode+'\n\n## Auto-évaluation\nJe connais la définition □\\nJe sais choisir la méthode □\\nJe sais vérifier mon résultat □'}],
      [chapitreId+'_fiche_revision',{type:'fiche',titre:'Fiche de révision — '+titre,ordre:5,contenu:'# Fiche de révision — '+titre+'\n\n## Notion\n'+notion+'\n\n## Exemple\n'+exemple+'\n\n## Réflexe\n'+methode}]
    ];

    for(const [id,d] of refs){
      const ref=db.collection('ca_ressources').doc(id);
      await ref.set({
        chapitreId,niveau:'6e',matiereId:'math',ecoleId:'',
        imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',
        difficulte:1,ressourceLieeId:'',questions:[],
        dureeMinutes:d.dureeMinutes||20,examen:'',annee:2026,serie:'',
        actif:true,ressourceNationale:true,auteur:'sentinel-pedagogie-math6e-2026',
        dateCreation:FieldValue.serverTimestamp(),dateMaj:FieldValue.serverTimestamp(),...d
      },{merge:true});
      resources++;
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    version:FieldValue.increment(1),dateMaj:FieldValue.serverTimestamp(),
    derniereRessourceNationale:'math_6e_approfondi'
  },{merge:true});

  console.log(JSON.stringify({ok:true,niveau:'6e',chapitres:lessons.length,ressourcesMisesAJour:resources},null,2));
}
main().catch(err=>{
  console.error('ENRICH_MATH6E_ERROR');
  console.error(err&&err.stack?err.stack:err);
  process.exit(1);
});

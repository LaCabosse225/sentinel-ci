const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const chapters = [
{n:1,t:'Nombres décimaux relatifs',c:`En 4e, on consolide le calcul avec les nombres décimaux relatifs et les puissances de 10. Un nombre relatif peut être positif, nul ou négatif. La distance à zéro est sa valeur absolue. Pour comparer deux nombres, on les place mentalement sur une droite graduée : le nombre situé le plus à droite est le plus grand.

Pour additionner deux nombres de même signe, on additionne leurs distances à zéro et on conserve le signe commun. Pour deux signes différents, on soustrait les distances à zéro et on garde le signe du nombre ayant la plus grande valeur absolue. Pour multiplier ou diviser, on applique la règle des signes : mêmes signes → résultat positif ; signes différents → résultat négatif.

Une puissance de 10 permet d'écrire simplement de très grands ou très petits nombres. 10^3 = 1000 et 10^-3 = 0,001. En notation scientifique, un nombre non nul s'écrit a × 10^n avec 1 ≤ a < 10. Cette écriture facilite les comparaisons et les ordres de grandeur.`,e:[
['Calcule : (-7,5) + 2,8.','-4,7.'],
['Calcule : (-3,2) × (-5).','16.'],
['Écris 0,00045 en notation scientifique.','4,5 × 10^-4.'],
['Calcule : 6,4 × 10^3.','6400.']],q:[
['Quel est le signe de (-4) × 7 ?',['positif','négatif','nul'],1],
['0,00072 en notation scientifique vaut :',['7,2 × 10^-4','72 × 10^-4','7,2 × 10^4'],0],
['10^-2 vaut :',['0,01','0,1','100'],0],
['|-8| vaut :',['-8','8','0'],1],
['(-5)+(-2) vaut :',['-7','7','-3'],0],
['(-6)×(-2) vaut :',['-12','12','8'],1],
['Le nombre 3,7 est :',['plus petit que 0','plus grand que 0','nul'],1],
['En notation scientifique, le coefficient est :',['compris entre 1 et 10','toujours entier','toujours négatif'],0]
]},
{n:2,t:'Nombres rationnels',c:`Un nombre rationnel peut s'écrire sous la forme a/b avec a et b entiers et b différent de zéro. Une fraction peut être simplifiée en divisant son numérateur et son dénominateur par un même diviseur commun. Le PGCD permet notamment de simplifier une fraction.

Pour additionner ou soustraire des fractions, on les réduit au même dénominateur. Pour multiplier, on multiplie les numérateurs entre eux et les dénominateurs entre eux, puis on simplifie. Diviser par une fraction revient à multiplier par son inverse. L'inverse de a/b est b/a lorsque a et b sont non nuls.

Il faut distinguer valeur exacte, approximation, troncature et arrondi. Une troncature coupe les chiffres au rang demandé ; un arrondi choisit la valeur la plus proche en observant le chiffre suivant.`,e:[
['Simplifie 18/24.','3/4.'],
['Calcule 2/3 + 1/6.','5/6.'],
['Calcule 5/8 × 4/15.','1/6.'],
['Calcule 3/4 ÷ 2/5.','15/8.']],q:[
['18/24 se simplifie en :',['3/4','9/12','2/3'],0],
['2/3 + 1/6 =',['1/2','5/6','3/9'],1],
['L’inverse de 3/5 est :',['-3/5','5/3','3/5'],1],
['Diviser par 2/3 revient à multiplier par :',['2/3','3/2','-3/2'],1],
['Le PGCD de 18 et 24 est :',['3','6','12'],1],
['Une fraction est nulle si :',['son numérateur est nul','son dénominateur est nul','les deux sont égaux à 1'],0],
['Pour additionner 1/3 et 1/4, un dénominateur commun possible est :',['7','12','4'],1],
['Un arrondi au dixième de 2,36 donne :',['2,3','2,4','2,36'],1]
]},
{n:3,t:'Équations et inéquations',c:`Une équation est une égalité contenant une inconnue. Résoudre une équation consiste à trouver toutes les valeurs de l'inconnue qui rendent l'égalité vraie. On conserve l'équivalence en ajoutant, retranchant, multipliant ou divisant les deux membres par un même nombre non nul.

Pour une équation du type ax+b=c, on isole progressivement x. Exemple : 3x+5=17 donne 3x=12 puis x=4. Pour une inéquation, on utilise les mêmes transformations, mais lorsqu'on multiplie ou divise par un nombre négatif, le sens de l'inégalité s'inverse.

Une solution peut être vérifiée en la remplaçant dans l'expression de départ. Pour une inéquation, on peut représenter l'ensemble des solutions sur une droite graduée.`,e:[
['Résous 3x + 5 = 17.','3x = 12 donc x = 4.'],
['Résous 2x - 1 < 7.','2x < 8 donc x < 4.'],
['Résous 5x = -20.','x = -4.'],
['Vérifie x = 4 dans 3x + 5 = 17.','3 × 4 + 5 = 17, donc la solution est vérifiée.']],q:[
['Dans 3x+5=17, on obtient d’abord :',['3x=22','3x=12','x=12'],1],
['La solution de 5x=-20 est :',['-4','4','-25'],0],
['Si on divise une inégalité par -2, il faut :',['garder le sens','inverser le sens','supprimer le signe'],1],
['2x<8 équivaut à :',['x<4','x>4','x=4'],0],
['Vérifier une solution signifie :',['remplacer x dans l’égalité de départ','changer l’équation','arrondir x'],0],
['Une équation peut avoir :',['une ou plusieurs solutions selon le cas','toujours deux solutions','toujours aucune solution'],0],
['x+7=10 donne :',['x=17','x=3','x=-3'],1],
['Pour isoler x dans 4x=12, on :',['multiplie par 4','divise par 4','ajoute 4'],1]
]},
{n:4,t:'Calcul littéral',c:`Le calcul littéral utilise des lettres pour représenter des nombres. Une expression littérale peut être réduite en regroupant les termes semblables. Par exemple 3x+5x=8x.

Développer utilise la distributivité : a(b+c)=ab+ac. Avec deux parenthèses, on peut utiliser la distributivité double. Factoriser est l'opération inverse du développement : on met en évidence un facteur commun. Exemple : 5x+10=5(x+2).

Les identités remarquables permettent de développer ou factoriser rapidement : (a+b)^2=a^2+2ab+b^2 ; (a-b)^2=a^2-2ab+b^2 ; (a-b)(a+b)=a^2-b^2. En 4e, on doit surtout savoir les reconnaître, les utiliser correctement et vérifier le résultat.`,e:[
['Réduis : 3x + 5x - 2.','8x - 2.'],
['Développe : 3(x + 2).','3x + 6.'],
['Factorise : 5x + 10.','5(x + 2).'],
['Développe : (x + 3)^2.','x^2 + 6x + 9.']],q:[
['3x+5x vaut :',['8x','15x','8'],0],
['Développer 2(x+4) donne :',['2x+4','2x+8','x+8'],1],
['5x+15 se factorise en :',['5(x+3)','15(x+1)','x(5+15)'],0],
['(x+2)^2 vaut :',['x^2+4','x^2+4x+4','x^2+2x+4'],1],
['Factoriser est l’opération inverse de :',['développer','additionner','diviser'],0],
['Dans 7x, le coefficient de x est :',['x','7','0'],1],
['2a+3a-1 se réduit en :',['5a-1','6a','5a+1'],0],
['(a-b)(a+b) donne :',['a^2-b^2','a^2+b^2','2a-2b'],0]
]},
{n:5,t:'Statistique',c:`En statistique, on étudie une population et un caractère observé. L'effectif est le nombre d'individus correspondant à une valeur ou une catégorie. L'effectif total est la somme des effectifs.

La moyenne d'une série est obtenue en additionnant les valeurs puis en divisant par leur nombre, ou par la somme des produits valeur × effectif divisée par l'effectif total. Le mode est la valeur qui possède l'effectif le plus élevé lorsqu'il existe.

Les données peuvent être présentées dans un tableau, un diagramme en bâtons, un histogramme ou un diagramme circulaire/semi-circulaire selon la situation. Pour un diagramme circulaire, l'angle correspondant à une catégorie est proportionnel à son effectif.`,e:[
['Pour 8, 10, 10, 12, 15, calcule la moyenne.','La somme est 55 et il y a 5 valeurs : moyenne = 11.'],
['Dans la série 8,10,10,12,15, quel est le mode ?','10.'],
['Une classe compte 30 élèves dont 12 filles. Quel est l’effectif des garçons ?','18 garçons.'],
['Quelle mesure décrit la valeur la plus fréquente ?','Le mode.']],q:[
['La moyenne de 2,4,6 est :',['4','6','12'],0],
['Dans 4,4,5,7, le mode est :',['4','5','7'],0],
['L’effectif total est :',['la somme des effectifs','la moyenne','la plus grande valeur'],0],
['Pour 10 élèves sur 20, la fréquence est :',['10 %','50 %','20 %'],1],
['Un diagramme circulaire représente une catégorie de 25 % par un angle de :',['25°','90°','180°'],1],
['Le mode est :',['la valeur la plus fréquente','la valeur la plus grande','la moyenne'],0],
['La moyenne dépend :',['de toutes les valeurs et de leurs effectifs','seulement du maximum','seulement du mode'],0],
['Dans une série, un effectif peut être :',['un nombre d’individus','un angle uniquement','un nombre toujours décimal'],0]
]},
{n:6,t:'Angles',c:`Un angle est déterminé par deux demi-droites de même origine. On utilise le degré comme unité. Deux angles peuvent être adjacents, opposés par le sommet ou complémentaires/supplémentaires selon leur somme.

Lorsque deux droites parallèles sont coupées par une sécante, les angles correspondants ont la même mesure et les angles alternes-internes ont également la même mesure. Ces propriétés permettent de calculer des angles inconnus et de démontrer que deux droites sont parallèles dans certaines configurations.

Dans un cercle, l'angle au centre intercepte un arc. Les cordes sont des segments dont les extrémités appartiennent au cercle. Une démonstration doit toujours citer la propriété utilisée et les données qui permettent son application.`,e:[
['Deux droites parallèles sont coupées par une sécante. Un angle correspondant mesure 65°. Que vaut l’autre ?','65°, car les angles correspondants sont égaux.'],
['Deux angles sont supplémentaires et l’un mesure 112°. Calculer l’autre.','68°, car 180° − 112° = 68°.'],
['Deux angles sont complémentaires et l’un mesure 35°. Calculer l’autre.','55°, car 90° − 35° = 55°.'],
['Pourquoi rédiger la propriété dans une démonstration ?','Pour justifier logiquement le calcul ou la conclusion.']],q:[
['Des angles correspondants formés par deux parallèles sont :',['égaux','toujours supplémentaires','toujours nuls'],0],
['Deux angles complémentaires ont une somme de :',['90°','180°','360°'],0],
['Deux angles supplémentaires ont une somme de :',['45°','90°','180°'],2],
['Un angle de 65° a pour angle supplémentaire :',['115°','25°','65°'],0],
['Les angles alternes-internes de deux parallèles sont :',['égaux','toujours droits','opposés'],0],
['Un angle nul mesure :',['0°','90°','180°'],0],
['Un angle plat mesure :',['90°','180°','360°'],1],
['Dans une démonstration, une propriété sert à :',['justifier une étape','décorer la réponse','remplacer les données'],0]
]},
{n:7,t:'Distances',c:`La distance d'un point A à une droite d est la longueur du segment perpendiculaire à d passant par A et dont l'extrémité sur d est le pied de la perpendiculaire. C'est la plus courte distance entre le point et la droite.

La distance entre deux droites parallèles est la longueur d'un segment perpendiculaire commun aux deux droites. Tous les segments perpendiculaires compris entre deux parallèles ont la même longueur.

La bissectrice d'un angle est la demi-droite qui partage l'angle en deux angles de même mesure. Un point situé sur la bissectrice est à égale distance des deux côtés de l'angle. Ces propriétés sont utiles dans les constructions et les démonstrations géométriques.`,e:[
['Que représente la distance d’un point A à une droite d ?','La longueur du segment perpendiculaire à d reliant A à son pied sur d.'],
['Deux parallèles sont distantes de 4 cm. Quelle est la longueur de tout segment perpendiculaire commun ?','4 cm.'],
['Un angle mesure 70°. Chaque angle obtenu par sa bissectrice mesure :','35°.'],
['Quelle construction permet de trouver le pied de la distance d’un point à une droite ?','Tracer la perpendiculaire à la droite passant par le point.']],q:[
['La distance d’un point à une droite est mesurée suivant :',['une perpendiculaire','une parallèle','une quelconque'],0],
['La distance entre deux parallèles est :',['constante','toujours variable','nulle'],0],
['La bissectrice partage un angle :',['en deux angles égaux','en trois angles','en deux angles opposés'],0],
['La moitié de 70° est :',['30°','35°','40°'],1],
['Le pied de la perpendiculaire appartient :',['à la droite','au cercle seulement','à aucune droite'],0],
['Une perpendiculaire forme un angle de :',['45°','90°','180°'],1],
['Si un point est sur la bissectrice, ses distances aux côtés sont :',['égales','opposées','toujours nulles'],0],
['Pour construire une distance à une droite, on utilise notamment :',['une équerre','une règle seule','un rapporteur seul'],0]
]},
{n:8,t:'Cercles et triangles',c:`Dans un triangle, plusieurs droites particulières sont importantes. Une médiane relie un sommet au milieu du côté opposé. Une hauteur est perpendiculaire au côté opposé ou à son prolongement. Une bissectrice partage un angle en deux angles égaux. Une médiatrice est perpendiculaire à un segment en son milieu.

Les points remarquables résultent des intersections de ces droites : le centre de gravité est l'intersection des médianes ; l'orthocentre est l'intersection des hauteurs ; le centre du cercle circonscrit est l'intersection des médiatrices ; le centre du cercle inscrit est l'intersection des bissectrices.

La tangente à un cercle en un point est perpendiculaire au rayon qui aboutit à ce point. Cette propriété permet de démontrer des perpendicularités et de construire une tangente.`,e:[
['Cite trois droites particulières d’un triangle.','Médiane, hauteur et bissectrice, par exemple.'],
['Quel est le point d’intersection des médianes ?','Le centre de gravité.'],
['Quel est le point d’intersection des hauteurs ?','L’orthocentre.'],
['Quelle relation existe entre rayon et tangente au point de contact ?','Le rayon est perpendiculaire à la tangente.']],q:[
['Une médiane relie un sommet :',['au milieu du côté opposé','à un angle droit','au centre du cercle'],0],
['L’orthocentre est l’intersection :',['des hauteurs','des médianes','des médiatrices'],0],
['Le centre de gravité est l’intersection :',['des médianes','des hauteurs','des bissectrices'],0],
['La tangente au cercle est perpendiculaire :',['au rayon au point de contact','à tout diamètre','à toute corde'],0],
['Une hauteur est :',['perpendiculaire au côté opposé ou à son prolongement','toujours parallèle au côté','une droite quelconque'],0],
['Une médiatrice passe par :',['le milieu du segment et lui est perpendiculaire','un sommet','le centre de gravité uniquement'],0],
['Le centre du cercle inscrit est lié aux :',['bissectrices','hauteurs','médianes'],0],
['Une tangente touche le cercle en :',['un point','deux points','aucun point'],0]
]},
{n:9,t:'Vecteurs',c:`Un vecteur est caractérisé par une direction, un sens et une longueur appelée norme. Le vecteur AB représente le déplacement de A vers B. Deux vecteurs sont égaux lorsqu'ils ont même direction, même sens et même longueur. Deux vecteurs opposés ont même direction et même longueur mais des sens contraires.

La relation de Chasles permet d'écrire vecteur AC = vecteur AB + vecteur BC. Elle est fondamentale pour calculer et démontrer des égalités vectorielles. Un vecteur peut être représenté par une flèche et on peut utiliser un repère pour lire ses coordonnées.

Dans un repère, les coordonnées du vecteur AB se calculent en faisant les coordonnées de B moins celles de A : AB = (xB − xA ; yB − yA).`,e:[
['Si A(2;1) et B(5;4), donne les coordonnées de AB.','AB = (3;3).'],
['Écris la relation de Chasles pour A, B et C.','AC = AB + BC.'],
['Quel est l’opposé du vecteur AB ?','Le vecteur BA.'],
['Si u=(2;-1) et v=(3;4), calcule u+v.','(5;3).']],q:[
['Un vecteur possède notamment :',['direction, sens et longueur','seulement une longueur','seulement un sens'],0],
['Le vecteur opposé à AB est :',['BA','AB','AA'],0],
['La relation de Chasles donne :',['AC=AB+BC','AB=AC+BC','BC=AB+AC'],0],
['A(1;2), B(4;6) donne AB :',['(3;4)','(5;8)','(-3;-4)'],0],
['Deux vecteurs égaux ont :',['même direction, même sens et même longueur','seulement même longueur','seulement même sens'],0],
['(2;3)+(1;4) vaut :',['(3;7)','(2;12)','(1;1)'],0],
['Le vecteur nul a pour norme :',['0','1','-1'],0],
['Pour AB en coordonnées, on calcule :',['B-A','A-B toujours','A+B'],0]
]},
{n:10,t:'Perspective cavalière',c:`La perspective cavalière est une convention de représentation plane des solides. Elle permet de représenter un objet en trois dimensions sur une feuille. Les arêtes parallèles dans l'espace restent représentées par des segments parallèles.

Les faces frontales peuvent être représentées sans déformation selon la convention choisie. Les arêtes en profondeur sont généralement obliques et peuvent être réduites par un coefficient de perspective. Les arêtes cachées sont souvent représentées en pointillés.

En 4e, on utilise notamment cette représentation pour le pavé droit, le prisme droit et le cylindre. Il faut conserver les parallélismes, respecter les dimensions données et distinguer les arêtes visibles des arêtes cachées.`,e:[
['Cite un solide représentable en perspective cavalière.','Un pavé droit, un prisme droit ou un cylindre droit.'],
['Que deviennent les arêtes parallèles ?','Elles restent représentées par des segments parallèles.'],
['À quoi servent les pointillés ?','À représenter conventionnellement des arêtes cachées.'],
['Pourquoi réduire parfois les longueurs en profondeur ?','Pour respecter la convention de perspective et rendre le dessin lisible.']],q:[
['La perspective cavalière sert à représenter :',['des solides','des nombres','des angles seulement'],0],
['Des arêtes parallèles dans l’espace sont dessinées :',['parallèles','perpendiculaires','toujours confondues'],0],
['Les arêtes cachées peuvent être représentées :',['en pointillés','en rouge obligatoirement','sans aucune ligne'],0],
['Un pavé droit est :',['un solide','une droite','un angle'],0],
['La perspective cavalière donne une représentation :',['plane d’un objet en 3D','uniquement en 1D','sans aucune convention'],0],
['Les longueurs en profondeur peuvent être :',['réduites selon la convention','toujours doublées','toujours nulles'],0],
['Un prisme droit peut être représenté :',['en perspective cavalière','seulement en photo','jamais'],0],
['Une bonne figure doit respecter notamment :',['les parallélismes','des couleurs imposées','des angles tous droits'],0]
]},
{n:11,t:'Symétries et translations',c:`Une transformation géométrique associe à chaque point une image. La symétrie centrale de centre O correspond à un demi-tour de 180° : O est le milieu du segment reliant un point à son image. Elle conserve les longueurs, les angles, l'alignement et le parallélisme.

La symétrie orthogonale par rapport à une droite d utilise cette droite comme axe : elle est la médiatrice du segment reliant un point à son image. La translation est un déplacement défini par un vecteur. Tous les points sont déplacés de la même manière : même direction, même sens et même longueur.

Ces transformations conservent les formes et les longueurs. Pour construire une image, on utilise les propriétés de la transformation et les instruments de géométrie adaptés.`,e:[
['Quelle transformation correspond à un demi-tour de 180° autour d’un point O ?','La symétrie centrale de centre O.'],
['Dans une symétrie centrale, quel rôle joue O ?','O est le milieu du segment reliant un point à son image.'],
['Qu’est-ce qui définit une translation ?','Un vecteur indiquant direction, sens et longueur du déplacement.'],
['Quel est l’axe d’une symétrie orthogonale ?','La droite qui est la médiatrice de chaque segment reliant un point à son image.']],q:[
['Un demi-tour correspond à :',['une symétrie centrale','une translation uniquement','une rotation de 90°'],0],
['Dans une symétrie centrale de centre O, O est :',['le milieu de MM’','un sommet obligatoire','le point le plus éloigné'],0],
['Une translation est définie par :',['un vecteur','un angle seul','un rayon seul'],0],
['Une symétrie orthogonale utilise :',['un axe','un centre uniquement','un diamètre'],0],
['Les transformations étudiées conservent notamment :',['les longueurs','les noms des points','la couleur du dessin'],0],
['Une translation déplace tous les points :',['de la même manière','au hasard','vers O'],0],
['Si M est sur l’axe d’une symétrie orthogonale, son image est :',['M lui-même','un autre point quelconque','le centre O'],0],
['Une symétrie centrale conserve :',['les angles et les longueurs','seulement les couleurs','aucune propriété'],0]
]}
];

function makeQuiz(ch){
 return ch.q.map((x,i)=>({id:'q'+(i+1),type:'qcm',enonce:x[0],choix:x[1],bonnesReponses:[x[2]],reponseAttendue:'',explication:'La bonne réponse est : '+x[1][x[2]]+'.',points:1}));
}

function resources(ch, id){
 const ex=ch.e.map((x,i)=>'### Exercice '+(i+1)+'\n'+x[0]+'\n\n**Correction :** '+x[1]).join('\n\n');
 const en=ch.e.map((x,i)=>(i+1)+'. '+x[0]).join('\n');
 const sol=ch.e.map((x,i)=>(i+1)+'. '+x[1]).join('\n');
 return [
  {id:id+'_cours_complet',type:'cours',titre:'Cours complet — '+ch.t,ordre:1,contenu:'# '+ch.t+'\n\n## Cours\n'+ch.c+'\n\n## Méthode de travail\n1. Lire attentivement la consigne.\n2. Relever les données et les inconnues.\n3. Identifier la propriété ou la technique adaptée.\n4. Effectuer les calculs en écrivant les étapes.\n5. Vérifier la cohérence du résultat et rédiger une conclusion.'},
  {id:id+'_exercices_corriges',type:'exercice',titre:'Exercices corrigés — '+ch.t,ordre:2,contenu:ex,enonce:en,solution:sol,difficulte:2},
  {id:id+'_renforcement',type:'renforcement',titre:'Renforcement — '+ch.t,ordre:3,contenu:'## Entraînement progressif\n\n1. Récite les définitions essentielles du chapitre.\n2. Reproduis un exemple du cours sans regarder la correction.\n3. Crée un exercice du même type avec d’autres nombres.\n4. Résous-le puis vérifie chaque étape.\n5. Explique à l’écrit la propriété utilisée.\n\n## Auto-évaluation\n□ Je connais les définitions\n□ Je sais choisir la méthode\n□ Je sais calculer ou construire\n□ Je sais justifier\n□ Je sais vérifier mon résultat'},
  {id:id+'_quiz',type:'quiz',titre:'Quiz — '+ch.t,ordre:4,questions:makeQuiz(ch),dureeMinutes:12},
  {id:id+'_fiche_revision',type:'revision',titre:'Fiche de révision — '+ch.t,ordre:5,contenu:'# Fiche de révision — '+ch.t+'\n\n## Essentiel\n'+ch.c+'\n\n## Réflexes\n• Identifier la notion.\n• Écrire les données.\n• Choisir la propriété adaptée.\n• Détailler les étapes.\n• Vérifier le résultat.\n• Utiliser les unités et les notations correctes.'}
 ];
}

async function main(){
 let updated=0;
 for(const ch of chapters){
  const chapitreId='4e_math_ch'+String(ch.n).padStart(2,'0');
  const cr=db.collection('ca_chapitres').doc(chapitreId);
  const old=await cr.get();
  const chapterData={code:'2026-2027_dpfc_4e_math_ch'+String(ch.n).padStart(2,'0'),niveau:'4e',matiereId:'math',anneeScolaire:'2026-2027',programmeVersion:'DPFC 2026-2027',serie:'',theme:'',titre:ch.t,description:'Cours de mathématiques 4e adapté au niveau collège et structuré pour Sentinelle CI.',ordre:ch.n,actif:true,ressourceNationale:true,auteur:'Sentinelle CI — génération pédagogique 2026-2027',dateMaj:FieldValue.serverTimestamp()};
  if(!old.exists) chapterData.dateCreation=FieldValue.serverTimestamp();
  await cr.set(chapterData,{merge:true});
  for(const r of resources(ch,chapitreId)){
   const ref=db.collection('ca_ressources').doc(r.id);
   const prev=await ref.get();
   await ref.set({type:r.type,titre:r.titre,ordre:r.ordre,chapitreId,niveau:'4e',matiereId:'math',ecoleId:'',contenu:r.contenu||'',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:r.enonce||'',solution:r.solution||'',difficulte:r.difficulte||1,ressourceLieeId:'',questions:r.questions||[],dureeMinutes:r.dureeMinutes||20,examen:false,annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'Sentinelle CI — Maths 4e 2026-2027',dateCreation:prev.exists?(prev.data().dateCreation||FieldValue.serverTimestamp()):FieldValue.serverTimestamp(),dateMaj:FieldValue.serverTimestamp()},{merge:true});
   updated++;
  }
 }
 await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),anneeScolaire:'2026-2027',dateMaj:FieldValue.serverTimestamp(),derniereRessourceNationale:'4e_math_complet_2026_2027'},{merge:true});
 console.log(JSON.stringify({ok:true,niveau:'4e',matiere:'math',chapitres:chapters.length,ressourcesMisesAJour:updated},null,2));
}
main().catch(e=>{console.error(e);process.exit(1);});

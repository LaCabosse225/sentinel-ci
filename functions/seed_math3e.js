const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({credential:applicationDefault(),projectId:'sentinel-ci-c7592'}); const db=getFirestore();

const lessons=[
['Calcul littéral','Développer, réduire et factoriser.',['3(x+5)','3x+15'],['7x-3+2x+8','9x+5'],['6x+18','6(x+3)']],
['Équations du premier degré','Résoudre ax+b=c et vérifier une solution.',['3x+5=20','x=5'],['7x-4=24','x=4'],['2x+3=15','x=6']],
['Nombres rationnels','Additionner, multiplier et diviser des fractions.',['3/4+1/8','7/8'],['5/6×3/10','1/4'],['2/3÷4/5','5/6']],
['Puissances et écriture scientifique','Utiliser les puissances de 10 et la notation scientifique.',['450000','4,5×10^5'],['0,00072','7,2×10^-4'],['10^3×10^4','10^7']],
['Racines carrées','Comprendre et calculer des racines carrées simples.',['√49','7'],['12²','144'],['Comparer √20 et √25','√20<5']],
['Théorème de Thalès','Utiliser Thalès et sa réciproque.',['AM/AB=2/5, AB=15','AM=6 cm'],['AM=4, AB=10, AC=15','AN=6 cm'],['Rôle de la réciproque','Démontrer le parallélisme']],
['Théorème de Pythagore','Calculer une longueur dans un triangle rectangle.',['6 et 8','Hypoténuse=10'],['13 et 5','Autre côté=12'],['Rôle de la réciproque','Démontrer qu’un triangle est rectangle']],
['Trigonométrie','Utiliser sinus, cosinus et tangente.',['cos(A)=0,8 et hyp=10','adjacent=8'],['opposé=6, adjacent=8','tan(A)=0,75'],['opposé/hypoténuse','sinus']],
['Statistique','Calculer moyenne, médiane et étendue.',['8,10,12,14','moyenne=11'],['3,5,7,9,12','médiane=7'],['4,7,10,15','étendue=11']],
['Fonctions','Calculer images et reconnaître une fonction affine.',['f(x)=2x+3, f(4)','11'],['g(x)=-x+5, g(2)','3'],['f(x)=3x-1','a=3, b=-1']],
['Géométrie dans l’espace','Calculer volumes de pavés et prismes.',['4×5×8','160 cm³'],['base=12 cm², h=7 cm','84 cm³'],['2,5 L','2,5 dm³']],
['Transformations et repérage','Utiliser translations, symétries, rotations et coordonnées.',['A(2;3), +4 en x','A’(6;3)'],['Effet d’une translation','Longueurs conservées'],['Symétrie axiale','Distances conservées']]
];

function questions(l){return [
{id:'q1',type:'qcm',enonce:'Quelle notion est étudiée ?',choix:[l[0],'Une notion sans rapport','Aucune notion'],bonnesReponses:[0],points:1},
{id:'q2',type:'qcm',enonce:'Quel résultat est correct ?',choix:[l[4][1], 'Aucun résultat','Impossible'],bonnesReponses:[0],points:1},
{id:'q3',type:'qcm',enonce:'Quelle démarche convient ?',choix:['Identifier les données puis choisir la propriété','Deviner','Ignorer les données'],bonnesReponses:[0],points:1},
{id:'q4',type:'qcm',enonce:'Après le calcul ?',choix:['Vérifier le résultat','Ne pas relire','Modifier les données'],bonnesReponses:[0],points:1}
];}

async function main(){
let cc=0,ce=0,rc=0;
for(const [n,l,d,e1,e2,e3] of lessons){
const id='3e_math_ch'+String(lessons.indexOf(lessons.find(x=>x[0]===n))+1).padStart(2,'0'), cr=db.collection('ca_chapitres').doc(id), s=await cr.get();
if(!s.exists){await cr.set({code:'2026-2027_dpfc_3e_math_'+id,niveau:'3e',matiereId:'math',anneeScolaire:'2026-2027',programmeVersion:'dpfc',serie:'',theme:n.match(/Thalès|Pythagore|Trigonométrie|Géométrie|Transformations/)?'Géométrie':n.match(/Statistique|Fonctions/)?'Données et fonctions':'Calcul et nombres',titre:n,description:d,ordre:lessons.findIndex(x=>x[0]===n)+1,actif:true,ressourceNationale:true,sourceOfficielle:'DPFC — Programme éducatif et guide d’exécution Mathématiques 3e',dateMaj:FieldValue.serverTimestamp()});cc++;}else ce++;
const ex=[e1,e2,e3], base=id+'_';
const docs=[
{ id:base+'cours_complet',type:'cours',titre:'Cours complet — '+n,ordre:1,contenu:'# '+n+'\n\n## Cours\n'+d+'\n\n## Méthode\nIdentifier les données, choisir la propriété, calculer, vérifier.'},
{ id:base+'exercices_corriges',type:'exercice',titre:'Exercices corrigés — '+n,ordre:2,contenu:ex.map((x,i)=>'### Exercice '+(i+1)+'\n'+x[0]+'\n\n**Correction :** '+x[1]).join('\n\n'),enonce:ex.map((x,i)=>(i+1)+'. '+x[0]).join('\n'),solution:ex.map((x,i)=>(i+1)+'. '+x[1]).join('\n')},
{ id:base+'renforcement',type:'renforcement',titre:'Renforcement — '+n,ordre:3,contenu:'Refais les trois exercices sans regarder les corrections.\n\n'+ex.map((x,i)=>(i+1)+'. '+x[0]).join('\n')+'\n\nAuto-évaluation : définitions □ méthode □ calcul □ vérification □'},
{ id:base+'quiz',type:'quiz',titre:'Quiz — '+n,ordre:4,questions:questions([n,d,e1,e2,e3]),dureeMinutes:8},
{ id:base+'fiche_revision',type:'fiche',titre:'Fiche de révision — '+n,ordre:5,contenu:'# Fiche de révision — '+n+'\n\n'+d+'\n\nRéflexes : données → propriété → calcul → vérification.'}
];
for(const r of docs){const ref=db.collection('ca_ressources').doc(r.id);if((await ref.get()).exists)continue;await ref.set({type:r.type,titre:r.titre,ordre:r.ordre,chapitreId:id,niveau:'3e',matiereId:'math',ecoleId:'',contenu:r.contenu||'',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:r.enonce||'',solution:r.solution||'',difficulte:1,ressourceLieeId:'',questions:r.questions||[],dureeMinutes:r.dureeMinutes||0,examen:'',annee:0,serie:'',actif:true,ressourceNationale:true,auteur:'sentinel-math3e-2026',dateCreation:FieldValue.serverTimestamp(),dateMaj:FieldValue.serverTimestamp()});rc++;}
}
await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),dateMaj:FieldValue.serverTimestamp(),derniereRessourceNationale:'3e_math_2026_2027'},{merge:true});
console.log(JSON.stringify({ok:true,niveau:'3e',lecons:lessons.length,chapitresCrees:cc,chapitresDejaPresents:ce,ressourcesCreees:rc},null,2));
}
main().catch(e=>{console.error(e);process.exit(1);});

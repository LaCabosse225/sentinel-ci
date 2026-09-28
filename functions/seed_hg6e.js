const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();
const niveau='6e', matiereId='hg', anneeScolaire='2026-2027';
const titres=["Les premières sociétés humaines","La Préhistoire en Afrique","L’Égypte ancienne","Les civilisations de l’Afrique ancienne","La Grèce antique","Rome antique","Les grands repères géographiques","Les milieux naturels de Côte d’Ivoire","Population et peuplement","Les activités économiques","L’agriculture et les ressources","Organisation de l’espace ivoirien"];
const types=[['cours','Cours'],['exercices','Exercices d’application'],['renforcement','Renforcement'],['quiz','Quiz'],['revision','Fiche de révision']];
(async()=>{
for(let i=0;i<titres.length;i++){
 const theme=titres[i], code='HG-'+niveau+'-'+String(i+1).padStart(2,'0');
 const q=await db.collection('ca_chapitres').where('code','==',code).limit(1).get(); let chapitreId;
 if(q.empty){const ref=db.collection('ca_chapitres').doc(); chapitreId=ref.id; await ref.set({code,niveau,matiereId,anneeScolaire,programmeVersion:'DPFC 2026-2027',serie:'',theme,titre:theme,description:'Base pédagogique Sentinel CI alignée sur le programme DPFC d’Histoire-Géographie '+niveau+'.',ordre:i+1,actif:true,ressourceNationale:true,sourceOfficielle:'DPFC — Programme éducatif et guide d’exécution Histoire-Géographie',dateMaj:FieldValue.serverTimestamp()});}else chapitreId=q.docs[0].id;
 for(let j=0;j<types.length;j++){const type=types[j][0],label=types[j][1]; const rq=await db.collection('ca_ressources').where('chapitreId','==',chapitreId).where('type','==',type).limit(1).get(); if(!rq.empty)continue;
 await db.collection('ca_ressources').add({type,titre:label+' — '+theme,ordre:j+1,chapitreId,niveau,matiereId,ecoleId:'',contenu:'Ressource Sentinel CI : '+label.toLowerCase()+' sur « '+theme+' ». Repères, notions essentielles, vocabulaire, exemples et méthode adaptés au niveau '+niveau+'.',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:type==='quiz'?'moyenne':'progressive',ressourceLieeId:'',questions:type==='quiz'?[{question:'Quel est le point essentiel à retenir sur « '+theme+' » ?',reponse:'Identifier les principaux repères, notions et relations étudiés dans ce chapitre.'}]:[],dureeMinutes:type==='cours'?30:20,examen:false,annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'Sentinel CI',dateCreation:FieldValue.serverTimestamp(),dateMaj:FieldValue.serverTimestamp()});}
}
await db.collection('ca_parametres').doc('version').set({anneeScolaire,derniereMaj:FieldValue.serverTimestamp()},{merge:true}); console.log('HG '+niveau+' seeded'); process.exit(0);
})().catch(e=>{console.error(e);process.exit(1);});
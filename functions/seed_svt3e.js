const admin = require('firebase-admin');
admin.initializeApp({credential: admin.credential.cert(require('./serviceAccountKey.json'))});
const db = admin.firestore();
const niveau = '3e'; const matiereId='svt'; const anneeScolaire='2026-2027';
const titres = ["Organisation et fonctionnement de l’organisme","Communication nerveuse","Réflexes et activité nerveuse","Mouvements et fonctionnement musculaire","Reproduction humaine et maîtrise de la reproduction","Transmission des caractères héréditaires","Génétique et variation","Évolution et diversité du vivant","Équilibres naturels et chaînes alimentaires","Ressources naturelles et développement durable","Pollutions et impacts sur la santé","Protection de l’environnement et biodiversité"];
const types=[['cours','Cours'],['exercices','Exercices d’application'],['renforcement','Renforcement'],['quiz','Quiz'],['revision','Fiche de révision']];
(async()=>{
for(let i=0;i<titres.length;i++){
 const theme=titres[i]; const code='SVT-'+niveau+'-'+String(i+1).padStart(2,'0');
 const q=await db.collection('ca_chapitres').where('code','==',code).limit(1).get();
 let chapitreId;
 if(q.empty){const ref=db.collection('ca_chapitres').doc(); chapitreId=ref.id; await ref.set({code,niveau,matiereId,anneeScolaire,programmeVersion:'DPFC 2026-2027',serie:'',theme,titre:theme,description:'Base pédagogique Sentinel CI alignée sur le programme DPFC de SVT '+niveau+'.',ordre:i+1,actif:true,ressourceNationale:true,sourceOfficielle:'DPFC — Programme éducatif et guide d’exécution SVT',dateMaj:admin.firestore.FieldValue.serverTimestamp()});} else chapitreId=q.docs[0].id;
 for(let j=0;j<types.length;j++){const type=types[j][0], label=types[j][1]; const rq=await db.collection('ca_ressources').where('chapitreId','==',chapitreId).where('type','==',type).limit(1).get(); if(!rq.empty) continue;
 await db.collection('ca_ressources').add({type,titre:label+' — '+theme,ordre:j+1,chapitreId,niveau,matiereId,ecoleId:'',contenu:'Ressource Sentinel CI : '+label.toLowerCase()+' sur « '+theme+' ». Notions essentielles, vocabulaire scientifique, exemples et méthode adaptés au niveau '+niveau+'.',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:type==='quiz'?'moyenne':'progressive',ressourceLieeId:'',questions:type==='quiz'?[{question:'Quelle notion essentielle faut-il retenir sur « '+theme+' » ?',reponse:'Identifier et expliquer la notion centrale du chapitre.'}]:[],dureeMinutes:type==='cours'?30:20,examen:false,annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'Sentinel CI',dateCreation:admin.firestore.FieldValue.serverTimestamp(),dateMaj:admin.firestore.FieldValue.serverTimestamp()});}
}
await db.collection('ca_parametres').doc('version').set({anneeScolaire,derniereMaj:admin.firestore.FieldValue.serverTimestamp()},{merge:true}); console.log('SVT '+niveau+' seeded'); process.exit(0);
})().catch(e=>{console.error(e);process.exit(1);});
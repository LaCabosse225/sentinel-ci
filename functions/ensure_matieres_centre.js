const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db=getFirestore();
const matieres=[
 ['math','Mathematiques','1565C0',1],
 ['pc','Physique-Chimie','6A1B9A',2],
 ['svt','SVT','1B9D21',3],
 ['franc','Francais','D32F2F',4],
 ['angl','Anglais','F57C00',5],
 ['hg','Histoire-Geographie','F9A825',6],
 ['philo','Philosophie','455A64',7,['2nde','1ere','Tle']],
 ['eps','EPS','00897B',8],
 ['info','Informatique','5E35B1',9],
 ['ecm','Education civique et morale','795548',10],
];
(async()=>{
 let created=0;
 for(const m of matieres){
   const [id,nom,couleurHex,ordre,niveaux=[]]=m;
   const ref=db.collection('ca_matieres').doc(id);
   const snap=await ref.get();
   if(snap.exists) continue;
   await ref.set({nom,couleurHex,ordre,niveaux,actif:true});
   created++;
 }
 await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),dateMaj:FieldValue.serverTimestamp()},{merge:true});
 console.log({created});
 process.exit(0);
})().catch(e=>{console.error(e);process.exit(1);});
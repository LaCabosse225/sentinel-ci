const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db=getFirestore();
(async()=>{
 const maps=[{prefix:'ANG-',matiereId:'angl'},{prefix:'HG-',matiereId:'hg'}];
 const ch=await db.collection('ca_chapitres').get(); let chapters=0,resources=0;
 for(const m of maps){for(const d of ch.docs){const data=d.data();if(typeof data.code!=='string'||!data.code.startsWith(m.prefix))continue;
   if(data.matiereId!==m.matiereId){await d.ref.update({matiereId:m.matiereId});chapters++;}
   const rs=await db.collection('ca_ressources').where('chapitreId','==',d.id).get();
   for(const r of rs.docs)if(r.data().matiereId!==m.matiereId){await r.ref.update({matiereId:m.matiereId});resources++;}
 }}
 await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),dateMaj:FieldValue.serverTimestamp()},{merge:true});
 console.log({chapters,resources});process.exit(0);
})().catch(e=>{console.error(e);process.exit(1);});
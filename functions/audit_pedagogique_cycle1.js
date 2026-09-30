const {initializeApp,applicationDefault}=require('firebase-admin/app');
const {getFirestore}=require('firebase-admin/firestore');
initializeApp({credential:applicationDefault(),projectId:'sentinel-ci-c7592'});
const db=getFirestore();

const MATIERES_PAR_NIVEAU={
 '6e':['math','franc','pc','svt','hg','angl','eps','info','ecm','arts','musique'],
 '5e':['math','franc','pc','svt','hg','angl','eps','info','ecm','arts','musique'],
 '4e':['math','franc','pc','svt','hg','angl','eps','info','ecm','arts','musique','allemand','espagnol'],
 '3e':['math','franc','pc','svt','hg','angl','eps','info','ecm','arts','musique','allemand','espagnol']
};
const REQUIRED=['cours','exercices','renforcement','quiz','revision'];
const alias=t=>{t=String(t||'').toLowerCase();if(t==='exercice')return'exercices';if(t==='fiche')return'revision';return t;};

(async()=>{
 let missing=0,short=0,weakQuiz=0,checked=0,duplicates=0;
 const details=[];
 for(const [niveau,mats] of Object.entries(MATIERES_PAR_NIVEAU)){
  for(const matiere of mats){
   const cs=await db.collection('ca_chapitres').where('anneeScolaire','==','2026-2027').where('niveau','==',niveau).where('matiereId','==',matiere).get();
   if(cs.empty){details.push('AUCUN_CHAPITRE '+niveau+' '+matiere);missing++;continue;}
   for(const ch of cs.docs){
    checked++;
    const rs=await db.collection('ca_ressources').where('chapitreId','==',ch.id).get();
    const by={};
    for(const d of rs.docs){const t=alias(d.data().type);(by[t]??=[]).push(d);}
    for(const t of REQUIRED){
      if(!by[t]?.length){missing++;details.push('MISSING '+niveau+' '+matiere+' '+ch.data().ordre+' '+t);}
      if((by[t]?.length||0)>1){duplicates++;details.push('DUPLICATE '+niveau+' '+matiere+' '+ch.data().ordre+' '+t+' x'+by[t].length);}
    }
    const course=by.cours?.[0];
    if(course){
      const len=String(course.data().contenu||'').trim().length;
      const minCourse=(niveau==='6e'&&matiere==='svt')?600:900;
      if(len<minCourse){short++;details.push('SHORT_COURSE '+niveau+' '+matiere+' '+ch.data().ordre+' '+len+' min='+minCourse);}
    }
    const quiz=by.quiz?.[0], nq=Array.isArray(quiz?.data().questions)?quiz.data().questions.length:0;
    if(quiz&&nq<4){weakQuiz++;details.push('WEAK_QUIZ '+niveau+' '+matiere+' '+ch.data().ordre+' '+nq);}
   }
  }
 }
 const ok=missing===0&&short===0&&weakQuiz===0&&duplicates===0;
 console.log(JSON.stringify({ok,chapitresVerifies:checked,ressourcesManquantes:missing,coursCourts:short,quizFaibles:weakQuiz,doublons:duplicates,details:details.slice(0,200)},null,2));
 process.exit(ok?0:2);
})().catch(e=>{console.error(e.stack||e);process.exit(1);});

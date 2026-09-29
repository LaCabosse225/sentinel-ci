const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId:'sentinel-ci-c7592' });
const db=getFirestore();

const NIVEAUX=['2nde','1ere','Tle'];
const MATIERES=['arts','math','pc','svt','franc','angl','hg','philo','eps','info','ecm'];
const TYPES=['cours','exercices','renforcement','quiz','revision'];

(async()=>{
  const [chapSnap,resSnap]=await Promise.all([
    db.collection('ca_chapitres').where('anneeScolaire','==','2026-2027').get(),
    db.collection('ca_ressources').where('annee','==',2026).get()
  ]);
  const chapitres=chapSnap.docs.map(d=>({id:d.id,...d.data()})).filter(c=>NIVEAUX.includes(String(c.niveau))&&MATIERES.includes(String(c.matiereId))&&c.actif!==false);
  const ressources=resSnap.docs.map(d=>({id:d.id,...d.data()}));
  const erreurs=[],alertes=[];
  const seen=new Set();
  for(const c of chapitres){
    const rs=ressources.filter(r=>r.chapitreId===c.id&&r.actif!==false);
    for(const type of TYPES){
      const same=rs.filter(r=>String(r.type||'')===type);
      if(same.length===0){erreurs.push(c.niveau+' / '+c.matiereId+' / '+c.ordre+' : '+type+' ABSENT');continue;}
      if(same.length>1) erreurs.push(c.niveau+' / '+c.matiereId+' / '+c.ordre+' : '+type+' DUPLIQUE ('+same.length+')');
      const r=same[0];
      const len=String(r.contenu||'').trim().length;
      if(type==='cours' && len<500) alertes.push(c.niveau+' / '+c.matiereId+' / '+c.ordre+' : cours court ('+len+')');
      if(type==='exercices' && !/Correction/i.test(String(r.contenu||''))) alertes.push(c.niveau+' / '+c.matiereId+' / '+c.ordre+' : exercices sans correction détectée');
      if(type==='renforcement' && len<500) alertes.push(c.niveau+' / '+c.matiereId+' / '+c.ordre+' : renforcement court ('+len+')');
      if(type==='quiz' && (!Array.isArray(r.questions)||r.questions.length<4)) alertes.push(c.niveau+' / '+c.matiereId+' / '+c.ordre+' : quiz faible ('+(Array.isArray(r.questions)?r.questions.length:0)+' questions)');
      if(type==='revision' && len<400) alertes.push(c.niveau+' / '+c.matiereId+' / '+c.ordre+' : fiche courte ('+len+')');
    }
    seen.add(c.id);
  }
  for(const niveau of NIVEAUX) for(const matiere of MATIERES){
    const count=chapitres.filter(c=>c.niveau===niveau&&c.matiereId===matiere).length;
    if(count===0) erreurs.push(niveau+' / '+matiere+' : AUCUN CHAPITRE');
  }
  const orphan=ressources.filter(r=>TYPES.includes(String(r.type||''))&&!chapitres.some(c=>c.id===r.chapitreId));
  if(orphan.length) erreurs.push(orphan.length+' ressources lycée orphelines');
  const summary={ok:erreurs.length===0,erreurs,alertes,totalChapitres:chapitres.length,totalRessources:ressources.length};
  console.log(JSON.stringify(summary,null,2));
  process.exit(erreurs.length?2:0);
})().catch(e=>{console.error(e);process.exit(1);});

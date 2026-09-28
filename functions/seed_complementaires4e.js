const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const programmes = {
  eps: ['Condition physique et santé','Athlétisme : courses','Athlétisme : sauts','Athlétisme : lancers','Sports collectifs','Gymnastique','Activités d’expression corporelle','Sécurité et fair-play'],
  info: ['Environnement numérique de travail','Recherche et évaluation de l’information','Traitement de texte','Présentation numérique','Tableur et données','Internet et communication','Sécurité numérique','Projet numérique'],
  ecm: ['Identité et citoyenneté','Droits et devoirs du citoyen','Respect des règles et des institutions','Égalité et non-discrimination','Paix et prévention des conflits','Protection de l’environnement','Responsabilité et solidarité','Citoyenneté numérique']
};

const noms = {eps:'EPS', info:'Informatique', ecm:'Education civique et morale'};
const types = [['cours','Cours'],['exercice','Exercices'],['renforcement','Renforcement'],['quiz','Quiz'],['fiche','Fiche de révision']];

async function main() {
  let c=0,r=0;
  for (const [matiereId,titres] of Object.entries(programmes)) {
    for (let i=0;i<titres.length;i++) {
      const theme=titres[i], n=String(i+1).padStart(2,'0'), id='4e_'+matiereId+'_ch'+n;
      const ref=db.collection('ca_chapitres').doc(id);
      if (!(await ref.get()).exists) {
        await ref.set({
          code:'2026-2027_dpfc_4e_'+matiereId+'_ch'+n,
          niveau:'4e', matiereId, anneeScolaire:'2026-2027',
          programmeVersion:'DPFC 2026-2027', serie:'', theme, titre:theme,
          description:'Base pédagogique Sentinel CI pour la '+noms[matiereId]+' en 4e.',
          ordre:i+1, actif:true, ressourceNationale:true,
          sourceOfficielle:'DPFC — programme secondaire', dateMaj:FieldValue.serverTimestamp()
        });
        c++;
      }
      for (let j=0;j<types.length;j++) {
        const [type,label]=types[j], rr=db.collection('ca_ressources').doc(id+'_r'+j);
        if ((await rr.get()).exists) continue;
        await rr.set({
          type,titre:label+' — '+theme,ordre:j+1,chapitreId:id,niveau:'4e',matiereId,
          ecoleId:'',contenu:'## '+theme+'\n\nRessource de base Sentinel CI : notions essentielles, vocabulaire, exemples et méthode adaptés à la 4e.',
          imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',
          difficulte:1,ressourceLieeId:'',
          questions:type==='quiz'?[{id:'q1',type:'qcm',enonce:'La notion étudiée correspond-elle au chapitre ?',choix:['Oui','Non'],bonnesReponses:[0],points:1}]:[],
          dureeMinutes:type==='quiz'?5:20,examen:false,annee:2026,serie:'',
          actif:true,ressourceNationale:true,auteur:'Sentinel CI',
          dateCreation:FieldValue.serverTimestamp(),dateMaj:FieldValue.serverTimestamp()
        });
        r++;
      }
    }
  }
  await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),dateMaj:FieldValue.serverTimestamp()},{merge:true});
  console.log({ok:true,niveau:'4e',chapitres:c,ressources:r});
}
main().catch(e=>{console.error(e);process.exit(1);});

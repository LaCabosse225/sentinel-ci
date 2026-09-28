const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const niveau = '5e';
const matiereId = 'pc';
const anneeScolaire = '2026-2027';

const titres = [
  "Adaptation d’un générateur à un récepteur",
  "Association de lampes électriques",
  "Association de piles en série",
  "Intensité du courant électrique",
  "Tension électrique",
  "Pression atmosphérique",
  "Les mélanges",
  "Atomes et molécules",
  "Combustion du carbone",
  "Combustion du soufre",
  "Dilatation des solides",
  "Dilatation des liquides et des gaz"
];

const ressources = [
  ['cours','Cours complet'],
  ['exercices','Exercices d’application'],
  ['renforcement','Renforcement'],
  ['quiz','Quiz'],
  ['revision','Fiche de révision']
];

async function main() {
  let chapitres = 0, ressourcesCreees = 0;

  for (let i = 0; i < titres.length; i++) {
    const theme = titres[i];
    const code = 'PC-' + niveau + '-' + String(i + 1).padStart(2, '0');
    const q = await db.collection('ca_chapitres').where('code', '==', code).limit(1).get();
    let chapitreId;

    if (q.empty) {
      const ref = db.collection('ca_chapitres').doc();
      chapitreId = ref.id;
      await ref.set({
        code,
        niveau,
        matiereId,
        anneeScolaire,
        programmeVersion: 'DPFC 2026-2027',
        serie: '',
        theme,
        titre: theme,
        description: 'Base pédagogique Sentinel CI alignée sur le programme DPFC de Physique-Chimie 5e.',
        ordre: i + 1,
        actif: true,
        ressourceNationale: true,
        sourceOfficielle: 'DPFC — Programme éducatif et progression Physique-Chimie 5e',
        dateMaj: FieldValue.serverTimestamp()
      });
      chapitres++;
    } else {
      chapitreId = q.docs[0].id;
      await q.docs[0].ref.update({ matiereId, niveau, anneeScolaire, actif: true, ressourceNationale: true });
    }

    for (let j = 0; j < ressources.length; j++) {
      const [type, label] = ressources[j];
      const rq = await db.collection('ca_ressources')
        .where('chapitreId', '==', chapitreId)
        .where('type', '==', type)
        .limit(1).get();
      if (!rq.empty) continue;

      await db.collection('ca_ressources').add({
        type,
        titre: label + ' — ' + theme,
        ordre: j + 1,
        chapitreId,
        niveau,
        matiereId,
        ecoleId: '',
        contenu: '## ' + theme + '\n\nRessource Sentinel CI adaptée au niveau 5e : notions essentielles, vocabulaire scientifique, méthode, exemples et applications guidées.',
        imagesUrls: [],
        pdfUrl: '',
        videoYoutubeId: '',
        enonce: '',
        solution: '',
        difficulte: type === 'quiz' ? 'moyenne' : 'progressive',
        ressourceLieeId: '',
        questions: type === 'quiz' ? [
          { question: 'Quelle notion principale faut-il retenir de « ' + theme + ' » ?', reponse: 'Identifier les notions, grandeurs et méthodes essentielles étudiées dans le chapitre.' }
        ] : [],
        dureeMinutes: type === 'cours' ? 30 : 20,
        examen: false,
        annee: 2026,
        serie: '',
        actif: true,
        ressourceNationale: true,
        auteur: 'Sentinel CI',
        dateCreation: FieldValue.serverTimestamp(),
        dateMaj: FieldValue.serverTimestamp()
      });
      ressourcesCreees++;
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    anneeScolaire,
    dateMaj: FieldValue.serverTimestamp()
  }, { merge: true });

  console.log({ ok: true, niveau, matiere: matiereId, chapitres, ressources: ressourcesCreees });
}

main().catch(e => { console.error(e); process.exit(1); });

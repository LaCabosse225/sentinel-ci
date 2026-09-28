const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const niveau = '3e';
const matiereId = 'hg';
const titres = [
  'La Première Guerre mondiale',
  'Les conséquences de la Première Guerre mondiale',
  'La crise économique de 1929',
  'Les régimes totalitaires et la Seconde Guerre mondiale',
  'La décolonisation',
  'Les indépendances africaines',
  'La Côte d’Ivoire de la colonisation à l’indépendance',
  'La population et les migrations en Afrique',
  'Les espaces agricoles et industriels africains',
  'Les échanges et transports en Afrique',
  'La Côte d’Ivoire : population, économie et développement',
  'Environnement, ressources et développement durable'
];

const types = [
  ['cours','Cours'],
  ['exercices','Exercices d’application'],
  ['renforcement','Renforcement'],
  ['quiz','Quiz'],
  ['revision','Fiche de révision']
];

(async () => {
  let chapitres = 0, ressources = 0;

  for (let i = 0; i < titres.length; i++) {
    const titre = titres[i];
    const code = 'HG-3e-' + String(i + 1).padStart(2, '0');
    const q = await db.collection('ca_chapitres').where('code', '==', code).limit(1).get();
    let chapitreId;

    if (q.empty) {
      const ref = db.collection('ca_chapitres').doc();
      chapitreId = ref.id;
      await ref.set({
        code,
        niveau,
        matiereId,
        anneeScolaire: '2026-2027',
        programmeVersion: 'DPFC 2026-2027',
        serie: '',
        theme: titre,
        titre,
        description: 'Base pédagogique Sentinel CI alignée sur le programme d’Histoire-Géographie 3e.',
        ordre: i + 1,
        actif: true,
        ressourceNationale: true,
        sourceOfficielle: 'DPFC — Histoire-Géographie',
        dateMaj: FieldValue.serverTimestamp()
      });
      chapitres++;
    } else {
      chapitreId = q.docs[0].id;
      await q.docs[0].ref.update({ matiereId, niveau, anneeScolaire:'2026-2027', actif:true, ressourceNationale:true });
    }

    for (let j = 0; j < types.length; j++) {
      const [type, label] = types[j];
      const rq = await db.collection('ca_ressources').where('chapitreId', '==', chapitreId).limit(50).get();
      if (rq.docs.some(d => d.data().type === type)) continue;

      await db.collection('ca_ressources').add({
        type,
        titre: label + ' — ' + titre,
        ordre: j + 1,
        chapitreId,
        niveau,
        matiereId,
        ecoleId: '',
        contenu: '## ' + titre + '\n\nRessource pédagogique Sentinel CI adaptée au niveau 3e : repères, notions essentielles, vocabulaire, méthode et activités guidées.',
        imagesUrls: [],
        pdfUrl: '',
        videoYoutubeId: '',
        enonce: '',
        solution: '',
        difficulte: type === 'quiz' ? 'moyenne' : 'progressive',
        ressourceLieeId: '',
        questions: type === 'quiz' ? [
          { question: 'Quel est le point essentiel à retenir de ce chapitre ?', reponse: 'Identifier les principaux repères, notions, acteurs et conséquences liés au thème étudié.' }
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
      ressources++;
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    anneeScolaire: '2026-2027',
    dateMaj: FieldValue.serverTimestamp()
  }, { merge:true });

  console.log({ok:true,niveau,matiere:matiereId,chapitres,ressources});
  process.exit(0);
})().catch(e => { console.error(e); process.exit(1); });

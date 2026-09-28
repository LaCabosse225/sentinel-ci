const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const niveaux = ['6e', '5e', '3e'];

const matieres = {
  eps: {
    nom: 'EPS',
    source: 'DPFC — Education Physique et Sportive',
    titres: [
      'Échauffement et sécurité en pratique sportive',
      'Course de vitesse et départ',
      'Endurance et gestion de l’effort',
      'Sauts et coordination',
      'Lancers et gestes techniques',
      'Sports collectifs et coopération',
      'Gymnastique et maîtrise du corps',
      'Règles, arbitrage, fair-play et santé'
    ]
  },
  info: {
    nom: 'Informatique',
    source: 'DPFC — TICE / Informatique au secondaire',
    titres: [
      'Environnement informatique et matériel',
      'Système d’exploitation et organisation des fichiers',
      'Traitement de texte',
      'Mise en forme et présentation d’un document',
      'Tableur et calculs simples',
      'Présentation numérique et communication',
      'Internet, recherche d’information et messagerie',
      'Sécurité numérique, données personnelles et citoyenneté'
    ]
  },
  ecm: {
    nom: 'Education civique et morale',
    source: 'DPFC — EDHC / Education civique',
    titres: [
      'Valeurs, règles et vie en société',
      'Droits et devoirs du citoyen',
      'Respect de soi et respect des autres',
      'Droits humains et égalité',
      'Paix, tolérance et règlement des conflits',
      'Institutions et participation citoyenne',
      'Protection de l’environnement et responsabilité',
      'Santé, solidarité et engagement citoyen'
    ]
  }
};

const types = [
  ['cours', 'Cours'],
  ['exercices', 'Exercices d’application'],
  ['renforcement', 'Renforcement'],
  ['quiz', 'Quiz'],
  ['revision', 'Fiche de révision']
];

async function seedMatiere(niveau, matiereId, config) {
  let chapitres = 0, ressources = 0;

  for (let i = 0; i < config.titres.length; i++) {
    const theme = config.titres[i];
    const code = matiereId.toUpperCase() + '-' + niveau + '-' + String(i + 1).padStart(2, '0');
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
        theme,
        titre: theme,
        description: 'Base pédagogique Sentinel CI pour le niveau ' + niveau + '.',
        ordre: i + 1,
        actif: true,
        ressourceNationale: true,
        sourceOfficielle: config.source,
        dateMaj: FieldValue.serverTimestamp()
      });
      chapitres++;
    } else {
      chapitreId = q.docs[0].id;
      await q.docs[0].ref.update({
        matiereId,
        niveau,
        anneeScolaire: '2026-2027',
        actif: true,
        ressourceNationale: true
      });
    }

    for (let j = 0; j < types.length; j++) {
      const [type, label] = types[j];
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
        contenu: '## ' + theme + '\n\nRessource Sentinel CI adaptée au niveau ' + niveau + '. Notions essentielles, vocabulaire, méthode, exemples et applications guidées.',
        imagesUrls: [],
        pdfUrl: '',
        videoYoutubeId: '',
        enonce: '',
        solution: '',
        difficulte: type === 'quiz' ? 'moyenne' : 'progressive',
        ressourceLieeId: '',
        questions: type === 'quiz' ? [
          {
            question: 'Quelle idée essentielle faut-il retenir de « ' + theme + ' » ?',
            reponse: 'Identifier les notions, règles et comportements essentiels étudiés dans ce chapitre.'
          }
        ] : [],
        dureeMinutes: type === 'cours' ? 25 : 15,
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

  return { chapitres, ressources };
}

(async () => {
  const bilan = {};

  for (const niveau of niveaux) {
    bilan[niveau] = {};
    for (const [matiereId, config] of Object.entries(matieres)) {
      bilan[niveau][matiereId] = await seedMatiere(niveau, matiereId, config);
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    anneeScolaire: '2026-2027',
    dateMaj: FieldValue.serverTimestamp()
  }, { merge: true });

  console.log(JSON.stringify({ ok: true, bilan }, null, 2));
  process.exit(0);
})().catch(e => {
  console.error(e);
  process.exit(1);
});

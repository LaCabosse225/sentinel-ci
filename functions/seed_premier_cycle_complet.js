const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const programmes = [
  {
    id: 'arts',
    nom: 'Arts plastiques',
    niveaux: ['6e','5e','4e','3e'],
    titres: [
      'Ligne, forme et composition',
      'Couleur et contrastes',
      'Espace et profondeur',
      'Lumière et volume',
      'Image et représentation',
      'Création graphique et techniques',
      'Arts, culture et patrimoine',
      'Projet artistique et présentation'
    ],
    source: 'DPFC — Arts Plastiques'
  },
  {
    id: 'musique',
    nom: 'Éducation musicale',
    niveaux: ['6e','5e','4e','3e'],
    titres: [
      'Écoute et découverte des sons',
      'Rythme et pulsation',
      'Voix et chant',
      'Mélodie et hauteur des sons',
      'Instruments et familles instrumentales',
      'Musique ivoirienne et patrimoines',
      'Musique africaine et cultures du monde',
      'Création et pratique musicale'
    ],
    source: 'DPFC — Education Musicale'
  },
  {
    id: 'allemand',
    nom: 'Allemand',
    niveaux: ['4e','3e'],
    titres: [
      'Se présenter et saluer',
      'La famille et les relations',
      'L’école et la vie quotidienne',
      'La maison et le quartier',
      'Les activités et les loisirs',
      'Les achats et les services',
      'Les voyages et les transports',
      'Communiquer et donner son opinion'
    ],
    source: 'DPFC — Allemand'
  },
  {
    id: 'espagnol',
    nom: 'Espagnol',
    niveaux: ['4e','3e'],
    titres: [
      'Saluer et se présenter',
      'La famille et les amis',
      'L’école et les activités',
      'La vie quotidienne',
      'La maison et la ville',
      'Les loisirs et les goûts',
      'Voyages et découvertes',
      'Exprimer une opinion et communiquer'
    ],
    source: 'DPFC — Espagnol'
  }
];

const types = [
  ['cours','Cours'],
  ['exercices','Exercices d’application'],
  ['renforcement','Renforcement'],
  ['quiz','Quiz'],
  ['revision','Fiche de révision']
];

async function seed(programme, niveau) {
  let chapitres = 0, ressources = 0;

  for (let i = 0; i < programme.titres.length; i++) {
    const theme = programme.titres[i];
    const code = programme.id.toUpperCase() + '-' + niveau + '-' + String(i + 1).padStart(2, '0');
    const q = await db.collection('ca_chapitres').where('code', '==', code).limit(1).get();
    let chapitreId;

    if (q.empty) {
      const ref = db.collection('ca_chapitres').doc();
      chapitreId = ref.id;
      await ref.set({
        code,
        niveau,
        matiereId: programme.id,
        anneeScolaire: '2026-2027',
        programmeVersion: 'DPFC 2026-2027',
        serie: '',
        theme,
        titre: theme,
        description: 'Base pédagogique nationale Sentinel CI pour le niveau ' + niveau + '.',
        ordre: i + 1,
        actif: true,
        ressourceNationale: true,
        sourceOfficielle: programme.source,
        dateMaj: FieldValue.serverTimestamp()
      });
      chapitres++;
    } else {
      chapitreId = q.docs[0].id;
      await q.docs[0].ref.update({
        matiereId: programme.id,
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
        matiereId: programme.id,
        ecoleId: '',
        contenu: '## ' + theme + '\n\nRessource pédagogique Sentinel CI adaptée au niveau ' + niveau + '. Notions essentielles, vocabulaire, méthode, exemples et activités guidées.',
        imagesUrls: [],
        pdfUrl: '',
        videoYoutubeId: '',
        enonce: '',
        solution: '',
        difficulte: type === 'quiz' ? 'moyenne' : 'progressive',
        ressourceLieeId: '',
        questions: type === 'quiz' ? [
          {
            question: 'Quelle notion essentielle faut-il retenir de « ' + theme + ' » ?',
            reponse: 'Identifier les notions, techniques ou compétences principales étudiées dans le chapitre.'
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
  for (const programme of programmes) {
    for (const niveau of programme.niveaux) {
      bilan[programme.id + '_' + niveau] = await seed(programme, niveau);
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

const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const cycle1 = {
  '6e': ['math','pc','svt','franc','angl','hg','eps','info','ecm','arts','musique'],
  '5e': ['math','pc','svt','franc','angl','hg','eps','info','ecm','arts','musique'],
  '4e': ['math','pc','svt','franc','angl','hg','eps','info','ecm','arts','musique','allemand','espagnol'],
  '3e': ['math','pc','svt','franc','angl','hg','eps','info','ecm','arts','musique','allemand','espagnol'],
};

const cycle2 = {
  '2nde': ['math','pc','svt','franc','angl','hg','philo','eps','info','ecm','arts'],
  '1ere': ['math','pc','svt','franc','angl','hg','philo','eps','info','ecm','arts'],
  'Tle': ['math','pc','svt','franc','angl','hg','philo','eps','info','ecm','arts'],
};

const noms = {
  math:'Mathématiques', pc:'Physique-Chimie', svt:'SVT', franc:'Français',
  angl:'Anglais', hg:'Histoire-Géographie', eps:'EPS', info:'Informatique',
  ecm:'Éducation civique et morale', arts:'Arts plastiques',
  musique:'Éducation musicale', allemand:'Allemand', espagnol:'Espagnol',
  philo:'Philosophie'
};

const attendu = { ...cycle1, ...cycle2 };

const PLACEHOLDER_MARKERS = [
  'Ressource pédagogique Sentinel CI adaptée au niveau',
  'Notions essentielles, vocabulaire, méthode, exemples et activités guidées.',
  'Notions essentielles, vocabulaire, méthode et exemples guidés.',
  'Notions essentielles, définitions, observations et méthode.',
  'Retenir les mots et expressions spécifiques au chapitre.',
];

function estCoursReel(data) {
  if (String(data.type || '') !== 'cours') return false;
  const contenu = String(data.contenu || '').trim();
  if (contenu.length < 450) return false;
  if (PLACEHOLDER_MARKERS.some(m => contenu.includes(m))) return false;
  return true;
}

(async () => {
  const [chapSnap, resSnap] = await Promise.all([
    db.collection('ca_chapitres').get(),
    db.collection('ca_ressources').get()
  ]);

  const chapitres = chapSnap.docs.map(d => ({ id:d.id, ...d.data() }));
  const ressources = resSnap.docs.map(d => ({ id:d.id, ...d.data() }));

  const erreurs = [];
  const alertes = [];
  const stats = {};

  for (const [niveau, matieres] of Object.entries(attendu)) {
    stats[niveau] = {};

    for (const matiereId of matieres) {
      const chaps = chapitres
        .filter(c => c.niveau === niveau && c.matiereId === matiereId && c.actif !== false)
        .sort((a,b) => (Number(a.ordre)||0) - (Number(b.ordre)||0));

      const courses = [];
      for (const ch of chaps) {
        const rs = ressources.filter(r => r.chapitreId === ch.id && r.actif !== false);
        const cours = rs.find(r => String(r.type || '') === 'cours');
        if (!cours) {
          erreurs.push(niveau + ' / ' + noms[matiereId] + ' / chapitre ' + ch.ordre + ' : COURS ABSENT');
        } else if (!estCoursReel(cours)) {
          alertes.push(niveau + ' / ' + noms[matiereId] + ' / chapitre ' + ch.ordre + ' : cours à enrichir');
        } else {
          courses.push(cours.id);
        }
      }

      stats[niveau][matiereId] = {
        matiere: noms[matiereId],
        chapitres: chaps.length,
        coursReels: courses.length,
      };

      if (chaps.length === 0) {
        erreurs.push(niveau + ' / ' + noms[matiereId] + ' : AUCUN CHAPITRE');
      }
    }
  }

  const coursOrphelins = ressources.filter(r =>
    r.type === 'cours' &&
    r.actif !== false &&
    !chapitres.some(c => c.id === r.chapitreId)
  );

  if (coursOrphelins.length) {
    erreurs.push(coursOrphelins.length + ' cours orphelins detectes');
  }

  console.log(JSON.stringify({
    ok: erreurs.length === 0,
    erreurs,
    alertes,
    stats,
    totalChapitres: chapitres.length,
    totalRessources: ressources.length,
    totalCoursActifs: ressources.filter(r => r.type === 'cours' && r.actif !== false).length
  }, null, 2));

  if (erreurs.length) process.exit(2);
  process.exit(0);
})().catch(e => {
  console.error(e);
  process.exit(1);
});

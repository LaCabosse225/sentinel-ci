const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const MAP = {
  francais: 'franc',
  physique_chimie: 'pc'
};

async function main() {
  let chapters = 0;
  let resources = 0;

  const snap = await db.collection('ca_chapitres')
    .where('anneeScolaire', '==', '2026-2027')
    .limit(2000)
    .get();

  for (const d of snap.docs) {
    const data = d.data();
    const oldId = String(data.matiereId || '');
    const newId = MAP[oldId];
    if (!newId) continue;

    await d.ref.update({
      matiereId: newId,
      dateMaj: FieldValue.serverTimestamp()
    });
    chapters++;

    const rs = await db.collection('ca_ressources')
      .where('chapitreId', '==', d.id)
      .limit(100)
      .get();

    for (const r of rs.docs) {
      if (String(r.data().matiereId || '') !== newId) {
        await r.ref.update({
          matiereId: newId,
          dateMaj: FieldValue.serverTimestamp()
        });
        resources++;
      }
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    dateMaj: FieldValue.serverTimestamp()
  }, { merge: true });

  console.log(JSON.stringify({
    ok: true,
    migratedChapterCount: chapters,
    migratedResourceCount: resources
  }, null, 2));
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});

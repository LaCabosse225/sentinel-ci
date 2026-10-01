const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({
  credential: applicationDefault(),
  projectId: 'sentinel-ci-c7592',
});

const db = getFirestore();

/**
 * Publication automatique du catalogue national.
 *
 * Règle Sentinel CI :
 * - le contenu national préparé dans le cadre du Centre d'apprentissage
 *   est considéré comme validé par l'équipe éditoriale ;
 * - il ne doit donc plus rester bloqué en brouillon ;
 * - on ne touche pas aux ressources explicitement liées à une école.
 *
 * Les scripts de remplacement peuvent continuer à écrire actif:false
 * pendant leur phase de préparation : cette étape finale de Codemagic
 * publie ensuite les ressources nationales avant le déploiement.
 */
async function main() {
  const snap = await db
    .collection('ca_ressources')
    .where('ressourceNationale', '==', true)
    .get();

  let updated = 0;
  let alreadyPublished = 0;

  for (let i = 0; i < snap.docs.length; i += 450) {
    const batch = db.batch();
    const chunk = snap.docs.slice(i, i + 450);
    let chunkUpdated = 0;

    for (const doc of chunk) {
      const data = doc.data();

      if (data.actif === true) {
        alreadyPublished++;
        continue;
      }

      batch.update(doc.ref, {
        actif: true,
        dateMaj: FieldValue.serverTimestamp(),
      });
      updated++;
      chunkUpdated++;
    }

    if (chunkUpdated > 0) {
      await batch.commit();
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    dateMaj: FieldValue.serverTimestamp(),
    publicationAutomatique: true,
    dernierePublicationNationale: 'AUTO_PUBLISH_VALIDATED_NATIONAL_CONTENT',
    ressourcesNationalesAnalysees: snap.size,
    ressourcesNationalesActivees: updated,
  }, { merge: true });

  console.log({
    ok: true,
    publication: 'directe',
    ressourcesNationalesAnalysees: snap.size,
    ressourcesNationalesDejaPubliees: alreadyPublished,
    ressourcesNationalesActivees: updated,
    regle: 'ressourceNationale=true uniquement',
  });
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

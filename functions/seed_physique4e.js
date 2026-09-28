const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const titres = [
  "Sources et récepteurs de lumière",
  "Propagation rectiligne de la lumière",
  "Ombres et éclipses",
  "Phases de la Lune",
  "Lumière blanche et couleurs",
  "Aimant et bobine",
  "Tension alternative",
  "Tension du secteur",
  "Redressement du courant",
  "Atomes et ions",
  "Métaux et formation des ions",
  "Traitement et potabilisation de l'eau"
];

const ressources = [
  ['cours','Cours complet','Notions essentielles, définitions, observations et méthode.'],
  ['exercice','Exercices corrigés','Applications progressives avec démarche et correction.'],
  ['renforcement','Renforcement','Applications supplémentaires pour consolider la notion.'],
  ['quiz','Quiz','Questions rapides pour vérifier les acquis.'],
  ['fiche','Fiche de révision','Résumé des définitions, lois, méthodes et points à retenir.']
];

async function main() {
  let chapitres = 0, ressourcesCreees = 0;
  for (let i = 0; i < titres.length; i++) {
    const theme = titres[i];
    const n = String(i + 1).padStart(2, '0');
    const id = '4e_pc_ch' + n;
    const ref = db.collection('ca_chapitres').doc(id);
    const snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        code: '2026-2027_dpfc_4e_pc_ch' + n,
        niveau: '4e',
        matiereId: 'pc',
        anneeScolaire: '2026-2027',
        programmeVersion: 'DPFC 2026-2027',
        serie: '',
        theme,
        titre: theme,
        description: 'Base pédagogique Sentinel CI alignée sur les notions de Physique-Chimie du secondaire.',
        ordre: i + 1,
        actif: true,
        ressourceNationale: true,
        sourceOfficielle: 'DPFC — Physique-Chimie 4e',
        dateMaj: FieldValue.serverTimestamp()
      });
      chapitres++;
    }

    for (let j = 0; j < ressources.length; j++) {
      const [type, label, texte] = ressources[j];
      const rr = ref.collection ? null : null;
      const rid = id + '_r' + j;
      const rref = db.collection('ca_ressources').doc(rid);
      if ((await rref.get()).exists) continue;

      await rref.set({
        type,
        titre: label + ' — ' + theme,
        ordre: j + 1,
        chapitreId: id,
        niveau: '4e',
        matiereId: 'pc',
        ecoleId: '',
        contenu: '## ' + theme + '\n\n' + texte + '\n\nObjectif : comprendre la notion, identifier les grandeurs utiles, appliquer la méthode et vérifier le résultat.',
        imagesUrls: [],
        pdfUrl: '',
        videoYoutubeId: '',
        enonce: '',
        solution: '',
        difficulte: 1,
        ressourceLieeId: '',
        questions: type === 'quiz' ? [
          { id:'q1', type:'qcm', enonce:'La notion étudiée correspond-elle au chapitre ?', choix:['Oui','Non'], bonnesReponses:[0], points:1 },
          { id:'q2', type:'qcm', enonce:'Faut-il vérifier le résultat d’une application ?', choix:['Oui','Non'], bonnesReponses:[0], points:1 }
        ] : [],
        dureeMinutes: type === 'quiz' ? 5 : 20,
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
    dateMaj: FieldValue.serverTimestamp(),
    derniereRessourceNationale: '4e_pc_2026_2027'
  }, { merge: true });

  console.log({ ok:true, niveau:'4e', matiere:'pc', chapitres, ressources:ressourcesCreees });
}

main().catch(e => { console.error(e); process.exit(1); });

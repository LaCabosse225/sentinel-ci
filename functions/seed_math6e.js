const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const chapitres = [
  [1, 'Nombres entiers naturels', 'Écriture, comparaison, opérations et propriétés des nombres entiers naturels.'],
  [2, 'Droites et points', 'Points, droites, demi-droites, segments, alignement et constructions.'],
  [3, 'Nombres décimaux relatifs', 'Repérage, comparaison et opérations sur les nombres décimaux relatifs.'],
  [4, 'Segments', 'Longueur, milieu, médiatrice et constructions de segments.'],
  [5, 'Pavés droits et cylindres droits', 'Patrons, aires et volumes des pavés droits et cylindres droits.'],
  [6, 'Fractions', 'Écriture, comparaison, opérations et problèmes avec les fractions.'],
  [7, 'Cercles et disques', 'Vocabulaire, constructions, périmètre et aire du disque.'],
  [8, 'Angles', 'Mesure, construction, angles particuliers et relations simples.'],
  [9, 'Triangles', 'Construction et propriétés des triangles.'],
  [10, 'Proportionnalité', 'Situations de proportionnalité, tableaux et calculs.'],
  [11, 'Figures symétriques par rapport à un point', 'Symétrie centrale et propriétés des figures.'],
  [12, 'Statistique', 'Collecte, organisation et représentation de données.'],
  [13, 'Parallélogramme', 'Construction et propriétés du parallélogramme.'],
];

async function main() {
  const chapRef = db.collection('ca_chapitres');
  const batch = db.batch();
  let created = 0;
  let existing = 0;

  for (const [ordre, titre, description] of chapitres) {
    const id = `6e_math_ch${String(ordre).padStart(2, '0')}`;
    const ref = chapRef.doc(id);
    const snap = await ref.get();
    if (snap.exists) {
      existing++;
      continue;
    }
    batch.set(ref, {
      code: `2026-2027_dpfc_6e_math_ch${String(ordre).padStart(2, '0')}`,
      niveau: '6e',
      matiereId: 'math',
      anneeScolaire: '2026-2027',
      programmeVersion: 'dpfc',
      serie: '',
      theme: '',
      titre,
      description,
      ordre,
      actif: true,
      dateMaj: FieldValue.serverTimestamp(),
    });
    created++;
  }

  if (created > 0) await batch.commit();

  // Un vrai mini-cours publié immédiatement pour la démonstration de demain.
  // On ne remplace jamais une ressource déjà existante.
  const ressources = [
    {
      id: '6e_math_ch01_cours_officiel',
      type: 'cours',
      titre: 'Cours — Nombres entiers naturels',
      ordre: 1,
      contenu: `# Nombres entiers naturels

Les nombres entiers naturels sont les nombres 0, 1, 2, 3, 4, ... Ils permettent de compter et de dénombrer.

## 1. Écriture et lecture
Un nombre entier peut être décomposé selon ses rangs : unités, dizaines, centaines, milliers, etc.

Exemple : 4 582 = 4 milliers + 5 centaines + 8 dizaines + 2 unités.

## 2. Comparer deux nombres
Pour comparer deux nombres, on compare d'abord leur nombre de chiffres. S'ils ont le même nombre de chiffres, on compare les chiffres de gauche à droite.

Exemple : 5 231 > 4 999.

## 3. Les quatre opérations
L'addition et la multiplication regroupent des quantités. La soustraction recherche une différence et la division permet notamment de partager une quantité.

Exemple : 24 + 18 = 42 ; 30 - 12 = 18 ; 6 × 7 = 42 ; 42 ÷ 6 = 7.

## À retenir
Un entier naturel est toujours positif ou nul. Pour résoudre un problème, lis attentivement les données, choisis l'opération adaptée puis vérifie que le résultat est cohérent.`,
      difficulte: 1,
      actif: true,
    },
    {
      id: '6e_math_ch01_renforcement',
      type: 'renforcement',
      titre: 'Renforcement — Lire et comparer les entiers',
      ordre: 2,
      contenu: `Pour comparer 7 405 et 7 450, les milliers puis les centaines sont identiques. On compare alors les dizaines : 0 < 5, donc 7 405 < 7 450.

Astuce : aligne toujours les nombres en colonnes avant de comparer ou de calculer.`,
      difficulte: 1,
      actif: true,
    },
    {
      id: '6e_math_ch01_exercice',
      type: 'exercice',
      titre: 'Exercice corrigé — Opérations sur les entiers',
      ordre: 3,
      enonce: 'Calcule : A = 245 + 378 ; B = 900 - 457 ; C = 24 × 15 ; D = 840 ÷ 12.',
      solution: 'A = 623 ; B = 443 ; C = 360 ; D = 70.',
      difficulte: 1,
      actif: true,
    },
    {
      id: '6e_math_ch01_quiz',
      type: 'quiz',
      titre: 'Quiz — Nombres entiers naturels',
      ordre: 4,
      questions: [
        {
          id: 'q1',
          type: 'qcm',
          enonce: 'Quel nombre est le plus grand ?',
          choix: ['3 205', '3 250', '3 025'],
          bonnesReponses: [1],
          reponseAttendue: '',
          explication: '3 250 est supérieur à 3 205 et à 3 025.',
          points: 1,
        },
        {
          id: 'q2',
          type: 'qcm',
          enonce: 'Combien font 8 × 7 ?',
          choix: ['54', '56', '64'],
          bonnesReponses: [1],
          reponseAttendue: '',
          explication: '8 × 7 = 56.',
          points: 1,
        },
      ],
      dureeMinutes: 5,
      difficulte: 1,
      actif: true,
    },
  ];

  let resourcesCreated = 0;
  for (const r of ressources) {
    const ref = db.collection('ca_ressources').doc(r.id);
    const snap = await ref.get();
    if (snap.exists) continue;
    const data = {
      type: r.type,
      titre: r.titre,
      ordre: r.ordre,
      chapitreId: '6e_math_ch01',
      niveau: '6e',
      matiereId: 'math',
      ecoleId: '',
      contenu: r.contenu || '',
      imagesUrls: [],
      pdfUrl: '',
      videoYoutubeId: '',
      enonce: r.enonce || '',
      solution: r.solution || '',
      difficulte: r.difficulte || 1,
      ressourceLieeId: '',
      questions: r.questions || [],
      dureeMinutes: r.dureeMinutes || 0,
      examen: '',
      annee: 0,
      serie: '',
      actif: true,
      auteur: 'sentinel-seed-2026',
      dateCreation: FieldValue.serverTimestamp(),
      dateMaj: FieldValue.serverTimestamp(),
    };
    await ref.set(data);
    resourcesCreated++;
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    dateMaj: FieldValue.serverTimestamp(),
  }, { merge: true });

  console.log(JSON.stringify({
    ok: true,
    collection: 'ca_chapitres',
    chapitresCrees: created,
    chapitresDejaPresents: existing,
    ressourcesDemoCreees: resourcesCreated,
    message: 'Peuplement 6e Math termine.'
  }, null, 2));
}

main().catch((err) => {
  console.error('SEED_FIRESTORE_ERROR');
  console.error(err && err.stack ? err.stack : err);
  process.exit(1);
});

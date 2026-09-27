const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const lecons = [
  [1, 'Nombres décimaux relatifs', 'Puissances de 10, notation scientifique, ordre de grandeur et opérations sur les nombres décimaux relatifs.', 'Écris 0,00045 en notation scientifique puis calcule (-2,5) × 4.', '0,00045 = 4,5 × 10^-4 et (-2,5) × 4 = -10.'],
  [2, 'Nombres rationnels', 'Nombres rationnels, PGCD, PPCM, opérations sur les fractions, inverse, approximation, troncature et arrondi.', 'Simplifie 18/24 puis calcule 2/3 + 1/6.', '18/24 = 3/4 et 2/3 + 1/6 = 5/6.'],
  [3, 'Équations et inéquations', 'Équations et inéquations du premier degré dans Q : traduction, résolution et représentation des solutions.', 'Résous 3x + 5 = 17 puis 2x - 1 < 7.', 'x = 4 ; pour 2x - 1 < 7, x < 4.'],
  [4, 'Calcul littéral', 'Développement, réduction, produits remarquables et factorisation d’expressions littérales.', 'Développe 3(x + 2) puis factorise 5x + 10.', '3x + 6 ; 5(x + 2).'],
  [5, 'Statistique', 'Population, caractère, effectifs, mode, moyenne et représentation par diagramme semi-circulaire.', 'Pour 8, 10, 10, 12, 15, calcule la moyenne et le mode.', 'Moyenne = 11 ; mode = 10.'],
  [6, 'Angles', 'Angles au centre, angles alternes-internes et correspondants, cordes et arcs de cercle.', 'Deux droites parallèles sont coupées par une sécante. Un angle correspondant mesure 65°. Que vaut l’autre angle correspondant ?', 'Il mesure 65°. Les angles correspondants sont de même mesure lorsque les droites sont parallèles.'],
  [7, 'Distances', 'Distance d’un point à une droite, distance de deux droites parallèles et bissectrice d’un angle.', 'Que représente la distance d’un point A à une droite d ?', 'C’est la longueur du segment perpendiculaire à d reliant A à son pied sur d.'],
  [8, 'Cercles et triangles', 'Tangente à un cercle, droite des milieux, droites particulières et points remarquables d’un triangle.', 'Dans un triangle, cite trois droites particulières et trois points remarquables.', 'Hauteur, médiane et bissectrice ; centre de gravité, orthocentre et centre du cercle inscrit.'],
  [9, 'Vecteurs', 'Vecteurs, direction, sens, longueur, égalité, opposés et relation de Chasles.', 'Si AB = BC comme vecteurs, quelle relation de Chasles peut-on écrire pour A, B et C ?', 'On peut écrire vecteur AC = vecteur AB + vecteur BC.'],
  [10, 'Perspective cavalière et symétries', 'Règles de perspective cavalière, pavé, prisme, cylindre, symétrie centrale, symétrie orthogonale et translation.', 'Quelle transformation correspond à un demi-tour de 180° autour d’un point ?', 'La symétrie centrale de centre ce point.'],
];

async function main() {
  let chaptersCreated = 0;
  let resourcesCreated = 0;

  for (const [ordre, titre, description, enonce, solution] of lecons) {
    const chapitreId = '4e_math_ch' + String(ordre).padStart(2, '0');
    const chapitreRef = db.collection('ca_chapitres').doc(chapitreId);
    if (!(await chapitreRef.get()).exists) {
      await chapitreRef.set({
        code: '2026-2027_dpfc_4e_math_ch' + String(ordre).padStart(2, '0'),
        niveau: '4e',
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
      chaptersCreated++;
    }

    const docs = [
      {
        id: chapitreId + '_cours_complet',
        type: 'cours',
        titre: 'Cours complet — ' + titre,
        ordre: 1,
        contenu: '# ' + titre + '\n\n' + description + '\n\n## Méthode\n\n' + enonce + '\n\n## Exemple corrigé\n\n' + solution + '\n\n## À retenir\n\nIdentifie les données, choisis la propriété adaptée, rédige les étapes et vérifie le résultat.'
      },
      {
        id: chapitreId + '_exercices_corriges',
        type: 'exercice',
        titre: 'Exercices corrigés — ' + titre,
        ordre: 2,
        enonce,
        solution,
        contenu: 'Exercice d’application basé sur le programme officiel de 4e.'
      },
      {
        id: chapitreId + '_renforcement',
        type: 'renforcement',
        titre: 'Renforcement — ' + titre,
        ordre: 3,
        contenu: 'Révise la notion : ' + description + '\n\nConseil : reprends les définitions, applique la méthode sur un exemple simple, puis refais l’exercice sans regarder la correction.'
      },
      {
        id: chapitreId + '_quiz',
        type: 'quiz',
        titre: 'Quiz — ' + titre,
        ordre: 4,
        questions: [
          { id: 'q1', type: 'qcm', enonce: 'Le cours présenté correspond-il à la leçon du chapitre ?', choix: ['Vrai', 'Faux'], bonnesReponses: [0], reponseAttendue: '', explication: 'Oui : le contenu porte sur la leçon annoncée.', points: 1 },
          { id: 'q2', type: 'qcm', enonce: 'La méthode proposée peut-elle être utilisée pour un exercice de cette leçon ?', choix: ['Vrai', 'Faux'], bonnesReponses: [0], reponseAttendue: '', explication: 'Oui : elle reprend les notions et démarches attendues.', points: 1 }
        ],
        dureeMinutes: 5
      },
      {
        id: chapitreId + '_fiche_revision',
        type: 'fiche',
        titre: 'Fiche de révision — ' + titre,
        ordre: 5,
        contenu: '# Fiche de révision — ' + titre + '\n\n### L’essentiel\n' + description + '\n\n### Exemple\n' + enonce + '\n\n### Correction\n' + solution
      }
    ];

    for (const r of docs) {
      const ref = db.collection('ca_ressources').doc(r.id);
      if ((await ref.get()).exists) continue;
      await ref.set({
        type: r.type,
        titre: r.titre,
        ordre: r.ordre,
        chapitreId,
        niveau: '4e',
        matiereId: 'math',
        ecoleId: '',
        contenu: r.contenu || '',
        imagesUrls: [],
        pdfUrl: '',
        videoYoutubeId: '',
        enonce: r.enonce || '',
        solution: r.solution || '',
        difficulte: 1,
        ressourceLieeId: '',
        questions: r.questions || [],
        dureeMinutes: r.dureeMinutes || 0,
        examen: '',
        annee: 0,
        serie: '',
        actif: true,
        auteur: 'sentinel-math4e-2026',
        dateCreation: FieldValue.serverTimestamp(),
        dateMaj: FieldValue.serverTimestamp(),
      });
      resourcesCreated++;
    }
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    dateMaj: FieldValue.serverTimestamp(),
  }, { merge: true });

  console.log(JSON.stringify({ ok: true, niveau: '4e', matiere: 'math', chapitresCrees: chaptersCreated, ressourcesCreees: resourcesCreated }, null, 2));
}

main().catch(err => {
  console.error('SEED_4E_ERROR');
  console.error(err && err.stack ? err.stack : err);
  process.exit(1);
});

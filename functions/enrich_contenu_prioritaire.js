const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const programmes = {
  'francais-6e': {
    codePrefix: '2026-2027_dpfc_6e_francais_ch',
    niveau: '6e',
    matiereId: 'franc',
    titres: [
      ['Dialogue oral', 'À l’oral, un dialogue repose sur des interlocuteurs, un sujet, un contexte et des tours de parole. Il faut écouter avant de répondre, utiliser une formule de politesse adaptée et construire des phrases compréhensibles. Le locuteur peut informer, demander, accepter, refuser ou remercier. Les marques de ponctuation et les verbes introducteurs permettent de repérer les paroles rapportées.'],
      ['Expression écrite', 'Une expression écrite réussie répond à une consigne précise. Avant de rédiger, on cherche les idées, on les organise et on choisit un vocabulaire adapté. Une production comporte généralement une introduction ou situation de départ, un développement cohérent et une fin. La relecture permet de corriger les accords, les temps, la ponctuation et les répétitions.'],
      ['Récit', 'Un récit raconte une suite d’événements. On distingue souvent une situation initiale, un événement déclencheur, des péripéties et une situation finale. Les verbes d’action font avancer l’histoire. Les connecteurs comme d’abord, ensuite, puis, enfin permettent d’organiser le temps et les événements.'],
      ['Description', 'Décrire consiste à donner à voir une personne, un lieu, un objet ou une scène. On part du général vers le particulier et on utilise des adjectifs précis, des compléments du nom et des verbes comme être, sembler, paraître. Une bonne description indique aussi la position dans l’espace grâce à des repères comme devant, derrière, à gauche ou au-dessus.'],
      ['Poésie', 'Un poème joue avec les sons, les images et le rythme. Le vers est une ligne poétique et la strophe un groupe de vers. Les rimes rapprochent certains sons en fin de vers. La comparaison utilise généralement « comme », tandis que la métaphore rapproche deux réalités sans outil de comparaison. Lire un poème demande de repérer à la fois ce qu’il dit et la manière dont il le dit.'],
      ['Théâtre', 'Une scène théâtrale présente des personnages qui parlent et agissent devant un public. Le texte contient les répliques et les didascalies, qui donnent des indications sur les gestes, le ton ou les déplacements. Les personnages peuvent se répondre rapidement dans un dialogue. Le lecteur doit identifier qui parle et comprendre les intentions de chaque personnage.'],
      ['Nom et déterminant', 'Le nom désigne une personne, un animal, une chose, un lieu ou une idée. Le déterminant accompagne le nom et permet souvent d’indiquer son genre et son nombre. On rencontre notamment les articles définis le, la, les et indéfinis un, une, des. Dans « les élèves », « élèves » est un nom commun masculin pluriel et « les » est son déterminant.'],
      ['Adjectif qualificatif', 'L’adjectif qualificatif apporte une précision sur un nom. Il s’accorde généralement avec le nom en genre et en nombre : un petit garçon, une petite fille, des petits garçons, des petites filles. Pour reconnaître l’adjectif, on peut demander quelle est la qualité ou la caractéristique du nom.'],
      ['Verbe et sujet', 'Le sujet indique qui fait l’action ou de qui l’on parle. Le verbe indique l’action ou l’état et se conjugue avec le sujet. Dans « Les enfants jouent », « les enfants » est sujet et « jouent » est le verbe. Pour trouver le sujet, on peut poser la question « qui est-ce qui ? » devant le verbe.'],
      ['Temps du récit', 'Dans un récit, les temps verbaux permettent de situer et d’organiser les actions. Le présent peut raconter une action actuelle ou rendre un récit vivant. Le passé composé exprime souvent une action achevée. L’imparfait sert fréquemment à décrire ou à présenter une action habituelle, tandis qu’un autre temps peut faire progresser l’action. Il faut surtout conserver une chronologie cohérente.'],
      ['Phrase complexe', 'Une phrase simple contient un seul verbe conjugué. Une phrase complexe en contient plusieurs et peut associer plusieurs propositions. Elles peuvent être reliées par une conjonction comme et, mais, ou, parce que, lorsque. Pour analyser une phrase complexe, on commence par repérer les verbes conjugués puis on cherche comment les propositions sont reliées.'],
      ['Vocabulaire', 'Le vocabulaire permet de choisir le mot juste. Un synonyme a un sens proche d’un autre mot, un antonyme exprime un sens contraire, et un homonyme possède la même forme ou le même son mais un sens différent. Pour comprendre un mot inconnu, on peut utiliser le contexte, la famille de mots et le dictionnaire.']
    ]
  },
  'pc-6e': {
    codePrefix: '2026-2027_dpfc_6e_physique_chimie_ch',
    niveau: '6e',
    matiereId: 'pc',
    titres: [
      ['Circuit électrique', 'Un circuit électrique simple comprend au minimum un générateur, un récepteur et des fils conducteurs formant une boucle fermée. Le courant peut circuler lorsque le circuit est fermé. Une pile fournit l’énergie électrique et une lampe transforme une partie de cette énergie en lumière et en chaleur. Dans un schéma, chaque composant est représenté par un symbole normalisé.'],
      ['Commande d’un circuit', 'Un interrupteur permet de commander le passage du courant. Lorsqu’il est fermé, la boucle est complète et le récepteur peut fonctionner ; lorsqu’il est ouvert, la boucle est interrompue. La commande d’un circuit consiste donc à ouvrir ou fermer volontairement le trajet du courant.'],
      ['Court-circuit et protection', 'Un court-circuit se produit lorsque les bornes d’un générateur sont reliées par un chemin de très faible résistance. Un courant très intense peut alors circuler, provoquer un échauffement et endommager le matériel. Les fusibles et disjoncteurs servent à interrompre le circuit lorsqu’un courant dangereux apparaît.'],
      ['Propriétés des liquides', 'Un liquide possède un volume propre mais prend la forme du récipient qui le contient. Sa surface libre est horizontale au repos. Les liquides sont peu compressibles. Leur volume peut être mesuré avec une éprouvette graduée en lisant correctement le niveau du liquide.'],
      ['Les gaz', 'Un gaz n’a ni forme propre ni volume propre : il occupe tout l’espace disponible. L’air est un mélange de gaz. Un gaz peut être comprimé et exerce une pression sur les parois du récipient. Pour manipuler un gaz en sécurité, on utilise un récipient adapté et on évite les échauffements excessifs.'],
      ['Température', 'La température indique l’état thermique d’un corps. On la mesure avec un thermomètre, généralement en degrés Celsius. Il faut placer correctement le thermomètre et attendre la stabilisation de l’indication. Il ne faut pas confondre température et chaleur : la température mesure un état, tandis que la chaleur correspond à un transfert d’énergie thermique.'],
      ['Changements d’état de l’eau', 'L’eau peut exister sous trois états : solide, liquide et gazeux. La fusion fait passer de la glace à l’eau liquide ; la solidification est le phénomène inverse. La vaporisation produit de la vapeur d’eau et la liquéfaction produit du liquide. Lors d’un changement d’état, la matière change d’organisation mais reste la même substance.'],
      ['Constituants de l’air', 'L’air est un mélange de gaz. Il contient principalement du diazote et du dioxygène, ainsi que de petites quantités d’autres gaz. Le dioxygène est indispensable à la respiration et intervient dans les combustions. Une bougie s’éteint lorsque le dioxygène disponible devient insuffisant.'],
      ['Combustion d’un solide et d’un liquide', 'Une combustion est une transformation chimique au cours de laquelle un combustible réagit avec un comburant, souvent le dioxygène. La combustion peut libérer de la chaleur et parfois de la lumière. Pour brûler, un combustible doit être en présence du dioxygène et atteindre une température suffisante d’inflammation.'],
      ['Combustion d’un gaz', 'La combustion d’un gaz comme le butane nécessite du dioxygène. Lorsque la combustion est complète, elle produit principalement du dioxyde de carbone et de l’eau. Une mauvaise arrivée d’air peut conduire à une combustion incomplète et à la formation de produits dangereux comme le monoxyde de carbone.'],
      ['Dangers des combustions', 'Les combustions présentent des risques d’incendie, de brûlure, d’explosion et d’intoxication. Le monoxyde de carbone est particulièrement dangereux car il est invisible et inodore. Pour prévenir les accidents, il faut assurer une bonne ventilation, éloigner les matières inflammables et respecter les consignes de sécurité.'],
      ['Volume et masse', 'Le volume indique l’espace occupé par un corps et peut être exprimé en litre ou en mètre cube. La masse mesure la quantité de matière et s’exprime en grammes ou en kilogrammes. Une balance mesure la masse tandis qu’une éprouvette graduée permet notamment de mesurer le volume d’un liquide.']
    ]
  },
  'svt-6e': {
    codePrefix: '2026-2027_dpfc_6e_svt_ch',
    niveau: '6e',
    matiereId: 'svt',
    titres: [
      ['Reproduction chez les vertébrés', 'Chez les vertébrés, la reproduction permet la naissance de nouveaux individus et assure la continuité de l’espèce. Les mâles produisent des spermatozoïdes et les femelles des ovules. Chez de nombreuses espèces, la fécondation résulte de la rencontre de ces cellules reproductrices. Le développement du jeune varie selon les groupes : il peut se faire dans un œuf ou dans le corps de la mère.'],
      ['Reproduction chez les plantes à fleurs', 'La fleur porte les organes reproducteurs de nombreuses plantes. Les étamines produisent le pollen et le pistil contient l’ovaire où se trouvent les ovules. La pollinisation correspond au transport du pollen vers le stigmate. Après fécondation, l’ovule peut devenir une graine et l’ovaire peut devenir un fruit.'],
      ['Germination de la graine', 'La germination commence lorsqu’une graine viable reçoit des conditions favorables, notamment de l’eau, une température adaptée et du dioxygène. La graine se réhydrate, puis la radicule sort en premier et la jeune plante se développe. Les réserves de la graine nourrissent l’embryon pendant les premières étapes.'],
      ['Nutrition chez les vertébrés', 'Les vertébrés doivent se nourrir pour obtenir de l’énergie et des matières nécessaires à leur croissance et à l’entretien de leur organisme. Les aliments apportent notamment des glucides, lipides, protéines, vitamines, sels minéraux et eau. Le régime alimentaire varie selon les espèces : herbivore, carnivore ou omnivore.'],
      ['Nutrition chez les plantes à fleurs', 'Les plantes vertes fabriquent leur matière organique grâce à la photosynthèse. En présence de lumière, elles utilisent notamment l’eau et le dioxyde de carbone pour produire de la matière organique et libérer du dioxygène. Les racines absorbent l’eau et les sels minéraux, tandis que les feuilles sont des organes majeurs de la photosynthèse.'],
      ['Besoins nutritifs des plantes', 'Une plante verte a besoin d’eau, de sels minéraux, de dioxyde de carbone et de lumière pour bien se développer. Une carence en eau peut provoquer le flétrissement. Une carence en certains sels minéraux peut ralentir la croissance et modifier la couleur des feuilles. Les conditions de culture doivent donc être adaptées aux besoins de la plante.'],
      ['Actions néfastes de l’Homme sur l’environnement', 'Les activités humaines peuvent modifier fortement les milieux naturels. La déforestation, l’extraction des ressources, les rejets polluants et l’urbanisation peuvent détruire des habitats. Lorsque ces transformations dépassent les capacités de régénération du milieu, elles perturbent les équilibres écologiques.'],
      ['Pollution et conséquences', 'La pollution correspond à l’introduction de substances ou d’agents nuisibles dans l’environnement. Elle peut toucher l’air, l’eau et le sol. Ses conséquences comprennent la dégradation des habitats, la mortalité de certains organismes, la contamination des chaînes alimentaires et des risques pour la santé humaine.'],
      ['Protection de l’environnement', 'Protéger l’environnement consiste à limiter les sources de dégradation et à utiliser les ressources de manière responsable. Les actions possibles sont le tri et la réduction des déchets, le traitement des eaux usées, la protection des forêts, la réduction des émissions polluantes et l’éducation au respect de la nature.'],
      ['Dégradation des milieux naturels', 'Un milieu naturel comprend des êtres vivants et les éléments physiques de leur environnement. La disparition d’un habitat, l’érosion des sols, la pollution ou l’introduction d’espèces invasives peuvent réduire la diversité biologique. Une dégradation durable modifie les relations entre les organismes et les ressources disponibles.'],
      ['Solutions aux problèmes environnementaux', 'Les solutions environnementales combinent prévention, réduction et restauration. Il faut d’abord réduire les causes de pollution et de destruction, puis restaurer les milieux déjà dégradés. Les collectivités, les écoles, les entreprises et les citoyens ont tous un rôle à jouer dans la gestion des déchets et la protection des ressources.'],
      ['Biodiversité et équilibre des écosystèmes', 'La biodiversité désigne la diversité des êtres vivants, des espèces et des écosystèmes. Dans un écosystème, les organismes sont liés entre eux par des relations alimentaires et par leur dépendance aux conditions du milieu. La disparition d’une espèce peut modifier plusieurs relations et déséquilibrer l’ensemble du système.']
    ]
  },
  'espagnol-4e': {
    codePrefix: 'ESP-4e-',
    niveau: '4e',
    matiereId: 'espagnol',
    titres: [
      ['Saluer et se présenter', 'En espagnol, on peut saluer avec « Hola », « Buenos días », « Buenas tardes » ou « Buenas noches ». Pour se présenter, on utilise « Me llamo… », « Soy… » et « Tengo … años ». Pour demander le nom : « ¿Cómo te llamas? ». Il faut distinguer les pronoms et adapter la formule au contexte.'],
      ['La famille et les amis', 'Le vocabulaire de la famille comprend padre, madre, hermano, hermana, abuelo, abuela et otros miembros. Pour présenter quelqu’un, on peut dire « Este es mi hermano » ou « Esta es mi madre ». Les possessifs mi, tu, su indiquent la relation. On travaille aussi la description avec ser : « Mi amigo es simpático ».'],
      ['L’école et les activités', 'À l’école, on utilise palabras comme profesor, alumno, aula, libro, cuaderno et asignatura. Pour parler de l’emploi du temps, on peut utiliser « tengo matemáticas », « estudio francés » ou « me gusta el español ». Les verbes réguliers en -ar, -er et -ir suivent des modèles de conjugaison au présent.'],
      ['La vie quotidienne', 'Pour raconter sa journée, on emploie des verbes comme levantarse, desayunar, ir, estudiar, comer et dormir. Les expressions « por la mañana », « por la tarde » et « por la noche » organisent le récit. Les verbes pronominaux se construisent avec me, te, se, nos, os, se.'],
      ['La maison et la ville', 'La maison peut être décrite avec habitación, cocina, salón, dormitorio et baño. Pour situer un lieu, on utilise « delante de », « detrás de », « al lado de », « cerca de » et « lejos de ». En ville, on trouve la escuela, el mercado, la estación et el hospital.'],
      ['Les loisirs et les goûts', 'Pour exprimer ses goûts, on utilise « me gusta » pour une activité ou un nom singulier et « me gustan » avec un pluriel. Exemples : « Me gusta leer », « Me gustan los deportes ». Pour parler des loisirs, on rencontre jugar, escuchar música, bailar, nadar et ver películas.'],
      ['Voyages et découvertes', 'Parler d’un voyage demande du vocabulaire sur les transports, les lieux et les activités : avión, tren, autobús, hotel, playa, museo. Les expressions « quiero visitar », « voy a viajar » et « me gustaría conocer » permettent d’exprimer un projet ou un souhait.'],
      ['Exprimer une opinion et communiquer', 'Pour donner son avis, on peut dire « pienso que », « creo que », « en mi opinión » ou « me parece que ». Pour être d’accord : « estoy de acuerdo ». Pour exprimer un désaccord, on peut dire « no estoy de acuerdo ». Une opinion doit être accompagnée d’une justification simple : « porque… ».']
    ]
  }
};

async function trouverOuCreerChapitre(programme, index, titre) {
  const code = programme.codePrefix + String(index + 1).padStart(2, '0');
  const q = await db.collection('ca_chapitres').where('code', '==', code).limit(1).get();
  if (!q.empty) {
    await q.docs[0].ref.update({
      niveau: programme.niveau,
      matiereId: programme.matiereId,
      anneeScolaire: '2026-2027',
      actif: true,
      ressourceNationale: true
    });
    return q.docs[0];
  }

  const ref = db.collection('ca_chapitres').doc(
    programme.niveau + '_' + programme.matiereId + '_prioritaire_ch' +
    String(index + 1).padStart(2, '0')
  );
  await ref.set({
    code,
    niveau: programme.niveau,
    matiereId: programme.matiereId,
    anneeScolaire: '2026-2027',
    programmeVersion: 'DPFC 2026-2027',
    serie: '',
    theme: titre,
    titre,
    description: 'Cours pédagogique national Sentinel CI — chapitre enrichi.',
    ordre: index + 1,
    actif: true,
    ressourceNationale: true,
    sourceOfficielle: 'Sentinel CI — base pédagogique 2026-2027',
    dateMaj: FieldValue.serverTimestamp()
  });
  return await ref.get();
}

function normaliserType(value) {
  const v = String(value || '').toLowerCase();
  if (v === 'exercices') return 'exercice';
  if (v === 'revision') return 'fiche';
  return v;
}

function contenuExercice(titre, niveau, matiereId) {
  if (matiereId === 'pc') {
    return {
      enonce: 'Explique la notion étudiée dans « ' + titre + ' » puis donne un exemple concret.',
      solution: 'La réponse doit reprendre la définition, les éléments essentiels et un exemple correctement expliqué.'
    };
  }
  if (matiereId === 'svt') {
    return {
      enonce: 'Présente deux éléments essentiels du chapitre « ' + titre + ' » et explique leur rôle.',
      solution: 'Il faut identifier deux éléments pertinents puis expliquer leur rôle avec le vocabulaire scientifique du chapitre.'
    };
  }
  if (matiereId === 'espagnol') {
    return {
      enonce: 'Écris cinq phrases simples en espagnol en réutilisant le vocabulaire du chapitre « ' + titre + ' ». ',
      solution: 'La production doit comporter cinq phrases compréhensibles, avec un vocabulaire adapté et des verbes correctement conjugués.'
    };
  }
  return {
    enonce: 'Rédige un court paragraphe de cinq à huit lignes en utilisant correctement la notion « ' + titre + ' ». ',
    solution: 'La production doit respecter la consigne, employer le vocabulaire étudié et comporter des phrases correctement construites.'
  };
}

async function enrichir(programme) {
  let chapitres = 0, ressources = 0;
  for (let i = 0; i < programme.titres.length; i++) {
    const [titre, cours] = programme.titres[i];
    const ch = await trouverOuCreerChapitre(programme, i, titre);
    if (!ch) {
      console.log('Chapitre introuvable:', programme.matiereId, programme.niveau, i + 1);
      continue;
    }
    chapitres++;

    const rs = await db.collection('ca_ressources').where('chapitreId', '==', ch.id).limit(50).get();
    const parType = {};
    for (const d of rs.docs) {
      const t = normaliserType(d.data().type);
      if (!parType[t]) parType[t] = d;
    }

    const ex = contenuExercice(titre, programme.niveau, programme.matiereId);
    const contenus = {
      cours: {
        titre: 'Cours complet — ' + titre,
        contenu: '# ' + titre + '\n\n## Objectif\nComprendre ' + titre.toLowerCase() + ' et savoir réutiliser la notion dans une situation simple.\n\n## Cours\n' + cours + '\n\n## Vocabulaire essentiel\nRetenir les mots et expressions spécifiques au chapitre.\n\n## Méthode\n1. Lire attentivement la situation.\n2. Repérer les informations utiles.\n3. Utiliser la notion étudiée.\n4. Vérifier que la réponse correspond bien à la question.\n\n## À retenir\nLa notion du chapitre doit pouvoir être expliquée avec ses mots-clés et illustrée par au moins un exemple.'
      },
      renforcement: {
        titre: 'Explication renforcée — ' + titre,
        contenu: '## Comprendre autrement\n\n' + cours + '\n\n### Petit exercice mental\nExplique cette notion à un camarade en trois phrases. Puis donne un exemple tiré de la vie quotidienne ou d’une situation scolaire.'
      },
      fiche: {
        titre: 'Fiche de révision — ' + titre,
        contenu: '# Fiche de révision\n\n## Définition et idée centrale\n' + cours + '\n\n## Mots-clés\nNotion — définition — exemple — méthode.\n\n## Réflexe à avoir\nToujours identifier la notion étudiée avant de répondre.'
      },
      exercice: {
        titre: 'Exercices corrigés — ' + titre,
        enonce: ex.enonce,
        solution: ex.solution,
        contenu: 'Travail d’application guidé sur « ' + titre + ' ».'
      },
      quiz: {
        titre: 'Quiz — ' + titre,
        questions: [
          {id:'q1',type:'qcm',enonce:'La définition et les notions essentielles du chapitre sont-elles à connaître ?',choix:['Oui','Non'],bonnesReponses:[0],reponseAttendue:'',explication:'Oui : elles permettent de comprendre et d’appliquer le cours.',points:1},
          {id:'q2',type:'qcm',enonce:'Une bonne réponse doit-elle être vérifiée ?',choix:['Oui','Non'],bonnesReponses:[0],reponseAttendue:'',explication:'Oui : la vérification permet de repérer les erreurs.',points:1}
        ],
        dureeMinutes: 5
      }
    };

    for (const type of ['cours','renforcement','fiche','exercice','quiz']) {
      let d = parType[type];
      if (!d) {
        const legacy = type === 'exercice' ? parType['exercices'] : type === 'fiche' ? parType['revision'] : null;
        d = legacy;
      }
      const data = contenus[type];
      if (d) {
        const updates = {
          type,
          titre: data.titre,
          niveau: programme.niveau,
          matiereId: programme.matiereId,
          ecoleId: '',
          actif: true,
          ressourceNationale: true,
          dateMaj: FieldValue.serverTimestamp()
        };
        if (data.contenu !== undefined) updates.contenu = data.contenu;
        if (data.enonce !== undefined) updates.enonce = data.enonce;
        if (data.solution !== undefined) updates.solution = data.solution;
        if (data.questions !== undefined) updates.questions = data.questions;
        if (data.dureeMinutes !== undefined) updates.dureeMinutes = data.dureeMinutes;
        await d.ref.update(updates);
        ressources++;
      }
    }
  }
  console.log(programme.matiereId, programme.niveau, {chapitres, ressources});
}

(async () => {
  for (const p of Object.values(programmes)) await enrichir(p);
  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    anneeScolaire: '2026-2027',
    dateMaj: FieldValue.serverTimestamp()
  }, { merge: true });
  console.log('ENRICHISSEMENT TERMINE');
})().catch(e => { console.error(e); process.exit(1); });

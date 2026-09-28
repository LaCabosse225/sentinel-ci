const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const programmes = {
  math: {
    nom: 'Mathematiques',
    niveaux: {
      '2nde': ['Ensembles de nombres et calcul numérique','Dénombrement','Calcul littéral','Équations et inéquations','Généralités sur les fonctions','Fonctions usuelles','Statistique','Systèmes d’équations linéaires'],
      '1ere': ['Équations et inéquations','Dénombrement et combinatoire','Fonctions et variations','Dérivation','Suites numériques','Limites et continuité','Probabilités','Statistique'],
      'Tle': ['Limites et continuité','Dérivation et étude de fonctions','Primitives et intégrales','Fonction logarithme','Fonction exponentielle','Suites numériques','Probabilités et variables aléatoires','Statistique à deux variables','Nombres complexes','Équations différentielles']
    }
  },
  pc: {
    nom: 'Physique-Chimie',
    niveaux: {
      '2nde': ['Matière et espèces chimiques','Quantité de matière et grandeurs physiques','Transformations chimiques','Solutions et concentrations','Mouvement et vitesse','Forces et interactions','Énergie et puissance','Électricité'],
      '1ere': ['Avancement et transformations chimiques','Acides et bases','Oxydoréduction','Cinématique','Dynamique et lois de Newton','Travail et énergie','Électricité et circuits','Ondes et signaux'],
      'Tle': ['Cinématique et dynamique','Travail et énergie mécanique','Électricité en régime continu','Dipôles et lois électriques','Ondes mécaniques','Optique géométrique','Transformations chimiques et équilibres','Réactions acide-base et oxydoréduction','Radioactivité','Énergie et applications']
    }
  },
  svt: {
    nom: 'SVT',
    niveaux: {
      '2nde': ['Organisation de la cellule','Métabolisme et échanges','Nutrition des organismes','Reproduction','Biodiversité et évolution','Géologie externe','Ressources et environnement','Santé et prévention'],
      '1ere': ['Communication nerveuse','Immunité','Reproduction humaine','Génétique et hérédité','Métabolisme cellulaire','Évolution','Géodynamique interne','Risques et environnement'],
      'Tle': ['Génétique et transmission des caractères','Expression de l’information génétique','Immunité et défense de l’organisme','Reproduction et régulation','Évolution et biodiversité','Dynamique des écosystèmes','Géologie et histoire de la Terre','Ressources naturelles et développement durable']
    }
  },
  franc: {
    nom: 'Francais',
    niveaux: {
      '2nde': ['Argumentation et persuasion','Narration et point de vue','Description et portrait','Poésie et figures de style','Théâtre et dialogue','Grammaire et organisation du texte','Écriture et réécriture','Lecture méthodique'],
      '1ere': ['Roman et récit','Poésie','Théâtre','Argumentation','Littérature francophone','Analyse de texte','Dissertation et commentaire','Culture littéraire'],
      'Tle': ['Littérature et enjeux sociaux','Poésie et modernité','Roman et récit','Théâtre','Argumentation et essai','Méthodologie du commentaire','Méthodologie de la dissertation','Préparation aux épreuves de français']
    }
  },
  angl: {
    nom: 'Anglais',
    niveaux: {
      '2nde': ['Identity and relationships','Education and school life','Health and lifestyle','Travel and tourism','Environment','Technology and communication','Culture and traditions','Giving opinions'],
      '1ere': ['Personal identity and society','Education and careers','Health and well-being','Travel and global exchanges','Environment and climate','Science and technology','Media and communication','Citizenship'],
      'Tle': ['Globalization and society','Education and employment','Environment and sustainable development','Science and innovation','Media and information','Culture and diversity','Citizenship and human rights','Revision and exam preparation']
    }
  },
  hg: {
    nom: 'Histoire-Geographie',
    niveaux: {
      '2nde': ['Peuples et États de l’Afrique','Colonisation et transformations','Économie et sociétés africaines','Population et dynamiques territoriales','Milieux et ressources','Urbanisation','Agriculture et développement','Côte d’Ivoire : territoire et économie'],
      '1ere': ['Première Guerre mondiale','Crises et transformations du XXe siècle','Seconde Guerre mondiale','Décolonisation','Indépendances africaines','Population et développement','Espaces économiques','Côte d’Ivoire contemporaine'],
      'Tle': ['Relations internationales','Organisation du monde contemporain','Afrique et mondialisation','Institutions et coopération internationale','Population et enjeux territoriaux','Économie et développement','Environnement et changements globaux','Côte d’Ivoire dans le monde']
    }
  },
  philo: {
    nom: 'Philosophie',
    niveaux: {
      '2nde': ['Découvrir la réflexion philosophique','La conscience','La liberté','La vérité','La raison','Le bonheur','La société','Le devoir'],
      '1ere': ['L’homme et la conscience','Liberté et responsabilité','Vérité et connaissance','Justice et droit','Travail et technique','Art et culture','Société et politique','Bonheur et désir'],
      'Tle': ['Méthode de dissertation philosophique','Conscience et inconscient','Liberté et déterminisme','Vérité et connaissance','Justice et droit','État et politique','Travail et technique','Art et culture','Religion et existence','Bonheur et désir']
    }
  },
  eps: {
    nom: 'EPS',
    niveaux: {
      '2nde': ['Condition physique et santé','Athlétisme','Sports collectifs','Gymnastique','Activités d’expression','Sécurité et prévention','Règlementation et arbitrage','Projet sportif'],
      '1ere': ['Endurance et gestion de l’effort','Athlétisme approfondi','Sports collectifs et stratégies','Gymnastique et coordination','Activités physiques artistiques','Préparation physique','Santé et récupération','Projet sportif'],
      'Tle': ['Performance et préparation physique','Athlétisme et optimisation','Sports collectifs et stratégie','Condition physique et santé','Gestion de l’effort','Récupération et prévention des blessures','Fair-play et responsabilité','Évaluation et projet sportif']
    }
  },
  info: {
    nom: 'Informatique',
    niveaux: {
      '2nde': ['Culture numérique','Système et matériel','Fichiers et données','Traitement de texte avancé','Tableur et calcul','Présentation numérique','Internet et recherche','Sécurité numérique'],
      '1ere': ['Algorithmique','Variables et structures de données','Programmation','Bases de données','Réseaux et Internet','Traitement de données','Projet numérique','Citoyenneté numérique'],
      'Tle': ['Algorithmique avancée','Programmation et résolution de problèmes','Structures de données','Bases de données','Réseaux et protocoles','Sécurité informatique','Projet de développement','Éthique et société numérique']
    }
  },
  ecm: {
    nom: 'Education civique et morale',
    niveaux: {
      '2nde': ['Citoyenneté et valeurs','Droits et libertés','Institutions','Paix et cohésion sociale','Responsabilité','Environnement','Économie et solidarité','Citoyenneté numérique'],
      '1ere': ['Droits humains','Démocratie et institutions','État de droit','Paix et prévention des conflits','Citoyenneté et engagement','Développement durable','Solidarité','Médias et information'],
      'Tle': ['Citoyenneté responsable','Droits humains et libertés','Institutions de la République','Paix et cohésion sociale','Éthique et responsabilité','Développement durable','Engagement citoyen','Citoyenneté numérique']
    }
  }
};

const descriptions = {
  math: 'Leçon de mathématiques : définition des notions, propriétés, méthode de résolution et applications progressives adaptées au lycée.',
  pc: 'Leçon de physique-chimie : phénomènes observables, grandeurs et relations, raisonnement scientifique, méthodes et applications.',
  svt: 'Leçon de SVT : observations, notions biologiques ou géologiques, mécanismes, vocabulaire scientifique et démarche d’investigation.',
  franc: 'Leçon de français : notions littéraires ou linguistiques, lecture, analyse, méthode et expression écrite.',
  angl: 'English lesson: key language, vocabulary, grammar, communication patterns and guided practice.',
  hg: 'Leçon d’histoire-géographie : repères, notions, acteurs, relations de cause à conséquence, analyse de documents et méthode.',
  philo: 'Leçon de philosophie : définition des notions, problématique, distinctions conceptuelles, arguments, exemples et préparation à la réflexion.',
  eps: 'Leçon d’EPS : objectifs, sécurité, technique, règles, préparation, récupération et mise en pratique.',
  info: 'Leçon d’informatique : concepts, vocabulaire technique, méthode, exemples et applications numériques.',
  ecm: 'Leçon d’éducation civique : valeurs, droits, devoirs, institutions, situations concrètes et comportement responsable.'
};

const types = [
  ['cours','Cours'],
  ['exercice','Exercices'],
  ['renforcement','Renforcement'],
  ['quiz','Quiz'],
  ['fiche','Fiche de révision']
];

function construireCours(matiereId, niveau, titre) {
  const intro = descriptions[matiereId];
  const section = matiereId === 'angl'
    ? '### Language focus\nIdentify the key vocabulary and structures, then reuse them in short sentences and a real-life situation.'
    : '### Comprendre la notion\n' + intro;
  const method = matiereId === 'math'
    ? '1. Identifier les données.\n2. Choisir la propriété ou la formule adaptée.\n3. Effectuer les calculs avec rigueur.\n4. Vérifier le résultat.'
    : matiereId === 'hg'
      ? '1. Situer le sujet dans le temps ou l’espace.\n2. Identifier les acteurs et les faits.\n3. Relier causes, événements et conséquences.\n4. Justifier à partir des documents.'
      : matiereId === 'philo'
        ? '1. Définir les termes du sujet.\n2. Faire apparaître le problème.\n3. Construire des arguments.\n4. Illustrer et discuter les limites.\n5. Conclure clairement.'
        : '1. Lire attentivement le sujet.\n2. Repérer les notions importantes.\n3. Mobiliser le cours.\n4. Construire une réponse organisée.\n5. Vérifier la cohérence et la précision.';
  return '# ' + titre + '\n\n## Niveau ' + niveau + '\n\n## Objectif\nMaîtriser les notions essentielles du chapitre et savoir les mobiliser dans une situation scolaire.\n\n## Cours\n' + intro + '\n\n## Développement\nLe chapitre « ' + titre + ' » doit être étudié progressivement : observation ou question de départ, définition des notions, explication des relations entre les éléments, puis application. L’élève doit pouvoir reformuler la notion avec ses propres mots et reconnaître une situation où elle s’applique.\n\n' + section + '\n\n## Méthode\n' + method + '\n\n## Exemple guidé\nPrends une situation concrète liée à « ' + titre + ' ». Commence par identifier ce qui est demandé, relève les informations utiles, applique la notion du cours et termine par une conclusion rédigée.\n\n## À retenir\nRetenir les définitions, les mots-clés, les propriétés ou règles essentielles et la méthode d’application. Le cours sera enrichi ultérieurement avec des exemples détaillés, schémas, exercices gradués et activités.';
}

async function seedMatiere(matiereId, config) {
  let chapitres = 0, ressources = 0;
  for (const niveau of ['2nde','1ere','Tle']) {
    const titres = config.niveaux[niveau];
    for (let i = 0; i < titres.length; i++) {
      const titre = titres[i];
      const code = 'LYCEE-' + matiereId.toUpperCase() + '-' + niveau + '-' + String(i + 1).padStart(2,'0');
      const q = await db.collection('ca_chapitres').where('code','==',code).limit(1).get();
      let chapitreId;
      if (q.empty) {
        const ref = db.collection('ca_chapitres').doc();
        chapitreId = ref.id;
        await ref.set({
          code, niveau, matiereId, anneeScolaire:'2026-2027',
          programmeVersion:'DPFC 2026-2027', serie:'', theme:titre, titre,
          description:'Socle pédagogique national Sentinel CI — second cycle.',
          ordre:i+1, actif:true, ressourceNationale:true,
          sourceOfficielle:'DPFC — progression 2026-2027',
          dateMaj:FieldValue.serverTimestamp()
        });
        chapitres++;
      } else {
        chapitreId=q.docs[0].id;
        await q.docs[0].ref.update({niveau,matiereId,anneeScolaire:'2026-2027',actif:true,ressourceNationale:true});
      }

      const contenu = construireCours(matiereId,niveau,titre);
      const docs = [
        {type:'cours',titre:'Cours complet — '+titre,contenu,dureeMinutes:35},
        {type:'exercice',titre:'Exercices — '+titre,contenu:'Application guidée sur « '+titre+' ».\n\nConsigne : explique, applique la méthode du chapitre et rédige une réponse complète.',enonce:'Traite une situation d’application sur « '+titre+' » en justifiant chaque étape.',solution:'La correction doit rappeler la notion utilisée, présenter les étapes de résolution et conclure clairement.',dureeMinutes:25},
        {type:'renforcement',titre:'Renforcement — '+titre,contenu:'Reformule « '+titre+' » avec tes propres mots, donne un exemple et indique l’erreur à éviter.',dureeMinutes:20},
        {type:'quiz',titre:'Quiz — '+titre,questions:[
          {id:'q1',type:'qcm',enonce:'Les définitions et notions essentielles du chapitre doivent-elles être maîtrisées ?',choix:['Oui','Non'],bonnesReponses:[0],explication:'Oui : elles permettent de comprendre et d’appliquer le chapitre.',points:1},
          {id:'q2',type:'qcm',enonce:'Une réponse correctement rédigée doit-elle être vérifiée ?',choix:['Oui','Non'],bonnesReponses:[0],explication:'Oui : la vérification permet de corriger les erreurs.',points:1},
          {id:'q3',type:'qcm',enonce:'Faut-il justifier une démarche quand le sujet le demande ?',choix:['Oui','Non'],bonnesReponses:[0],explication:'Oui : la justification fait partie de la qualité du raisonnement.',points:1}
        ],dureeMinutes:8},
        {type:'fiche',titre:'Fiche de révision — '+titre,contenu:'# '+titre+'\n\nMots-clés : définitions, notions, méthode et exemple.\n\nRéflexe : être capable d’expliquer le chapitre sans lire le cours.',dureeMinutes:15}
      ];

      const existants = await db.collection('ca_ressources').where('chapitreId','==',chapitreId).limit(50).get();
      const typesExistants = new Set(existants.docs.map(d=>String(d.data().type)));
      for (const r of docs) {
        const ref = typesExistants.has(r.type)
          ? existants.docs.find(d=>String(d.data().type)===r.type).ref
          : db.collection('ca_ressources').doc(chapitreId+'_lycee_'+r.type);
        const snap = await ref.get();
        const data = {
          type:r.type,titre:r.titre,ordre:docs.indexOf(r)+1,chapitreId,niveau,matiereId,
          ecoleId:'',contenu:r.contenu||'',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',
          enonce:r.enonce||'',solution:r.solution||'',difficulte:r.type==='quiz'?2:1,
          ressourceLieeId:'',questions:r.questions||[],dureeMinutes:r.dureeMinutes||20,
          examen:'',annee:2026,serie:'',actif:true,ressourceNationale:true,
          auteur:'Sentinel CI',dateCreation:snap.exists?(snap.data().dateCreation||FieldValue.serverTimestamp()):FieldValue.serverTimestamp(),
          dateMaj:FieldValue.serverTimestamp()
        };
        if (snap.exists) await ref.update(data); else await ref.set(data);
        ressources++;
      }
    }
  }
  return {chapitres,ressources};
}

(async()=>{
  const bilan={};
  for(const [id,config] of Object.entries(programmes)) bilan[id]=await seedMatiere(id,config);
  await db.collection('ca_parametres').doc('version').set({
    version:FieldValue.increment(1),anneeScolaire:'2026-2027',dateMaj:FieldValue.serverTimestamp()
  },{merge:true});
  console.log(JSON.stringify({ok:true,bilan},null,2));
  process.exit(0);
})().catch(e=>{console.error(e);process.exit(1);});

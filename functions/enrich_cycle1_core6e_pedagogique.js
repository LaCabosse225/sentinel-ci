const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const SUBJECTS = ['franc', 'pc', 'svt'];

const CORE = {
  franc: {
    base: 'Le Français développe la compréhension, l’expression orale et écrite, la lecture et la maîtrise de la langue. L’élève doit apprendre à observer un texte, identifier les indices utiles, mobiliser une notion puis justifier sa réponse.',
    facts(title) {
      const t = title.toLowerCase();
      const M = {
        'dialogue oral': ['Un dialogue met en relation des interlocuteurs dans une situation précise. Chacun doit écouter, respecter les tours de parole, formuler une question ou une réponse claire et adapter son niveau de langue. Les marques de ponctuation et les verbes de parole permettent de restituer l’échange.', 'Dans une demande de renseignement, « Bonjour, pouvez-vous m’indiquer la salle ? » est plus adapté qu’une formulation trop familière.', 'Identifier les interlocuteurs, le but de l’échange, le registre de langue et les informations à transmettre.'],
        'expression écrite': ['Une expression écrite réussie répond exactement à la consigne. Il faut chercher les idées, les classer, construire des paragraphes cohérents puis relire le texte. La relecture porte sur le sens, les répétitions, les accords, les temps verbaux et la ponctuation.', 'Pour raconter une sortie scolaire, organiser les idées dans l’ordre : départ, activités, événement marquant, retour et bilan.', 'Comprendre la consigne → chercher les idées → les organiser → rédiger → relire et corriger.'],
        'récit': ['Un récit raconte des événements organisés dans le temps. On peut distinguer situation initiale, élément déclencheur, péripéties et situation finale. Les connecteurs chronologiques et les verbes permettent au lecteur de suivre l’action.', '« Il faisait nuit quand Awa a entendu un bruit. » L’imparfait installe le cadre et le passé composé marque l’événement.', 'Repérer le cadre, ordonner les événements, choisir les temps adaptés et utiliser des connecteurs comme d’abord, ensuite, puis, enfin.'],
        'description': ['Décrire consiste à donner au lecteur une représentation précise d’une personne, d’un lieu, d’un objet ou d’une scène. On va du général au particulier et on utilise adjectifs, groupes nominaux enrichis et repères spatiaux.', 'Pour décrire une cour, situer d’abord l’espace puis préciser les bâtiments, les arbres, les élèves, les couleurs et les positions.', 'Organiser l’espace → choisir des détails pertinents → utiliser un vocabulaire précis → relire pour vérifier les accords.'],
        'poésie': ['La poésie travaille les mots, les sons, les images et le rythme. Un vers est une ligne du poème et une strophe regroupe plusieurs vers. La comparaison rapproche deux éléments avec un outil comme « comme » ; la métaphore établit un rapprochement sans cet outil.', '« La lune brille comme une lampe » est une comparaison ; « La lune est une lampe » est une métaphore.', 'Observer la forme du poème, repérer les images et les sons, puis expliquer l’effet produit par les choix du poète.'],
        'théâtre': ['Le texte théâtral est destiné à être joué. Les répliques donnent les paroles des personnages et les didascalies indiquent parfois gestes, déplacements, ton ou décor. Pour comprendre une scène, il faut identifier qui parle, à qui, pourquoi et avec quelle intention.', '« PERSONNAGE A : Où vas-tu ? » puis « PERSONNAGE B : À la bibliothèque. » constitue un échange de répliques ; une indication entre parenthèses peut être une didascalie.', 'Repérer les personnages → lire les répliques → identifier les intentions → interpréter les didascalies → expliquer la scène.'],
        'nom et déterminant': ['Le nom désigne une personne, un animal, un objet, un lieu ou une idée. Le déterminant accompagne généralement le nom et permet notamment d’indiquer son genre et son nombre. Les articles définis sont le, la, les ; les articles indéfinis sont un, une, des.', 'Dans « les grandes maisons », « les » est le déterminant, « maisons » le nom et « grandes » l’adjectif.', 'Repérer le groupe nominal → identifier le déterminant et le nom → vérifier genre et nombre.'],
        'adjectif qualificatif': ['L’adjectif qualificatif précise une caractéristique du nom. Il s’accorde généralement avec lui en genre et en nombre. Il peut être placé avant ou après le nom selon la construction de la phrase.', 'Un petit garçon, une petite fille, des petits garçons, des petites filles : l’adjectif change pour s’accorder avec le nom.', 'Trouver le nom décrit → identifier l’adjectif → déterminer genre et nombre → effectuer l’accord.'],
        'verbe et sujet': ['Le sujet indique qui fait l’action ou de qui l’on parle. Le verbe exprime une action ou un état et s’accorde avec le sujet. Pour trouver le sujet, on peut poser « qui est-ce qui ? » devant le verbe.', 'Dans « Les élèves révisent », le sujet est « les élèves » et le verbe « révisent » est au pluriel.', 'Repérer le verbe → poser la question du sujet → vérifier le nombre → accorder le verbe.'],
        'temps du récit': ['Les temps verbaux organisent le récit. L’imparfait sert souvent à décrire, installer un cadre ou exprimer une habitude. Le passé composé exprime fréquemment une action achevée. Le présent peut être utilisé pour raconter une action actuelle ou rendre un récit plus vivant.', '« Il pleuvait lorsque les élèves sont sortis. » L’imparfait installe la situation et le passé composé marque l’action.', 'Repérer les verbes → identifier la valeur de chaque temps → vérifier la chronologie → conserver un système cohérent.'],
        'phrase complexe': ['Une phrase complexe comporte plusieurs verbes conjugués et donc plusieurs propositions. Les propositions peuvent être coordonnées ou reliées par des mots qui expriment une cause, un temps, une condition ou une autre relation.', '« Je reste à la maison parce qu’il pleut » contient deux propositions reliées par « parce que ».', 'Repérer les verbes conjugués → délimiter les propositions → identifier le mot de liaison → expliquer la relation.'],
        'vocabulaire': ['Le vocabulaire permet de choisir le mot juste. Un synonyme a un sens proche, un antonyme un sens contraire et les mots d’une même famille partagent une base commune. Le contexte aide à déterminer le sens d’un mot polysémique ou inconnu.', '« Commencer » et « débuter » sont synonymes ; « grand » et « petit » sont antonymes ; « chanter » et « chanteur » appartiennent à une même famille.', 'Observer le contexte → chercher les indices de sens → vérifier avec la famille de mots ou le dictionnaire.']
      };
      return M[t] || ['La notion est étudiée à partir de textes et de situations permettant de comprendre, appliquer et réutiliser les connaissances en français.', 'Un exemple concret permet d’observer la notion avant de la généraliser.', 'Lire la consigne → repérer les indices → mobiliser la notion → justifier → relire.'];
    }
  },
  pc: {
    base: 'La Physique-Chimie apprend à observer les phénomènes, réaliser des mesures, utiliser des modèles et expliquer les résultats avec un vocabulaire scientifique précis.',
    facts(title) {
      const t = title.toLowerCase();
      const M = {
        'circuit électrique': ['Un circuit électrique simple comprend un générateur, un récepteur et des conducteurs formant une boucle. Le courant peut circuler lorsque le circuit est fermé. Une pile fournit de l’énergie électrique et une lampe en transforme une partie en lumière et en chaleur.', 'Une pile reliée à une lampe par deux fils constitue une boucle fermée ; si un fil est débranché, la lampe ne fonctionne plus.', 'Identifier les composants → vérifier les connexions → déterminer si la boucle est fermée → représenter le montage avec les symboles.'],
        'commande d’un circuit': ['Un interrupteur permet de commander le fonctionnement d’un circuit en ouvrant ou en fermant la boucle électrique. Circuit fermé : le récepteur peut fonctionner. Circuit ouvert : le trajet du courant est interrompu.', 'Un interrupteur placé en série avec une lampe permet d’allumer ou d’éteindre la lampe sans débrancher les fils.', 'Identifier le récepteur → placer l’interrupteur dans le trajet du circuit → tester les deux états → expliquer le résultat.'],
        'court-circuit et protection': ['Un court-circuit relie directement des points du circuit par un chemin de très faible résistance. Le courant peut devenir très important et provoquer un échauffement. Les fusibles et disjoncteurs interrompent le circuit lorsqu’un courant dangereux apparaît.', 'Relier directement les bornes d’une pile avec un conducteur peut provoquer un échauffement important et endommager le générateur.', 'Identifier le trajet anormal → expliquer le risque → citer le dispositif de protection → appliquer les règles de sécurité.'],
        'propriétés des liquides': ['Un liquide possède un volume propre mais pas de forme propre. Il prend la forme du récipient qui le contient et sa surface libre est horizontale au repos. Son volume peut être mesuré avec une éprouvette graduée.', 'Une même quantité d’eau garde son volume lorsqu’elle passe d’un verre à un autre, mais elle change de forme.', 'Placer l’éprouvette sur une surface stable → lire correctement le niveau → noter l’unité → éviter les erreurs de lecture.'],
        'les gaz': ['Un gaz n’a ni forme ni volume propres. Il occupe l’espace disponible et peut être comprimé. L’air est un mélange de gaz et exerce une pression sur les parois du récipient.', 'L’air contenu dans une seringue bouchée peut être comprimé en poussant le piston, ce qui montre qu’un gaz peut voir son volume diminuer.', 'Identifier le récipient et le gaz → observer sa compressibilité → expliquer le comportement avec le modèle d’un gaz occupant l’espace disponible.'],
        'température': ['La température caractérise l’état thermique d’un corps. Elle se mesure avec un thermomètre, généralement en degrés Celsius. Il faut attendre la stabilisation de la mesure et éviter de confondre température et transfert de chaleur.', 'Une eau à 40 °C a une température supérieure à une eau à 20 °C ; cette comparaison ne dépend pas seulement de la quantité d’eau.', 'Choisir le thermomètre adapté → placer correctement le réservoir → attendre la stabilisation → lire et noter la valeur avec son unité.'],
        'changements d’état de l’eau': ['L’eau existe sous les états solide, liquide et gazeux. Fusion, solidification, vaporisation et liquéfaction sont des changements d’état. La substance reste de l’eau : c’est son état physique qui change.', 'La glace fond lors de la fusion ; la vapeur d’eau peut se liquéfier sur une surface froide.', 'Identifier l’état initial et final → nommer le changement d’état → vérifier que la substance reste la même.'],
        'constituants de l’air': ['L’air est un mélange de gaz. Il contient principalement du diazote et du dioxygène, ainsi que d’autres constituants en plus faible quantité. Le dioxygène intervient dans la respiration et les combustions.', 'Une bougie placée sous un récipient fermé finit par s’éteindre lorsque le dioxygène disponible devient insuffisant.', 'Distinguer mélange et corps pur → identifier le gaz recherché → relier l’observation à son rôle.'],
        'combustion d’un solide et d’un liquide': ['Une combustion est une transformation chimique entre un combustible et un comburant. Dans l’air, le dioxygène est un comburant courant. Une combustion libère généralement de l’énergie sous forme de chaleur et parfois de lumière.', 'Lorsqu’une bougie brûle, la cire joue le rôle de combustible et le dioxygène de l’air celui de comburant.', 'Identifier combustible et comburant → rechercher les produits si demandé → expliquer pourquoi la combustion cesse lorsque le dioxygène manque.'],
        'combustion d’un gaz': ['Un gaz combustible peut brûler dans le dioxygène de l’air. Une combustion complète d’un gaz comme le butane produit notamment du dioxyde de carbone et de l’eau. Une mauvaise arrivée d’air peut favoriser une combustion incomplète.', 'La flamme d’un appareil à gaz doit être surveillée et l’aération doit être suffisante pour limiter les risques liés aux combustions incomplètes.', 'Identifier le combustible → identifier le comburant → décrire les produits attendus → appliquer les règles de sécurité.'],
        'dangers des combustions': ['Les combustions peuvent provoquer incendies, brûlures et intoxications. Une combustion incomplète peut produire du monoxyde de carbone, gaz dangereux et difficilement détectable sans dispositif adapté. L’aération et l’entretien des appareils sont essentiels.', 'Un appareil à combustion utilisé dans une pièce mal ventilée peut présenter un risque d’intoxication au monoxyde de carbone.', 'Identifier le danger → rechercher la cause → proposer une prévention → connaître la conduite à tenir en cas de suspicion d’intoxication.'],
        'volume et masse': ['Le volume mesure l’espace occupé par un corps et peut s’exprimer en litre ou en millilitre pour les liquides. La masse mesure la quantité de matière et se mesure avec une balance, souvent en grammes ou kilogrammes.', 'Un litre correspond à 1000 millilitres. Une balance permet de mesurer la masse d’un solide ou d’un récipient contenant un liquide.', 'Choisir l’instrument adapté → lire correctement la mesure → écrire la valeur avec son unité → vérifier la cohérence du résultat.']
      };
      return M[t] || ['La notion est étudiée par l’observation, la mesure et l’interprétation de phénomènes physiques ou chimiques.', 'Une expérience simple permet de relier une observation à une explication scientifique.', 'Observer → mesurer si nécessaire → identifier la notion → expliquer → vérifier les unités et la sécurité.'];
    }
  },
  svt: {
    base: 'Les SVT permettent d’observer le vivant, d’identifier des relations entre structures et fonctions et de construire une explication à partir de faits, d’expériences ou de documents.',
    facts(title) {
      const t = title.toLowerCase();
      const M = {
        'reproduction chez les vertébrés': ['Chez les vertébrés, la reproduction permet la naissance de nouveaux individus. Elle fait généralement intervenir des individus mâle et femelle et des cellules reproductrices. Les modalités de fécondation et de développement varient selon les groupes.', 'Chez plusieurs mammifères, la fécondation est interne et le jeune se développe dans l’organisme maternel ; chez les oiseaux, le développement de l’embryon se déroule dans un œuf après la ponte.', 'Identifier le mode de reproduction → distinguer fécondation et développement → comparer les groupes sans généraliser à partir d’une seule espèce.'],
        'reproduction chez les plantes à fleurs': ['La fleur porte les organes reproducteurs de nombreuses plantes à fleurs. Les étamines produisent le pollen et le pistil contient notamment l’ovaire. La pollinisation permet le dépôt du pollen sur le stigmate ; la fécondation peut ensuite conduire à la formation de graines.', 'Le transport du pollen par le vent ou par un animal peut permettre la pollinisation d’une fleur.', 'Observer la fleur → identifier les organes → expliquer pollinisation et fécondation → relier la fécondation à la formation de la graine.'],
        'germination de la graine': ['La germination commence lorsqu’une graine viable reçoit des conditions favorables. L’eau permet la réhydratation, une température adaptée favorise l’activité biologique et le dioxygène est nécessaire. La radicule apparaît généralement en premier et les réserves nourrissent l’embryon au début.', 'Une expérience comparant des graines avec ou sans eau permet de montrer que l’eau est une condition de la germination.', 'Formuler une hypothèse → choisir un seul facteur à faire varier → observer → comparer → conclure avec des preuves.'],
        'nutrition chez les vertébrés': ['Les vertébrés se nourrissent pour obtenir de l’énergie et des matières nécessaires à la croissance et à l’entretien de l’organisme. Les aliments apportent notamment glucides, lipides, protéines, vitamines, sels minéraux et eau. Le régime alimentaire varie selon les espèces.', 'Un herbivore, un carnivore et un omnivore n’ont pas les mêmes aliments dominants, mais tous ont besoin de matières et d’énergie pour vivre.', 'Identifier les aliments → rechercher les besoins couverts → relier alimentation, croissance et fonctionnement de l’organisme.'],
        'nutrition chez les plantes à fleurs': ['Les plantes vertes fabriquent leur matière organique grâce à la photosynthèse. En présence de lumière, elles utilisent notamment l’eau et le dioxyde de carbone et libèrent du dioxygène. Les racines absorbent l’eau et les sels minéraux.', 'Une plante placée durablement dans l’obscurité ne présente pas le même fonctionnement qu’une plante éclairée, ce qui permet d’étudier le rôle de la lumière.', 'Identifier les matières premières et conditions → observer les résultats → relier racines, feuilles et lumière → conclure.'],
        'besoins nutritifs des plantes': ['Pour se développer, une plante verte a besoin notamment d’eau, de sels minéraux, de dioxyde de carbone et de lumière. Une carence peut ralentir la croissance ou modifier l’aspect de la plante.', 'Deux plantes de même espèce soumises à des conditions différentes peuvent présenter des croissances différentes.', 'Comparer les conditions expérimentales → repérer le facteur qui change → relier ce facteur à la croissance → éviter de conclure au-delà des observations.'],
        'actions néfastes de l’homme sur l’environnement': ['La déforestation, l’urbanisation, les rejets polluants, les feux de brousse ou la surexploitation des ressources peuvent modifier les milieux naturels. Ces actions peuvent détruire des habitats et perturber les équilibres écologiques.', 'La destruction d’une zone végétalisée peut réduire les habitats disponibles pour plusieurs espèces.', 'Identifier l’action humaine → décrire le changement du milieu → rechercher les conséquences → proposer une mesure de prévention.'],
        'pollution et conséquences': ['La pollution correspond à l’introduction d’agents ou de substances nuisibles dans un milieu. Elle peut toucher l’air, l’eau ou le sol et avoir des conséquences sur les organismes, les chaînes alimentaires et la santé humaine.', 'Le rejet d’eaux usées non traitées dans un cours d’eau peut modifier la qualité de l’eau et affecter les êtres vivants.', 'Identifier la source → préciser le milieu touché → décrire les conséquences → distinguer cause, effet et solution.'],
        'protection de l’environnement': ['Protéger l’environnement consiste à réduire les causes de dégradation, préserver les ressources et restaurer les milieux lorsque cela est nécessaire. Les actions concernent les citoyens, les écoles, les collectivités et les entreprises.', 'Réduire les déchets à la source, trier, traiter les eaux usées et protéger les forêts sont des exemples d’actions complémentaires.', 'Partir du problème → rechercher une cause → choisir une action réaliste → expliquer son effet attendu.'],
        'dégradation des milieux naturels': ['Un milieu naturel associe des êtres vivants et les éléments physiques qui les entourent. La disparition d’un habitat, l’érosion, la pollution ou certaines pratiques humaines peuvent réduire les ressources disponibles et la biodiversité.', 'La disparition d’une zone humide peut affecter les espèces qui utilisent cette zone pour se nourrir ou se reproduire.', 'Décrire le milieu initial → identifier la dégradation → relier la modification aux êtres vivants concernés.'],
        'solutions aux problèmes environnementaux': ['Une réponse environnementale efficace combine prévention, réduction des causes et restauration. Une solution doit être adaptée au problème, aux ressources disponibles et aux acteurs concernés.', 'Pour réduire les déchets, il faut agir à plusieurs niveaux : réduire la production, réutiliser, trier et organiser une collecte adaptée.', 'Définir le problème → identifier les causes → proposer plusieurs solutions → comparer leur faisabilité et leur effet.'],
        'biodiversité et équilibre des écosystèmes': ['La biodiversité désigne la diversité des êtres vivants et des écosystèmes. Dans un écosystème, les organismes entretiennent des relations entre eux et dépendent des conditions du milieu. Une modification importante d’une population peut avoir des conséquences en cascade.', 'La diminution d’un prédateur peut entraîner une augmentation de certaines proies et modifier la végétation : les relations alimentaires participent à l’équilibre de l’écosystème.', 'Identifier les êtres vivants et leurs relations → construire une chaîne ou un réseau alimentaire → prévoir une conséquence d’une perturbation.']
      };
      return M[t] || ['La notion est étudiée à partir d’observations du vivant, d’expériences ou de documents scientifiques.', 'Un document ou une expérience permet de formuler une explication fondée sur des faits.', 'Observer → relever les résultats → interpréter → conclure en s’appuyant sur les preuves.'];
    }
  }
};

function buildCourse(subject, level, title, facts) {
  const [notion, example, method] = facts;
  return '# ' + title + '\n\n## Niveau : ' + level + '\n\n## 1. Situation-problème\nÀ partir d’une situation concrète, l’élève doit comprendre « ' + title + ' », expliquer le phénomène ou la notion et être capable de réutiliser ses connaissances dans un exercice nouveau.\n\n## 2. Objectifs d’apprentissage\nÀ la fin du chapitre, l’élève doit pouvoir :\n- définir les notions essentielles ;\n- expliquer le phénomène ou le raisonnement ;\n- utiliser le vocabulaire scientifique ou linguistique adapté ;\n- traiter une situation d’application ;\n- justifier une réponse à partir des informations disponibles.\n\n## 3. Cours développé\n' + notion + '\n\n## 4. Exemple guidé\n' + example + '\n\n**Question :** que faut-il observer ou expliquer ?\n\n**Démarche :** repérer les informations utiles, mobiliser la notion du chapitre, construire le raisonnement puis formuler une conclusion claire.\n\n## 5. Méthode\n' + method + '\n\n## 6. Activité d’apprentissage\nReprends une situation de la vie quotidienne, du laboratoire ou de la classe en lien avec « ' + title + ' ». Note d’abord ce que tu observes, puis ce que tu cherches à expliquer. Utilise ensuite la méthode du chapitre et termine par une conclusion.\n\n## 7. Erreurs fréquentes\n- réciter une définition sans répondre à la question ;\n- confondre observation et explication ;\n- oublier une étape du raisonnement ;\n- employer un vocabulaire imprécis ;\n- négliger les unités ou les règles de sécurité lorsqu’elles sont nécessaires.\n\n## 8. Bilan\n' + subject.base + '\n\n**À retenir :** une bonne réponse associe connaissance, application et justification.'; 
}

function buildExercises(subject, title, facts) {
  const [notion, example, method] = facts;
  const domain = subject === CORE.pc ? 'scientifique' : subject === CORE.svt ? 'scientifique' : 'linguistique';
  return '# Exercices d’application — ' + title + '\n\n## Exercice 1 — Comprendre\nExplique avec tes propres mots la notion centrale du chapitre « ' + title + ' ». Donne deux mots-clés.\n\n### Correction\nLa réponse doit reprendre l’idée centrale : ' + notion + '\n\n## Exercice 2 — Application\nÀ partir de l’exemple suivant, explique ce que tu observes et ce que cela permet de conclure : ' + example + '\n\n### Correction\nIl faut partir de l’observation, mobiliser la notion puis formuler une conclusion. La démarche attendue est : ' + method + '\n\n## Exercice 3 — Raisonnement\nUn élève donne uniquement une réponse finale sans expliquer son raisonnement. Réécris sa réponse en ajoutant les étapes nécessaires et le vocabulaire du chapitre.\n\n### Correction\nUne réponse complète doit présenter les éléments utiles, le raisonnement et une conclusion. Elle ne doit pas juxtaposer des mots-clés sans lien logique.\n\n## Exercice 4 — Transfert\nImagine une situation nouvelle, différente de l’exemple du cours, dans laquelle « ' + title + ' » permet de comprendre ou de résoudre un problème.\n\n### Correction\nLa situation doit être différente mais la méthode doit rester identifiable. Vérifie que chaque étape est justifiée.\n\n## Méthode de correction\nPour chaque exercice : comprendre la consigne → repérer les données → choisir la notion → raisonner → conclure → relire.';
}

function buildReinforcement(subject, title, facts) {
  const [notion, example, method] = facts;
  return '# Renforcement — ' + title + '\n\n## Situation-problème\nUn élève connaît la leçon mais rencontre une difficulté lorsqu’il doit l’utiliser dans une situation nouvelle. Il doit reprendre le problème sans apprendre une réponse par cœur.\n\n## Travail demandé\n1. Reformule le problème.\n2. Relève les informations utiles.\n3. Identifie la notion du chapitre.\n4. Choisis une méthode.\n5. Réalise les étapes.\n6. Justifie la conclusion.\n\n## Correction détaillée\nLa notion centrale est : ' + notion + '\n\nL’exemple repère montre : ' + example + '\n\nLa méthode correcte est : ' + method + '\n\n## Remédiation\nSi tu bloques, commence par écrire trois mots-clés du chapitre puis explique chacun avec une phrase. Reprends ensuite la situation.\n\n## Défi\nExplique le chapitre à un camarade en trois minutes sans lire le cours, puis invente une question qu’il doit résoudre.';
}

function buildQuiz(subject, title) {
  const questions = [
    {e:'Le chapitre « '+title+' » doit-il être compris puis réutilisé dans une situation nouvelle ?', c:['Oui','Non'], b:0, x:'Oui. La maîtrise d’une notion ne se limite pas à sa mémorisation.'},
    {e:'Une réponse complète doit-elle comporter une justification lorsque le raisonnement est demandé ?', c:['Oui','Non'], b:0, x:'Oui. La justification permet de rendre le raisonnement vérifiable.'},
    {e:'Faut-il repérer les informations utiles avant de choisir une méthode ?', c:['Oui','Non'], b:0, x:'Oui. Les données pertinentes orientent le raisonnement.'},
    {e:'Peut-on confondre une observation avec l’explication du phénomène ?', c:['Oui','Non'], b:1, x:'Non. Une observation décrit un fait ; une explication lui donne un sens en mobilisant des connaissances.'},
    {e:'Faut-il vérifier que la conclusion répond exactement à la consigne ?', c:['Oui','Non'], b:0, x:'Oui. Une conclusion doit répondre à la question posée.'},
    {e:'Le vocabulaire propre à « '+title+' » est-il important pour communiquer une réponse précise ?', c:['Oui','Non'], b:0, x:'Oui. Le vocabulaire précis permet d’exprimer correctement les notions étudiées.'}
  ];
  return questions.map((q,i)=>({id:'q'+(i+1),type:'qcm',enonce:q.e,choix:q.c,bonnesReponses:[q.b],reponseAttendue:'',explication:q.x,points:1}));
}

function buildRevision(title, facts) {
  const [notion, example, method] = facts;
  return '# Fiche de révision — ' + title + '\n\n## Idée centrale\n' + notion + '\n\n## Exemple repère\n' + example + '\n\n## Méthode express\n' + method + '\n\n## Mots-clés\nNotion — observation — explication — application — justification — conclusion.\n\n## Je dois savoir\n☐ définir la notion ;\n☐ expliquer avec mes mots ;\n☐ traiter un exercice ;\n☐ justifier ma réponse ;\n☐ transférer la méthode à une situation nouvelle.\n\n## Auto-évaluation\nSi je peux expliquer le chapitre sans regarder le cours et résoudre une situation différente de l’exemple, le chapitre est compris.';
}

async function upsertResource(chapitre, type, data, ordre) {
  const q = await db.collection('ca_ressources')
    .where('chapitreId', '==', chapitre.id)
    .where('type', '==', type)
    .limit(1).get();

  const payload = {
    type,
    titre: data.titre,
    ordre,
    chapitreId: chapitre.id,
    niveau: chapitre.niveau,
    matiereId: chapitre.matiereId,
    ecoleId: '',
    contenu: data.contenu || '',
    imagesUrls: [],
    pdfUrl: '',
    videoYoutubeId: '',
    enonce: data.enonce || '',
    solution: data.solution || '',
    difficulte: type === 'quiz' ? 2 : 1,
    ressourceLieeId: '',
    questions: data.questions || [],
    dureeMinutes: type === 'cours' ? 30 : type === 'quiz' ? 10 : 20,
    examen: '',
    annee: 2026,
    serie: '',
    actif: true,
    ressourceNationale: true,
    auteur: 'Sentinel CI — contenu pédagogique 6e',
    dateMaj: FieldValue.serverTimestamp()
  };

  if (!q.empty) {
    const existing = q.docs[0].data();
    payload.dateCreation = existing.dateCreation || FieldValue.serverTimestamp();
    await q.docs[0].ref.set(payload, { merge: true });
  } else {
    payload.dateCreation = FieldValue.serverTimestamp();
    await db.collection('ca_ressources').add(payload);
  }
}

async function main() {
  let chapters = 0;
  let resources = 0;

  const snap = await db.collection('ca_chapitres')
    .where('anneeScolaire', '==', '2026-2027')
    .where('niveau', '==', '6e')
    .limit(1000).get();

  for (const d of snap.docs) {
    const chapitre = { id: d.id, ...d.data() };
    const subject = CORE[chapitre.matiereId];
    if (!subject) continue;

    const title = String(chapitre.titre || '').trim();
    const facts = subject.facts(title);
    const resourcesData = [
      ['cours', {titre:'Cours complet — '+title, contenu:buildCourse(subject, chapitre.niveau, title, facts)}],
      ['exercices', {titre:'Exercices et corrections — '+title, contenu:buildExercises(subject, title, facts)}],
      ['renforcement', {titre:'Renforcement — '+title, contenu:buildReinforcement(subject, title, facts)}],
      ['quiz', {titre:'QCM — '+title, contenu:'QCM de consolidation des acquis.', questions:buildQuiz(subject, title)}],
      ['revision', {titre:'Fiche de révision — '+title, contenu:buildRevision(title, facts)}]
    ];

    for (let i=0;i<resourcesData.length;i++) {
      await upsertResource(chapitre, resourcesData[i][0], resourcesData[i][1], i+1);
      resources++;
    }

    await d.ref.update({
      description: 'Chapitre enrichi avec cours développé, exercices corrigés, renforcement, QCM et fiche de révision.',
      matiereId: chapitre.matiereId,
      dateMaj: FieldValue.serverTimestamp()
    });
    chapters++;
  }

  await db.collection('ca_parametres').doc('version').set({
    version: FieldValue.increment(1),
    dateMaj: FieldValue.serverTimestamp()
  }, { merge: true });

  console.log(JSON.stringify({ok:true, chapters, resources}, null, 2));
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});

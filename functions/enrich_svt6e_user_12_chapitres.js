const {initializeApp,applicationDefault}=require('firebase-admin/app');
const {getFirestore,FieldValue}=require('firebase-admin/firestore');
initializeApp({credential:applicationDefault(),projectId:'sentinel-ci-c7592'});
const db=getFirestore();

const CH=[
{n:1,t:'Reproduction chez les vertébrés',course:`## Objectifs
Comprendre la reproduction, distinguer reproduction sexuée et naissance, reconnaître les appareils reproducteurs, distinguer fécondation interne et externe et différencier ovipares et vivipares.

## Cours
La **reproduction** permet aux êtres vivants de donner naissance à de nouveaux individus de la même espèce et contribue au maintien des espèces.
Chez les vertébrés, l'appareil reproducteur mâle produit les **spermatozoïdes** et l'appareil reproducteur femelle les **ovules**. Ce sont des gamètes.
La **fécondation** est la rencontre et l'union d'un spermatozoïde et d'un ovule ; elle forme une **cellule-œuf**.
La fécondation est **interne** lorsqu'elle se déroule dans le corps de la femelle, par exemple chez le chien, le chat et la poule. Elle est **externe** lorsque les gamètes se rencontrent dans le milieu extérieur, souvent dans l'eau, comme chez de nombreux poissons et les grenouilles.
Un animal **ovipare** pond des œufs dans lesquels se développe le jeune : poule, tortue, crocodile. Un animal **vivipare** donne naissance à un jeune qui s'est développé dans le corps de la femelle : chien, chat, vache, humain.`,
ex:`1. Définis reproduction, fécondation, ovule et spermatozoïde.
2. Classe poule, chat, tortue, chien, grenouille et vache en ovipares/vivipares.
3. Indique si la fécondation est interne ou externe chez le chien, la grenouille, la poule et de nombreux poissons.
**Corrections :** reproduction = phénomène donnant de nouveaux individus ; fécondation = union des gamètes ; poule/tortue/grenouille = ovipares ; chat/chien/vache = vivipares ; chien/poule = interne ; grenouille/nombreux poissons = externe.`,
renf:`Une grenouille pond ses œufs dans une mare. Explique où les gamètes se rencontrent, quel type de fécondation a lieu et pourquoi le têtard n'est pas identique à la grenouille adulte.`,
q:[['La reproduction permet :',['de se nourrir','de produire de nouveaux individus','de respirer','de se déplacer'],1],['Le spermatozoïde est :',['une cellule reproductrice mâle','une cellule reproductrice femelle','un organe','un embryon'],0],['La fécondation produit :',['un œuf alimentaire','une cellule-œuf','un spermatozoïde','un têtard directement'],1],['La poule est :',['vivipare','ovipare','végétale','asexuée'],1],['Chez de nombreux poissons, la fécondation est :',['externe','interne','impossible','aérienne'],0]],
rev:`## Fiche mémo
**Spermatozoïde + ovule → fécondation → cellule-œuf**
**Fécondation interne** : dans le corps de la femelle.
**Fécondation externe** : dans le milieu extérieur.
**Ovipare** : développement dans un œuf.
**Vivipare** : développement dans le corps de la femelle.`},
{n:2,t:'Reproduction chez les plantes à fleurs',course:`## Objectifs
Identifier les parties principales d'une fleur, comprendre le rôle des étamines et du pistil, expliquer la pollinisation, la fécondation et la formation de la graine et du fruit.

## Cours
La fleur est l'organe reproducteur de nombreuses plantes à fleurs. Elle comprend notamment **sépales, pétales, étamines et pistil**. Les étamines constituent la partie reproductrice mâle et produisent les grains de **pollen**. Le pistil constitue la partie reproductrice femelle ; sa partie supérieure est le **stigmate**.
La **pollinisation** est le transport du pollen jusqu'au stigmate. Elle peut être assurée par le vent, les insectes, certains oiseaux ou d'autres animaux.
Après la pollinisation, l'élément reproducteur mâle rencontre l'ovule situé dans l'ovaire. La fécondation forme une cellule-œuf. Après fécondation, l'ovule devient une **graine** et l'ovaire peut devenir un **fruit**.`,
ex:`1. Cite quatre parties d'une fleur.
2. Quel est le rôle des étamines et du pistil ?
3. Définis pollinisation.
4. Donne deux agents pollinisateurs.
**Corrections :** sépales, pétales, étamines, pistil ; étamines = partie mâle et production du pollen ; pistil = partie femelle ; pollinisation = transport du pollen vers le stigmate ; exemples : vent et insectes.`,
renf:`Explique le trajet : **étamine → pollen → stigmate → ovule → graine**. Une plante produit beaucoup de fleurs mais très peu de fruits en absence d'insectes : explique ce phénomène.`,
q:[['Le pollen est produit par :',['le pistil','les étamines','les racines','les feuilles'],1],['La pollinisation est :',['la germination','le transport du pollen vers le stigmate','la formation des racines','la chute des feuilles'],1],['Après fécondation, l’ovule devient :',['une feuille','une racine','une graine','un pétale'],2],['L’ovaire peut donner :',['un fruit','une racine','une feuille','du pollen'],0]],
rev:`## Fiche mémo
**Étamine → partie mâle**
**Pistil → partie femelle**
**Pollen → élément reproducteur mâle**
**Pollinisation → transport du pollen**
**Ovule fécondé → graine**
**Ovaire → fruit**`},
{n:3,t:'Germination de la graine',course:`## Objectifs
Comprendre ce qu'est une graine, les conditions nécessaires à la germination, ses étapes et la différence entre germination et croissance.

## Cours
Une graine provient généralement d'un ovule après fécondation. Elle contient un **embryon** et des réserves nutritives.
La **germination** est le début du développement de l'embryon. La graine absorbe de l'eau, gonfle et son enveloppe se fragilise. La **radicule** sort généralement en premier et donnera la racine ; la jeune tige se développe ensuite.
Les principales conditions nécessaires sont **l'eau, une quantité suffisante de dioxygène et une température convenable**. La lumière n'est pas indispensable à la germination de toutes les graines.`,
ex:`1. Définis germination.
2. Cite les trois conditions principales.
3. Quelle partie donne la racine ?
4. Pourquoi la graine absorbe-t-elle de l'eau ?
**Correction :** germination = début du développement de l'embryon ; eau + dioxygène + température convenable ; la radicule donne la racine ; l'eau permet notamment l'imbibition et le démarrage des transformations nécessaires au développement.`,
renf:`Compare quatre lots : graines sèches ; graines humidifiées exposées à l'air ; graines complètement immergées ; graines humidifiées placées dans un milieu très froid. Indique le lot le plus favorable et justifie.`,
q:[['La germination est :',['la mort de la graine','le début du développement de l’embryon','la formation du fruit','la pollinisation'],1],['Une graine a besoin principalement :',['uniquement de lumière','d’eau, de dioxygène et d’une température convenable','uniquement de terre','uniquement d’engrais'],1],['La radicule donnera :',['la fleur','la racine','le fruit','le pollen'],1]],
rev:`## Fiche mémo
**Graine + eau + dioxygène + température favorable → germination**
**Radicule → racine**
La germination précède la croissance de la jeune plante.
Défi : faire germer des haricots sur coton humide et noter chaque jour la date, la taille, l'apparition de la racine, de la tige et des feuilles.`},
{n:4,t:'Nutrition chez les vertébrés',course:`## Objectifs
Comprendre pourquoi les animaux se nourrissent, les régimes alimentaires, le rôle des aliments, le trajet des aliments et les grandes étapes de la digestion.

## Cours
Les animaux ont besoin de nourriture pour produire de l'énergie, grandir, entretenir leur organisme, se déplacer et assurer le fonctionnement de leurs organes.
Un animal peut être **herbivore** (principalement végétaux), **carnivore** (principalement animaux) ou **omnivore** (aliments d'origine végétale et animale).
Chez l'être humain, les aliments suivent notamment le trajet **bouche → œsophage → estomac → intestin grêle → gros intestin → anus**.
La digestion transforme les aliments en substances plus simples utilisables par l'organisme : les **nutriments**. L'intestin grêle permet une grande partie de leur passage vers le sang.`,
ex:`1. Pourquoi un animal doit-il se nourrir ?
2. Donne deux herbivores, deux carnivores et deux omnivores.
3. Remets les organes digestifs dans l'ordre.
4. Explique pourquoi la mastication est importante.
**Correction :** elle contribue à fournir matière et énergie et à faire fonctionner l'organisme ; exemples acceptés selon les catégories ; ordre : bouche, œsophage, estomac, intestin grêle, gros intestin, anus ; la mastication réduit les aliments et facilite leur transformation.`,
renf:`Explique pourquoi une vache et un lion n'ont pas le même régime alimentaire. Relie régime alimentaire, nature des aliments consommés et adaptation de la digestion.`,
q:[['Un herbivore mange principalement :',['des végétaux','des pierres','uniquement des insectes','uniquement du poisson'],0],['La digestion commence :',['dans l’intestin','dans la bouche','dans l’estomac uniquement','dans le sang'],1],['L’intestin grêle participe notamment :',['à l’absorption des nutriments','à la respiration','à la reproduction','à la vision'],0]],
rev:`## Fiche mémo
**Aliment → digestion → nutriments → absorption → utilisation par l'organisme**
**Bouche → œsophage → estomac → intestin grêle → gros intestin → anus**
Herbivore = végétaux ; carnivore = animaux ; omnivore = végétaux + animaux.`},
{n:5,t:'Nutrition chez les plantes à fleurs',course:`## Objectifs
Comprendre comment les plantes absorbent l'eau et les sels minéraux, utilisent le dioxyde de carbone et la lumière et fabriquent leur matière organique.

## Cours
Les plantes vertes prélèvent dans leur environnement de l'**eau**, des **sels minéraux** et du **dioxyde de carbone**. Les racines absorbent principalement l'eau et les sels minéraux du sol. Les feuilles réalisent des échanges gazeux avec l'air.
La **photosynthèse** utilise la lumière pour fabriquer de la matière organique à partir notamment de dioxyde de carbone et d'eau. Elle s'accompagne d'un rejet de dioxygène.`,
ex:`1. Que prélèvent les racines ?
2. Quel gaz les feuilles prélèvent-elles dans l'air ?
3. Quelle énergie intervient dans la photosynthèse ?
4. Où la photosynthèse est-elle particulièrement active ?
**Correction :** eau et sels minéraux ; dioxyde de carbone ; énergie lumineuse ; principalement dans les parties vertes, notamment les feuilles.`,
renf:`Deux plantes identiques sont placées, l'une à la lumière et l'autre dans l'obscurité totale. Après plusieurs jours leur aspect diffère. Explique le résultat en utilisant la photosynthèse.`,
q:[['Les racines absorbent principalement :',['la lumière','l’eau et les sels minéraux','le dioxygène uniquement','les fruits'],1],['La photosynthèse nécessite notamment :',['la lumière','uniquement du sable','absence totale d’eau','obscurité totale'],0],['Les feuilles permettent notamment :',['des échanges gazeux','la mastication','la digestion des aliments','la marche'],0]],
rev:`## Fiche mémo
**Racines → eau + sels minéraux**
**Feuilles → échanges gazeux**
**Lumière + eau + CO₂ → photosynthèse → matière organique + O₂**`},
{n:6,t:'Besoins nutritifs des plantes',course:`## Objectifs
Identifier les besoins nutritifs d'une plante, distinguer eau et sels minéraux, comprendre le rôle du sol, expliquer l'importance des engrais et les conséquences d'une carence.

## Cours
Pour grandir correctement, une plante a besoin notamment d'**eau, de sels minéraux, de dioxyde de carbone et de lumière**. Les racines prélèvent l'eau et les sels minéraux du sol.
Les sels minéraux participent à la croissance, à la formation des feuilles, au développement des racines et au bon fonctionnement de la plante.
Un **engrais** peut apporter des éléments minéraux au sol, mais un excès peut être néfaste à l'environnement.`,
ex:`1. Cite quatre besoins d'une plante.
2. Où sont prélevés les sels minéraux ?
3. Quel est le rôle des engrais ?
4. Pourquoi éviter l'excès d'engrais ?
**Correction :** eau, sels minéraux, CO₂, lumière ; les sels minéraux sont prélevés par les racines dans le sol ; l'engrais peut fournir des éléments minéraux ; l'excès peut polluer les sols et l'eau.`,
renf:`Deux plantes reçoivent la même eau et la même lumière mais sont cultivées dans des sols différents : l'une riche en sels minéraux, l'autre très pauvre. Explique la différence de développement.`,
q:[['Les sels minéraux sont principalement prélevés :',['par les fleurs','par les racines','par les fruits','par les graines'],1],['Un engrais peut :',['fournir des éléments minéraux','remplacer la lumière','remplacer toutes les racines','empêcher toute croissance'],0],['Un excès d’engrais peut :',['toujours améliorer la plante','polluer les sols et l’eau','supprimer le besoin d’eau','transformer la plante en animal'],1]],
rev:`## Fiche mémo
Une plante a besoin de **eau + sels minéraux + CO₂ + lumière**.
**Racines → eau + sels minéraux**
**Feuilles → lumière + échanges gazeux**
Un engrais apporte des éléments minéraux ; l'excès est nuisible.`},
{n:7,t:"Actions néfastes de l'Homme sur l'environnement",course:`## Objectifs
Identifier les principales actions humaines nuisibles, leurs conséquences et les moyens de réduire leur impact.

## Cours
L'environnement comprend les êtres vivants et les éléments non vivants qui les entourent. Les activités humaines peuvent le modifier.
Exemples d'actions nuisibles : **déforestation, feux de brousse, exploitation excessive des ressources, destruction des habitats, pollution, braconnage et mauvaise gestion des déchets**.
La déforestation peut entraîner disparition d'habitats, diminution de la biodiversité, érosion des sols et modification du cycle de l'eau. Les feux répétés peuvent détruire végétaux, animaux, sols et habitats.`,
ex:`1. Définis déforestation.
2. Cite trois actions humaines nuisibles.
3. Donne deux conséquences de la déforestation.
4. Pourquoi les feux répétés sont-ils dangereux ?
**Correction :** déforestation = destruction des forêts ; exemples : pollution, braconnage, feux, destruction d'habitats ; conséquences : perte d'habitats, biodiversité et érosion ; les feux répétés dégradent durablement certains milieux.`,
renf:`Une forêt est progressivement transformée en zone agricole. Analyse les changements possibles pour les habitats, les animaux, les végétaux et le sol.`,
q:[['La déforestation correspond :',['à la plantation d’arbres','à la destruction des forêts','à la protection des forêts','à l’arrosage'],1],['Le braconnage peut provoquer :',['une augmentation automatique de la biodiversité','une diminution de certaines populations animales','la formation des nuages','la germination'],1],['La destruction d’un habitat peut :',['menacer les espèces qui y vivent','toujours favoriser les animaux','n’avoir aucun effet','produire de l’eau'],0]],
rev:`## Fiche mémo
**Actions humaines → perturbation des milieux → conséquences sur les êtres vivants**
Menaces : déforestation, feux, pollution, braconnage, destruction des habitats.`},
{n:8,t:'Pollution et conséquences',course:`## Objectifs
Comprendre la pollution, ses types, ses causes, ses conséquences et les moyens de prévention.

## Cours
La **pollution** est une dégradation de l'environnement provoquée par l'introduction de substances ou d'agents nuisibles.
La pollution de l'air peut provenir des fumées, gaz d'échappement, brûlage des déchets et certaines activités industrielles. Elle dégrade la qualité de l'air et peut perturber les écosystèmes.
La pollution de l'eau peut être due aux déchets, eaux usées, produits chimiques et hydrocarbures ; elle peut entraîner mortalité d'organismes aquatiques, contamination de l'eau et déséquilibre des écosystèmes.
La pollution du sol peut être liée aux déchets, pesticides excessifs, produits chimiques et hydrocarbures.`,
ex:`Associe : fumées ; déchets dans une rivière ; produits chimiques dans le sol avec pollution de l'air, de l'eau et du sol.
**Correction :** fumées → air ; déchets dans une rivière → eau ; produits chimiques dans le sol → sol.`,
renf:`Une rivière reçoit régulièrement des eaux usées et quelques mois plus tard le nombre de poissons diminue. Propose une explication en reliant pollution, qualité de l'eau et organismes aquatiques.`,
q:[['La pollution est :',['toujours naturelle','une dégradation de l’environnement','la croissance des plantes','une forme de reproduction'],1],['Les fumées peuvent provoquer :',['une pollution de l’air','une pollution génétique uniquement','la germination','la photosynthèse'],0],['Les déchets dans une rivière provoquent :',['une pollution de l’eau','une pollution sonore uniquement','aucune modification','une augmentation garantie des poissons'],0]],
rev:`## Fiche mémo
**Air → fumées et gaz**
**Eau → déchets, eaux usées, produits chimiques**
**Sol → déchets, produits chimiques, pesticides**
La pollution peut perturber les êtres vivants et les écosystèmes.`},
{n:9,t:"Protection de l'environnement",course:`## Objectifs
Expliquer pourquoi protéger l'environnement, identifier des comportements responsables et comprendre réduction, réutilisation et recyclage.

## Cours
Protéger l'environnement signifie limiter les dégradations et préserver les ressources naturelles.
Les **3 R** sont : **Réduire** (produire moins de déchets), **Réutiliser** (utiliser plusieurs fois un objet) et **Recycler** (transformer certains déchets pour fabriquer de nouveaux produits).
On peut économiser l'eau et l'énergie, éviter le gaspillage, planter et protéger les arbres, ne pas jeter les déchets dans la nature, protéger les animaux et respecter les espaces naturels.`,
ex:`Classe les actions : jeter une bouteille dans une poubelle adaptée ; laisser couler inutilement un robinet ; réutiliser un sac ; brûler des déchets ; planter un arbre.
**Correction attendue :** actions responsables : poubelle adaptée, réutilisation, plantation ; action à éviter : gaspillage de l'eau et brûlage des déchets.`,
renf:`Une école produit beaucoup de déchets chaque jour. Propose un plan simple fondé sur réduction, réutilisation, tri, recyclage et sensibilisation.`,
q:[['Réduire signifie :',['produire davantage de déchets','limiter sa consommation et ses déchets','tout jeter','brûler tous les déchets'],1],['Réutiliser signifie :',['utiliser plusieurs fois un objet lorsque c’est possible','jeter immédiatement','polluer','gaspiller'],0],['Planter des arbres peut contribuer à :',['protéger certains sols et habitats','augmenter automatiquement les déchets','supprimer toute pollution','empêcher la pluie'],0]],
rev:`## Fiche mémo
🌱 Protéger — 💧 Économiser — ♻️ Recycler — 🔄 Réutiliser — 🗑️ Trier — 🌳 Planter et préserver.
**Réduire = moins de consommation et de déchets ; Réutiliser = plusieurs usages ; Recycler = transformer certains déchets.**`},
{n:10,t:'Dégradation des milieux naturels',course:`## Objectifs
Comprendre ce qu'est un milieu naturel, ses causes de dégradation, les conséquences sur les espèces et le lien entre activités humaines et équilibre écologique.

## Cours
Un milieu naturel comprend les êtres vivants, le sol, l'eau, l'air et les conditions physiques du milieu. Les êtres vivants et leur milieu forment un **écosystème**.
Les causes de dégradation peuvent être la déforestation, pollution, urbanisation, agriculture intensive, exploitation excessive, feux de brousse et introduction de certaines espèces invasives.
Les conséquences peuvent être disparition d'espèces, diminution des populations, destruction des habitats, érosion, pollution de l'eau et diminution de la biodiversité.`,
ex:`1. Définis milieu naturel.
2. Cite quatre causes de dégradation.
3. Cite trois conséquences.
4. Explique le rôle de l'habitat.
**Correction :** milieu naturel = êtres vivants + éléments physiques ; causes : déforestation, pollution, urbanisation, feux, etc. ; conséquences : perte d'habitats, espèces et biodiversité ; l'habitat fournit les conditions nécessaires à la vie d'une espèce.`,
renf:`Une zone humide est remblayée pour construire des bâtiments. Analyse les conséquences possibles sur les plantes, les animaux, l'eau et les habitants.`,
q:[['Un écosystème comprend :',['seulement les animaux','seulement les plantes','les êtres vivants et leur milieu','uniquement l’eau'],2],['La déforestation peut provoquer :',['une destruction d’habitats','toujours une augmentation de la biodiversité','aucune conséquence','uniquement une augmentation des poissons'],0],['La destruction d’un milieu peut provoquer :',['une perte de biodiversité','une reproduction illimitée','une disparition de l’eau uniquement','aucun changement'],0]],
rev:`## Fiche mémo
**Milieu naturel = êtres vivants + éléments physiques**
**Dégradation → destruction des habitats → perturbation des populations → perte possible de biodiversité**`},
{n:11,t:'Solutions aux problèmes environnementaux',course:`## Objectifs
Identifier un problème environnemental, rechercher ses causes, prévoir ses conséquences, proposer des solutions réalistes et comprendre l'action collective.

## Cours
Pour résoudre un problème environnemental, on suit une démarche : **identifier le problème → rechercher les causes → identifier les conséquences → rechercher des solutions → agir → évaluer**.
Exemple des déchets : causes possibles = absence de poubelles, mauvaises habitudes, collecte insuffisante, manque d'information ; conséquences = mauvaises odeurs, prolifération de certains animaux nuisibles, pollution, obstruction des caniveaux ; solutions = installer des poubelles, organiser la collecte, sensibiliser, trier et recycler.
Une solution doit être **réaliste, durable, adaptée au problème et respectueuse des populations et de l'environnement**.`,
ex:`Pour chacun des problèmes suivants, donne une cause, une conséquence et une solution : pollution d'une rivière ; déforestation ; déchets dans les rues ; feux de brousse.
**Correction :** toute réponse cohérente reliant clairement cause, conséquence et action adaptée est recevable.`,
renf:`Une école constate que beaucoup de bouteilles en plastique sont jetées chaque jour. Construis un programme comprenant prévention, collecte, tri, réutilisation ou recyclage et sensibilisation.`,
q:[['Une bonne démarche consiste d’abord à :',['identifier le problème','jeter davantage','ignorer la situation','détruire le milieu'],0],['Une solution durable cherche notamment à :',['traiter les causes du problème','déplacer le problème','augmenter la pollution','supprimer toute activité humaine'],0],['La protection de l’environnement nécessite souvent :',['uniquement une personne','une action collective','aucune organisation','uniquement des machines'],1]],
rev:`## Fiche mémo
**Problème → Causes → Conséquences → Solutions → Actions → Évaluation**
Une bonne solution est réaliste, durable, adaptée au problème et respectueuse des populations et de l'environnement.`},
{n:12,t:'Biodiversité et équilibre des écosystèmes',course:`## Objectifs
Définir biodiversité, reconnaître la diversité du vivant, comprendre les relations alimentaires, construire une chaîne alimentaire simple, expliquer les conséquences de la disparition d'une espèce et comprendre l'équilibre d'un écosystème.

## Cours
La **biodiversité** correspond à la diversité du vivant : diversité des espèces, des individus et des milieux de vie.
Dans un écosystème, les êtres vivants sont liés par des relations alimentaires. Exemple : **herbe → criquet → grenouille → serpent** ; la flèche signifie « est mangé par ».
Les plantes vertes sont généralement des **producteurs** car elles fabriquent leur matière organique grâce à la photosynthèse. Les animaux sont des **consommateurs**.
Une chaîne alimentaire montre qui mange qui. Une modification importante d'une population peut avoir des conséquences sur d'autres populations. Si des prédateurs disparaissent, certaines proies peuvent augmenter, consommer davantage de végétaux et perturber l'écosystème.`,
ex:`1. Construis une chaîne alimentaire avec herbe, lion et gazelle.
2. Dans maïs → criquet → grenouille → serpent, identifie le producteur, le consommateur primaire et l'animal qui mange la grenouille.
3. Définis biodiversité.
**Correction :** herbe → gazelle → lion ; maïs = producteur, criquet = consommateur primaire, serpent mange la grenouille ; biodiversité = diversité du vivant.`,
renf:`Dans une région, le nombre de rapaces diminue fortement. Quelques années plus tard les rongeurs augmentent et consomment beaucoup de graines et de jeunes plantes. Explique les différentes étapes de cette perturbation.`,
q:[['La biodiversité correspond :',['uniquement au nombre d’animaux','à la diversité du vivant','uniquement aux plantes','uniquement aux microbes'],1],['Dans herbe → criquet → grenouille, l’herbe est :',['consommateur','producteur','prédateur','décomposeur'],1],['Le criquet est :',['producteur','consommateur primaire','consommateur secondaire','végétal'],1],['Une disparition d’espèce peut :',['perturber les relations alimentaires','ne jamais avoir de conséquence','toujours améliorer l’écosystème','arrêter la photosynthèse mondiale'],0],['La biodiversité doit être protégée notamment parce que :',['les espèces sont liées entre elles','toutes les espèces sont identiques','les écosystèmes n’ont aucun équilibre','les animaux ne dépendent jamais des plantes'],0]],
rev:`## Fiche mémo
**Biodiversité = diversité du vivant**
**Producteur = organisme qui produit sa matière organique, notamment grâce à la photosynthèse**
**Consommateur = organisme qui obtient sa matière en consommant d'autres organismes**
Exemple de chaîne : **herbe → criquet → grenouille → serpent**.
Les populations d'un écosystème sont liées ; une modification peut provoquer des changements ailleurs.`}
];

const EXTRA={
3:['Une condition favorable à la germination est :',['une température convenable','l’absence totale d’eau','l’absence de dioxygène','la destruction de l’embryon'],0],
4:['Le trajet correct des aliments comprend :',['bouche → œsophage → estomac → intestin grêle','poumons → cœur → intestin','rein → estomac → bouche','foie → poumons → anus'],0],
5:['Lors de la photosynthèse, la plante utilise notamment :',['dioxyde de carbone et eau','uniquement du sable','uniquement des sels minéraux','uniquement du dioxygène'],0],
6:['Les sels minéraux sont principalement prélevés :',['dans le sol par les racines','dans les fruits par les fleurs','dans la lumière par les feuilles','dans l’air par les graines'],0],
7:['Une conséquence possible de la déforestation est :',['la destruction d’habitats','la disparition de toute pluie','la germination automatique','l’augmentation garantie des espèces'],0],
8:['Les eaux usées rejetées dans une rivière peuvent :',['perturber les organismes aquatiques','améliorer toujours la qualité de l’eau','empêcher toute pollution','produire directement des poissons'],0],
9:['Recycler consiste à :',['transformer certains déchets pour fabriquer de nouveaux produits','jeter tous les objets','gaspiller davantage','laisser les déchets dans la nature'],0],
10:['La dégradation d’un milieu peut entraîner :',['une diminution de la biodiversité','une augmentation automatique de toutes les espèces','aucun changement','la disparition de toutes les ressources'],0],
11:['Après avoir identifié un problème environnemental, il faut notamment :',['rechercher ses causes et ses conséquences','ignorer les causes','augmenter les déchets','supprimer toute activité humaine'],0]
};
function parseQ(q,n){const all=q.slice();if(all.length<4&&EXTRA[n])all.push(EXTRA[n]);return all.map((x,i)=>({id:'q'+(i+1),type:'qcm',enonce:x[0],choix:x[1],bonnesReponses:[x[2]],points:1}));}
async function delRefs(refs){let total=0;for(let i=0;i<refs.length;i+=450){const b=db.batch();for(const r of refs.slice(i,i+450))b.delete(r);await b.commit();total+=Math.min(450,refs.length-i);}return total;}
async function main(){
 let oldResourcesDeleted=0,resourcesCreated=0;
 for(const ch of CH){
   const id='6e_svt_ch'+String(ch.n).padStart(2,'0');
   const snap=await db.collection('ca_ressources').where('chapitreId','==',id).get();
   oldResourcesDeleted+=await delRefs(snap.docs.map(d=>d.ref));
   const base={chapitreId:id,niveau:'6e',matiereId:'svt',ecoleId:'',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:1,ressourceLieeId:'',examen:'',annee:0,serie:'',actif:false,ressourceNationale:true,auteur:'sentinel-svt6e-user-source-2026',dateMaj:FieldValue.serverTimestamp()};
   const resources=[
    {type:'cours',titre:'Cours complet — '+ch.t,contenu:ch.course,ordre:1},
    {type:'exercices',titre:'Exercices et corrections — '+ch.t,contenu:ch.ex,ordre:2},
    {type:'renforcement',titre:'Renforcement et problème — '+ch.t,contenu:ch.renf,ordre:3},
    {type:'quiz',titre:'QCM, quiz et défi — '+ch.t,contenu:ch.renf,questions:parseQ(ch.q,ch.n),dureeMinutes:10,ordre:4},
    {type:'revision',titre:'Fiche de révision — '+ch.t,contenu:ch.rev,ordre:5}
   ];
   const batch=db.batch();
   for(let j=0;j<resources.length;j++){const x=resources[j],ref=db.collection('ca_ressources').doc(id+'_user_r'+j);batch.set(ref,{...base,...x,dateCreation:FieldValue.serverTimestamp()});}
   await batch.commit();resourcesCreated+=5;
 }
 await db.collection('ca_parametres').doc('version').set({dateMaj:FieldValue.serverTimestamp(),derniereRessourceNationale:'SVT_6E_USER_12_CHAPTERS_REPLACEMENT_DRAFT',svt6eReplacement:{chapters:12,resourcesCreated,oldResourcesDeleted,actif:false,source:'Fichier markdown(5).md collé'}},{merge:true});
 console.log({ok:true,mode:'full_replacement',chaptersProcessed:12,oldResourcesDeleted,resourcesCreated,expectedResources:60,publication:'draft_only'});
}
main().catch(e=>{console.error(e);process.exit(1);});
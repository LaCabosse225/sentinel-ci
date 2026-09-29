const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const chapters = [
  {
    code:'SVT-4e-02',
    title:'Digestion des aliments',
    description:'Étude approfondie de la transformation des aliments, du rôle des organes et des sucs digestifs, et de l’absorption intestinale.',
    course:`# DIGESTION DES ALIMENTS

## Introduction

Nous mangeons des aliments complexes : riz, pain, viande, poisson, fruits, légumes, etc. Pourtant, les cellules de notre organisme utilisent des substances beaucoup plus simples appelées **nutriments**.

La digestion transforme donc les aliments afin de rendre leurs constituants utilisables par l’organisme.

## 1. Le tube digestif

Le tube digestif est un long conduit parcouru par les aliments.

**Bouche → pharynx → œsophage → estomac → intestin grêle → gros intestin → rectum → anus**

Chaque partie possède un rôle particulier.

### La bouche

Les dents découpent et broient les aliments : c’est la **mastication**.

La salive humidifie les aliments et commence la transformation de certains glucides. La langue mélange l’ensemble et facilite la déglutition.

Le mélange obtenu est appelé **bol alimentaire**.

### L’œsophage

L’œsophage conduit le bol alimentaire vers l’estomac grâce aux contractions de sa paroi.

### L’estomac

L’estomac brasse les aliments et les mélange au **suc gastrique**. La digestion se poursuit et le contenu devient progressivement liquide.

### L’intestin grêle

L’intestin grêle est le principal siège de la digestion finale et de l’**absorption intestinale**.

Les nutriments traversent sa paroi et rejoignent le sang.

### Le gros intestin

Il récupère notamment une partie de l’eau et participe à la formation des selles.

## 2. Transformation mécanique et transformation chimique

La digestion comporte deux grands types de transformations.

**Transformation mécanique** : mastication et brassage des aliments.

**Transformation chimique** : action des sucs digestifs qui transforment certaines grosses molécules alimentaires en molécules plus simples.

## 3. Les sucs digestifs

Les sucs digestifs contiennent des substances qui facilitent les transformations chimiques.

On peut notamment citer :
- la salive ;
- le suc gastrique ;
- le suc pancréatique ;
- le suc intestinal.

La bile, produite par le foie et stockée dans la vésicule biliaire, facilite notamment la digestion des lipides en favorisant leur dispersion.

## 4. Les produits de la digestion

Les glucides complexes peuvent être transformés en sucres simples comme le **glucose**.

Les protides sont transformés en **acides aminés**.

Les lipides sont transformés en produits simples, notamment **acides gras et glycérol**.

L’eau, les vitamines et les sels minéraux n’ont pas besoin d’une digestion comparable : ils peuvent être absorbés sous leur forme simple.

## 5. L’absorption intestinale

L’absorption intestinale correspond au passage des nutriments de l’intestin vers le milieu intérieur, principalement le sang.

La paroi de l’intestin grêle possède de nombreux replis et de petites structures appelées **villosités intestinales**, ce qui augmente la surface d’échange.

Les nutriments peuvent ainsi rejoindre rapidement les vaisseaux sanguins.

## 6. Bilan

**Aliments → transformations digestives → nutriments → absorption intestinale → sang → cellules**

La digestion est donc indispensable pour rendre une grande partie des constituants alimentaires utilisables par les cellules.
`,
    exercises:`## Exercice 1 — Remettre dans l’ordre

Replace dans l’ordre le trajet suivant : intestin grêle, bouche, estomac, anus, œsophage, gros intestin.

### Correction

**Bouche → œsophage → estomac → intestin grêle → gros intestin → anus.**

## Exercice 2 — Expliquer

Pourquoi dit-on que la digestion est à la fois mécanique et chimique ?

### Correction

Elle est mécanique parce que les aliments sont mastiqués et brassés. Elle est chimique parce que les sucs digestifs transforment certaines molécules alimentaires en substances plus simples.

## Exercice 3 — Raisonnement

Un élève mange du pain. Explique comment une partie de l’amidon du pain peut finalement fournir du glucose aux cellules.

### Correction

L’amidon est transformé au cours de la digestion par l’action des sucs digestifs. Il donne notamment du glucose. Le glucose est absorbé au niveau de l’intestin grêle, passe dans le sang puis est distribué aux cellules.
`,
    reinforcement:`# RENFORCEMENT — Digestion des aliments

## Situation-problème

Une personne affirme : « Comme je mange du riz, mes cellules reçoivent directement du riz. »

### Question

Explique pourquoi cette affirmation est incorrecte.

### Correction

Les cellules ne reçoivent pas directement les aliments consommés. Ceux-ci subissent des transformations dans le tube digestif. Une partie de leurs constituants est transformée en nutriments. Les nutriments sont ensuite absorbés dans l’intestin grêle et transportés par le sang jusqu’aux cellules.

## Schéma-bilan

**Aliment complexe → digestion → molécules simples → intestin grêle → sang → cellules**
`,
    qcm:[
      ['La digestion correspond principalement à :',['la fabrication des aliments','la transformation des aliments','la respiration','la circulation du sang'],1,'La digestion transforme les aliments afin de rendre leurs constituants utilisables.'],
      ['Quel organe reçoit directement le bol alimentaire après l’œsophage ?',['Le gros intestin','L’estomac','Le foie','Le rein'],1,'Le bol alimentaire arrive dans l’estomac.'],
      ['L’absorption intestinale se produit principalement dans :',['la bouche','l’estomac','l’intestin grêle','le gros intestin'],2,'L’intestin grêle est le principal siège de l’absorption des nutriments.'],
      ['Les protides sont notamment transformés en :',['acides aminés','dioxygène','eau uniquement','sels minéraux'],0,'La digestion des protides conduit notamment à des acides aminés.'],
      ['Les villosités intestinales servent notamment à :',['augmenter la surface d’échange','mastiquer les aliments','produire de l’air','fabriquer les selles'],0,'Elles augmentent la surface disponible pour les échanges et l’absorption.'],
      ['La bile est produite par :',['le foie','le rein','l’estomac','le poumon'],0,'La bile est produite par le foie.']
    ],
    revision:`# FICHE DE RÉVISION — DIGESTION

## Définitions

**Digestion** : ensemble des transformations mécaniques et chimiques des aliments dans le tube digestif.

**Nutriment** : substance simple utilisable par les cellules.

**Absorption intestinale** : passage des nutriments vers le milieu intérieur, principalement le sang.

## Trajet des aliments

**Bouche → œsophage → estomac → intestin grêle → gros intestin → rectum → anus**

## À retenir

- La bouche assure mastication et début de digestion.
- L’estomac brasse les aliments et agit avec le suc gastrique.
- L’intestin grêle termine une grande partie de la digestion et assure principalement l’absorption.
- Les villosités augmentent la surface d’absorption.
- Les nutriments rejoignent le sang puis les cellules.

## Schéma essentiel

**Aliments → digestion → nutriments → absorption → sang → cellules**
`
  },
  {
    code:'SVT-4e-03',
    title:'Respiration et échanges gazeux',
    description:'Étude de l’appareil respiratoire, des mouvements respiratoires et des échanges de dioxygène et de dioxyde de carbone.',
    course:`# RESPIRATION ET ÉCHANGES GAZEUX

## Introduction

Les cellules ont besoin de **dioxygène (O₂)** pour fonctionner. Elles produisent notamment du **dioxyde de carbone (CO₂)**.

L’appareil respiratoire permet les échanges entre l’air et le sang.

## 1. Les organes respiratoires

L’air entre généralement par le nez ou la bouche puis suit le trajet :

**Nez ou bouche → trachée → bronches → bronchioles → poumons**

Les poumons contiennent de très nombreuses petites structures appelées **alvéoles pulmonaires**.

## 2. Les mouvements respiratoires

Lors de l’**inspiration**, l’air entre dans les poumons.

Lors de l’**expiration**, l’air sort des poumons.

Le diaphragme et les muscles respiratoires participent à ces mouvements en modifiant le volume de la cage thoracique.

## 3. Les échanges gazeux

Au niveau des alvéoles pulmonaires, une mince paroi sépare l’air du sang.

Le **dioxygène** passe de l’air alvéolaire vers le sang.

Le **dioxyde de carbone** passe du sang vers l’air alvéolaire puis est rejeté lors de l’expiration.

Ces échanges sont facilités par :
- la grande surface des alvéoles ;
- leur paroi très mince ;
- leur riche vascularisation.

## 4. Respiration et activité physique

Pendant un effort, les muscles travaillent davantage. Leur consommation de dioxygène augmente et la production de dioxyde de carbone augmente également.

La fréquence respiratoire et la fréquence cardiaque augmentent afin d’apporter davantage de dioxygène aux muscles et d’éliminer davantage de dioxyde de carbone.

## 5. Préserver l’appareil respiratoire

La fumée du tabac et certains polluants peuvent endommager l’appareil respiratoire.

Éviter le tabagisme actif et passif, limiter l’exposition aux polluants et maintenir des espaces aérés contribuent à protéger les voies respiratoires.

## Bilan

**Air inspiré → poumons → échanges gazeux → sang → cellules**

**Cellules → sang → poumons → air expiré**
`,
    exercises:`## Exercice 1 — Compléter

Complète : alvéoles – dioxygène – dioxyde de carbone – inspiration – expiration.

1. L’_____ correspond à l’entrée de l’air.
2. L’_____ correspond à la sortie de l’air.
3. Les échanges gazeux ont lieu au niveau des _____.
4. Le sang reçoit du _____.
5. Le sang apporte du _____ aux poumons pour qu’il soit rejeté.

### Correction

1. inspiration ; 2. expiration ; 3. alvéoles ; 4. dioxygène ; 5. dioxyde de carbone.

## Exercice 2 — Raisonnement

Pourquoi la respiration devient-elle plus rapide pendant une course ?

### Correction

Les muscles ont besoin de davantage d’énergie. Leur consommation de dioxygène et leur production de dioxyde de carbone augmentent. La respiration s’accélère pour favoriser les échanges gazeux et répondre à ces besoins.

## Exercice 3 — Schéma

Construis le trajet du dioxygène depuis l’air extérieur jusqu’aux cellules.

### Correction

**Air → voies respiratoires → alvéoles → sang → organes → cellules.**
`,
    reinforcement:`# RENFORCEMENT — Respiration

## Situation-problème

Après plusieurs minutes de course, un élève respire plus vite et son cœur bat plus rapidement.

### Explique ce phénomène.

Pendant l’effort, les muscles ont des besoins énergétiques plus importants. Ils prélèvent davantage de dioxygène et rejettent davantage de dioxyde de carbone. L’organisme augmente donc la ventilation et la circulation sanguine pour adapter les apports et l’élimination des déchets gazeux.

### À retenir

**Effort → besoins des muscles augmentent → respiration et circulation s’adaptent.**
`,
    qcm:[
      ['Le gaz indispensable aux cellules pour leur fonctionnement énergétique est :',['CO₂','O₂','N₂','H₂'],1,'Le dioxygène est indispensable au fonctionnement énergétique des cellules.'],
      ['Les échanges gazeux pulmonaires ont lieu principalement dans :',['les bronches','les alvéoles','la trachée','le nez'],1,'Les alvéoles constituent la principale surface d’échanges entre air et sang.'],
      ['Pendant l’inspiration :',['l’air sort','l’air entre','le sang sort des poumons','les aliments entrent'],1,'L’inspiration correspond à l’entrée de l’air dans les poumons.'],
      ['Le CO₂ produit par les cellules est transporté vers :',['les poumons','les dents','l’estomac uniquement','la peau uniquement'],0,'Le sang transporte le CO₂ vers les poumons pour son élimination.'],
      ['Pendant un effort, la fréquence respiratoire :',['diminue toujours','reste toujours identique','augmente généralement','s’arrête'],2,'Elle augmente généralement pour répondre aux besoins accrus des muscles.'],
      ['Le tabagisme peut :',['protéger les poumons','endommager l’appareil respiratoire','augmenter les alvéoles saines','supprimer les besoins en O₂'],1,'La fumée du tabac peut endommager l’appareil respiratoire.']
    ],
    revision:`# FICHE DE RÉVISION — RESPIRATION

**Respiration** : ensemble des mécanismes permettant notamment les échanges de dioxygène et de dioxyde de carbone.

## Trajet de l’air

**Nez/bouche → trachée → bronches → bronchioles → alvéoles**

## Échanges

**Air → O₂ → sang → cellules**

**Cellules → CO₂ → sang → poumons → air**

## Pendant l’effort

Les besoins des muscles augmentent : la respiration et la circulation s’adaptent.

## Mots-clés

Dioxygène — dioxyde de carbone — alvéoles — inspiration — expiration — échanges gazeux.
`
  },
  {
    code:'SVT-4e-04',
    title:'Circulation sanguine',
    description:'Comprendre le rôle du cœur, des vaisseaux sanguins et du sang dans le transport des substances.',
    course:`# CIRCULATION SANGUINE

## Introduction

Le sang met en relation les organes. Il apporte aux cellules des substances utiles et récupère des substances produites par leur fonctionnement.

La circulation sanguine repose sur trois éléments essentiels : **le cœur, les vaisseaux sanguins et le sang**.

## 1. Le cœur

Le cœur est un muscle creux qui fonctionne comme une pompe.

Il propulse le sang dans les vaisseaux grâce à ses contractions.

Le cœur possède quatre cavités : deux oreillettes et deux ventricules.

## 2. Les vaisseaux sanguins

On distingue principalement :
- les **artères**, qui conduisent le sang du cœur vers les organes ;
- les **veines**, qui ramènent le sang des organes vers le cœur ;
- les **capillaires**, très fins, où se réalisent de nombreux échanges avec les cellules.

## 3. La double circulation

Chez l’être humain, la circulation est organisée en deux grands circuits.

La **circulation pulmonaire** relie le cœur aux poumons. Elle permet notamment l’oxygénation du sang et l’élimination du CO₂.

La **circulation générale** relie le cœur à l’ensemble des organes.

## 4. Le sang

Le sang contient notamment :
- le plasma ;
- les globules rouges ;
- les globules blancs ;
- les plaquettes.

Les globules rouges participent au transport du dioxygène grâce à l’**hémoglobine**.

Le sang transporte aussi des nutriments, du dioxyde de carbone et certains déchets.

## 5. Les échanges au niveau des organes

Au niveau des capillaires, les cellules prélèvent des substances utiles et rejettent des déchets.

Ainsi, la circulation permet d’établir un lien permanent entre les organes respiratoires, digestifs, excréteurs et les autres organes.

## 6. Hygiène cardiovasculaire

Une alimentation équilibrée, l’activité physique régulière, l’absence de tabac et un sommeil suffisant participent à la protection du système cardiovasculaire.

## Bilan

**Cœur → artères → capillaires des organes → veines → cœur**

Le sang assure donc une fonction essentielle de transport.
`,
    exercises:`## Exercice 1 — Associer

Associe chaque élément à son rôle : artère, veine, capillaire, cœur.

A. Pompe le sang.  
B. Ramène le sang vers le cœur.  
C. Conduit le sang du cœur vers les organes.  
D. Permet de nombreux échanges avec les cellules.

### Correction

Cœur = A ; veine = B ; artère = C ; capillaire = D.

## Exercice 2 — Expliquer

Pourquoi le cœur est-il indispensable à la circulation sanguine ?

### Correction

Le cœur agit comme une pompe. Ses contractions mettent le sang en mouvement et permettent son acheminement vers les poumons et les différents organes.

## Exercice 3 — Raisonnement

Un muscle en activité reçoit davantage de sang. Explique l’intérêt de cette augmentation.

### Correction

Le muscle actif a des besoins accrus en dioxygène et en nutriments et produit davantage de déchets. Une augmentation du débit sanguin permet de mieux apporter les substances utiles et d’évacuer les déchets.
`,
    reinforcement:`# RENFORCEMENT — Le sang, un système de transport

## Situation-problème

Un muscle en activité consomme davantage de dioxygène et de nutriments.

### Question

Comment le système circulatoire répond-il à ce besoin ?

### Correction

Le cœur augmente son activité et le débit sanguin vers les muscles peut augmenter. Le sang apporte alors davantage de dioxygène et de nutriments aux cellules musculaires et récupère davantage de dioxyde de carbone et de déchets.

### Schéma-bilan

**Poumons + intestin → sang → cœur → organes → cellules**

Puis :

**Cellules → déchets → sang → organes d’élimination**
`,
    qcm:[
      ['Le cœur fonctionne principalement comme :',['un filtre','une pompe','un poumon','un os'],1,'Le cœur propulse le sang.'],
      ['Les artères conduisent généralement le sang :',['vers le cœur','du cœur vers les organes','uniquement dans les poumons','vers l’estomac uniquement'],1,'Les artères conduisent le sang du cœur vers les organes.'],
      ['Les échanges avec les cellules ont surtout lieu au niveau :',['des capillaires','des grosses artères','des os','des oreillettes uniquement'],0,'Les capillaires sont adaptés aux échanges avec les tissus.'],
      ['Les globules rouges transportent notamment :',['le dioxygène','les aliments entiers','les os','les dents'],0,'L’hémoglobine des globules rouges participe au transport du dioxygène.'],
      ['La circulation pulmonaire met en relation le cœur et :',['les reins','les poumons','les muscles uniquement','le cerveau uniquement'],1,'Elle relie le cœur aux poumons.'],
      ['Une bonne hygiène cardiovasculaire comprend notamment :',['tabagisme','activité physique régulière','absence totale de sommeil','alimentation exclusivement sucrée'],1,'L’activité physique régulière contribue à la santé cardiovasculaire.']
    ],
    revision:`# FICHE DE RÉVISION — CIRCULATION SANGUINE

## Les trois éléments

**Cœur** : pompe.

**Vaisseaux** : conduits du sang.

**Sang** : moyen de transport.

## Vaisseaux

**Artères : cœur → organes**

**Veines : organes → cœur**

**Capillaires : échanges avec les cellules**

## À retenir

Le sang transporte notamment O₂, nutriments, CO₂ et certains déchets.

**Cœur → artères → capillaires → veines → cœur**
`
  },
  {
    code:'SVT-4e-05',
    title:'Excrétion et santé',
    description:'Comprendre l’élimination des déchets du fonctionnement cellulaire et le rôle des reins et des voies urinaires.',
    course:`# EXCRÉTION ET SANTÉ

## Introduction

Les cellules produisent des déchets au cours de leur fonctionnement. Ces déchets doivent être éliminés afin de maintenir l’équilibre interne de l’organisme.

L’ensemble des mécanismes d’élimination de certains déchets constitue l’**excrétion**.

## 1. Les déchets produits par l’organisme

Le fonctionnement cellulaire produit notamment du **dioxyde de carbone** et d’autres déchets.

Le CO₂ est éliminé principalement par les poumons.

D’autres déchets sont transportés par le sang vers les reins.

## 2. Les reins

L’être humain possède généralement deux reins situés dans la région lombaire.

Les reins filtrent le sang et participent à la formation de l’urine.

Ils contribuent ainsi à éliminer certaines substances inutiles ou en excès.

## 3. Les voies urinaires

L’urine formée par les reins passe par les **uretères** jusqu’à la vessie.

La vessie stocke temporairement l’urine.

L’urine est ensuite évacuée vers l’extérieur par l’**urètre**.

**Reins → uretères → vessie → urètre → extérieur**

## 4. Pourquoi boire de l’eau ?

L’eau est indispensable à l’organisme. Elle participe notamment au transport des substances et à l’élimination des déchets.

Une hydratation suffisante aide au bon fonctionnement des reins.

Les besoins en eau varient selon l’âge, l’activité physique, la température et d’autres facteurs.

## 5. Protéger ses reins

Il est important d’éviter l’automédication abusive, de respecter les doses des médicaments prescrits ou recommandés et de maintenir une bonne hydratation.

Une consommation excessive de certaines substances peut également solliciter ou endommager les reins.

## Bilan

**Déchets cellulaires → sang → organes d’élimination**

Pour les déchets urinaires :

**Sang → reins → urine → uretères → vessie → urètre**
`,
    exercises:`## Exercice 1 — Compléter

1. Les reins participent à la formation de l’_____.
2. Les _____ relient les reins à la vessie.
3. La _____ stocke temporairement l’urine.
4. Le _____ élimine principalement le dioxyde de carbone.

### Correction

1. urine ; 2. uretères ; 3. vessie ; 4. poumon.

## Exercice 2 — Expliquer

Pourquoi peut-on dire que les reins jouent un rôle d’élimination ?

### Correction

Ils filtrent le sang et permettent la formation d’urine contenant certaines substances à éliminer.

## Exercice 3 — Raisonnement

Une personne boit très peu pendant une journée chaude. Explique pourquoi une bonne hydratation est importante.

### Correction

L’organisme perd de l’eau et doit maintenir son équilibre hydrique. L’eau participe notamment au transport des substances et au fonctionnement des reins. Les besoins augmentent notamment avec la chaleur et l’activité physique.
`,
    reinforcement:`# RENFORCEMENT — Les reins et l’élimination

## Situation-problème

Après un effort sportif sous forte chaleur, une personne urine moins et son urine est plus concentrée.

### Question

Comment expliquer cette observation ?

### Correction

Une partie importante de l’eau est perdue par la transpiration. L’organisme cherche à conserver son eau. Les reins participent à cette régulation en ajustant la quantité d’eau éliminée dans l’urine.

**Hydratation → sang → reins → urine → élimination adaptée**
`,
    qcm:[
      ['L’excrétion concerne notamment :',['l’élimination de déchets','la mastication','la vision','la croissance des cheveux'],0,'L’excrétion permet l’élimination de certains déchets du fonctionnement de l’organisme.'],
      ['Quel organe forme l’urine ?',['le cœur','le rein','le poumon','l’estomac'],1,'Les reins participent à la formation de l’urine.'],
      ['Les uretères relient :',['les poumons et le cœur','les reins et la vessie','la bouche et l’estomac','le cœur et le cerveau'],1,'Les uretères conduisent l’urine des reins vers la vessie.'],
      ['La vessie sert principalement à :',['produire le sang','stocker temporairement l’urine','digérer les protéines','respirer'],1,'La vessie stocke temporairement l’urine.'],
      ['Le CO₂ est principalement éliminé par :',['les reins','les poumons','la vessie','l’intestin grêle'],1,'Le CO₂ est rejeté lors de l’expiration.'],
      ['Une bonne hydratation :',['est inutile','participe au bon fonctionnement de l’organisme','remplace tous les aliments','supprime les reins'],1,'L’eau est indispensable au fonctionnement de l’organisme.']
    ],
    revision:`# FICHE DE RÉVISION — EXCRÉTION

**Excrétion** : élimination de certains déchets produits par l’organisme.

## Déchets et organes

**CO₂ → poumons**

**Déchets urinaires → reins → urine**

## Voies urinaires

**Reins → uretères → vessie → urètre → extérieur**

## À retenir

- Les reins filtrent le sang.
- Les reins participent à la formation de l’urine.
- La vessie stocke l’urine.
- Une bonne hydratation est importante.
`
  },
  {
    code:'SVT-4e-06',
    title:'Reproduction humaine',
    description:'Étudier les fonctions reproductrices chez l’Homme et la femme et comprendre la production des cellules reproductrices.',
    course:`# REPRODUCTION HUMAINE

## Introduction

La reproduction humaine permet la naissance de nouveaux individus. Elle fait intervenir deux types de cellules reproductrices : les **spermatozoïdes** chez l’homme et les **ovules** chez la femme.

## 1. L’appareil reproducteur masculin

L’appareil reproducteur masculin comprend notamment les testicules, les voies génitales et le pénis.

Les **testicules** produisent les spermatozoïdes et sécrètent une hormone sexuelle importante : la testostérone.

Les spermatozoïdes sont des cellules reproductrices mobiles.

## 2. L’appareil reproducteur féminin

L’appareil reproducteur féminin comprend notamment les ovaires, les trompes utérines, l’utérus et le vagin.

Les **ovaires** produisent les ovules et sécrètent des hormones sexuelles.

L’utérus est l’organe dans lequel peut se développer l’embryon puis le fœtus pendant une grossesse.

## 3. Les cellules reproductrices

Le spermatozoïde et l’ovule sont différents mais jouent chacun un rôle dans la reproduction.

La rencontre des cellules reproductrices permet la formation d’une première cellule appelée **cellule-œuf**.

## 4. La puberté et la fonction reproductrice

À la puberté, les organes reproducteurs deviennent progressivement fonctionnels.

Chez le garçon, la production de spermatozoïdes commence.

Chez la fille, les ovaires commencent à fonctionner selon un cycle et les premières règles apparaissent.

## 5. Reproduction et responsabilité

La reproduction humaine est liée à la santé et à la responsabilité. Une bonne information permet de comprendre le fonctionnement du corps et de prévenir les infections sexuellement transmissibles ainsi que les grossesses non prévues.

## Bilan

**Testicule → spermatozoïdes**

**Ovaire → ovule**

La rencontre des cellules reproductrices peut conduire à la formation d’une cellule-œuf.
`,
    exercises:`## Exercice 1 — Associer

Testicule / ovaire / utérus / spermatozoïde.

A. Cellule reproductrice masculine  
B. Organe reproducteur féminin qui produit les ovules  
C. Organe reproducteur masculin qui produit les spermatozoïdes  
D. Organe où se développe l’embryon

### Correction

Testicule = C ; ovaire = B ; utérus = D ; spermatozoïde = A.

## Exercice 2 — Expliquer

Quel est le rôle des testicules ?

### Correction

Les testicules produisent les spermatozoïdes et sécrètent notamment la testostérone.

## Exercice 3 — Raisonnement

Pourquoi la puberté constitue-t-elle une étape importante pour la reproduction ?

### Correction

À la puberté, les organes reproducteurs deviennent progressivement fonctionnels et la production des cellules reproductrices commence.
`,
    reinforcement:`# RENFORCEMENT — Comprendre la reproduction

## Situation-problème

Un adolescent pense que la reproduction devient possible dès la naissance.

### Correction

La reproduction humaine nécessite des appareils reproducteurs fonctionnels et la production de cellules reproductrices. Ces fonctions deviennent progressivement opérationnelles à partir de la puberté.

**Puberté → maturation des appareils reproducteurs → production de cellules reproductrices**
`,
    qcm:[
      ['Les spermatozoïdes sont produits par :',['les ovaires','les testicules','l’utérus','les reins'],1,'Les testicules produisent les spermatozoïdes.'],
      ['Les ovules sont produits par :',['les ovaires','les poumons','les testicules','la vessie'],0,'Les ovaires produisent les ovules.'],
      ['L’utérus est notamment le lieu :',['des échanges gazeux','du développement de l’embryon et du fœtus','de la production des spermatozoïdes','de la digestion'],1,'L’embryon puis le fœtus se développent dans l’utérus.'],
      ['La testostérone est principalement produite par :',['les testicules','les poumons','l’intestin','la vessie'],0,'Les testicules sécrètent notamment la testostérone.'],
      ['La puberté correspond notamment :',['à la disparition des organes reproducteurs','à leur maturation progressive','à l’arrêt de la croissance','à la digestion'],1,'La puberté s’accompagne de la maturation des fonctions reproductrices.'],
      ['La cellule formée lors de la fécondation est appelée :',['globule rouge','cellule-œuf','neurone','plaquette'],1,'La fécondation conduit à la formation d’une cellule-œuf.']
    ],
    revision:`# FICHE DE RÉVISION — REPRODUCTION HUMAINE

## Cellules reproductrices

**Homme : spermatozoïde**

**Femme : ovule**

## Organes

**Testicules → spermatozoïdes + testostérone**

**Ovaires → ovules + hormones sexuelles**

**Utérus → développement de l’embryon puis du fœtus**

## À retenir

La puberté correspond à la maturation progressive des fonctions reproductrices.

La rencontre d’un spermatozoïde et d’un ovule peut conduire à une **cellule-œuf**.
`
  },
  {
    code:'SVT-4e-07',
    title:'Puberté et fonctionnement des appareils reproducteurs',
    description:'Comprendre les transformations de la puberté et le fonctionnement cyclique de l’appareil reproducteur féminin.',
    course:`# PUBERTÉ ET FONCTIONNEMENT DES APPAREILS REPRODUCTEURS

## Introduction

La puberté est une période de transformation progressive du corps au cours de laquelle l’appareil reproducteur devient fonctionnel.

Elle s’accompagne de changements physiques et hormonaux.

## 1. Les changements à la puberté

Chez le garçon, on observe notamment une augmentation du volume des organes génitaux, l’apparition de la pilosité, la mue de la voix et le début de la production de spermatozoïdes.

Chez la fille, on observe notamment le développement des seins, l’apparition de la pilosité, les premières règles et la maturation des ovaires.

Les transformations varient d’une personne à l’autre.

## 2. Le rôle des hormones

Les hormones sont des substances produites par des organes et transportées par le sang. Elles agissent sur des organes cibles.

Les hormones sexuelles participent à la mise en fonctionnement des appareils reproducteurs et aux transformations de la puberté.

## 3. Le fonctionnement de l’appareil reproducteur masculin

Après la puberté, les testicules produisent des spermatozoïdes de façon continue.

Les spermatozoïdes sont ensuite transportés par les voies génitales.

## 4. Le fonctionnement de l’appareil reproducteur féminin

Le fonctionnement ovarien est cyclique.

Au cours du cycle, un ovule arrive à maturité et peut être libéré : c’est l’**ovulation**.

La paroi interne de l’utérus se prépare à accueillir un éventuel embryon.

En l’absence de grossesse, cette paroi se détache en partie : ce sont les **règles**.

## 5. Respect et diversité

La puberté ne se déroule pas exactement au même âge ni au même rythme chez tous les adolescents.

Les différences individuelles sont normales. Le respect du corps et de l’intimité de chacun est essentiel.

## Bilan

**Puberté → hormones → maturation des appareils reproducteurs → fonctionnement reproducteur**
`,
    exercises:`## Exercice 1 — Vrai ou faux

1. Tous les adolescents connaissent la puberté exactement au même âge.
2. Les hormones participent aux transformations de la puberté.
3. L’ovulation correspond à la libération d’un ovule.
4. Les règles signifient toujours qu’une grossesse est présente.

### Correction

1. Faux. 2. Vrai. 3. Vrai. 4. Faux.

## Exercice 2 — Expliquer

Pourquoi les changements de la puberté ne se produisent-ils pas tous au même âge ?

### Correction

Le développement humain présente des variations individuelles. Le rythme de maturation dépend notamment des caractéristiques biologiques de chaque personne.

## Exercice 3 — Raisonnement

Explique le lien entre hormones et fonctionnement reproducteur.

### Correction

Les hormones sexuelles sont transportées par le sang et agissent sur des organes cibles. Elles participent à la maturation des appareils reproducteurs et à leur fonctionnement.
`,
    reinforcement:`# RENFORCEMENT — La puberté

## Situation-problème

Deux adolescents du même âge constatent que leur corps ne change pas exactement au même moment.

### Réponse scientifique

Cela est compatible avec le développement normal. La puberté est une période progressive et variable selon les individus.

### Idée essentielle

**Même âge ≠ même rythme de développement.**

Le respect de soi et des autres est donc essentiel pendant cette période.
`,
    qcm:[
      ['La puberté correspond notamment :',['à la disparition des hormones','à la maturation de la fonction reproductive','à l’arrêt définitif de la croissance','à la digestion'],1,'La puberté accompagne la maturation des fonctions reproductrices.'],
      ['Une hormone est transportée principalement par :',['le sang','les aliments','l’air extérieur','les os'],0,'Les hormones sont transportées par le sang.'],
      ['L’ovulation est :',['la digestion','la libération d’un ovule','la production d’urine','la respiration'],1,'L’ovulation correspond à la libération d’un ovule.'],
      ['Les règles correspondent notamment :',['à une préparation permanente des poumons','à l’élimination de la muqueuse utérine en l’absence de grossesse','à la production des spermatozoïdes','à une maladie obligatoire'],1,'Les règles surviennent lorsque la grossesse n’a pas débuté et que la muqueuse utérine se détache.'],
      ['Chez le garçon, les testicules commencent à produire des spermatozoïdes :',['avant la naissance uniquement','à partir de la puberté','uniquement après 60 ans','jamais'],1,'La production de spermatozoïdes débute à la puberté.'],
      ['Le rythme de la puberté :',['est identique pour tous','peut varier selon les individus','est toujours terminé en une semaine','n’existe pas'],1,'Le développement pubertaire varie d’un individu à l’autre.']
    ],
    revision:`# FICHE DE RÉVISION — PUBERTÉ

**Puberté** : période de maturation progressive du corps et de la fonction reproductive.

## À connaître

- Les hormones participent aux transformations.
- Chez le garçon, les testicules deviennent producteurs de spermatozoïdes.
- Chez la fille, le fonctionnement ovarien devient cyclique.
- **Ovulation** = libération d’un ovule.
- **Règles** = élimination de la muqueuse utérine en l’absence de grossesse.

## Message important

La puberté varie d’une personne à l’autre. Les différences de rythme sont normales.
`
  },
  {
    code:'SVT-4e-08',
    title:'Fécondation et grossesse',
    description:'Étudier la rencontre des gamètes, la formation de la cellule-œuf et les principales étapes du développement prénatal.',
    course:`# FÉCONDATION ET GROSSESSE

## Introduction

La reproduction sexuée humaine commence par la rencontre d’une cellule reproductrice masculine et d’une cellule reproductrice féminine.

Cette rencontre est appelée **fécondation**.

## 1. La fécondation

La fécondation correspond à la fusion d’un spermatozoïde et d’un ovule.

Elle conduit à la formation d’une **cellule-œuf**.

Chez l’être humain, la fécondation se produit généralement dans une trompe utérine.

## 2. De la cellule-œuf à l’embryon

Après la fécondation, la cellule-œuf se divise progressivement.

Elle donne un embryon qui poursuit son développement et s’implante dans la paroi de l’utérus.

L’implantation de l’embryon dans la muqueuse utérine est appelée **nidation**.

## 3. La grossesse

Pendant la grossesse, l’embryon puis le fœtus se développent dans l’utérus.

Le placenta constitue une interface importante entre la mère et le fœtus.

Il permet notamment des échanges de dioxygène, de nutriments et de déchets, sans que le sang maternel et le sang fœtal se mélangent directement comme deux liquides identiques.

## 4. Le développement du fœtus

Au cours de la grossesse, les organes se forment et se développent progressivement.

Le fœtus reçoit les substances nécessaires à sa croissance et rejette des déchets qui sont pris en charge grâce aux échanges avec l’organisme maternel.

## 5. Santé pendant la grossesse

Une grossesse nécessite un suivi médical adapté.

Le tabac, l’alcool et certaines drogues peuvent être dangereux pour le développement du futur enfant.

Les médicaments ne doivent pas être pris sans avis professionnel pendant une grossesse.

## Bilan

**Spermatozoïde + ovule → fécondation → cellule-œuf → embryon → nidation → fœtus → naissance**
`,
    exercises:`## Exercice 1 — Remettre dans l’ordre

Cellule-œuf, naissance, fécondation, embryon, fœtus, nidation.

### Correction

**Fécondation → cellule-œuf → embryon → nidation → fœtus → naissance.**

## Exercice 2 — Définir

Qu’est-ce que la fécondation ?

### Correction

C’est la fusion d’un spermatozoïde et d’un ovule conduisant à la formation d’une cellule-œuf.

## Exercice 3 — Raisonnement

Pourquoi conseille-t-on de ne pas consommer d’alcool pendant une grossesse ?

### Correction

L’alcool peut passer dans l’environnement sanguin du fœtus par les échanges placentaires et perturber son développement. L’abstinence pendant la grossesse est donc recommandée.
`,
    reinforcement:`# RENFORCEMENT — Du gamète au futur enfant

## Situation-problème

Un élève pense qu’un embryon apparaît immédiatement après la rencontre des parents.

### Correction

La reproduction suit plusieurs étapes : fécondation, formation de la cellule-œuf, divisions cellulaires, développement de l’embryon, nidation puis développement du fœtus.

### Schéma

**Gamètes → fécondation → cellule-œuf → embryon → nidation → fœtus**
`,
    qcm:[
      ['La fécondation est :',['la fusion d’un spermatozoïde et d’un ovule','la digestion','la respiration','la formation de l’urine'],0,'La fécondation correspond à la fusion des deux gamètes.'],
      ['La cellule issue de la fécondation est appelée :',['globule rouge','cellule-œuf','neurone','plaquette'],1,'La fécondation forme une cellule-œuf.'],
      ['La nidation correspond :',['à l’implantation de l’embryon dans l’utérus','à la respiration','à l’ovulation','à la digestion'],0,'La nidation est l’implantation de l’embryon dans la muqueuse utérine.'],
      ['Le développement prénatal se déroule principalement dans :',['l’estomac','l’utérus','les poumons','les reins'],1,'L’embryon puis le fœtus se développent dans l’utérus.'],
      ['Le placenta permet notamment :',['des échanges entre mère et fœtus','la mastication','la production de bile uniquement','la respiration directe du fœtus avec l’air'],0,'Le placenta constitue une interface d’échanges entre les organismes maternel et fœtal.'],
      ['Pendant la grossesse, l’alcool :',['est sans risque','peut être dangereux pour le développement du fœtus','est indispensable','remplace les nutriments'],1,'L’alcool peut perturber le développement du fœtus.']
    ],
    revision:`# FICHE DE RÉVISION — FÉCONDATION ET GROSSESSE

## Étapes

**Spermatozoïde + ovule → fécondation → cellule-œuf → embryon → nidation → fœtus → naissance**

**Fécondation** : fusion des gamètes.

**Nidation** : implantation de l’embryon dans la muqueuse utérine.

## À retenir

- La grossesse se déroule dans l’utérus.
- Le placenta permet des échanges mère-fœtus.
- Le suivi médical est important.
- L’alcool, le tabac et certaines drogues peuvent être dangereux pour le développement du fœtus.
`
  },
  {
    code:'SVT-4e-09',
    title:'Transmission de la vie et santé',
    description:'Relier reproduction, prévention des grossesses non prévues, infections sexuellement transmissibles et comportements responsables.',
    course:`# TRANSMISSION DE LA VIE ET SANTÉ

## Introduction

La sexualité humaine comporte des dimensions biologiques, affectives et sociales. En SVT, l’étude porte ici sur les mécanismes de reproduction et les moyens de préserver la santé.

## 1. La reproduction nécessite la rencontre des gamètes

La fécondation nécessite la rencontre d’un spermatozoïde et d’un ovule.

Sans fécondation, une grossesse ne débute pas.

## 2. Prévenir une grossesse non prévue

Différentes méthodes contraceptives existent.

Elles ont pour objectif d’éviter une grossesse en empêchant la rencontre des gamètes, l’ovulation ou la progression des spermatozoïdes selon la méthode.

Le **préservatif** occupe une place particulière : il contribue à prévenir une grossesse et protège aussi contre de nombreuses infections sexuellement transmissibles lorsqu’il est utilisé correctement.

Pour choisir une méthode contraceptive, il est important de disposer d’une information fiable et, lorsque nécessaire, de demander conseil à un professionnel de santé.

## 3. Les infections sexuellement transmissibles

Les **IST** sont des infections pouvant être transmises lors de rapports sexuels.

Parmi elles figurent notamment le VIH, la syphilis, la gonorrhée, certaines infections à chlamydia et certaines infections liées aux papillomavirus humains.

Certaines IST peuvent être asymptomatiques. Une personne peut donc être infectée sans se sentir malade.

## 4. Prévention

La prévention repose notamment sur :
- l’information et l’éducation à la santé ;
- l’utilisation correcte du préservatif ;
- le dépistage lorsque cela est indiqué ;
- la vaccination contre certaines infections, notamment certains papillomavirus ;
- la prise en charge médicale des personnes infectées.

## 5. Responsabilité et consentement

Toute relation sexuelle doit respecter le consentement, l’intégrité et la dignité des personnes.

Le consentement doit être libre et peut être retiré à tout moment.

## Bilan

**Connaissance + prévention + dépistage + prise en charge = protection de la santé sexuelle.**
`,
    exercises:`## Exercice 1 — Vrai ou faux

1. Une IST peut parfois ne provoquer aucun symptôme.
2. Le préservatif peut contribuer à prévenir certaines IST.
3. La contraception protège toujours contre toutes les IST.
4. Le consentement doit être libre.

### Correction

1. Vrai. 2. Vrai. 3. Faux. 4. Vrai.

## Exercice 2 — Expliquer

Pourquoi le dépistage peut-il être important pour les IST ?

### Correction

Certaines IST peuvent être silencieuses. Le dépistage permet d’identifier une infection et de favoriser une prise en charge adaptée ainsi que la prévention de sa transmission.

## Exercice 3 — Situation

Un adolescent pense qu’une méthode contraceptive hormonale protège aussi automatiquement contre les IST. Que lui répondrais-tu ?

### Correction

La contraception hormonale vise principalement à prévenir une grossesse. Elle ne protège pas automatiquement contre les IST. Le préservatif contribue à réduire le risque de transmission de nombreuses IST.
`,
    reinforcement:`# RENFORCEMENT — Prévention

## Situation-problème

Une personne se demande pourquoi il faut parler de contraception et d’IST séparément.

### Correction

Les deux sujets concernent la santé sexuelle mais ne répondent pas exactement au même objectif. La contraception vise principalement à éviter une grossesse. La prévention des IST vise à réduire le risque d’infection et de transmission.

### À retenir

**Grossesse non prévue → contraception**

**IST → prévention, préservatif, dépistage et soins adaptés**
`,
    qcm:[
      ['Le préservatif contribue à :',['prévenir certaines IST et les grossesses','guérir toutes les infections','remplacer les vaccins','empêcher toute maladie'],0,'Le préservatif contribue à réduire le risque de nombreuses IST et de grossesse lorsqu’il est correctement utilisé.'],
      ['Une IST peut être :',['toujours visible','parfois asymptomatique','toujours mortelle','impossible à dépister'],1,'Certaines IST peuvent être asymptomatiques.'],
      ['La contraception vise principalement à :',['prévenir une grossesse','traiter toutes les IST','augmenter la fièvre','remplacer les reins'],0,'La contraception a pour objectif d’éviter une grossesse.'],
      ['Le dépistage permet notamment :',['d’identifier certaines infections','de produire des spermatozoïdes','de digérer les aliments','de remplacer la vaccination'],0,'Le dépistage permet de rechercher une infection.'],
      ['Le consentement doit être :',['forcé','libre','automatique','définitif'],1,'Le consentement doit être libre et peut être retiré.'],
      ['Certaines infections à papillomavirus peuvent être prévenues par :',['la vaccination','la digestion','le sommeil uniquement','la respiration'],0,'Une vaccination existe contre certains papillomavirus humains.']
    ],
    revision:`# FICHE DE RÉVISION — TRANSMISSION DE LA VIE ET SANTÉ

## Deux objectifs à distinguer

**Contraception → éviter une grossesse**

**Prévention des IST → réduire le risque d’infection et de transmission**

## Prévention des IST

- préservatif ;
- dépistage lorsque nécessaire ;
- vaccination contre certaines infections ;
- prise en charge médicale.

## À retenir

Une IST peut être présente sans symptôme.

Le consentement doit être libre, éclairé et respecté.
`
  },
  {
    code:'SVT-4e-10',
    title:'Microorganismes et maladies',
    description:'Identifier les microorganismes, comprendre les modes de transmission des maladies infectieuses et les mesures de prévention.',
    course:`# MICROORGANISMES ET MALADIES

## Introduction

Notre environnement contient de nombreux êtres microscopiques. Certains sont utiles, d’autres peuvent provoquer des maladies.

## 1. Qu’est-ce qu’un microorganisme ?

Un microorganisme est un être vivant ou une entité biologique microscopique que l’on ne peut généralement pas observer à l’œil nu.

On rencontre notamment :
- des bactéries ;
- des champignons microscopiques ;
- des protozoaires ;
- des virus, qui sont des agents infectieux particuliers.

## 2. Microorganismes utiles et pathogènes

Tous les microorganismes ne sont pas dangereux.

Certaines bactéries participent par exemple à la fabrication des aliments fermentés ou vivent normalement dans notre microbiote.

Un microorganisme **pathogène** peut provoquer une maladie dans certaines conditions.

## 3. Transmission des maladies infectieuses

Les agents infectieux peuvent se transmettre selon différents modes :
- par l’air et les gouttelettes ;
- par les mains et les objets contaminés ;
- par l’eau ou les aliments contaminés ;
- par le sang ;
- par les rapports sexuels ;
- par certains animaux vecteurs.

Le mode de transmission dépend de l’agent infectieux.

## 4. La contamination et l’infection

La **contamination** correspond à l’entrée d’un agent infectieux dans l’organisme.

L’**infection** correspond à sa multiplication et/ou à son développement dans l’organisme.

Une contamination n’entraîne pas nécessairement les mêmes conséquences dans tous les cas.

## 5. Prévenir la transmission

La prévention peut utiliser :
- le lavage des mains ;
- l’hygiène alimentaire ;
- l’eau potable ;
- l’aération des locaux ;
- la vaccination ;
- l’utilisation du préservatif pour les IST ;
- la lutte contre certains vecteurs.

## Bilan

**Agent infectieux → transmission → contamination → infection possible → symptômes ou maladie**

La prévention vise à interrompre une ou plusieurs étapes de cette chaîne.
`,
    exercises:`## Exercice 1 — Classer

Indique si les exemples suivants correspondent à un microorganisme ou à un mode de transmission : bactérie, eau contaminée, virus, gouttelettes respiratoires.

### Correction

Microorganismes/agents : bactérie, virus. Modes de transmission : eau contaminée, gouttelettes respiratoires.

## Exercice 2 — Expliquer

Pourquoi le lavage des mains peut-il limiter certaines infections ?

### Correction

Il permet d’éliminer ou de réduire la quantité de microorganismes présents sur les mains et limite ainsi leur transfert vers la bouche, le nez, les yeux, les aliments ou d’autres personnes.

## Exercice 3 — Raisonnement

Pourquoi faut-il adapter la prévention au mode de transmission ?

### Correction

Parce que les agents infectieux ne se transmettent pas tous de la même manière. Une mesure efficace contre une transmission par les mains n’est pas nécessairement suffisante contre une transmission par un vecteur ou par le sang.
`,
    reinforcement:`# RENFORCEMENT — Casser la chaîne de transmission

## Situation-problème

Dans une classe, plusieurs élèves tombent malades après une infection respiratoire.

### Mesures possibles

- aérer régulièrement la salle ;
- respecter l’hygiène des mains ;
- éviter de tousser directement vers les autres ;
- rester chez soi en cas de maladie lorsque cela est recommandé ;
- suivre les recommandations sanitaires.

### Idée essentielle

**Comprendre le mode de transmission permet de choisir une prévention adaptée.**
`,
    qcm:[
      ['Un microorganisme est généralement :',['observable facilement à l’œil nu','microscopique','toujours dangereux','toujours utile'],1,'Les microorganismes sont généralement observables avec un microscope.'],
      ['Tous les microorganismes sont-ils pathogènes ?',['Oui','Non','Seulement les bactéries','Seulement les virus'],1,'De nombreux microorganismes sont inoffensifs ou utiles.'],
      ['La contamination correspond notamment :',['à l’entrée d’un agent infectieux dans l’organisme','à la digestion','à la respiration','à la croissance'],0,'La contamination correspond à l’entrée d’un agent infectieux.'],
      ['Une maladie peut se transmettre par :',['des gouttelettes respiratoires','uniquement les aliments','uniquement le sang','jamais l’environnement'],0,'Les gouttelettes respiratoires constituent un mode de transmission pour certaines infections.'],
      ['Le lavage des mains :',['peut réduire certaines transmissions','provoque toutes les maladies','remplace tous les vaccins','est inutile'],0,'Le lavage des mains réduit le transfert de nombreux agents infectieux.'],
      ['La prévention doit être :',['adaptée au mode de transmission','toujours identique','inutile','basée uniquement sur les antibiotiques'],0,'Le mode de transmission détermine les mesures adaptées.']
    ],
    revision:`# FICHE DE RÉVISION — MICROORGANISMES

**Microorganisme** : organisme ou agent microscopique.

**Pathogène** : capable de provoquer une maladie dans certaines conditions.

**Contamination** : entrée d’un agent infectieux.

**Infection** : développement ou multiplication de l’agent dans l’organisme.

## Transmission

Air — mains/objets — eau/aliments — sang — rapports sexuels — vecteurs.

## Prévention

Hygiène des mains, eau potable, hygiène alimentaire, aération, vaccination, préservatif, lutte contre certains vecteurs.
`
  },
  {
    code:'SVT-4e-11',
    title:'Défenses de l’organisme',
    description:'Comprendre les barrières naturelles, la réaction immunitaire et le rôle des cellules de défense.',
    course:`# DÉFENSES DE L’ORGANISME

## Introduction

L’organisme est constamment exposé à des microorganismes. Il possède plusieurs systèmes de défense qui permettent de limiter les infections.

## 1. Les barrières naturelles

La peau et les muqueuses constituent des barrières physiques et chimiques.

D’autres mécanismes contribuent à la protection :
- mucus ;
- larmes ;
- salive ;
- acidité de certaines régions ;
- microbiote.

Ces barrières empêchent ou limitent l’entrée et l’installation de nombreux agents infectieux.

## 2. La réaction inflammatoire

Lorsqu’un tissu est agressé, une réaction inflammatoire peut apparaître.

Elle peut se manifester par :
- rougeur ;
- chaleur ;
- gonflement ;
- douleur.

Des cellules et des substances de défense interviennent alors sur le lieu de l’agression.

## 3. Les cellules immunitaires

Certains globules blancs peuvent reconnaître et détruire des agents infectieux.

Les **phagocytes** peuvent notamment englober et digérer des microorganismes : c’est la phagocytose.

D’autres lymphocytes participent à des réponses immunitaires spécifiques et peuvent produire des anticorps.

## 4. Les anticorps

Les anticorps sont des molécules produites par certaines cellules immunitaires. Ils reconnaissent spécifiquement certaines molécules étrangères.

Ils participent à la neutralisation et à l’élimination des agents infectieux ou de leurs antigènes.

## 5. La mémoire immunitaire

Après certaines infections ou après une vaccination, l’organisme peut conserver des cellules mémoires.

Lors d’un nouveau contact avec le même agent, la réponse peut être plus rapide et plus efficace.

## 6. La vaccination

La vaccination expose l’organisme à un élément permettant de préparer une réponse immunitaire sans provoquer la maladie de la même manière qu’une infection naturelle.

Elle permet de développer une mémoire immunitaire contre certaines maladies.

## Bilan

**Barrières → réaction rapide → réponse immunitaire spécifique → mémoire**
`,
    exercises:`## Exercice 1 — Identifier

Cite trois barrières naturelles de l’organisme.

### Correction

Par exemple : peau, muqueuses, mucus, larmes, salive.

## Exercice 2 — Expliquer

Qu’est-ce que la phagocytose ?

### Correction

C’est un mécanisme par lequel certaines cellules de défense englobent puis digèrent des microorganismes ou des particules étrangères.

## Exercice 3 — Raisonnement

Pourquoi une vaccination peut-elle protéger lors d’un contact ultérieur avec un agent infectieux ?

### Correction

La vaccination prépare le système immunitaire et peut permettre la formation d’une mémoire immunitaire. Lors d’un contact ultérieur, la réponse peut être plus rapide et plus efficace.
`,
    reinforcement:`# RENFORCEMENT — Pourquoi tombe-t-on parfois malade ?

## Situation-problème

Deux personnes rencontrent le même microorganisme. Une tombe malade, l’autre non.

### Explication

La maladie dépend de nombreux facteurs : quantité d’agents, voie d’entrée, état de l’organisme, immunité préalable, caractéristiques de l’agent infectieux, etc.

Le système immunitaire ne garantit pas qu’aucune infection ne se produira, mais il contribue à protéger l’organisme.

### Schéma

**Agent infectieux → barrières → défenses immunitaires → élimination ou contrôle**
`,
    qcm:[
      ['La peau constitue :',['une barrière de défense','un organe digestif','un globule blanc','un virus'],0,'La peau limite l’entrée des agents infectieux.'],
      ['La phagocytose est réalisée par certaines :',['cellules de défense','cellules musculaires uniquement','cellules osseuses','cellules alimentaires'],0,'Certains phagocytes peuvent englober et digérer des agents étrangers.'],
      ['Les anticorps sont :',['des molécules de défense','des aliments','des hormones digestives','des globules rouges'],0,'Les anticorps sont des molécules produites lors de certaines réponses immunitaires.'],
      ['La mémoire immunitaire permet notamment :',['une réponse plus rapide lors d’un nouveau contact','la digestion','la respiration','la production d’urine'],0,'Les cellules mémoires permettent une réponse secondaire plus rapide et efficace.'],
      ['La vaccination vise notamment à :',['préparer le système immunitaire','provoquer volontairement toutes les maladies','remplacer le sang','supprimer les anticorps'],0,'Elle prépare le système immunitaire contre certaines maladies.'],
      ['Une réaction inflammatoire peut provoquer :',['rougeur et gonflement','digestion des aliments','croissance des os uniquement','baisse systématique de la température'],0,'Rougeur, chaleur, gonflement et douleur sont des signes classiques de l’inflammation.']
    ],
    revision:`# FICHE DE RÉVISION — DÉFENSES DE L’ORGANISME

## Première protection

**Peau + muqueuses + sécrétions = barrières naturelles**

## Réponse immunitaire

Certaines cellules détruisent les agents infectieux.

**Phagocytose** = englober et digérer un agent étranger.

Les lymphocytes participent à des réponses spécifiques et certains permettent la production d’anticorps.

## Mémoire

Une vaccination ou certaines infections peuvent laisser une mémoire immunitaire.

**Mémoire → réponse secondaire plus rapide et efficace**
`
  },
  {
    code:'SVT-4e-12',
    title:'Prévention et protection de la santé',
    description:'Mettre en relation comportements, environnement, prévention et facteurs de risque pour protéger la santé individuelle et collective.',
    course:`# PRÉVENTION ET PROTECTION DE LA SANTÉ

## Introduction

La santé ne dépend pas d’un seul facteur. Elle résulte de l’interaction de facteurs biologiques, environnementaux, comportementaux et sociaux.

La prévention vise à réduire les risques et à favoriser la santé.

## 1. Prévention et protection

La prévention cherche à éviter l’apparition d’une maladie ou à en limiter les conséquences.

Elle peut être :
- individuelle ;
- collective ;
- comportementale ;
- médicale.

## 2. Hygiène de vie

Une bonne hygiène de vie comprend notamment :
- une alimentation variée et équilibrée ;
- une activité physique régulière ;
- un sommeil suffisant ;
- une bonne hygiène corporelle ;
- une hydratation adaptée ;
- l’évitement du tabac et des drogues ;
- une consommation d’alcool à éviter chez les mineurs.

## 3. Prévenir les maladies infectieuses

Les mesures comprennent selon les situations :
- vaccination ;
- lavage des mains ;
- eau potable ;
- conservation correcte des aliments ;
- ventilation des locaux ;
- protection contre les vecteurs ;
- préservatif pour réduire le risque de nombreuses IST.

## 4. Les facteurs de risque

Un facteur de risque est un élément qui augmente la probabilité de développer un problème de santé.

Exemples : tabagisme, sédentarité, alimentation déséquilibrée, exposition à certains polluants ou comportements à risque.

La présence d’un facteur de risque ne signifie pas qu’une maladie apparaîtra forcément.

## 5. Santé individuelle et santé collective

Certaines actions protègent à la fois l’individu et la collectivité.

La vaccination, l’hygiène, la surveillance sanitaire et l’accès aux soins participent à la protection collective.

## 6. Développer une attitude responsable

Face à une information de santé, il faut vérifier sa source et privilégier les recommandations des professionnels et des organismes de santé reconnus.

Une bonne décision de santé repose sur des informations fiables.

## Bilan

**Connaître les risques → adopter des comportements protecteurs → prévenir → consulter si nécessaire → protéger sa santé et celle des autres.**
`,
    exercises:`## Exercice 1 — Classer

Classe les actions suivantes : vaccination, tabagisme, activité physique, lavage des mains, sommeil insuffisant.

### Correction

Actions protectrices : vaccination, activité physique, lavage des mains.

Facteurs de risque : tabagisme, sommeil insuffisant.

## Exercice 2 — Expliquer

Pourquoi la prévention peut-elle être collective ?

### Correction

Certaines mesures réduisent non seulement le risque individuel mais aussi la transmission des maladies dans la population. C’est notamment le cas de certaines vaccinations et mesures d’hygiène.

## Exercice 3 — Raisonnement

Une information circulant sur les réseaux sociaux affirme qu’un produit « guérit toutes les infections ». Que faut-il faire ?

### Correction

Ne pas considérer cette affirmation comme vraie sans vérification. Rechercher une source médicale fiable et demander conseil à un professionnel de santé. Éviter l’automédication dangereuse.
`,
    reinforcement:`# RENFORCEMENT — Construire une stratégie de prévention

## Situation-problème

Une école souhaite réduire les infections respiratoires pendant une période de circulation importante de virus.

### Proposer des mesures

- aérer les salles ;
- renforcer l’hygiène des mains ;
- informer les élèves ;
- respecter les recommandations sanitaires ;
- favoriser une consultation en cas de symptômes nécessitant un avis médical.

### Idée essentielle

La prévention efficace associe **information, comportements adaptés, mesures collectives et accès aux soins**.
`,
    qcm:[
      ['La prévention vise notamment à :',['réduire les risques','provoquer les maladies','remplacer tous les médecins','supprimer le sommeil'],0,'La prévention vise à réduire les risques et les conséquences des problèmes de santé.'],
      ['Lequel est un comportement protecteur ?',['tabagisme','activité physique régulière','sédentarité totale','consommation excessive de substances'],1,'L’activité physique régulière participe à une bonne hygiène de vie.'],
      ['La vaccination participe à :',['la prévention de certaines maladies','la digestion','la production de nourriture','la croissance des cheveux'],0,'La vaccination prépare une protection immunitaire contre certaines maladies.'],
      ['Un facteur de risque :',['garantit une maladie','peut augmenter la probabilité d’un problème de santé','est toujours un médicament','est toujours une infection'],1,'Un facteur de risque augmente la probabilité sans garantir l’apparition d’une maladie.'],
      ['Face à une information de santé douteuse, il faut :',['la partager immédiatement','vérifier sa source','arrêter tous les traitements','croire uniquement les réseaux sociaux'],1,'La vérification de la source est essentielle.'],
      ['Une mesure collective peut :',['protéger plusieurs personnes','ne protéger que les animaux','être toujours inutile','remplacer l’hygiène'],0,'Certaines mesures collectives réduisent les risques pour une population.']
    ],
    revision:`# FICHE DE RÉVISION — PRÉVENTION ET SANTÉ

## Prévention

**Prévenir = réduire le risque ou les conséquences d’un problème de santé.**

## Hygiène de vie

- alimentation variée et équilibrée ;
- activité physique ;
- sommeil suffisant ;
- hydratation ;
- hygiène ;
- éviter tabac et drogues.

## Prévention des infections

Vaccination, lavage des mains, eau potable, hygiène alimentaire, aération, protection contre les vecteurs, préservatif pour les IST.

## À retenir

**Facteur de risque ≠ maladie certaine.**

Toujours vérifier les informations de santé auprès de sources fiables et de professionnels lorsque nécessaire.
`
  }
];

function makeExercises(title, text){ return text; }

async function upsertResource(chapitreId, niveau, matiereId, r){
  const data={
    type:r.type,titre:r.titre,ordre:r.ordre,chapitreId,niveau,matiereId,ecoleId:'',
    contenu:r.contenu||'',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',
    enonce:r.enonce||'',solution:r.solution||'',difficulte:r.type==='quiz'?2:1,
    ressourceLieeId:'',questions:r.questions||[],dureeMinutes:r.type==='cours'?30:r.type==='quiz'?15:25,
    examen:false,annee:2026,serie:'',actif:true,ressourceNationale:true,
    auteur:'Sentinelle CI — contenu pédagogique enrichi',dateMaj:FieldValue.serverTimestamp()
  };
  const q=await db.collection('ca_ressources').where('chapitreId','==',chapitreId).where('type','==',r.type).limit(1).get();
  if(q.empty){data.dateCreation=FieldValue.serverTimestamp();await db.collection('ca_ressources').add(data);}
  else await q.docs[0].ref.set(data,{merge:true});
}

async function main(){
  let total=0;
  for(const ch of chapters){
    const q=await db.collection('ca_chapitres').where('code','==',ch.code).limit(1).get();
    if(q.empty){console.log('Chapitre absent:',ch.code);continue;}
    const ref=q.docs[0].ref;
    await ref.set({description:ch.description,dateMaj:FieldValue.serverTimestamp()},{merge:true});
    const resources=[
      {type:'cours',titre:'Cours complet — '+ch.title,ordre:1,contenu:ch.course},
      {type:'exercices',titre:'Exercices — '+ch.title,ordre:2,contenu:ch.exercises,enonce:ch.exercises,solution:''},
      {type:'renforcement',titre:'Renforcement — '+ch.title,ordre:3,contenu:ch.reinforcement},
      {type:'quiz',titre:'Quiz — '+ch.title,ordre:4,contenu:'# QCM — '+ch.title,questions:ch.qcm.map((q,i)=>({id:'q'+(i+1),type:'qcm',enonce:q[0],choix:q[1],bonnesReponses:[q[2]],reponseAttendue:'',explication:q[3],points:1}))},
      {type:'revision',titre:'Fiche de révision — '+ch.title,ordre:5,contenu:ch.revision}
    ];
    for(const r of resources){await upsertResource(ref.id,'4e','svt',r);total++;}
  }
  await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),derniereMaj:FieldValue.serverTimestamp()},{merge:true});
  console.log(JSON.stringify({ok:true,chaptersProcessed:chapters.length,resourcesUpdated:total},null,2));
}
main().catch(e=>{console.error('ENRICH_SVT4E_ALL_ERROR',e.stack||e);process.exit(1);});

const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();

const chapterCode = 'SVT-4e-01';
const title = 'Fonction de nutrition chez l’Homme';

const cours = `# FONCTION DE NUTRITION CHEZ L’HOMME

## Introduction

Pour vivre, grandir, se déplacer et réaliser ses différentes activités, l’être humain a besoin d’énergie et de matières nutritives.

Ces éléments proviennent des **aliments** que nous consommons.

Mais les aliments tels que nous les mangeons ne peuvent pas tous être directement utilisés par notre organisme. Ils doivent subir des transformations dans le tube digestif.

La fonction de nutrition permet donc à l’organisme de :
- se procurer les **nutriments** nécessaires ;
- apporter du **dioxygène** aux cellules ;
- utiliser ces substances pour produire de l’énergie ;
- éliminer les **déchets** produits par le fonctionnement des cellules.

## A. Les besoins nutritifs de l’Homme

### 1. Les aliments

Les aliments contiennent différents constituants :
- les **glucides** ;
- les **lipides** ;
- les **protides** ;
- les **vitamines** ;
- les **sels minéraux** ;
- l’**eau**.

Les glucides et les lipides fournissent principalement de l'énergie.

Les protides participent notamment à la construction et au renouvellement des tissus de l'organisme.

L'eau, les vitamines et les sels minéraux sont indispensables au bon fonctionnement de l'organisme.

### 2. Le dioxygène

Les cellules ont également besoin de **dioxygène (O₂)**.

Le dioxygène provient de l'air inspiré.

Il est prélevé au niveau des poumons puis transporté par le sang vers les organes.

## B. La digestion des aliments

### 1. Qu'est-ce que la digestion ?

La **digestion** est l'ensemble des transformations que subissent les aliments dans le tube digestif afin de produire des nutriments absorbables par l'organisme.

Les aliments complexes sont donc transformés en substances plus simples.

### 2. Le tube digestif

Le tube digestif comprend principalement :

**Bouche → œsophage → estomac → intestin grêle → gros intestin → anus**

La digestion commence dans la **bouche**.

Les aliments y sont :
- mastiqués par les dents ;
- mélangés à la salive ;
- transformés progressivement en une pâte appelée **bol alimentaire**.

Le bol alimentaire est ensuite avalé et passe dans l'œsophage.

### 3. L'estomac

Dans l'estomac, les aliments sont brassés et mélangés aux sucs digestifs.

Ils subissent des transformations chimiques.

La digestion se poursuit ainsi avant le passage du contenu digestif dans l'intestin grêle.

### 4. L'intestin grêle

L'intestin grêle joue un rôle essentiel.

C'est principalement à son niveau que les nutriments issus de la digestion passent dans le sang.

Ce passage est appelé **absorption intestinale**.

### 5. Les nutriments

Les **nutriments** sont des substances simples provenant de la digestion des aliments et pouvant être directement utilisées par les cellules.

Exemples :
- le glucose ;
- les acides aminés ;
- les acides gras ;
- le glycérol ;
- l'eau ;
- les vitamines ;
- les sels minéraux.

## C. Le transport des nutriments dans l'organisme

Une fois absorbés au niveau de l'intestin grêle, les nutriments rejoignent le **sang**.

Le sang les transporte vers les différents organes.

Les cellules prélèvent dans le sang les substances dont elles ont besoin.

**Aliments → digestion → nutriments → absorption intestinale → sang → cellules**

## D. Le rôle de l'appareil respiratoire

Pour fonctionner, les cellules ont besoin de dioxygène.

L'appareil respiratoire permet à l'organisme de prendre le dioxygène présent dans l'air.

### Le trajet de l'air

**Nez/bouche → trachée → bronches → bronchioles → poumons**

Au niveau des poumons, le dioxygène passe dans le sang.

En même temps, le **dioxyde de carbone (CO₂)** produit par les cellules passe du sang vers l'air contenu dans les poumons et est ensuite rejeté lors de l'expiration.

## E. Le rôle du sang

Le sang assure le transport de nombreuses substances dans l'organisme.

Il transporte notamment :
- le dioxygène ;
- les nutriments ;
- le dioxyde de carbone ;
- certains déchets.

Le sang constitue donc un véritable **moyen de transport entre les organes et les cellules**.

## F. L'utilisation des nutriments et du dioxygène par les cellules

Les cellules utilisent les nutriments et le dioxygène pour assurer leur fonctionnement.

Cette utilisation permet notamment de libérer de l'énergie.

**Nutriments + dioxygène → énergie + dioxyde de carbone + eau**

L'énergie produite permet à l'organisme de réaliser ses différentes activités :
- mouvements ;
- croissance ;
- fonctionnement des organes ;
- maintien de la température corporelle ;
- activités intellectuelles.

## G. L'élimination des déchets

Le fonctionnement des cellules produit des déchets.

Le dioxyde de carbone est principalement éliminé par les **poumons**.

D'autres déchets sont éliminés notamment par les **reins**, qui participent à la formation de l'urine.

Ainsi, l'organisme doit constamment :

**apporter des substances utiles aux cellules ET éliminer les déchets.**

## À RETENIR

La fonction de nutrition comprend plusieurs grandes fonctions :

**Alimentation → digestion → absorption → transport → respiration → utilisation par les cellules → élimination des déchets**

La fonction de nutrition permet donc à l'organisme de fournir aux cellules les substances nécessaires à leur fonctionnement.
`;

const exercices = [
['Compléter les phrases','Complète avec : nutriments – intestin grêle – dioxygène – digestion – sang. 1. La transformation des aliments dans le tube digestif constitue la ______. 2. Les substances simples obtenues après digestion sont appelées ______. 3. L’absorption intestinale se réalise principalement au niveau de l’______. 4. Le ______ transporte les nutriments vers les organes. 5. Les cellules ont besoin de ______ pour libérer de l’énergie.','1. digestion\n2. nutriments\n3. intestin grêle\n4. sang\n5. dioxygène'],
['Vrai ou faux','1. La digestion commence dans la bouche.\n2. L’œsophage est un organe respiratoire.\n3. Les nutriments peuvent passer dans le sang.\n4. Les poumons permettent les échanges gazeux.\n5. Les cellules n’ont pas besoin de dioxygène.\n6. Les reins participent à l’élimination de certains déchets.','1. Vrai\n2. Faux\n3. Vrai\n4. Vrai\n5. Faux\n6. Vrai'],
['Raisonnement scientifique','Après avoir mangé un repas, les nutriments issus de la digestion passent dans le sang. Explique comment les nutriments peuvent parvenir jusqu’aux cellules musculaires des jambes.','Les aliments sont digérés dans le tube digestif. Les nutriments obtenus sont absorbés principalement au niveau de l’intestin grêle et passent dans le sang. Le sang les transporte ensuite jusqu’aux différents organes, notamment les muscles des jambes. Les cellules musculaires prélèvent les nutriments dont elles ont besoin.']
];

const qcm = [
['Où commence la digestion ?',['Dans l’estomac','Dans la bouche','Dans l’intestin grêle','Dans les poumons'],1,'La digestion commence dans la bouche avec la mastication et l’action de la salive.'],
['Les nutriments sont :',['des déchets','des substances simples utilisables par les cellules','uniquement des vitamines','uniquement des glucides'],1,'Les nutriments sont des substances simples pouvant être utilisées par les cellules.'],
['Où se réalise principalement l’absorption des nutriments ?',['Dans l’œsophage','Dans l’estomac','Dans l’intestin grêle','Dans la bouche'],2,'L’absorption des nutriments se réalise principalement dans l’intestin grêle.'],
['Quel gaz est nécessaire aux cellules pour produire de l’énergie ?',['Dioxyde de carbone','Azote','Dioxygène','Vapeur d’eau'],2,'Le dioxygène est nécessaire au fonctionnement des cellules.'],
['Quel organe permet principalement les échanges entre l’air et le sang ?',['L’estomac','Les poumons','Les reins','Le foie'],1,'Les poumons assurent les échanges gazeux entre l’air et le sang.'],
['Quelle substance est principalement éliminée par les poumons ?',['Le glucose','Le dioxygène','Le dioxyde de carbone','Les protéines'],2,'Le dioxyde de carbone est rejeté principalement par les poumons.'],
['Quel est le rôle principal du sang dans la nutrition ?',['Mastiquer les aliments','Transporter différentes substances','Digérer les aliments','Produire les aliments'],1,'Le sang transporte notamment les nutriments et le dioxygène.'],
['Les cellules utilisent principalement les nutriments et le dioxygène pour :',['produire de l’énergie','fabriquer de l’air','digérer les aliments','produire des déchets uniquement'],0,'Les cellules utilisent les nutriments et le dioxygène pour libérer de l’énergie.'],
['Quel organe participe à l’élimination des déchets par l’urine ?',['Le poumon','L’estomac','Le rein','L’œsophage'],2,'Les reins participent à l’élimination de certains déchets dans l’urine.']
];

const fiche = `# FONCTION DE NUTRITION CHEZ L'HOMME

## Les mots-clés

**Aliment** : substance consommée par l'être humain.

**Digestion** : transformation des aliments dans le tube digestif.

**Nutriment** : substance simple utilisable directement par les cellules.

**Absorption intestinale** : passage des nutriments de l'intestin vers le sang.

**Respiration** : ensemble des échanges permettant notamment l'entrée du dioxygène et le rejet du dioxyde de carbone.

## À connaître absolument

**1. Le trajet des aliments**

**Bouche → œsophage → estomac → intestin grêle → gros intestin → anus**

**2. Le trajet des nutriments**

**Aliments → digestion → nutriments → intestin grêle → sang → cellules**

**3. Le trajet du dioxygène**

**Air → poumons → sang → cellules**

**4. L'élimination du dioxyde de carbone**

**Cellules → sang → poumons → air extérieur**

## Schéma essentiel

**ALIMENTS → DIGESTION → NUTRIMENTS → INTESTIN GRÊLE → SANG → CELLULES**

En parallèle :

**AIR → POUMONS → SANG → CELLULES**

Dans les cellules :

**Nutriments + dioxygène → énergie + déchets**

## Ce que l'élève doit savoir faire

L'élève de 4ème doit être capable de :
- définir la digestion ;
- citer les principaux organes du tube digestif ;
- expliquer le rôle de l'intestin grêle ;
- définir un nutriment ;
- expliquer le rôle du sang ;
- expliquer le rôle des poumons ;
- expliquer pourquoi les cellules ont besoin de dioxygène ;
- expliquer comment les nutriments atteignent les cellules ;
- identifier les principaux déchets produits par l'organisme ;
- construire et expliquer un schéma simple de la fonction de nutrition.
`;

const renforcement = `# RENFORCEMENT — Fonction de nutrition chez l'Homme

## Situation-problème

Un élève affirme :

> « Quand je mange, les aliments vont directement dans mes muscles pour leur donner de l'énergie. »

### Question

Cette affirmation est-elle correcte ? Explique ta réponse.

### Correction

Cette affirmation est **incorrecte**.

Les aliments ne vont pas directement dans les muscles.

Ils passent d'abord dans le **tube digestif**, où ils sont transformés par la digestion.

Les nutriments obtenus sont ensuite absorbés au niveau de l'**intestin grêle** et passent dans le **sang**.

Le sang les transporte jusqu'aux muscles.

Les cellules musculaires utilisent ensuite les nutriments et le dioxygène pour produire l'énergie nécessaire à leur fonctionnement.

## Schéma-bilan

**Aliments → Digestion → Nutriments → Intestin grêle → Sang → Muscles → Utilisation avec le dioxygène → Libération d'énergie**
`;

async function main(){
 const cq=await db.collection('ca_chapitres').where('code','==',chapterCode).limit(1).get();
 if(cq.empty) throw new Error('Chapitre '+chapterCode+' introuvable');
 const chapitre=cq.docs[0];
 const chapitreId=chapitre.id;
 await chapitre.ref.set({description:'Fonction de nutrition chez l’Homme — cours complet, exercices, renforcement, QCM et fiche de révision adaptés au niveau 4e.',dateMaj:FieldValue.serverTimestamp()},{merge:true});

 const resources=[
  {type:'cours',titre:'Cours complet — '+title,ordre:1,contenu:cours,enonce:'',solution:''},
  {type:'exercices',titre:'Exercices — '+title,ordre:2,contenu:exercices.map((e,i)=>'## Exercice '+(i+1)+' — '+e[0]+'\n\n'+e[1]+'\n\n### Correction\n'+e[2]).join('\n\n'),enonce:exercices.map((e,i)=>(i+1)+'. '+e[1]).join('\n\n'),solution:exercices.map((e,i)=>(i+1)+'. '+e[2]).join('\n\n')},
  {type:'renforcement',titre:'Renforcement — '+title,ordre:3,contenu:renforcement,enonce:'',solution:''},
  {type:'quiz',titre:'Quiz — '+title,ordre:4,contenu:'# QCM — '+title,questions:qcm.map((q,i)=>({id:'q'+(i+1),type:'qcm',enonce:q[0],choix:q[1],bonnesReponses:[q[2]],reponseAttendue:'',explication:q[3],points:1})),dureeMinutes:12},
  {type:'revision',titre:'Fiche de révision — '+title,ordre:5,contenu:fiche,enonce:'',solution:''}
 ];
 for(const r of resources){
  const rq=await db.collection('ca_ressources').where('chapitreId','==',chapitreId).where('type','==',r.type).limit(1).get();
  const data={type:r.type,titre:r.titre,ordre:r.ordre,chapitreId,niveau:'4e',matiereId:'svt',ecoleId:'',contenu:r.contenu||'',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:r.enonce||'',solution:r.solution||'',difficulte:r.type==='quiz'?2:1,ressourceLieeId:'',questions:r.questions||[],dureeMinutes:r.dureeMinutes||30,examen:false,annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'Sentinelle CI — contenu fourni par utilisateur',dateMaj:FieldValue.serverTimestamp()};
  if(rq.empty){data.dateCreation=FieldValue.serverTimestamp(); await db.collection('ca_ressources').add(data);} else {await rq.docs[0].ref.set(data,{merge:true});}
 }
 await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),dateMaj:FieldValue.serverTimestamp(),derniereRessourceNationale:'SVT_4e_fonction_nutrition_homme_test'},{merge:true});
 console.log(JSON.stringify({ok:true,chapitreId,resourcesUpdated:5},null,2));
}
main().catch(e=>{console.error('ENRICH_SVT4E_ERROR',e.stack||e);process.exit(1);});

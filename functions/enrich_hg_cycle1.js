const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({credential:applicationDefault(),projectId:'sentinel-ci-c7592'});
const db=getFirestore();

const data={
'6e':[
['Les premières sociétés humaines','Les premières sociétés humaines vivaient de chasse, de pêche, de cueillette puis, progressivement, d’agriculture et d’élevage. L’étude des outils, des habitats et des restes archéologiques permet de reconstituer leur mode de vie.','Un outil en pierre taillée peut renseigner sur les techniques utilisées et sur les activités quotidiennes.','Explique deux indices permettant aux historiens et archéologues de connaître la vie des premières sociétés.'],
['La Préhistoire en Afrique','L’Afrique occupe une place majeure dans l’histoire ancienne de l’humanité. Les découvertes archéologiques montrent une longue évolution des techniques, des modes de vie et des formes d’organisation.','Des sites archéologiques africains livrent des outils, des ossements et d’autres traces permettant de reconstituer le passé.','Distingue une source archéologique d’une interprétation historique et explique leur complémentarité.'],
['L’Égypte ancienne','L’Égypte ancienne s’est développée autour du Nil. L’agriculture bénéficiait de l’eau et des terres fertiles. Le pharaon exerçait un pouvoir politique et religieux important et la société était organisée en groupes aux fonctions différentes.','Le calendrier agricole dépendait du rythme du Nil et des travaux des champs.','Explique pourquoi le Nil était essentiel à la vie de l’Égypte ancienne.'],
['Les civilisations de l’Afrique ancienne','Les sociétés africaines anciennes ont développé des formes variées d’organisation politique, économique et culturelle. L’agriculture, le commerce, les techniques et les échanges ont contribué à leur développement.','Les échanges entre régions favorisaient la circulation de produits, de techniques et d’idées.','Donne trois éléments permettant de caractériser une civilisation et applique-les à une société africaine ancienne.'],
['La Grèce antique','Les cités grecques étaient des communautés politiques indépendantes. Athènes développa une forme de démocratie réservée à une partie de la population. Les Grecs partagèrent aussi des pratiques religieuses et culturelles.','À Athènes, les citoyens participaient à certaines décisions politiques, mais les femmes, esclaves et étrangers n’avaient pas les mêmes droits politiques.','Explique pourquoi la démocratie athénienne ne correspond pas exactement à la citoyenneté moderne.'],
['Rome antique','Rome passa d’une cité à une puissance méditerranéenne puis à un vaste empire. Son organisation reposait notamment sur l’armée, les routes, les villes et une administration étendue.','Les voies romaines facilitaient le déplacement des soldats, des marchandises et des informations.','Explique deux facteurs qui ont favorisé l’expansion de Rome.'],
['Les grands repères géographiques','Pour se repérer, on utilise les points cardinaux, les coordonnées géographiques, les continents, les océans et les grands ensembles du relief. Une carte représente l’espace selon une échelle et une légende.','Sur une carte, la légende permet de comprendre la signification des couleurs et des symboles.','Localise la Côte d’Ivoire, l’Afrique de l’Ouest et l’océan Atlantique en utilisant les principaux repères.'],
['Les milieux naturels de Côte d’Ivoire','La Côte d’Ivoire présente des milieux variés influencés par le relief, le climat, les sols et la végétation. Le sud est plus humide tandis que les conditions deviennent plus sèches vers le nord.','La végétation forestière est particulièrement présente dans les régions plus humides.','Explique comment le climat influence la végétation et les activités humaines.'],
['Population et peuplement','La population est répartie de manière inégale dans l’espace. Les densités dépendent notamment des possibilités économiques, des ressources, des transports et de l’histoire des territoires.','Les grandes villes attirent des populations en raison des emplois, des services et des infrastructures.','Donne trois facteurs pouvant expliquer une forte concentration de population.'],
['Les activités économiques','Les activités économiques comprennent notamment l’agriculture, l’élevage, la pêche, l’industrie, le commerce et les services. Elles utilisent des ressources et transforment les territoires.','Une chaîne de production agricole peut relier production, transformation, transport, commercialisation et consommation.','Construis une chaîne simple reliant une production agricole à sa consommation.'],
['L’agriculture et les ressources','L’agriculture dépend du climat, des sols, de l’eau, des techniques et de l’accès aux marchés. Les ressources naturelles doivent être exploitées en tenant compte de leur renouvellement et de leurs impacts.','Une culture peut être productive mais provoquer une dégradation des sols si les pratiques ne préservent pas leur fertilité.','Explique pourquoi une ressource naturelle doit être gérée durablement.'],
['Organisation de l’espace ivoirien','Le territoire ivoirien est organisé autour de villes, axes de transport, espaces agricoles, zones industrielles et littorales. Les activités créent des flux entre les territoires.','Abidjan joue un rôle majeur dans les échanges, les services, les transports et l’activité économique nationale.','Explique comment les transports relient les différents espaces d’un pays.']
],
'5e':[
['Le christianisme et l’islam au Moyen Âge','Le christianisme et l’islam sont deux grandes religions qui se développent et structurent des sociétés au Moyen Âge. Leur expansion influence les territoires, les cultures, les échanges et les pouvoirs politiques.','Les villes et routes commerciales facilitent la circulation des personnes, des marchandises et des idées.','Compare le rôle d’une religion dans la société médiévale avec un autre rôle social ou culturel.'],
['Les grands empires africains','Les empires africains médiévaux contrôlaient des territoires et des réseaux commerciaux. Leur puissance reposait notamment sur l’organisation politique, les ressources et le commerce à longue distance.','Le contrôle des routes et des zones productrices renforçait les revenus et le pouvoir des souverains.','Explique deux facteurs de puissance d’un empire africain médiéval.'],
['L’empire du Mali','L’empire du Mali s’est développé en Afrique de l’Ouest grâce à l’organisation politique et au contrôle de zones et routes commerciales. Le commerce de l’or et du sel joua un rôle majeur.','Mansa Moussa est associé à la puissance du Mali et à son rayonnement dans le monde musulman.','Explique le lien entre commerce de l’or, pouvoir politique et rayonnement du Mali.'],
['L’empire Songhaï','L’empire Songhaï s’est développé autour du Niger et de grands centres urbains et commerciaux. Son organisation politique et militaire permit une expansion importante avant son affaiblissement à la fin du XVIe siècle.','Tombouctou et Gao furent des centres importants de commerce et de savoir.','Explique pourquoi les villes commerciales peuvent renforcer la puissance d’un empire.'],
['Les échanges transsahariens','Les routes transsahariennes reliaient l’Afrique du Nord et l’Afrique subsaharienne. Les caravanes transportaient notamment du sel, de l’or et d’autres produits. Ces échanges favorisaient aussi la circulation des hommes et des idées.','Le commerce caravanier nécessitait une organisation adaptée aux longues distances et aux contraintes du désert.','Explique deux difficultés des échanges transsahariens et une solution utilisée par les commerçants.'],
['Les sociétés et cultures africaines','Les sociétés africaines médiévales étaient diverses par leurs organisations politiques, leurs activités, leurs langues et leurs pratiques culturelles. Les échanges ont favorisé des influences réciproques.','Les centres urbains pouvaient être à la fois des marchés, des lieux de pouvoir et des centres intellectuels.','Montre comment le commerce peut aussi produire des échanges culturels.'],
['Les grands ensembles du relief','Le relief comprend des montagnes, plateaux, plaines et vallées. Il influence les déplacements, l’agriculture, l’implantation des villes et parfois les activités industrielles.','Une plaine facilite généralement les transports et certaines cultures, tandis qu’un relief escarpé peut rendre les déplacements plus difficiles.','Explique deux conséquences du relief sur les activités humaines.'],
['Les climats et végétations','Le climat se décrit à partir de températures et de précipitations observées sur une longue période. Les végétations dépendent notamment du climat, des sols et de l’eau.','Une région chaude et humide peut favoriser une végétation dense, alors qu’une région plus sèche présente une végétation adaptée au manque d’eau.','Explique le lien entre précipitations, végétation et activités agricoles.'],
['Population et migrations','Les migrations sont des déplacements de population liés à des raisons économiques, sociales, politiques, familiales ou environnementales. Elles transforment les territoires de départ et d’arrivée.','Une personne peut migrer vers une ville pour chercher un emploi ou poursuivre des études.','Distingue migration, mobilité quotidienne et déplacement touristique.'],
['Les villes et l’urbanisation','L’urbanisation correspond à l’augmentation de la population vivant dans les villes et à l’extension des espaces urbains. Elle crée des besoins en logements, transports, eau, énergie et services.','Une ville qui s’étend rapidement doit organiser les transports et les équipements pour éviter l’isolement de certains quartiers.','Cite trois défis liés à une urbanisation rapide.'],
['Agriculture et élevage','L’agriculture et l’élevage fournissent des aliments et des matières premières. Les systèmes de production dépendent des conditions naturelles, des techniques, des marchés et des choix des producteurs.','L’irrigation peut améliorer la production dans certaines zones mais nécessite une gestion raisonnée de l’eau.','Explique un avantage et un risque d’une intensification agricole.'],
['Les ressources naturelles','Les ressources naturelles comprennent l’eau, les sols, les forêts, les minerais et les ressources énergétiques. Leur exploitation peut soutenir le développement mais aussi provoquer des dégradations si elle n’est pas maîtrisée.','Une forêt fournit du bois et des services écologiques, mais sa surexploitation peut réduire la biodiversité et dégrader les sols.','Propose deux règles pour exploiter une ressource tout en la préservant.']
]
};

function course(title,lesson,example,exercise){
return ['# '+title,'','## 1. Leçon',lesson,'','## 2. Exemple','**'+example+'**','','## 3. Méthode','Pour répondre à une question d’histoire-géographie : identifier le lieu ou la période, définir les mots importants, utiliser les informations du document puis construire une réponse organisée.','','## 4. Application',exercise,'','## 5. À retenir','**Repère → explique → justifie → conclus.**'].join('\n');
}
function questions(title){
return [
{id:'q1',type:'qcm',enonce:'Quel élément est central pour comprendre « '+title+' » ?',choix:['Les repères, notions et relations étudiés dans le chapitre','Un élément sans rapport avec le chapitre','Une opinion personnelle','Aucune information'],bonnesReponses:[0],points:1,explication:'La réponse doit s’appuyer sur les notions et repères du chapitre.'},
{id:'q2',type:'qcm',enonce:'Quelle démarche est adaptée en histoire-géographie ?',choix:['Identifier les informations puis les relier pour expliquer','Répondre sans lire les documents','Mémoriser sans comprendre','Ignorer les repères spatiaux ou temporels'],bonnesReponses:[0],points:1,explication:'Une réponse solide relie les informations aux repères et au raisonnement.'},
{id:'q3',type:'qcm',enonce:'Que faut-il faire avant de conclure ?',choix:['Justifier avec des éléments précis','Inventer une information','Changer de sujet','Supprimer les repères'],bonnesReponses:[0],points:1,explication:'Une conclusion doit être fondée sur les informations disponibles.'}
];
}
function fiche(title,lesson){
return ['# Fiche de révision — '+title,'','## Notion essentielle',lesson,'','## Réflexes','• Situer dans le temps ou l’espace.','• Définir les termes importants.','• Donner au moins un exemple précis.','• Relier cause, conséquence ou organisation.','• Rédiger une conclusion courte et justifiée.'].join('\n');
}
async function resource(ch,type){
const s=await db.collection('ca_ressources').where('chapitreId','==',ch).where('type','==',type).limit(5).get();return s.empty?null:s.docs[0];
}
async function main(){
let updated=0,created=0;
for(const [niveau,items] of Object.entries(data)){
for(let i=0;i<items.length;i++){
const [title,lesson,example,exercise]=items[i];
const code='HG-'+niveau+'-'+String(i+1).padStart(2,'0');
const s=await db.collection('ca_chapitres').where('code','==',code).limit(1).get();
if(s.empty){console.log('CHAPITRE_ABSENT',code);continue;}
const ch=s.docs[0];
const base={chapitreId:ch.id,niveau,matiereId:'hg',ecoleId:'',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:1,ressourceLieeId:'',dureeMinutes:25,examen:false,annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'sentinel-pedagogie-hg-2026',dateMaj:FieldValue.serverTimestamp()};
const rs=[
{type:'cours',titre:'Cours complet — '+title,ordre:1,contenu:course(title,lesson,example,exercise),questions:[]},
{type:'exercices',titre:'Exercices corrigés — '+title,ordre:2,contenu:'## Exercice 1\n'+exercise+'\n\n### Correction guidée\nRepère la période ou l’espace concerné, utilise deux informations du cours et termine par une phrase qui répond directement à la question.\n\n## Exercice 2\nDonne un exemple concret et explique son lien avec la notion étudiée.',questions:[]},
{type:'renforcement',titre:'Renforcement — '+title,ordre:3,contenu:'## Défi\nExplique le chapitre en cinq phrases sans recopier le cours. Puis écris une question qu’un camarade pourrait poser et donne sa réponse.',questions:[]},
{type:'quiz',titre:'Quiz — '+title,ordre:4,contenu:'QCM corrigé : chaque réponse est accompagnée d’une explication.',questions:questions(title)},
{type:'revision',titre:'Fiche de révision — '+title,ordre:5,contenu:fiche(title,lesson),questions:[]}
];
for(const item of rs){
const old=await resource(ch.id,item.type);const payload={...base,...item,dateMaj:FieldValue.serverTimestamp()};
if(old){await old.ref.update(payload);updated++;}else{await db.collection('ca_ressources').add({...payload,dateCreation:FieldValue.serverTimestamp()});created++;}
}
}
}
await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),anneeScolaire:'2026-2027',derniereRessourceNationale:'hg_cycle1_approfondi',dateMaj:FieldValue.serverTimestamp()},{merge:true});
console.log(JSON.stringify({ok:true,updated,created},null,2));
}
main().catch(e=>{console.error('ENRICH_HG_ERROR');console.error(e&&e.stack?e.stack:e);process.exit(1);});

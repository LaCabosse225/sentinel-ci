const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db=getFirestore();
const niveau='4e', matiereId='hg', anneeScolaire='2026-2027';
const titres=[
'Les Européens et les grandes découvertes','La traite négrière atlantique','Les empires coloniaux','La révolution industrielle',
'Le mouvement impérialiste','La colonisation de l’Afrique','Le relief et les climats de l’Afrique','La population africaine',
'Les activités économiques de l’Afrique','L’agriculture africaine','Les ressources minières et énergétiques','Les échanges et transports en Afrique'
];
const details=[
'À partir du XVe siècle, les royaumes européens recherchent de nouvelles routes commerciales vers l’Asie. Les progrès des navires, des cartes et de la navigation facilitent les expéditions. Les voyages de Christophe Colomb, Vasco de Gama et Magellan intensifient les contacts entre continents et entraînent des échanges, des conquêtes et des rivalités.',
'Du XVIe au XIXe siècle, la traite atlantique déporte des millions d’Africains vers les Amériques. Les captifs sont soumis à la violence, transportés par mer puis réduits en esclavage. Ce système transforme profondément les sociétés africaines, européennes et américaines et constitue un épisode majeur de l’histoire mondiale.',
'Les puissances européennes construisent des empires coloniaux en Amérique, en Afrique et en Asie. Une colonie est placée sous la domination politique, militaire et économique d’une puissance extérieure. Les populations colonisées réagissent par des stratégies variées : négociation, adaptation, résistance ou révolte.',
'La révolution industrielle transforme la production à partir du XVIIIe siècle. La mécanisation, la machine à vapeur puis l’électricité favorisent le développement des usines. L’industrialisation accélère l’urbanisation, modifie l’organisation du travail et augmente fortement les capacités de production, tout en provoquant des conditions de travail difficiles à ses débuts.',
'Au XIXe siècle, plusieurs puissances renforcent leur domination sur des territoires d’Afrique et d’Asie. L’impérialisme désigne une politique d’expansion et de domination. Les intérêts économiques, stratégiques, politiques et les idéologies de l’époque jouent un rôle dans cette expansion. Les conquêtes rencontrent de nombreuses résistances.',
'À la fin du XIXe siècle, la majorité de l’Afrique passe progressivement sous domination européenne. Les puissances imposent ou négocient des frontières et organisent l’administration des territoires. Les sociétés africaines connaissent de profondes transformations politiques, économiques et sociales et plusieurs peuples résistent aux conquêtes.',
'L’Afrique possède de grands ensembles de relief : plateaux, montagnes, bassins et plaines. Les climats varient notamment selon la latitude, l’altitude et la proximité des océans. On distingue des zones équatoriales humides, tropicales, désertiques et méditerranéennes. Le climat influence la végétation, l’agriculture et la répartition des populations.',
'La population africaine est diverse et connaît une forte croissance dans de nombreux pays. Sa répartition est inégale : certaines régions côtières, vallées, plaines et grandes villes concentrent davantage d’habitants. La densité dépend des facteurs naturels, historiques, économiques et des possibilités d’emploi.',
'Les économies africaines reposent sur des activités variées : agriculture, élevage, pêche, mines, industrie, commerce et services. Leur importance varie selon les territoires. L’exploitation des ressources peut générer des revenus, mais elle pose aussi des questions de transformation locale, d’environnement et de répartition de la valeur.',
'L’agriculture occupe une place importante dans de nombreux pays africains. Les cultures vivrières servent principalement à l’alimentation tandis que les cultures commerciales sont destinées à la vente. Les rendements dépendent des pluies, des sols, des techniques, des équipements et de l’accès aux marchés. Les agriculteurs doivent aussi faire face aux risques climatiques.',
'L’Afrique possède de nombreuses ressources minières et énergétiques : or, bauxite, fer, cuivre, pétrole, gaz ou uranium selon les pays. Leur exploitation peut créer des revenus et des emplois, mais elle dépend des marchés mondiaux et peut provoquer des impacts environnementaux. La transformation locale permet de créer davantage de valeur sur place.',
'Les échanges relient les territoires par les routes, chemins de fer, ports, voies aériennes et réseaux numériques. Les ports jouent un rôle essentiel dans le commerce international et les corridors relient les zones de production aux marchés. L’amélioration des infrastructures facilite les échanges mais les distances, les coûts et l’état des réseaux restent des contraintes.'
];
function quiz(theme,idx){
 const notions=[
 ['Quel est le thème étudié ?',theme],
 ['Quelle idée essentielle faut-il retenir ?',details[idx].split('.')[0]+'.'],
 ['Quelle démarche aide à répondre à une question d’histoire-géographie ?','Identifier les mots-clés, mobiliser un repère précis, expliquer puis justifier.'],
 ['Que faut-il faire avec un document ?', 'Identifier sa nature, son auteur ou sa source, relever les informations utiles puis les interpréter.'],
 ['Comment construire une réponse organisée ?', 'Définir la notion, donner un repère ou un exemple précis, expliquer et répondre directement à la consigne.']
 ];
 return notions.map((q,i)=>({id:'q'+(i+1),type:'qcm',enonce:q[0],choix:[q[1],'Une réponse sans rapport','Une affirmation non justifiée'],bonnesReponses:[0],points:1,explication:q[1]}));
}
(async()=>{
 for(let i=0;i<titres.length;i++){
  const theme=titres[i], code='HG-'+niveau+'-'+String(i+1).padStart(2,'0');
  const q=await db.collection('ca_chapitres').where('code','==',code).limit(1).get();
  let chapitreId;
  if(q.empty){
   const ref=db.collection('ca_chapitres').doc(); chapitreId=ref.id;
   await ref.set({code,niveau,matiereId,anneeScolaire,programmeVersion:'DPFC 2026-2027',serie:'',theme,titre:theme,description:'Cours et activités pédagogiques Sentinel CI.',ordre:i+1,actif:true,ressourceNationale:true,sourceOfficielle:'DPFC — Histoire-Géographie',dateMaj:FieldValue.serverTimestamp()});
  } else chapitreId=q.docs[0].id;
  const base={chapitreId,niveau,matiereId,ecoleId:'',imagesUrls:[],pdfUrl:'',videoYoutubeId:'',difficulte:1,ressourceLieeId:'',examen:false,annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'Sentinel CI — HG 4e 2026-2027',dateMaj:FieldValue.serverTimestamp()};
  const docs=[
   {type:'cours',titre:'Cours complet — '+theme,contenu:'# '+theme+'\\n\\n## Cours\\n'+details[i]+'\\n\\n## Repères et vocabulaire\\n• Situer les faits dans le temps et dans l’espace.\\n• Identifier les acteurs et les territoires.\\n• Relier causes, événements et conséquences.\\n\\n## Méthode\\nLire la consigne, repérer les mots-clés, sélectionner les informations utiles, expliquer et justifier.'},
   {type:'exercice',titre:'Exercices corrigés — '+theme,contenu:'## Exercice 1\\nDéfinis le thème du chapitre.\\n\\n**Correction :** '+details[i]+'\\n\\n## Exercice 2\\nCite deux éléments importants à retenir.\\n\\n**Correction :** On retient les repères, notions et exemples présentés dans le cours.\\n\\n## Exercice 3\\nExplique une cause et une conséquence liées au chapitre.\\n\\n**Correction :** Une réponse correcte relie explicitement une cause à un effet historique ou géographique.'},
   {type:'renforcement',titre:'Renforcement — '+theme,contenu:'Refais les activités sans regarder le cours.\\n\\n1. Définis la notion principale.\\n2. Donne deux repères précis.\\n3. Explique une relation de cause à conséquence.\\n4. Rédige une réponse organisée en 6 à 10 lignes.\\n\\nAuto-évaluation : □ repères □ vocabulaire □ raisonnement □ rédaction'},
   {type:'quiz',titre:'Quiz — '+theme,questions:quiz(theme,i),dureeMinutes:10},
   {type:'revision',titre:'Fiche de révision — '+theme,contenu:'# Fiche de révision — '+theme+'\\n\\n'+details[i]+'\\n\\n## À retenir\\n• Repères chronologiques et géographiques.\\n• Vocabulaire précis.\\n• Causes et conséquences.\\n• Exemples.\\n\\n## Réflexe\\nRépondre à la consigne avec une définition, un repère précis et une explication.'}
  ];
  for(const d of docs){
   const id=chapitreId+'_'+d.type;
   const ref=db.collection('ca_ressources').doc(id);
   const old=await ref.get();
   await ref.set({...base,...d,ordre:{cours:1,exercice:2,renforcement:3,quiz:4,revision:5}[d.type],enonce:d.enonce||'',solution:d.solution||'',contenu:d.contenu||'',questions:d.questions||[],dateCreation:old.exists?(old.data().dateCreation||FieldValue.serverTimestamp()):FieldValue.serverTimestamp()},{merge:true});
  }
 }
 await db.collection('ca_parametres').doc('version').set({anneeScolaire,version:FieldValue.increment(1),dateMaj:FieldValue.serverTimestamp(),derniereRessourceNationale:'4e_hg_2026_2027'},{merge:true});
 console.log(JSON.stringify({ok:true,niveau:'4e',matiere:'hg',chapitres:titres.length},null,2));
})().catch(e=>{console.error(e);process.exit(1);});

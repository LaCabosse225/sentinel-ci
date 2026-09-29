const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();
const programmes = {"6e":[["Greetings and introductions","hello; good morning; goodbye; name; age; country","to be; to have","Hello, my name is Awa. I am twelve years old. I am from Côte d’Ivoire.","Introduce yourself with your name, age and country."],["Family and friends","mother; father; brother; sister; cousin; friend; parents","my; your; his; her","This is my sister. Her name is Mariam. She is my friend.","Present one member of your family in five sentences."],["School life","school; classroom; teacher; student; book; notebook; subject; timetable","there is; there are","There is a board in the classroom. There are thirty students.","Describe your classroom and favourite subject."],["Daily routines","wake up; wash; breakfast; school; study; lunch; sleep","present simple; usually; sometimes; never","I wake up at six. I usually go to school at seven.","Write six sentences about your school day."],["Time and dates","day; month; Monday; January; today; tomorrow; morning; evening","What time; When","What time is it? It is eight o'clock. When is your birthday?","Say the date, time and one weekly activity."],["Food and drinks","rice; bread; fish; chicken; fruit; water; milk; juice","some; any; countable; uncountable","I eat some rice. Do you have any water?","Describe a healthy breakfast and drink."],["Clothes and appearance","shirt; trousers; dress; shoes; tall; short; young; hair","have got; has got; adjectives","He has got short hair. She is tall and friendly.","Describe yourself and a classmate politely."],["Home and neighbourhood","house; room; kitchen; bedroom; street; market; school; near","in; on; under; next to; near","The kitchen is next to the living room. The school is near my house.","Describe your room and two nearby places."],["Weather and seasons","sunny; rainy; cloudy; hot; cold; dry; wet; season","It is; weather expressions","It is rainy today. It is usually hot in March.","Give a short weather report."],["Hobbies and free time","read; play football; listen to music; dance; swim; draw","like; likes; like + ing","I like music. I like playing football. My brother likes reading.","Talk about three activities you enjoy."],["Places in town","hospital; market; bank; school; station; pharmacy; park; shop","there is; there are; where is","Excuse me, where is the market? It is next to the bank.","Give simple directions from school to the market."],["Simple communication","please; sorry; thank you; help; repeat; understand; speak; listen","can; can't","Can you help me, please? I can speak a little English.","Practise a short dialogue: greet, ask, answer, close."]],"5e":[["Introducing oneself and others","first name; surname; address; country; nationality; introduce; meet","to be; to have; question words","What is your surname? Where do you live? I live in Bouaké.","Write a personal profile and ask three questions."],["Family and relationships","grandfather; grandmother; uncle; aunt; parents; neighbour; classmate","possessive 's; possessive adjectives","This is Koffi's brother. Their parents live in Abidjan.","Describe two family relationships."],["School and education","lesson; homework; test; library; laboratory; break; timetable; subject","present simple for routines","We have English on Monday. She studies French in the afternoon.","Explain your school timetable."],["Healthy lifestyle","exercise; healthy; balanced; breakfast; vegetables; sleep; water; habit","should; shouldn't","You should drink water. You shouldn't skip breakfast.","Give five pieces of advice to a student."],["Travel and transport","bus; taxi; train; plane; ticket; journey; station; airport","going to for plans","We are going to travel by bus. We are going to visit Grand-Bassam.","Plan a short trip."],["Shopping and services","price; money; cheap; expensive; size; kilo; customer; cashier","how much; how many; some; any","How much is the shirt? How many kilos do you need?","Write a customer-seller dialogue."],["Describing past experiences","yesterday; last week; visit; travel; play; see; buy; go","past simple","I visited my aunt last weekend. We went to the beach.","Tell what you did last weekend."],["Plans and intentions","tomorrow; next week; plan; project; hope; visit; study; prepare","going to; will","I am going to study tonight. I will help you.","Explain three holiday plans."],["Environment and nature","forest; river; waste; plastic; tree; animal; pollution; recycle","must; mustn't; imperative","We must protect forests. We mustn't throw plastic into rivers.","Write five eco-rules."],["Technology and communication","phone; computer; message; email; internet; website; password","can; can't; imperatives","You can send an email. Do not share your password.","Give three safe digital habits."],["Culture and traditions","festival; music; dance; food; celebration; tradition","like; enjoy; often; usually","I enjoy traditional music. We often celebrate with family.","Describe one Ivorian tradition."],["Opinions and advice","think; agree; disagree; important; useful; problem; solution","I think; I agree; should","I think reading is useful. You should practise every day.","Give an opinion and one piece of advice."]],"4e":[["Introducing oneself and others","identity; background; nationality; address; interests; introduce","present simple; question forms","My name is Yao. I live in Yamoussoukro and I enjoy football.","Write a personal profile."],["Family and relationships","relative; friendship; close; married; respect; support","possessive forms; whose","Whose phone is this? It is my brother's.","Describe a relationship and why it matters."],["School and education","career; subject; project; exam; result; skill; education","present simple; frequency","I usually revise after school because exams are important.","Describe your study habits."],["Healthy lifestyle","nutrition; exercise; hygiene; sleep; stress; balanced; habit","should; have to; shouldn't","Students should sleep enough and have to drink water.","Prepare advice for a tired student."],["Travel and transport","destination; booking; passenger; luggage; departure; arrival; ticket","going to; future time expressions","We are going to leave at 7 a.m. and arrive at noon.","Organise a trip with time and activities."],["Shopping and services","customer; receipt; discount; change; size; quality; service; order","comparatives; how much; how many","This shirt is cheaper than that one. How much is it?","Compare two products."],["Describing past experiences","experience; event; trip; memorable; happened; visited; returned","past simple; past time markers","Last year I visited Korhogo. I saw a traditional craft market.","Narrate a memorable day."],["Plans and intentions","ambition; project; future; career; goal; intend; hope; prepare","going to; will; want to","I am going to study science. I want to become an engineer.","Write a one-week study plan."],["Environment and nature","climate; biodiversity; forest; drought; pollution; waste; protect","must; should; first conditional","If we recycle, we reduce waste. We should protect local forests.","Explain one environmental problem and two solutions."],["Technology and communication","device; application; account; message; privacy; information; network","can; must; imperatives","You can send a message, but you must protect your account.","Write five smartphone safety rules."],["Culture and traditions","heritage; ceremony; custom; language; food; music; identity","passive voice introduction; frequency","Traditional dances are performed during celebrations.","Present a local tradition and its meaning."],["Opinions and advice","opinion; argument; reason; advantage; disadvantage; solution","I think; because; however; should","I think uniforms are useful because they create a sense of identity.","Give an opinion, two reasons and advice."]],"3e":[["Introducing oneself and others","profile; background; achievement; interest; personality; interview","present simple; present perfect introduction","I have lived in Abidjan for three years. I have studied English since 2023.","Prepare a short interview introduction."],["Family and relationships","generation; responsibility; friendship; conflict; trust; respect; support","present perfect with for and since","We have been friends for five years. Since 2022, she has lived here.","Write about a relationship using time markers."],["School and education","curriculum; assignment; revision; examination; result; career; subject","must; have to; should","Students must revise. They should organise their time before an examination.","Build a revision timetable."],["Healthy lifestyle","well-being; balanced diet; physical activity; prevention; hygiene; sleep","must; have to; should; cause and effect","Regular exercise can improve well-being. Poor sleep can affect concentration.","Write an advice article for teenagers."],["Travel and transport","destination; itinerary; accommodation; reservation; delay; passenger; luggage","future forms; first conditional","If the bus is late, we will take a taxi.","Plan a journey with a possible problem and solution."],["Shopping and services","consumer; quality; price; warranty; refund; bargain; service","comparatives; superlatives; polite requests","This option is more reliable than the other one. Could I have a receipt?","Compare products and write a purchasing dialogue."],["Describing past experiences","memorable; achievement; challenge; accident; journey; discover; realise","past simple; past continuous; present perfect","I was travelling when it started to rain. I have never forgotten that day.","Narrate an event and what was happening."],["Plans and intentions","ambition; objective; opportunity; scholarship; training; career","future forms; want to; hope to; plan to","I hope to study computer science. I am planning to prepare for the exam.","Write a study and career plan."],["Environment and nature","climate change; deforestation; biodiversity; renewable; pollution; conservation","first conditional; should; must","If forests disappear, biodiversity will decrease. We must act now.","Explain a local environmental issue and three actions."],["Technology and communication","social media; privacy; cyberbullying; digital footprint; source; reliable","modals; reported speech introduction","You should check a source before sharing information. She said the message was false.","Write rules for responsible digital behaviour."],["Culture and traditions","heritage; identity; diversity; ceremony; language; influence; generation","passive voice introduction","Traditional dishes are prepared during many celebrations.","Describe how a tradition is transmitted."],["Opinions and advice","argument; evidence; point of view; suggest; recommend; consequence","because; although; however; should","In my opinion, practice is essential because confidence grows with regular use.","Write a balanced paragraph with reasons."]]};

function course(niveau, l){
  const title=l[0], vocab=l[1].split(';').map(x => '- **'+x.trim()+'**').join('\\n'), grammar=l[2], examples=l[3], task=l[4];
  return ['# '+title,'','## 1. Objectif','Comprendre et utiliser le vocabulaire et la structure grammaticale de la leçon dans une situation de communication adaptée au niveau '+niveau+'.','','## 2. Vocabulary',vocab,'','## 3. Grammar focus','**'+grammar+'**','','Cette structure aide à construire des phrases correctes. Observe le sujet, le verbe et les marqueurs de temps. Commence par une phrase courte puis ajoute une précision.','','## 4. Guided examples',examples,'','### Notice','Lis la phrase, identifie le sujet et le verbe, puis observe l ordre des mots. Pour une question, repère le mot interrogatif et l auxiliaire nécessaires.','','## 5. Communication task',task,'','## 6. Study method','1. Lis le vocabulaire à voix haute.','2. Copie cinq expressions et crée une nouvelle phrase avec chacune.','3. Repère la structure grammaticale dans les exemples.','4. Écris cinq phrases personnelles.','5. Relis et corrige les verbes, l orthographe et la ponctuation.','','## 7. À retenir','**Le vocabulaire, la grammaire et la communication doivent être travaillés ensemble.** Connaître un mot signifie pouvoir le comprendre et le réutiliser dans une phrase.','','### Mini-check','Puis-je définir les mots importants ? Puis-je construire une phrase correcte ? Puis-je poser une question ? Puis-je répondre ? Puis-je réutiliser la leçon dans une situation nouvelle ?'].join('\\n');
}
function fiche(title,l){
  const vocab=l[1].split(';').map(x => x.trim()).join(' · ');
  return ['# Fiche de révision — '+title,'','## Vocabulary',vocab,'','## Grammar','**'+l[2]+'**','','## Example',l[3],'','## Practice',l[4],'','## Reflexe','Écris trois phrases personnelles et une question en réutilisant la leçon.'].join('\\n');
}

function practice(title,l,niveau){
  const vocab=l[1].split(';').map(x=>x.trim());
  return `# Practice — ${title}

## Exercice 1 — Vocabulary
Write a sentence with each of these words: **${vocab.slice(0,5).join(', ')}**.

### Correction guidée
Each sentence must use the word in a meaningful context and have a correct subject, verb and punctuation.

## Exercice 2 — Grammar
Write five sentences using **${l[2]}**.

### Correction
Check the subject, verb form, word order and punctuation.

## Exercice 3 — Communication
${l[4]}

### Correction guidée
Use at least three key words and the grammar structure studied. Prefer short, correct sentences before adding details.

## Exercice 4 — Questions
Turn two of your sentences into questions and provide an answer for each.

### Correction
Check the question word or auxiliary, subject, verb and final punctuation.`;
}
function reinforcement(title,l,niveau){
  return `# Reinforcement — ${title}

## Situation
${l[4]}

## Mission
Produce a short oral or written response of 5 to 8 sentences using the vocabulary and **${l[2]}**.

## Method
1. Choose five key words.
2. Build short sentences.
3. Add one question and one answer.
4. Reread and correct grammar, spelling and punctuation.

## Expected result
A clear English production adapted to level ${niveau}.`;
}
function qcm(title,l){
  const vocab=l[1].split(';').map(x=>x.trim());
  return [
    {id:'q1',type:'qcm',enonce:'Which word belongs to this lesson?',choix:[vocab[0]||'school','banana','yesterday','mountain'],bonnesReponses:[0],reponseAttendue:'',explication:'This word belongs to the key vocabulary of the lesson.',points:1},
    {id:'q2',type:'qcm',enonce:'What should you check when writing a sentence?',choix:['Subject and verb','Only length','Only handwriting','Nothing'],bonnesReponses:[0],reponseAttendue:'',explication:'A correct sentence needs a clear subject and an appropriate verb form.',points:1},
    {id:'q3',type:'qcm',enonce:'Which item is the grammar focus of the lesson?',choix:[l[2],'Only a noun','Only a number','A punctuation mark'],bonnesReponses:[0],reponseAttendue:'',explication:'The lesson grammar focus is the structure learners practise.',points:1},
    {id:'q4',type:'qcm',enonce:'What is a good way to learn vocabulary?',choix:['Reuse words in sentences','Read once and forget','Avoid examples','Never speak'],bonnesReponses:[0],reponseAttendue:'',explication:'Active reuse helps learners remember and use vocabulary.',points:1},
    {id:'q5',type:'qcm',enonce:'What is the main goal of a communication task?',choix:['Communicate a clear message','Use the longest sentence','Avoid the vocabulary','Ignore the listener'],bonnesReponses:[0],reponseAttendue:'',explication:'The goal is meaningful and understandable communication.',points:1},
    {id:'q6',type:'qcm',enonce:'What should you do after writing?',choix:['Reread and correct','Delete punctuation','Change every verb','Do nothing'],bonnesReponses:[0],reponseAttendue:'',explication:'Rereading helps correct grammar, spelling and punctuation.',points:1}
  ];
}

async function find(chapterId, type){
  const snap=await db.collection('ca_ressources').where('chapitreId','==',chapterId).limit(50).get();
  for(const d of snap.docs){ const t=String(d.data().type||'').toLowerCase(); if(t===type || (type==='exercice'&&t==='exercices') || (type==='fiche'&&t==='revision')) return d; }
  return null;
}
async function main(){
  let courses=0, fiches=0, chapters=0;
  for(const niveau of Object.keys(programmes)){
    for(let i=0;i<programmes[niveau].length;i++){
      const l=programmes[niveau][i], code='ANG-'+niveau+'-'+String(i+1).padStart(2,'0');
      const q=await db.collection('ca_chapitres').where('code','==',code).limit(1).get();
      if(q.empty){ console.log('Chapitre absent '+code); continue; }
      const ch=q.docs[0]; chapters++;
      const base={type:'cours',titre:'Cours complet — '+l[0],ordre:1,chapitreId:ch.id,niveau,matiereId:'angl',ecoleId:'',contenu:course(niveau,l),imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:1,ressourceLieeId:'',questions:[],dureeMinutes:35,examen:'',annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'sentinel-pedagogie-anglais-2026',dateMaj:FieldValue.serverTimestamp()};
      let r=await find(ch.id,'cours');
      if(r) await r.ref.update(base); else await db.collection('ca_ressources').add({...base,dateCreation:FieldValue.serverTimestamp()});
      courses++;
      const ex={type:'exercices',titre:'Practice exercises — '+l[0],ordre:2,chapitreId:ch.id,niveau,matiereId:'angl',ecoleId:'',contenu:practice(l[0],l,niveau),imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:1,ressourceLieeId:'',questions:[],dureeMinutes:25,examen:'',annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'sentinel-pedagogie-anglais-2026',dateMaj:FieldValue.serverTimestamp()};
      r=await find(ch.id,'exercices');
      if(r) await r.ref.update(ex); else await db.collection('ca_ressources').add({...ex,dateCreation:FieldValue.serverTimestamp()});

      const ren={type:'renforcement',titre:'Reinforcement — '+l[0],ordre:3,chapitreId:ch.id,niveau,matiereId:'angl',ecoleId:'',contenu:reinforcement(l[0],l,niveau),imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:2,ressourceLieeId:'',questions:[],dureeMinutes:20,examen:'',annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'sentinel-pedagogie-anglais-2026',dateMaj:FieldValue.serverTimestamp()};
      r=await find(ch.id,'renforcement');
      if(r) await r.ref.update(ren); else await db.collection('ca_ressources').add({...ren,dateCreation:FieldValue.serverTimestamp()});

      const quiz={type:'quiz',titre:'Quiz — '+l[0],ordre:4,chapitreId:ch.id,niveau,matiereId:'angl',ecoleId:'',contenu:'# Quiz — '+l[0],imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:2,ressourceLieeId:'',questions:qcm(l[0],l),dureeMinutes:12,examen:'',annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'sentinel-pedagogie-anglais-2026',dateMaj:FieldValue.serverTimestamp()};
      r=await find(ch.id,'quiz');
      if(r) await r.ref.update(quiz); else await db.collection('ca_ressources').add({...quiz,dateCreation:FieldValue.serverTimestamp()});

      const f={type:'fiche',titre:'Fiche de révision — '+l[0],ordre:5,chapitreId:ch.id,niveau,matiereId:'angl',ecoleId:'',contenu:fiche(l[0],l),imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:1,ressourceLieeId:'',questions:[],dureeMinutes:15,examen:'',annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'sentinel-pedagogie-anglais-2026',dateMaj:FieldValue.serverTimestamp()};
      r=await find(ch.id,'fiche');
      if(r) await r.ref.update(f); else await db.collection('ca_ressources').add({...f,dateCreation:FieldValue.serverTimestamp()});
      fiches++;
    }
  }
  await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),derniereRessourceNationale:'anglais_cycle1_approfondi',dateMaj:FieldValue.serverTimestamp()},{merge:true});
  console.log(JSON.stringify({ok:true,chapitres:chapters,coursApprofondis:courses,fichesMisesAJour:fiches},null,2));
}
main().catch(e=>{console.error('ENRICH_ANGLAIS_ERROR');console.error(e&&e.stack?e.stack:e);process.exit(1);});
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId:'sentinel-ci-c7592' });
const db=getFirestore();

const PROGRAMMES = {
  arts: {
    niveaux:['6e','5e','4e','3e'],
    titres:['Ligne, forme et composition','Couleur et contrastes','Espace et profondeur','Lumière et volume','Image et représentation','Création graphique et techniques','Arts, culture et patrimoine','Projet artistique et présentation'],
    notions:[
      ['La ligne organise le regard. Une forme peut être géométrique ou organique et la composition désigne la manière de disposer les éléments dans l’espace de la feuille ou du support. Une production lisible repose sur des choix : direction des lignes, taille des formes, répétition, contraste et hiérarchie visuelle.','À partir de trois formes simples, l’élève construit une composition où une forme domine les autres. Il explique comment la taille, la position et les lignes de force attirent le regard.','Observer avant de modifier : repérer les lignes de force, les formes dominantes, les vides et les zones de concentration.'],
      ['La couleur possède une dimension visuelle et expressive. On distingue notamment couleurs primaires, secondaires, chaudes, froides, complémentaires, valeurs claires et foncées. Le contraste peut servir à séparer des plans ou à créer une tension dans l’image.','Une affiche utilisant bleu et orange produit un contraste de complémentaires plus marqué qu’un ensemble de couleurs proches. Le choix dépend de l’effet recherché.','Identifier la fonction de chaque couleur avant de la choisir : attirer, calmer, distinguer, symboliser ou créer une ambiance.'],
      ['L’espace plastique est construit par des indices comme la superposition, la diminution des tailles, le chevauchement, les lignes convergentes et les plans. La profondeur n’est donc pas seulement une propriété du sujet représenté : elle résulte de choix graphiques.','Pour représenter une rue, des maisons plus petites et placées plus haut peuvent donner une impression d’éloignement ; le premier plan reçoit davantage de détails.','Nommer premier plan, second plan et arrière-plan, puis expliquer les procédés qui produisent l’illusion de profondeur.'],
      ['La lumière permet de distinguer les volumes grâce aux zones éclairées, aux demi-teintes et aux ombres. La direction de la source lumineuse modifie la forme perçue et l’ambiance. En arts plastiques, la lumière peut être observée, représentée ou volontairement transformée.','Un même objet placé près d’une fenêtre présente une zone éclairée et une ombre portée. Déplacer la source modifie immédiatement la lecture du volume.','Repérer la source, observer la direction des ombres et simplifier les valeurs avant d’ajouter les détails.'],
      ['Une image représente, informe, raconte, persuade ou symbolise. Comprendre une image demande de distinguer ce qui est visible de ce qui est suggéré : cadrage, personnages, objets, couleurs, texte, point de vue et contexte.','Une photographie d’un marché ne produit pas le même message selon qu’elle montre une vue générale, un vendeur en gros plan ou un détail d’un produit.','Décrire d’abord sans interpréter, puis rechercher l’intention, les signes importants et l’effet produit sur le spectateur.'],
      ['Une technique est un ensemble de gestes et de procédés adaptés à un matériau et à un projet. Crayon, peinture, collage, encre, empreinte ou techniques numériques ne produisent pas les mêmes textures ni les mêmes effets. Le choix du support et de l’outil fait partie du projet.','Un collage de papiers déchirés produit des contours et des textures différents d’un dessin au crayon. Le matériau devient lui-même un élément expressif.','Choisir la technique en fonction de l’intention et tester un petit échantillon avant la réalisation finale.'],
      ['Le patrimoine artistique rassemble des productions reconnues pour leur valeur culturelle, historique ou esthétique. En Côte d’Ivoire, les masques, sculptures, textiles, architectures, danses et autres pratiques constituent des traces de cultures diverses. Étudier une œuvre implique de respecter son contexte et d’éviter de la réduire à un simple objet décoratif.','Une œuvre liée à une cérémonie traditionnelle doit être étudiée en tenant compte de son usage, de sa communauté et de son contexte, pas seulement de sa forme.','Présenter l’œuvre, son contexte, ses matériaux, sa fonction et les éléments visuels observables avant toute interprétation.'],
      ['Un projet artistique part d’une intention et se construit par étapes : recherche, essais, choix techniques, réalisation, analyse et présentation. L’artiste peut modifier son idée en fonction des essais. Présenter un projet, c’est expliquer les choix réalisés et les effets recherchés.','Pour créer une affiche de sensibilisation, l’élève définit le message, choisit une image principale, organise texte et image, réalise plusieurs essais puis justifie la version retenue.','Conserver les essais et noter les choix importants : ils permettent de montrer la démarche et pas seulement le résultat final.']
    ]
  },
  musique: {
    niveaux:['6e','5e','4e','3e'],
    titres:['Écoute et découverte des sons','Rythme et pulsation','Voix et chant','Mélodie et hauteur des sons','Instruments et familles instrumentales','Musique ivoirienne et patrimoines','Musique africaine et cultures du monde','Création et pratique musicale'],
    notions:[
      ['Écouter une musique signifie identifier progressivement ses caractéristiques : source sonore, intensité, tempo, durée, timbre, répétitions et contrastes. Une écoute active ne consiste pas seulement à dire si l’on aime une musique ; elle s’appuie sur des indices que l’on peut décrire.','Lors d’une écoute, l’élève repère un début doux, une augmentation progressive de l’intensité puis l’entrée d’un chœur. Il décrit les changements dans l’ordre où ils apparaissent.','Faire plusieurs écoutes courtes : première écoute globale, deuxième écoute des éléments précis, troisième écoute pour vérifier les hypothèses.'],
      ['La pulsation est un battement régulier qui sert de repère. Le rythme organise les durées autour de cette pulsation. Le tempo indique la vitesse d’exécution. Une même suite rythmique peut être interprétée à des tempos différents sans devenir automatiquement une autre suite rythmique.','En frappant régulièrement quatre pulsations puis une suite longue-courte-courte, on distingue le repère stable de la combinaison rythmique.','Marcher la pulsation avant de frapper le rythme, puis compter à voix haute pour stabiliser la coordination.'],
      ['La voix humaine produit des sons grâce à la mise en vibration des cordes vocales et à la résonance des cavités. Chanter demande respiration, posture, articulation, écoute et contrôle de l’intensité. Le timbre permet de distinguer des voix même lorsqu’elles chantent la même hauteur.','Un groupe chante la même mélodie : les voix restent différentes par leur timbre et peuvent être organisées en parties selon la hauteur ou le rôle musical.','Respirer sans hausser les épaules, articuler clairement, écouter le groupe et éviter de forcer la voix.'],
      ['La hauteur permet de distinguer un son grave d’un son aigu. Une mélodie est organisée par des hauteurs successives et des durées. Elle peut comporter répétitions, mouvements conjoints, sauts, motifs et phrases musicales.','Une mélodie qui monte progressivement donne une impression différente d’une mélodie qui répète longtemps la même note.','Repérer d’abord les répétitions puis suivre le contour mélodique : monte, descend, reste stable ou alterne.'],
      ['Les instruments produisent le son par vibration et se distinguent notamment par leur mode de production. On peut regrouper les instruments en grandes familles : cordes, vents, percussions, auxquelles s’ajoutent des catégories plus détaillées. Le timbre dépend de la source et de la manière de produire le son.','Une guitare, une flûte et un tambour peuvent jouer une pulsation identique mais produisent des timbres différents grâce à des modes de vibration différents.','Associer instrument, famille, matériau principal, geste du musicien et caractéristique sonore.'],
      ['Les musiques ivoiriennes appartiennent à des contextes culturels variés. Elles peuvent accompagner une cérémonie, une danse, un récit, une célébration ou une expression contemporaine. Étudier un patrimoine musical demande d’identifier les pratiques, les instruments, les fonctions et les transformations dans le temps.','Une musique liée à une cérémonie peut avoir une fonction sociale précise qui ne se réduit pas à l’écoute comme divertissement.','Décrire le contexte d’usage, les instruments ou voix, le rythme, la fonction et les éléments qui montrent une transmission culturelle.'],
      ['Les musiques africaines présentent une grande diversité. Certaines pratiques utilisent la répétition, la réponse entre soliste et groupe, la polyrythmie ou des instruments spécifiques, mais ces caractéristiques ne sont pas présentes dans toutes les traditions. Il faut éviter les généralisations.','Dans une pratique en appel-réponse, un soliste énonce une phrase et le groupe répond selon une organisation prévue.','Décrire ce que l’on entend réellement et relier les observations au contexte étudié plutôt que d’attribuer les mêmes caractéristiques à toute l’Afrique.'],
      ['Créer une séquence musicale consiste à choisir une pulsation, des motifs, des sons ou des hauteurs, à les organiser puis à les répéter ou transformer. Une production collective demande écoute, répartition des rôles et respect du tempo commun.','Un groupe crée une courte pièce en quatre mesures : percussion pour la pulsation, voix pour un motif et objet sonore pour une réponse.','Commencer par une cellule simple, la stabiliser, puis ajouter un seul élément à la fois. Enregistrer et réécouter pour corriger.']
    ]
  },
  allemand: {
    niveaux:['4e','3e'],
    titres:['Se présenter et saluer','La famille et les relations','L’école et la vie quotidienne','La maison et le quartier','Les activités et les loisirs','Les achats et les services','Les voyages et les transports','Communiquer et donner son opinion'],
    notions:[
      ['En allemand, se présenter mobilise les verbes sein et heißen, les pronoms personnels, les salutations et les questions simples. La phrase déclarative place généralement le verbe conjugué en deuxième position.','Ich heiße Awa. Ich bin vierzehn Jahre alt. Ich wohne in Abidjan.','Mémoriser des blocs utiles puis vérifier la place du verbe : sujet + verbe + compléments dans une phrase déclarative simple.'],
      ['Pour parler de la famille, on utilise les noms de parenté et les possessifs mein, meine, dein, deine. Le genre grammatical du nom influence les formes. Une description peut combiner sein/haben et des adjectifs simples.','Das ist meine Mutter. Sie ist freundlich. Das ist mein Bruder. Er ist sechzehn Jahre alt.','Identifier le nom et son genre, puis choisir le possessif adapté avant de construire la phrase.'],
      ['Parler de l’école demande le vocabulaire des matières, lieux, horaires et activités. Le présent permet de décrire une routine. Les questions wie, was, wann, wo et warum servent à obtenir des informations différentes.','Wann beginnt der Unterricht? — Um sieben Uhr. Was ist dein Lieblingsfach? — Mathematik.','Construire la question à partir de l’information recherchée puis placer le verbe correctement.'],
      ['Décrire une maison ou un quartier mobilise les pièces, lieux, prépositions et verbes de localisation. Les prépositions an, auf, in, neben, vor, hinter permettent de préciser les relations spatiales.','Die Küche ist neben dem Wohnzimmer. Die Schule ist in der Nähe.','Commencer par le lieu principal puis ajouter les relations spatiales avec une préposition précise.'],
      ['Les loisirs permettent de parler de goûts et de fréquence. Les verbes spielen, lesen, hören, schwimmen, tanzen et les expressions gern, nicht gern, oft, manchmal structurent la description.','Ich spiele gern Fußball, aber ich lese nicht gern am Abend.','Utiliser un exemple positif et un exemple négatif, puis ajouter une indication de fréquence.'],
      ['Dans une situation d’achat, il faut demander un prix, une quantité ou une taille et comprendre la réponse. Les nombres et expressions wie viel? sont essentiels. La politesse structure l’échange.','Wie viel kostet das T-Shirt? — Es kostet 5 000 Francs. Ich möchte eine andere Größe, bitte.','Jouer le dialogue vendeur-client en trois étapes : saluer, demander/préciser, conclure.'],
      ['Parler d’un voyage demande les moyens de transport, les lieux, les horaires et les actions. Le présent peut exprimer un programme ; des expressions temporelles situent les étapes.','Wir fahren am Samstag mit dem Bus nach Yamoussoukro. Der Bus fährt um acht Uhr ab.','Organiser le récit dans l’ordre chronologique et associer chaque étape à une indication de temps ou de lieu.'],
      ['Donner son opinion demande de distinguer avis et raison. Des expressions comme Ich denke, Ich glaube, Ich finde permettent d’introduire une position ; weil introduit une justification.','Ich finde Sport wichtig, weil er gesund ist.','Donner l’opinion, fournir au moins une raison, puis éventuellement reconnaître un point de vue différent.']
    ]
  },
  espagnol: {
    niveaux:['4e','3e'],
    titres:['Saluer et se présenter','La famille et les amis','L’école et les activités','La vie quotidienne','La maison et la ville','Les loisirs et les goûts','Voyages et découvertes','Exprimer une opinion et communiquer'],
    notions:[
      ['Se présenter en espagnol mobilise llamarse, ser, tener et les salutations. Les questions ¿Cómo te llamas?, ¿De dónde eres? et ¿Cuántos años tienes? permettent d’établir une identité simple.','Me llamo Awa. Tengo catorce años. Soy de Côte d’Ivoire. Vivo en Abidjan.','Mémoriser les structures interrogatives et répondre avec une phrase complète, en accordant attention aux accents.'],
      ['Parler de la famille mobilise les liens de parenté, les adjectifs possessifs et ser/tener. L’accord des adjectifs en genre et en nombre doit être contrôlé.','Mi hermana es amable. Mis padres viven en Abidjan.','Identifier le nom, choisir le possessif puis vérifier l’accord de l’adjectif.'],
      ['L’école se décrit avec les matières, les lieux, l’emploi du temps et les activités. Le présent permet d’exprimer les habitudes. Les verbes gustar et preferir servent à parler des préférences.','Estudio matemáticas el lunes. Me gusta la historia porque es interesante.','Construire une phrase sur l’activité, préciser quand elle a lieu et ajouter une justification simple.'],
      ['La vie quotidienne s’organise autour de verbes pronominaux comme levantarse, lavarse, acostarse. Les marqueurs primero, después, luego, finalmente permettent de raconter une routine clairement.','Primero me levanto a las seis. Después desayuno y voy al colegio.','Apprendre les verbes pronominaux dans une phrase complète et utiliser des connecteurs pour ordonner les actions.'],
      ['Décrire une maison et une ville demande les lieux, les prépositions et hay/estar. Hay sert à présenter l’existence d’un élément ; estar sert à situer un élément précis.','Hay un mercado cerca de mi casa. La farmacia está al lado del banco.','Choisir entre hay et estar selon que l’on introduit un élément ou qu’on le localise précisément.'],
      ['Parler des goûts mobilise gustar, encantar, preferir et les activités. La structure avec gustar est particulière : Me gusta el fútbol ; Me gustan los libros.','Me gusta bailar, pero me gustan también los deportes colectivos.','Vérifier si le complément est singulier ou pluriel pour choisir gusta ou gustan.'],
      ['Raconter un voyage demande les lieux, moyens de transport, étapes et expériences. Les marqueurs temporels organisent le récit. Au niveau 3e, le passé peut être introduit pour raconter un événement achevé.','El sábado viajé en autobús. Primero visitamos el museo y después caminamos por el centro.','Construire le récit dans l’ordre, préciser où et quand, puis utiliser les temps verbaux de manière cohérente.'],
      ['Exprimer une opinion demande une idée claire et une justification : Creo que, pienso que, en mi opinión, porque. Pour nuancer, on peut utiliser pero ou sin embargo.','En mi opinión, leer es importante porque ayuda a aprender palabras nuevas, pero también es necesario practicar.','Formuler l’opinion, donner deux raisons ou un exemple, puis relire les accords et les connecteurs.']
    ]
  }
};

function niveauAjustement(niveau){
  return ['6e','5e'].includes(niveau)
    ? 'À ce niveau, privilégier des phrases courtes, des manipulations concrètes, le vocabulaire essentiel et une progression très guidée.'
    : 'À ce niveau, demander davantage de justification, de comparaison, de réutilisation et d’autonomie dans la production.';
}

function makeCourse(id,niveau,titre,notion,exemple,methode){
  const intro = id==='allemand'||id==='espagnol'
    ? 'Ce chapitre construit une compétence de communication. L’objectif n’est pas seulement de mémoriser des mots, mais de comprendre une situation, choisir une structure correcte et produire un message compréhensible.'
    : 'Ce chapitre part de l’observation et conduit progressivement vers une production. L’élève apprend à identifier les éléments importants, à les organiser et à justifier ses choix.';
  return '# '+titre+'\\n\\n## 1. Situation de départ\\n'+intro+'\\n\\n## 2. Cours expliqué\\n'+notion+'\\n\\n## 3. Exemple guidé\\n'+exemple+'\\n\\n## 4. Méthode de travail\\n'+methode+'\\n\\n## 5. Activité guidée\\nRéalise une première production courte. Compare-la ensuite aux critères du chapitre : exactitude des notions, organisation, précision du vocabulaire et cohérence avec la consigne. Corrige au moins deux éléments avant de produire la version finale.\\n\\n## 6. Ce qu’il faut comprendre\\nUne réussite ne consiste pas à recopier une définition. Il faut pouvoir expliquer la notion, reconnaître une situation où elle s’applique et réutiliser la méthode dans une tâche nouvelle.\\n\\n## 7. Erreurs fréquentes\\n- réciter sans répondre à la consigne ;\\n- employer un vocabulaire sans comprendre son rôle ;\\n- négliger l’ordre des étapes ;\\n- oublier de vérifier la cohérence de la production ;\\n- confondre exemple et règle générale.\\n\\n## 8. À retenir\\n'+notion+'\\n\\n**Adaptation au niveau :** '+niveauAjustement(niveau);
}

function makeExercises(id,niveau,titre,notion,exemple){
  const lang=id==='allemand'||id==='espagnol';
  return '# Exercices — '+titre+'\\n\\n## Exercice 1 — Comprendre\\nExplique avec tes propres mots la notion centrale du chapitre et relève trois éléments indispensables à retenir.\\n\\n### Correction\\nLa réponse doit reprendre l’idée centrale sans recopier mécaniquement le cours et citer trois éléments réellement utiles pour appliquer la notion.\\n\\n## Exercice 2 — Application guidée\\nÀ partir de la situation suivante, construis une réponse complète en utilisant la méthode du chapitre : « '+exemple+' »\\n\\n### Correction\\nCommencer par identifier ce que demande la consigne, sélectionner la notion pertinente, réaliser la tâche étape par étape puis relire. Une réponse complète doit être justifiée et cohérente.\\n\\n## Exercice 3 — Transfert\\nCrée une nouvelle situation dans laquelle la notion « '+titre+' » est nécessaire. Résous-la ensuite.\\n\\n### Correction\\nLa situation doit être différente de l’exemple du cours mais mobiliser la même compétence. La correction doit montrer clairement le lien entre la situation et la notion.\\n\\n## Exercice 4 — Défi\\n'+(lang?'Produis un mini-dialogue ou un paragraphe de 6 à 10 phrases en réutilisant le vocabulaire et les structures du chapitre.':'Réalise une production personnelle en faisant apparaître au moins trois choix justifiés.')+'\\n\\n### Correction attendue\\nLa production est correcte si elle respecte la consigne, utilise les notions du chapitre et présente une organisation lisible. Les erreurs doivent être repérées puis corrigées lors de la relecture.\\n';
}

function makeReinforcement(id,niveau,titre,notion){
  return '# Renforcement — '+titre+'\\n\\n## Situation-problème\\nUn élève connaît les éléments du cours mais produit une réponse confuse ou incomplète. Il doit reprendre une situation nouvelle et montrer comment la notion permet réellement de la traiter.\\n\\n## Travail demandé\\n1. Reformule la notion centrale.\\n2. Repère les informations utiles.\\n3. Choisis la méthode adaptée.\\n4. Réalise la tâche en justifiant les étapes.\\n5. Relis et corrige au moins deux points.\\n\\n## Correction détaillée attendue\\nUne bonne résolution relie explicitement les observations à la notion du cours. Elle ne se limite pas à donner une réponse finale : elle explique pourquoi cette réponse est pertinente.\\n\\n## Défi de consolidation\\nExplique le chapitre à un camarade en trois minutes, puis propose-lui une question qu’il doit résoudre sans regarder le cours.\\n\\n## Critères de réussite\\n☐ notion comprise ☐ vocabulaire précis ☐ méthode respectée ☐ justification présente ☐ production relue';
}

function makeQuiz(titre,notion){
  const questions=[
    ['La notion du chapitre doit-elle être comprise et réutilisée, plutôt que simplement récitée ?',['Oui','Non'],0,'Oui : le transfert vers une situation nouvelle montre la compréhension.'],
    ['Une réponse complète doit-elle respecter la consigne ?',['Oui','Non'],0,'Oui : une réponse peut être exacte mais hors sujet si elle ne traite pas la demande.'],
    ['La justification permet-elle d’expliquer pourquoi une réponse ou un choix est pertinent ?',['Oui','Non'],0,'Oui : elle rend le raisonnement vérifiable.'],
    ['Faut-il relire une production avant de la considérer terminée ?',['Oui','Non'],0,'Oui : la relecture permet de corriger les erreurs et incohérences.'],
    ['Un exemple suffit-il à remplacer la règle ou la notion générale ?',['Oui','Non'],1,'Non : un exemple illustre une notion mais ne remplace pas son explication.'],
    ['Peut-on transférer une compétence à une situation différente ?',['Oui','Non'],0,'Oui : c’est une étape essentielle de l’apprentissage.']
  ];
  return questions.map((q,i)=>({id:'q'+(i+1),type:'qcm',enonce:q[0]+' — '+titre,choix:q[1],bonnesReponses:[q[2]],reponseAttendue:'',explication:q[3],points:1}));
}

function makeRevision(titre,notion,methode){
  return '# Fiche de révision — '+titre+'\\n\\n## Mots-clés\\n'+notion.split('.')[0]+'.\\n\\n## Je dois savoir\\n- définir ou expliquer la notion centrale ;\\n- reconnaître une situation d’application ;\\n- appliquer la méthode ;\\n- justifier mes choix ;\\n- corriger ma production après relecture.\\n\\n## Méthode express\\n'+methode+'\\n\\n## Auto-évaluation\\n☐ Je peux expliquer le chapitre sans lire.\\n☐ Je peux donner un exemple personnel.\\n☐ Je peux résoudre une situation nouvelle.\\n☐ Je peux justifier ma réponse.\\n☐ Je peux repérer une erreur et la corriger.';
}

async function main(){
  let processed=0,updated=0,created=0;
  for(const [matiereId,p] of Object.entries(PROGRAMMES)){
    for(const niveau of p.niveaux){
      for(let i=0;i<p.titres.length;i++){
        const titre=p.titres[i], [notion,exemple,methode]=p.notions[i];
        const qs=await db.collection('ca_chapitres').where('niveau','==',niveau).where('matiereId','==',matiereId).where('ordre','==',i+1).limit(5).get();
        for(const ch of qs.docs){
          const types=[
            ['cours','Cours complet — '+titre,makeCourse(matiereId,niveau,titre,notion,exemple,methode),[],40],
            ['exercices','Exercices et corrections — '+titre,makeExercises(matiereId,niveau,titre,notion,exemple),[],30],
            ['renforcement','Renforcement — '+titre,makeReinforcement(matiereId,niveau,titre,notion),[],25],
            ['quiz','QCM — '+titre,'QCM de consolidation.',makeQuiz(titre,notion),10],
            ['revision','Fiche de révision — '+titre,makeRevision(titre,notion,methode),[],15]
          ];
          for(let j=0;j<types.length;j++){
            const [type,titreR,contenu,questions,duree]=types[j];
            const old=await db.collection('ca_ressources').where('chapitreId','==',ch.id).where('type','==',type).limit(1).get();
            let skip=false;
            if(!old.empty){
              const d=old.docs[0].data(), len=String(d.contenu||'').trim().length, nq=Array.isArray(d.questions)?d.questions.length:0;
              skip=type==='quiz'?nq>=6:len>=1800;
            }
            if(skip) continue;
            const data={type,titre:titreR,ordre:j+1,chapitreId:ch.id,niveau,matiereId,ecoleId:'',contenu,imagesUrls:[],pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:type==='quiz'?2:1,ressourceLieeId:'',questions,dureeMinutes:duree,examen:'',annee:2026,serie:'',actif:true,ressourceNationale:true,auteur:'Sentinel CI — enrichissement pédagogique',dateMaj:FieldValue.serverTimestamp(),dateCreation:old.empty?FieldValue.serverTimestamp():(old.docs[0].data().dateCreation||FieldValue.serverTimestamp())};
            const ref=old.empty?db.collection('ca_ressources').doc(ch.id+'_restants_'+type):old.docs[0].ref;
            await ref.set(data,{merge:true});
            old.empty?created++:updated++;
          }
          processed++;
        }
      }
    }
  }
  await db.collection('ca_parametres').doc('version').set({version:FieldValue.increment(1),dateMaj:FieldValue.serverTimestamp()},{merge:true});
  console.log(JSON.stringify({ok:true,processed,updated,created},null,2));
}
main().catch(e=>{console.error(e);process.exit(1);});

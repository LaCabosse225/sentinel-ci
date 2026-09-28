const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
initializeApp({ credential: applicationDefault(), projectId: 'sentinel-ci-c7592' });
const db = getFirestore();
const lessons = {"2nde":[["Ensembles de nombres et calcul numérique","En 2nde, on distingue les ensembles de nombres : entiers naturels, entiers relatifs, décimaux, rationnels et réels. Une même valeur peut appartenir à plusieurs ensembles. Les calculs respectent les priorités opératoires : parenthèses, puissances, multiplications et divisions, puis additions et soustractions. Les fractions permettent de conserver une valeur exacte.","3 + 2×5 = 13. Pour 3/4 + 1/2, on écrit 1/2 = 2/4, donc la somme vaut 5/4.","Avant de calculer, identifie la nature des nombres et les opérations présentes. Écris les étapes et vérifie le résultat par une estimation."],["Dénombrement","Le dénombrement consiste à compter des possibilités sans les énumérer une par une. Le principe multiplicatif permet de compter une succession de choix : si une première étape offre a possibilités et une seconde b possibilités, le total est a×b. Les tableaux et arbres permettent d'organiser les cas.","Pour choisir une tenue avec 3 chemises et 2 pantalons, il existe 3×2 = 6 tenues.","Identifie les étapes du choix. Utilise un arbre lorsque plusieurs cas doivent être distingués et vérifie que chaque possibilité n'est comptée qu'une fois."],["Calcul littéral","Le calcul littéral utilise des lettres pour représenter des nombres variables. Développer utilise la distributivité, réduire regroupe les termes semblables et factoriser met un facteur commun en évidence.","3(x+4)-2x = 3x+12-2x = x+12. Et 5x+15 = 5(x+3).","Transforme l'expression ligne par ligne et conserve les signes. Une expression développée et une expression factorisée doivent rester équivalentes."],["Équations et inéquations","Une équation cherche les valeurs qui rendent deux expressions égales. Une inéquation cherche celles qui rendent une comparaison vraie. Les transformations doivent préserver les solutions. Dans une inéquation, une multiplication ou division par un nombre négatif inverse le sens du signe.","2x+5=17 donne x=6. Pour -3x>9, on obtient x<-3.","Isole progressivement l'inconnue et écris une ligne par transformation. Termine par une vérification."],["Généralités sur les fonctions","Une fonction associe à chaque nombre x de son domaine une unique image f(x). Elle peut être décrite par une formule, un tableau ou un graphique. Calculer une image consiste à remplacer x par une valeur.","Pour f(x)=2x-3, f(5)=7. Le nombre 5 est un antécédent de 7.","Distingue toujours image et antécédent : pour une image, on remplace x ; pour un antécédent, on résout f(x)=y."],["Fonctions usuelles","Une fonction affine s'écrit f(x)=ax+b. Les fonctions carrée et inverse possèdent des propriétés particulières de domaine et de variation. Le coefficient directeur d'une fonction affine décrit une variation constante.","Pour f(x)=3x-2, quand x augmente de 1, l'image augmente de 3 et f(0)=-2.","Identifie d'abord la forme de la fonction puis utilise ses propriétés plutôt que de recalculer inutilement."],["Statistique","Les effectifs et fréquences décrivent une série. La moyenne donne une valeur centrale calculée, la médiane partage une série ordonnée et l'étendue mesure l'écart entre maximum et minimum.","Pour 8, 10, 10, 12, 15, la moyenne est 11, la médiane est 10 et l'étendue est 7.","Ordonne les données avant la médiane. Pour une moyenne, additionne toutes les valeurs puis divise par l'effectif total."],["Systèmes d'équations linéaires","Un système de deux équations à deux inconnues cherche un couple satisfaisant simultanément les deux égalités. On peut utiliser la substitution ou la combinaison linéaire.","x+y=7 et x-y=1. En additionnant, 2x=8, donc x=4 puis y=3.","Choisis l'inconnue la plus facile à isoler ou une combinaison qui fait disparaître une inconnue. Vérifie les deux équations."]],"1ere":[["Équations et inéquations","Les équations et inéquations permettent de formaliser des problèmes. On effectue les mêmes transformations aux deux membres ; pour une inéquation, le sens change lorsqu'on multiplie ou divise par un nombre négatif.","4x-7=9 donne x=4. Pour 2x+1≤7, x≤3.","Réduis, regroupe l'inconnue d'un côté puis les constantes de l'autre. Vérifie la solution."],["Dénombrement et combinatoire","La combinatoire organise le comptage de configurations. Il faut distinguer les situations où l'ordre des choix compte de celles où il ne compte pas.","Pour choisir un président parmi 5 puis un secrétaire parmi les 4 personnes restantes, il y a 5×4=20 choix.","Avant de calculer, demande-toi si échanger deux positions produit une nouvelle configuration."],["Fonctions et variations","Une fonction est croissante lorsque ses images augmentent avec x et décroissante lorsqu'elles diminuent. Le tableau de variation synthétise le comportement de la fonction sur chaque intervalle.","Pour f(x)=x² sur [0;+∞[, la fonction est croissante.","Découpe l'étude en intervalles lorsque le comportement change et justifie les variations par une propriété ou le signe de la dérivée lorsqu'elle est disponible."],["Dérivation","La dérivée décrit la variation locale d'une fonction. Son signe permet souvent de déterminer les intervalles de croissance et de décroissance et de repérer les extremums.","Pour f(x)=x², f'(x)=2x. La fonction décroît avant 0 puis croît après 0.","Calcule la dérivée, étudie son signe, puis construis le tableau de variation et vérifie les valeurs importantes."],["Suites numériques","Une suite est une succession ordonnée de nombres. Une suite arithmétique s'obtient en ajoutant toujours la même raison ; une suite géométrique en multipliant toujours par la même raison.","Si u0=5 et u(n+1)=u(n)+3, alors u1=8, u2=11 et u3=14.","Identifie le type de suite et la manière dont l'indice évolue avant d'appliquer une formule."],["Limites et continuité","La limite décrit le comportement d'une fonction près d'un point ou à l'infini. La continuité traduit l'absence de rupture locale et relie la valeur de la fonction à sa limite.","Pour f(x)=x², lorsque x tend vers 2, f(x) tend vers 4.","Distingue valeur, limite et comportement à gauche ou à droite. Utilise les limites usuelles avant de transformer une expression."],["Probabilités","Une expérience aléatoire possède un ensemble d'issues. Une probabilité est comprise entre 0 et 1. En équiprobabilité, elle se calcule par nombre de cas favorables sur nombre de cas possibles.","Pour un dé équilibré, P(nombre pair)=3/6=1/2.","Décris d'abord l'univers, puis l'événement. Vérifie que les probabilités de toutes les issues totalisent 1."],["Statistique","Les quartiles complètent la moyenne et la médiane pour décrire une série et sa dispersion. L'écart interquartile mesure la largeur de la partie centrale des données.","Pour une série ordonnée, Q1 situe la zone des 25 % inférieurs et Q3 celle des 75 %.","Trie les données avant de déterminer médiane et quartiles. Interprète ensuite l'indicateur dans le contexte."]],"Tle":[["Limites et continuité","La limite décrit le comportement d'une fonction autour d'un point ou à l'infini. Elle intervient dans l'étude des asymptotes et de la continuité. Certaines formes nécessitent une transformation avant de calculer la limite.","Pour f(x)=1/x, quand x tend vers +∞, f(x) tend vers 0 ; y=0 est une asymptote horizontale.","Identifie le type de limite et recherche d'abord les limites connues. Simplifie lorsqu'une forme indéterminée apparaît."],["Dérivation et étude de fonctions","La dérivée permet de construire un tableau de signe et de variation et d'identifier des extremums. Les solutions de f'(x)=0 sont des valeurs critiques à étudier.","Pour f(x)=x³-3x, f'(x)=3(x²-1)=3(x-1)(x+1).","Travaille dans l'ordre domaine → dérivée → signe → variations → valeurs remarquables."],["Primitives et intégrales","Une primitive F d'une fonction f vérifie F'=f. Une intégrale définie peut représenter une aire algébrique ou une quantité accumulée.","Une primitive de 2x est x². L'intégrale de 0 à 3 de 2x vaut 9.","Pour une intégrale définie, trouve une primitive puis applique les bornes dans l'ordre. Vérifie le signe attendu de l'aire ou de la quantité."],["Fonction logarithme","Le logarithme népérien ln est défini sur ]0;+∞[. Il transforme les produits en sommes et les quotients en différences. Sa dérivée est 1/x.","ln(e²)=2 et l'équation ln(x)=3 donne x=e³.","Vérifie toujours que les arguments des logarithmes sont strictement positifs."],["Fonction exponentielle","La fonction exponentielle est positive sur R, vérifie e^(a+b)=e^a e^b et sa dérivée est elle-même. Elle est liée au logarithme par réciprocité.","e^0=1 et e^(ln 5)=5. L'équation e^x=7 donne x=ln 7.","Cherche d'abord une forme commune puis utilise le logarithme lorsque l'inconnue est dans l'exposant."],["Suites numériques","Les suites modélisent des évolutions discrètes. Les suites arithmétiques et géométriques possèdent des expressions générales qui permettent de calculer rapidement un terme.","Avec u0=3 et une raison arithmétique 2, un=3+2n. Avec v0=5 et une raison géométrique 3, vn=5×3^n.","Identifie le type de suite puis choisis une formule cohérente avec l'indice utilisé."],["Probabilités et variables aléatoires","Une variable aléatoire associe un nombre à chaque issue. Sa loi donne les probabilités des valeurs, et son espérance est une moyenne théorique pondérée.","Si X vaut 0 avec probabilité 0,4 et 10 avec probabilité 0,6, E(X)=6.","Construis le tableau des valeurs et probabilités. Vérifie que la somme des probabilités vaut 1."],["Statistique à deux variables","Une série à deux variables étudie la relation entre deux grandeurs. Le nuage de points montre la tendance ; un ajustement affine peut servir à estimer une valeur.","Pour une droite d'ajustement y=2x+5, x=10 donne une estimation de y=25.","Sépare bien valeur observée et valeur estimée. Analyse d'abord la tendance du nuage."],["Nombres complexes","Un nombre complexe s'écrit z=a+ib avec a,b réels et i²=-1. Les calculs se font comme avec des expressions littérales puis on remplace i² par -1.","(2+3i)+(1-5i)=3-2i.","Regroupe les parties réelles et imaginaires. Lors d'un produit, développe puis simplifie les puissances de i."],["Équations différentielles","Une équation différentielle relie une fonction inconnue à ses dérivées. Pour y'=ay, les solutions sont de la forme y=Ce^(ax). Une condition initiale permet de déterminer C.","Pour y'=2y, y=Ce^(2x). Si y(0)=3, alors C=3.","Trouve d'abord la famille générale puis utilise la condition initiale et vérifie la solution par dérivation."]]};

async function findChapter(niveau,index,titre){
  const code='LYCEE-MATH-'+niveau+'-'+String(index+1).padStart(2,'0');
  const q=await db.collection('ca_chapitres').where('code','==',code).limit(1).get();
  if(!q.empty) return q.docs[0];
  const q2=await db.collection('ca_chapitres').where('niveau','==',niveau).where('matiereId','==','math').limit(100).get();
  return q2.docs.find(d=>d.data().titre===titre && Number(d.data().ordre||0)===index+1) || null;
}

async function main(){
  let updated=0;
  for(const [niveau,items] of Object.entries(lessons)){
    for(let i=0;i<items.length;i++){
      const [titre,notion,example,method]=items[i];
      const ch=await findChapter(niveau,i,titre);
      if(!ch){console.log('CHAPITRE_NON_TROUVE',niveau,i+1,titre);continue;}

      const contenu=[
        '# '+titre,
        '',
        '## 1. Comprendre',
        notion,
        '',
        '## 2. Exemple guidé',
        example,
        '',
        '## 3. Méthode',
        method,
        '',
        '1. Lire précisément la question.',
        '2. Relever les données utiles.',
        '3. Choisir la propriété, la formule ou le raisonnement adapté.',
        '4. Rédiger les étapes.',
        '5. Vérifier le résultat et sa cohérence.',
        '',
        '## 4. Erreurs à éviter',
        'Ne choisis pas une formule simplement parce qu elle contient les mêmes nombres que l énoncé. Vérifie toujours les conditions d utilisation de la propriété.',
        '',
        '## À retenir',
        'Une notion est maîtrisée lorsque tu peux la définir, l expliquer avec tes propres mots et l appliquer à une situation nouvelle.'
      ].join('\n');

      const base={
        chapitreId:ch.id,niveau,matiereId:'math',ecoleId:'',imagesUrls:[],
        pdfUrl:'',videoYoutubeId:'',enonce:'',solution:'',difficulte:1,
        ressourceLieeId:'',questions:[],dureeMinutes:40,examen:'',
        annee:2026,serie:'',actif:true,ressourceNationale:true,
        auteur:'sentinel-pedagogie-math-lycee-2026',dateMaj:FieldValue.serverTimestamp()
      };
      const qr=await db.collection('ca_ressources').where('chapitreId','==',ch.id).where('type','==','cours').limit(5).get();
      const data={...base,type:'cours',titre:'Cours approfondi — '+titre,ordre:1,contenu};
      if(!qr.empty) await qr.docs[0].ref.update(data);
      else await db.collection('ca_ressources').doc(ch.id+'_math_lycee_cours').set({...data,dateCreation:FieldValue.serverTimestamp()});
      updated++;
    }
  }
  await db.collection('ca_parametres').doc('version').set({
    version:FieldValue.increment(1),dateMaj:FieldValue.serverTimestamp(),
    derniereRessourceNationale:'math_lycee_approfondi'
  },{merge:true});
  console.log(JSON.stringify({ok:true,ressourcesCoursMisesAJour:updated},null,2));
}

main().catch(err=>{console.error('ENRICH_MATH_LYCEE_ERROR');console.error(err&&err.stack?err.stack:err);process.exit(1);});

// ============================================================================
//  SENTINEL CI — CENTRE D'APPRENTISSAGE
//  Service Firestore : lecture, ecriture et cache du contenu pedagogique
//  Fichier : lib/centre_apprentissage/services/contenu_service.dart
//
//  IMPORTANT — Toutes les collections sont prefixees "ca_" (Centre
//  d'Apprentissage) pour ne JAMAIS entrer en collision avec les collections
//  existantes de l'application, en particulier 'matieres' qui est propre a
//  chaque ecole.
//
//  Regle respectee partout : UN SEUL filtre par requete Firestore.
//  Le filtrage secondaire et le tri se font cote application, donc aucun
//  index composite n'est necessaire.
// ============================================================================

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../modeles/contenu.dart';

class ContenuService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --------------------------------------------------------------------------
  //  NOMS DES COLLECTIONS
  // --------------------------------------------------------------------------
  static const String colMatieres = 'ca_matieres';
  static const String colChapitres = 'ca_chapitres';
  static const String colRessources = 'ca_ressources';
  static const String colParametres = 'ca_parametres';
  static const String docVersion = 'version';

  // ==========================================================================
  //  1. CACHE MEMOIRE
  //
  //  Le catalogue change rarement mais est lu en permanence. On le garde en
  //  memoire et on ne relit Firestore que si le numero de version a change.
  // ==========================================================================

  static int _versionConnue = -1;
  static List<Matiere>? _cacheMatieres;
  static final Map<String, List<Chapitre>> _cacheChapitres = {}; // cle : niveau
  static final Map<String, List<Ressource>> _cacheRessources = {}; // cle : chapitreId|ecoleId

  /// Vide entierement le cache (appele automatiquement quand la version change).
  static void viderCache() {
    _cacheMatieres = null;
    _cacheChapitres.clear();
    _cacheRessources.clear();
  }

  /// Lit le numero de version du catalogue et vide le cache s'il a change.
  /// Cout : 1 lecture Firestore, et uniquement au demarrage d'une consultation.
  static Future<void> verifierVersion() async {
    try {
      final d = await _db.collection(colParametres).doc(docVersion).get();
      final v = VersionContenu.depuisDoc(d).version;
      if (v != _versionConnue) {
        viderCache();
        _versionConnue = v;
      }
    } catch (_) {
      // Hors ligne : on garde le cache existant, l'eleve continue de travailler.
    }
  }

  /// Incremente le numero de version : previent toutes les applications
  /// qu'elles doivent recharger le catalogue. Appele apres chaque publication.
  static Future<void> _signalerChangement() async {
    try {
      await _db.collection(colParametres).doc(docVersion).set({
        'version': FieldValue.increment(1),
        'dateMaj': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
    viderCache();
  }

  // ==========================================================================
  //  2. MATIERES  (collection ca_matieres)
  // ==========================================================================

  /// Flux temps reel des matieres — pour le back-office.
  static Stream<List<Matiere>> streamMatieres() {
    return _db.collection(colMatieres).snapshots().map((s) {
      final l = s.docs.map((d) => Matiere.depuisDoc(d)).toList();
      l.sort((a, b) {
        final c = a.ordre.compareTo(b.ordre);
        return c != 0 ? c : a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
      });
      return l;
    });
  }

  /// Matieres actives d'un niveau donne — lecture mise en cache (cote eleve).
  static Future<List<Matiere>> matieres({String? niveau}) async {
    await verifierVersion();
    if (_cacheMatieres == null) {
      final s = await _db.collection(colMatieres).get();
      final l = s.docs.map((d) => Matiere.depuisDoc(d)).toList();
      l.sort((a, b) {
        final c = a.ordre.compareTo(b.ordre);
        return c != 0 ? c : a.nom.toLowerCase().compareTo(b.nom.toLowerCase());
      });
      _cacheMatieres = l;
    }
    final toutes = _cacheMatieres!.where((m) => m.actif).toList();
    if (niveau == null || niveau.isEmpty) return toutes;
    // Une matiere sans liste de niveaux est consideree comme enseignee partout.
    return toutes
        .where((m) => m.niveaux.isEmpty || m.niveaux.contains(niveau))
        .toList();
  }

  /// Cree une matiere. [id] est un identifiant court et lisible : 'math',
  /// 'franc', 'pc', 'svt'... Renvoie null si tout s'est bien passe.
  static Future<String?> creerMatiere(Matiere m) async {
    try {
      final ref = _db.collection(colMatieres).doc(m.id);
      if ((await ref.get()).exists) {
        return 'Cet identifiant de matiere existe deja.';
      }
      await ref.set(m.versMap());
      await _signalerChangement();
      return null;
    } catch (e) {
      return 'Erreur : $e';
    }
  }

  static Future<void> modifierMatiere(Matiere m) async {
    await _db.collection(colMatieres).doc(m.id).set(m.versMap(), SetOptions(merge: true));
    await _signalerChangement();
  }

  /// Suppression douce : la matiere est masquee, son contenu n'est pas detruit.
  static Future<void> desactiverMatiere(String matiereId) async {
    await _db.collection(colMatieres).doc(matiereId).update({'actif': false});
    await _signalerChangement();
  }

  // ==========================================================================
  //  3. CHAPITRES  (collection ca_chapitres)
  //
  //  Requete : UN seul filtre (niveau). Le tri par ordre et le filtrage par
  //  matiere se font cote application — donc aucun index a creer.
  // ==========================================================================

  /// Flux temps reel des chapitres d'un niveau — pour le back-office.
  static Stream<List<Chapitre>> streamChapitres(String niveau, {String? matiereId}) {
    return _db
        .collection(colChapitres)
        .where('niveau', isEqualTo: niveau)
        .snapshots()
        .map((s) {
      var l = s.docs.map((d) => Chapitre.depuisDoc(d)).toList();
      if (matiereId != null && matiereId.isNotEmpty) {
        l = l.where((c) => c.matiereId == matiereId).toList();
      }
      l.sort((a, b) {
        final c = a.matiereId.compareTo(b.matiereId);
        return c != 0 ? c : a.ordre.compareTo(b.ordre);
      });
      return l;
    });
  }

  /// Chapitres actifs d'un niveau et d'une matiere — lecture mise en cache.
  static Future<List<Chapitre>> chapitres(String niveau, String matiereId) async {
    await verifierVersion();
    if (!_cacheChapitres.containsKey(niveau)) {
      final s = await _db.collection(colChapitres)
          .where('niveau', isEqualTo: niveau).get();
      final l = s.docs.map((d) => Chapitre.depuisDoc(d)).toList();
      l.sort((a, b) {
        final c = a.matiereId.compareTo(b.matiereId);
        return c != 0 ? c : a.ordre.compareTo(b.ordre);
      });
      _cacheChapitres[niveau] = l;
    }
    return _cacheChapitres[niveau]!
        .where((c) => c.actif && c.matiereId == matiereId)
        .toList();
  }

  /// Un chapitre precis (utile pour la revision personnalisee).
  static Future<Chapitre?> chapitre(String chapitreId) async {
    try {
      final d = await _db.collection(colChapitres).doc(chapitreId).get();
      return d.exists ? Chapitre.depuisDoc(d) : null;
    } catch (_) {
      return null;
    }
  }

  /// Cree un chapitre. Si [c.id] est vide, un identifiant lisible est
  /// fabrique automatiquement : "6e_math_ch03".
  /// Renvoie l'identifiant cree, ou un message d'erreur prefixe par "!".
  static Future<String> creerChapitre(Chapitre c) async {
    try {
      final id = c.id.isNotEmpty
          ? c.id
          : Chapitre.construireId(c.niveau, c.matiereId, c.ordre);
      final ref = _db.collection(colChapitres).doc(id);
      if ((await ref.get()).exists) {
        return '!Un chapitre porte deja l identifiant $id (verifiez le numero d ordre).';
      }
      await ref.set(c.versMap());
      await _signalerChangement();
      return id;
    } catch (e) {
      return '!Erreur : $e';
    }
  }

  static Future<void> modifierChapitre(Chapitre c) async {
    await _db.collection(colChapitres).doc(c.id).set(c.versMap(), SetOptions(merge: true));
    await _signalerChangement();
  }

  /// Supprime un chapitre ET toutes ses ressources (par lots de 400).
  /// Renvoie le nombre total de documents effaces.
  static Future<int> supprimerChapitre(String chapitreId) async {
    int total = 0;
    while (true) {
      final s = await _db.collection(colRessources)
          .where('chapitreId', isEqualTo: chapitreId).limit(400).get();
      if (s.docs.isEmpty) break;
      final batch = _db.batch();
      for (final d in s.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
      total += s.docs.length;
      if (s.docs.length < 400) break;
    }
    await _db.collection(colChapitres).doc(chapitreId).delete();
    total += 1;
    await _signalerChangement();
    return total;
  }

  // ==========================================================================
  //  4. RESSOURCES  (collection ca_ressources)
  //
  //  Une seule collection pour les 9 types de contenu. Requete a un seul
  //  filtre : chapitreId (contenu de cours) ou examen (sujets BEPC / BAC).
  // ==========================================================================

  /// Flux temps reel des ressources d'un chapitre — pour le back-office.
  /// Affiche aussi les brouillons (actif = false).
  /// [portee] filtre l'affichage du back-office :
  ///  - null  : tout ce que l'utilisateur a le droit de voir ;
  ///  - ''    : uniquement le contenu national ;
  ///  - 'id'  : uniquement le contenu de cette ecole.
  static Stream<List<Ressource>> streamRessourcesChapitre(String chapitreId,
      {TypeRessource? type, String? portee}) {
    return _db
        .collection(colRessources)
        .where('chapitreId', isEqualTo: chapitreId)
        .snapshots()
        .map((s) {
      var l = s.docs.map((d) => Ressource.depuisDoc(d)).toList();
      if (portee != null) l = l.where((r) => r.ecoleId == portee).toList();
      if (type != null) l = l.where((r) => r.type == type).toList();
      l.sort((a, b) {
        final e = (a.estNational ? 1 : 0).compareTo(b.estNational ? 1 : 0);
        if (e != 0) return e;
        final c = a.type.index.compareTo(b.type.index);
        return c != 0 ? c : a.ordre.compareTo(b.ordre);
      });
      return l;
    });
  }

  /// Ressources publiees d'un chapitre — lecture mise en cache (cote eleve).
  ///
  /// [ecoleId] est l'ecole de l'eleve. Il recoit :
  ///  - le contenu NATIONAL (ecoleId vide sur la ressource) ;
  ///  - le contenu PRIVE de SON ecole.
  /// Le contenu des autres ecoles est ecarte.
  ///
  /// Le contenu de l'ecole passe AVANT le national : le cours du professeur
  /// de l'eleve doit arriver en premier.
  static Future<List<Ressource>> ressourcesChapitre(String chapitreId,
      {TypeRessource? type, String ecoleId = ''}) async {
    await verifierVersion();
    final cle = '$chapitreId|$ecoleId';
    if (!_cacheRessources.containsKey(cle)) {
      final s = await _db.collection(colRessources)
          .where('chapitreId', isEqualTo: chapitreId).get();
      final l = s.docs
          .map((d) => Ressource.depuisDoc(d))
          .where((r) => r.estNational || r.ecoleId == ecoleId)
          .toList();
      l.sort((a, b) {
        // 1. le contenu de l'ecole d'abord
        final e = (a.estNational ? 1 : 0).compareTo(b.estNational ? 1 : 0);
        if (e != 0) return e;
        // 2. puis par type, dans l'ordre pedagogique
        final c = a.type.index.compareTo(b.type.index);
        return c != 0 ? c : a.ordre.compareTo(b.ordre);
      });
      _cacheRessources[cle] = l;
    }
    var l = _cacheRessources[cle]!.where((r) => r.actif).toList();
    if (type != null) l = l.where((r) => r.type == type).toList();
    return l;
  }

  /// Exercices d'un chapitre classes du plus facile au niveau examen.
  static Future<List<Ressource>> exercices(String chapitreId,
      {int? difficulte, String ecoleId = ''}) async {
    var l = await ressourcesChapitre(chapitreId,
        type: TypeRessource.exercice, ecoleId: ecoleId);
    if (difficulte != null) {
      l = l.where((r) => r.difficulte == difficulte).toList();
    }
    l.sort((a, b) {
      final c = a.difficulte.compareTo(b.difficulte);
      return c != 0 ? c : a.ordre.compareTo(b.ordre);
    });
    return l;
  }

  /// Sujets d'examen : 'BEPC' ou 'BAC'. Filtre unique sur le champ 'examen',
  /// tri par annee decroissante cote application.
  static Future<List<Ressource>> sujetsExamen(String examen,
      {String? matiereId, String? serie, String ecoleId = ''}) async {
    final s = await _db.collection(colRessources)
        .where('examen', isEqualTo: examen).get();
    var l = s.docs
        .map((d) => Ressource.depuisDoc(d))
        .where((r) => r.actif && (r.estNational || r.ecoleId == ecoleId))
        .toList();
    if (matiereId != null && matiereId.isNotEmpty) {
      l = l.where((r) => r.matiereId == matiereId).toList();
    }
    if (serie != null && serie.isNotEmpty) {
      l = l.where((r) => r.serie == serie).toList();
    }
    l.sort((a, b) => b.annee.compareTo(a.annee));
    return l;
  }

  /// Flux temps reel des sujets d'examen — pour le back-office.
  static Stream<List<Ressource>> streamSujetsExamen(String examen) {
    return _db
        .collection(colRessources)
        .where('examen', isEqualTo: examen)
        .snapshots()
        .map((s) {
      final l = s.docs.map((d) => Ressource.depuisDoc(d)).toList();
      l.sort((a, b) => b.annee.compareTo(a.annee));
      return l;
    });
  }

  /// Une ressource precise (ouverture d'un cours, d'un quiz, d'un corrige...).
  static Future<Ressource?> ressource(String ressourceId) async {
    try {
      final d = await _db.collection(colRessources).doc(ressourceId).get();
      return d.exists ? Ressource.depuisDoc(d) : null;
    } catch (_) {
      return null;
    }
  }

  /// Publie une nouvelle ressource. Renvoie son identifiant,
  /// ou un message d'erreur prefixe par "!".
  static Future<String> creerRessource(Ressource r) async {
    try {
      final ref = r.id.isNotEmpty
          ? _db.collection(colRessources).doc(r.id)
          : _db.collection(colRessources).doc();
      await ref.set(r.versMap(creation: true));
      await _signalerChangement();
      return ref.id;
    } catch (e) {
      return '!Erreur : $e';
    }
  }

  static Future<void> modifierRessource(Ressource r) async {
    await _db.collection(colRessources).doc(r.id).set(r.versMap(), SetOptions(merge: true));
    await _signalerChangement();
  }

  /// Bascule brouillon <-> publie.
  static Future<void> basculerPublication(String ressourceId, bool actif) async {
    await _db.collection(colRessources).doc(ressourceId).update({
      'actif': actif,
      'dateMaj': FieldValue.serverTimestamp(),
    });
    await _signalerChangement();
  }

  static Future<void> supprimerRessource(String ressourceId) async {
    await _db.collection(colRessources).doc(ressourceId).delete();
    await _signalerChangement();
  }

  // ==========================================================================
  //  5. FICHIERS (images et PDF)
  //
  //  Les VIDEOS ne passent jamais par ici : on stocke uniquement l'identifiant
  //  YouTube (voir Ressource.extraireIdYoutube). Cout de stockage : zero.
  // ==========================================================================

  /// Televerse une image (schema, illustration) et renvoie son adresse.
  static Future<String> uploadImage(
      String chapitreId, Uint8List bytes, String nom) async {
    final chemin =
        'centre_apprentissage/$chapitreId/${DateTime.now().millisecondsSinceEpoch}_$nom';
    final ref = FirebaseStorage.instance.ref(chemin);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  /// Televerse un PDF (cours officiel, sujet d'examen, corrige).
  static Future<String> uploadPdf(
      String dossier, Uint8List bytes, String nom) async {
    final chemin =
        'centre_apprentissage/pdf/$dossier/${DateTime.now().millisecondsSinceEpoch}_$nom';
    final ref = FirebaseStorage.instance.ref(chemin);
    await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));
    return await ref.getDownloadURL();
  }

  // ==========================================================================
  //  6. STATISTIQUES DU BACK-OFFICE
  //
  //  Compte ce qui est publie, pour piloter la production de contenu.
  // ==========================================================================

  static Future<({int chapitres, int ressources, int brouillons})>
      statistiques() async {
    try {
      final ch = await _db.collection(colChapitres).get();
      final re = await _db.collection(colRessources).get();
      final brouillons =
          re.docs.where((d) => (d.data()['actif'] ?? false) != true).length;
      return (
        chapitres: ch.docs.length,
        ressources: re.docs.length,
        brouillons: brouillons,
      );
    } catch (_) {
      return (chapitres: 0, ressources: 0, brouillons: 0);
    }
  }

  /// Nombre de ressources publiees par type, pour un niveau donne.
  /// Utile pour reperer les trous du programme (ex. « 3e : aucun quiz »).
  static Future<Map<TypeRessource, int>> repartitionParType(String niveau) async {
    final out = <TypeRessource, int>{};
    try {
      final s = await _db.collection(colRessources)
          .where('niveau', isEqualTo: niveau).get();
      for (final d in s.docs) {
        final r = Ressource.depuisDoc(d);
        if (!r.actif) continue;
        out[r.type] = (out[r.type] ?? 0) + 1;
      }
    } catch (_) {}
    return out;
  }

  // ==========================================================================
  //  7. DEMARRAGE RAPIDE
  //
  //  Cree les matieres courantes du secondaire ivoirien si elles n'existent
  //  pas encore. Meme principe que « Ajouter les matieres courantes » deja
  //  present dans l'application. Renvoie le nombre de matieres ajoutees.
  // ==========================================================================

  static const List<Matiere> matieresCourantes = [
    Matiere(id: 'math', nom: 'Mathematiques', couleurHex: '1565C0', ordre: 1),
    Matiere(id: 'pc', nom: 'Physique-Chimie', couleurHex: '6A1B9A', ordre: 2),
    Matiere(id: 'svt', nom: 'SVT', couleurHex: '1B9D21', ordre: 3),
    Matiere(id: 'franc', nom: 'Francais', couleurHex: 'D32F2F', ordre: 4),
    Matiere(id: 'angl', nom: 'Anglais', couleurHex: 'F57C00', ordre: 5),
    Matiere(id: 'hg', nom: 'Histoire-Geographie', couleurHex: 'F9A825', ordre: 6),
    Matiere(id: 'philo', nom: 'Philosophie', couleurHex: '455A64',
        ordre: 7, niveaux: ['Tle']),
    Matiere(id: 'eps', nom: 'EPS', couleurHex: '00897B', ordre: 8),
    Matiere(id: 'info', nom: 'Informatique', couleurHex: '5E35B1', ordre: 9),
    Matiere(id: 'ecm', nom: 'Education civique et morale',
        couleurHex: '795548', ordre: 10),
  ];

  static Future<int> installerMatieresCourantes() async {
    int ajoutees = 0;
    try {
      final existantes = (await _db.collection(colMatieres).get())
          .docs.map((d) => d.id).toSet();
      final batch = _db.batch();
      for (final m in matieresCourantes) {
        if (existantes.contains(m.id)) continue;
        batch.set(_db.collection(colMatieres).doc(m.id), m.versMap());
        ajoutees++;
      }
      if (ajoutees > 0) {
        await batch.commit();
        await _signalerChangement();
      }
    } catch (_) {}
    return ajoutees;
  }
}

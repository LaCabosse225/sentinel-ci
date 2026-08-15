// ============================================================================
//  SENTINEL CI — AVIS DES UTILISATEURS
//  Fichier : lib/avis/avis.dart
//
//  PRINCIPE : SÉPARER LE RECUEIL DE LA PUBLICATION
//  Un avis donné dans l'application n'est visible par PERSONNE d'autre que
//  l'équipe Sentinel. Rien n'est publié automatiquement.
//
//  Pourquoi ce choix :
//   - un parent en colère peut nommer un enseignant ou évoquer un enfant ;
//     publié tel quel, cela deviendrait un problème juridique et une crise
//     avec l'établissement ;
//   - les élèves sont mineurs : on ne leur ouvre aucun canal de publication
//     de texte libre. Ils notent, ils n'écrivent pas ;
//   - un avis négatif affiché dans l'application desservirait précisément
//     ce que l'on cherche à construire.
//
//  Les témoignages retenus sont validés un par un par le super admin, puis
//  repris sur le site et dans le dossier commercial, avec l'accord de leur
//  auteur.
//
//  L'avis porte sur SENTINEL, jamais sur l'établissement : aucun directeur
//  n'accepterait un outil permettant à ses parents de le noter.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

// ============================================================================
//  1. MODÈLE
// ============================================================================

class Avis {
  final String id; // = uid de l'auteur : un seul avis par personne
  final String auteurNom;
  final String role;
  final String ecoleId;
  final int note; // de 1 à 5
  final String texte; // facultatif, jamais rempli par un élève
  final bool publiable; // validé par le super admin
  final bool accordPublication; // l'auteur a accepté d'être cité
  final DateTime? date;

  const Avis({
    required this.id,
    required this.auteurNom,
    required this.role,
    required this.ecoleId,
    required this.note,
    this.texte = '',
    this.publiable = false,
    this.accordPublication = false,
    this.date,
  });

  factory Avis.depuisDoc(DocumentSnapshot d) {
    final m = (d.data() as Map<String, dynamic>?) ?? {};
    return Avis(
      id: d.id,
      auteurNom: m['auteurNom'] as String? ?? '',
      role: m['role'] as String? ?? '',
      ecoleId: m['ecoleId'] as String? ?? '',
      note: (m['note'] as num?)?.toInt() ?? 0,
      texte: m['texte'] as String? ?? '',
      publiable: m['publiable'] as bool? ?? false,
      accordPublication: m['accordPublication'] as bool? ?? false,
      date: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> versMap() => {
        'auteurNom': auteurNom,
        'role': role,
        'ecoleId': ecoleId,
        'note': note,
        'texte': texte,
        'publiable': publiable,
        'accordPublication': accordPublication,
        'createdAt': FieldValue.serverTimestamp(),
      };

  String get roleLisible {
    switch (role) {
      case 'parent':
        return 'Parent';
      case 'eleve':
        return 'Élève';
      case 'prof':
        return 'Professeur';
      case 'directeur':
        return 'Directeur';
      case 'admin':
        return 'Administrateur';
      default:
        return role;
    }
  }
}

// ============================================================================
//  2. SERVICE
// ============================================================================

class AvisService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String col = 'avis';

  /// Enregistre l'avis. L'identifiant du document est l'uid de l'auteur :
  /// une personne ne peut donc laisser qu'un seul avis, qu'elle peut
  /// modifier. Cela évite tout gonflement artificiel de la moyenne.
  static Future<void> envoyer(Avis a) async {
    await _db.collection(col).doc(a.id).set(a.versMap(), SetOptions(merge: true));
  }

  /// L'avis déjà donné par cette personne, s'il existe.
  static Future<Avis?> mien(String uid) async {
    try {
      final d = await _db.collection(col).doc(uid).get();
      return d.exists ? Avis.depuisDoc(d) : null;
    } catch (_) {
      return null;
    }
  }

  /// Tous les avis — réservé au super admin par les règles Firestore.
  static Stream<List<Avis>> tous() {
    return _db.collection(col).snapshots().map((s) {
      final l = s.docs.map((d) => Avis.depuisDoc(d)).toList();
      l.sort((a, b) {
        final da = a.date, db_ = b.date;
        if (da == null || db_ == null) return 0;
        return db_.compareTo(da); // du plus récent au plus ancien
      });
      return l;
    });
  }

  static Future<void> marquerPubliable(String id, bool valeur) =>
      _db.collection(col).doc(id).update({'publiable': valeur});

  static Future<void> supprimer(String id) => _db.collection(col).doc(id).delete();
}

// ============================================================================
//  3. LA CARTE DE RECUEIL, SUR LE TABLEAU DE BORD
//
//  Discrète, et jamais insistante : elle n'apparaît qu'après plusieurs
//  ouvertures de l'application, disparaît définitivement une fois l'avis
//  donné, et se reporte de trente jours si la personne dit « plus tard ».
// ============================================================================

class CarteDemandeAvis extends StatefulWidget {
  final AppUser user;
  const CarteDemandeAvis({super.key, required this.user});
  @override
  State<CarteDemandeAvis> createState() => _CarteDemandeAvisState();
}

class _CarteDemandeAvisState extends State<CarteDemandeAvis> {
  bool _visible = false;

  /// Nombre d'ouvertures avant de proposer : on laisse la personne se faire
  /// une vraie opinion avant de la solliciter.
  static const int _ouverturesMinimum = 5;

  @override
  void initState() {
    super.initState();
    _decider();
  }

  Future<void> _decider() async {
    try {
      final p = await SharedPreferences.getInstance();
      final uid = widget.user.uid;

      // Déjà donné ? on n'y revient jamais.
      if (p.getBool('avis_donne_$uid') ?? false) return;

      // Reporté ? on respecte le délai.
      final reporte = p.getInt('avis_reporte_$uid') ?? 0;
      if (reporte > DateTime.now().millisecondsSinceEpoch) return;

      // Comptage des ouvertures.
      final n = (p.getInt('avis_ouvertures_$uid') ?? 0) + 1;
      await p.setInt('avis_ouvertures_$uid', n);
      if (n < _ouverturesMinimum) return;

      // Vérification côté serveur, au cas où l'appareil aurait changé.
      final existant = await AvisService.mien(uid);
      if (existant != null) {
        await p.setBool('avis_donne_$uid', true);
        return;
      }

      if (mounted) setState(() => _visible = true);
    } catch (_) {}
  }

  Future<void> _reporter() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(
          'avis_reporte_${widget.user.uid}',
          DateTime.now()
              .add(const Duration(days: 30))
              .millisecondsSinceEpoch);
    } catch (_) {}
    if (mounted) setState(() => _visible = false);
  }

  Future<void> _ouvrir() async {
    final envoye = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => DonnerAvisPage(user: widget.user)));
    if (envoye == true) {
      try {
        final p = await SharedPreferences.getInstance();
        await p.setBool('avis_donne_${widget.user.uid}', true);
      } catch (_) {}
      if (mounted) setState(() => _visible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.star_rounded, color: AppColors.gold, size: 24),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Votre avis nous aide',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 6),
          const Text(
              'Vous utilisez Sentinel depuis quelque temps. Deux minutes pour '
              'nous dire ce qui vous aide et ce qui vous manque ?',
              style: TextStyle(
                  fontSize: 12.5, height: 1.45, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _reporter,
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 11)),
                child: const Text('Plus tard', style: TextStyle(fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _ouvrir,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11)),
                child: const Text('Donner mon avis',
                    style: TextStyle(fontSize: 13)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ============================================================================
//  4. L'ÉCRAN DE SAISIE
// ============================================================================

class DonnerAvisPage extends StatefulWidget {
  final AppUser user;
  const DonnerAvisPage({super.key, required this.user});
  @override
  State<DonnerAvisPage> createState() => _DonnerAvisPageState();
}

class _DonnerAvisPageState extends State<DonnerAvisPage> {
  int _note = 0;
  final _texte = TextEditingController();
  bool _accord = false;
  bool _envoi = false;

  /// Un élève note, mais n'écrit pas : on n'ouvre aucun canal de texte
  /// libre à des mineurs, conformément à notre charte.
  bool get _peutEcrire => widget.user.role != UserRole.eleve;

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  static const List<String> _libelles = [
    '',
    'Cela ne me convient pas',
    'Cela peut mieux faire',
    'Correct',
    'Cela m\'aide vraiment',
    'Excellent, je le recommande',
  ];

  Future<void> _envoyer() async {
    if (_note == 0) {
      showSnack(context, 'Choisissez une note', error: true);
      return;
    }
    setState(() => _envoi = true);
    try {
      await AvisService.envoyer(Avis(
        id: widget.user.uid,
        auteurNom: widget.user.name,
        role: widget.user.role.name,
        ecoleId: widget.user.school,
        note: _note,
        texte: _peutEcrire ? _texte.text.trim() : '',
        accordPublication: _peutEcrire && _accord,
      ));
      if (!mounted) return;
      Navigator.pop(context, true);
      showSnack(context, 'Merci, votre avis nous a bien été transmis.');
    } catch (e) {
      if (mounted) {
        setState(() => _envoi = false);
        showSnack(context, 'Envoi impossible. Reessayez.', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Votre avis')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Que pensez-vous de Sentinel CI ?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
              'Votre avis porte sur l\'application, pas sur votre '
              'établissement. Il est transmis uniquement à l\'équipe Sentinel.',
              style: TextStyle(
                  fontSize: 12.5, height: 1.45, color: AppColors.textMuted)),
          const SizedBox(height: 22),

          // ---- Les étoiles ----
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final n = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _note = n),
                  icon: Icon(
                    _note >= n ? Icons.star_rounded : Icons.star_border_rounded,
                    color: _note >= n ? AppColors.gold : AppColors.textMuted,
                    size: 40,
                  ),
                );
              }),
            ),
          ),
          if (_note > 0)
            Center(
              child: Text(_libelles[_note],
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold)),
            ),
          const SizedBox(height: 24),

          // ---- Le texte, sauf pour les élèves ----
          if (_peutEcrire) ...[
            SCCard(
                child: TextField(
              controller: _texte,
              maxLines: 6,
              maxLength: 600,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Votre commentaire (facultatif)',
                alignLabelWithHint: true,
                helperText:
                    'Ce qui vous aide, ce qui vous manque, ce que vous amélioreriez',
              ),
            )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.blueBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: const [
                Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Merci de ne pas citer le nom d\'un enseignant ni d\'un '
                      'élève. Pour un problème précis, écrivez-nous depuis la '
                      'page Assistance.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.blue)),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () => setState(() => _accord = !_accord),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(
                  value: _accord,
                  activeColor: AppColors.green,
                  onChanged: (v) => setState(() => _accord = v ?? false),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                        'J\'accepte que mon témoignage soit cité par Sentinel CI, '
                        'avec mon prénom et mon rôle.',
                        style: TextStyle(fontSize: 12.5, height: 1.4)),
                  ),
                ),
              ]),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(12)),
              child: const Text(
                  'Ta note suffit : elle nous dit si l\'application t\'aide '
                  'vraiment dans ton travail. Merci !',
                  style: TextStyle(fontSize: 13, height: 1.45)),
            ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _envoi ? null : _envoyer,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15)),
              child: _envoi
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Envoyer mon avis'),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
                'Votre avis n\'apparaît nulle part dans l\'application.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ============================================================================
//  5. L'ÉCRAN DE MODÉRATION — SUPER ADMIN
// ============================================================================

class AvisRecusPage extends StatefulWidget {
  final AppUser user;
  const AvisRecusPage({super.key, required this.user});
  @override
  State<AvisRecusPage> createState() => _AvisRecusPageState();
}

class _AvisRecusPageState extends State<AvisRecusPage> {
  String _filtre = ''; // '' = tous, sinon un rôle

  static const Map<String, String> _roles = {
    'parent': 'Parents',
    'eleve': 'Élèves',
    'prof': 'Professeurs',
    'directeur': 'Direction',
  };

  @override
  Widget build(BuildContext context) {
    if (!widget.user.estSuperAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Avis reçus')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Text('Cet espace est réservé au super administrateur.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Avis reçus')),
      body: StreamBuilder<List<Avis>>(
        stream: AvisService.tous(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tous = snap.data!;
          if (tous.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text('Aucun avis reçu pour le moment.',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            );
          }

          final moyenne =
              tous.fold<int>(0, (s, a) => s + a.note) / tous.length;
          final publiables = tous.where((a) => a.publiable).length;
          final avecAccord =
              tous.where((a) => a.accordPublication && a.texte.isNotEmpty).length;

          final liste = _filtre.isEmpty
              ? tous
              : tous.where((a) => a.role == _filtre).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---- Synthèse ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.green, Color(0xFF0E6D14)]),
                    image: const DecorationImage(
                        image: AssetImage('assets/images/motif.png'),
                        repeat: ImageRepeat.repeat),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(moyenne.toStringAsFixed(2),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 4),
                      child: Text('/ 5',
                          style: TextStyle(color: Colors.white70, fontSize: 18)),
                    ),
                  ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) => Icon(
                            moyenne >= i + 0.75
                                ? Icons.star_rounded
                                : (moyenne >= i + 0.25
                                    ? Icons.star_half_rounded
                                    : Icons.star_border_rounded),
                            color: Colors.white,
                            size: 20,
                          ))),
                  const SizedBox(height: 8),
                  Text('${tous.length} avis reçus',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13.5)),
                ]),
              ),
              const SizedBox(height: 14),

              // ---- Compteurs ----
              Row(children: [
                _petit('Validés', '$publiables', AppColors.green,
                    AppColors.greenBg),
                const SizedBox(width: 10),
                _petit('Citables', '$avecAccord', AppColors.blue,
                    AppColors.blueBg),
                const SizedBox(width: 10),
                _petit('En attente', '${tous.length - publiables}',
                    AppColors.gold, AppColors.goldBg),
              ]),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                    '« Citables » : avis contenant un texte, dont l\'auteur a '
                    'accepté d\'être cité nommément.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ),
              const SizedBox(height: 14),

              // ---- Répartition par rôle ----
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _puce('', 'Tous (${tous.length})'),
                    ..._roles.entries.map((e) {
                      final n = tous.where((a) => a.role == e.key).length;
                      return _puce(e.key, '${e.value} ($n)');
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ---- La liste ----
              ...liste.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _carte(a),
                  )),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _petit(String label, String valeur, Color c, Color fond) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: fond, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text(valeur,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: c)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
          ]),
        ),
      );

  Widget _puce(String valeur, String libelle) {
    final actif = _filtre == valeur;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filtre = valeur),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              color: actif ? AppColors.green : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: actif ? AppColors.green : AppColors.border)),
          child: Text(libelle,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: actif ? Colors.white : AppColors.textMuted)),
        ),
      ),
    );
  }

  Widget _carte(Avis a) {
    return SCCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Row(
              children: List.generate(5, (i) => Icon(
                    a.note > i ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.gold,
                    size: 16,
                  ))),
          const SizedBox(width: 10),
          Expanded(
            child: Text(a.auteurNom,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w700)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                size: 18, color: AppColors.textMuted),
            onSelected: (v) async {
              if (v == 'valider') {
                await AvisService.marquerPubliable(a.id, !a.publiable);
                if (context.mounted) {
                  showSnack(
                      context,
                      a.publiable
                          ? 'Retiré des témoignages retenus.'
                          : 'Marqué comme utilisable en communication.');
                }
              } else if (v == 'supprimer') {
                final ok = await confirmerDialog(context, 'Supprimer cet avis ?',
                    'Il sera définitivement effacé.');
                if (ok) {
                  await AvisService.supprimer(a.id);
                  if (context.mounted) showSnack(context, 'Avis supprimé.');
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'valider',
                  child: Text(a.publiable ? 'Retirer' : 'Retenir')),
              const PopupMenuItem(
                  value: 'supprimer',
                  child: Text('Supprimer',
                      style: TextStyle(color: AppColors.red))),
            ],
          ),
        ]),
        const SizedBox(height: 2),
        Row(children: [
          Text(a.roleLisible,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted)),
          if (a.date != null) ...[
            const Text('  ·  ',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            Text(
                '${a.date!.day.toString().padLeft(2, '0')}/'
                '${a.date!.month.toString().padLeft(2, '0')}/${a.date!.year}',
                style: const TextStyle(
                    fontSize: 11.5, color: AppColors.textMuted)),
          ],
        ]),
        if (a.texte.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
            child: SelectableText(a.texte,
                style: const TextStyle(fontSize: 13, height: 1.5)),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 4, children: [
          if (a.publiable)
            _badge('Retenu', AppColors.green, AppColors.greenBg),
          if (a.accordPublication)
            _badge('Accord de citation', AppColors.blue, AppColors.blueBg)
          else if (a.texte.isNotEmpty)
            _badge('Sans accord de citation', AppColors.gold, AppColors.goldBg),
        ]),
      ]),
    );
  }

  Widget _badge(String texte, Color c, Color fond) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: fond, borderRadius: BorderRadius.circular(20)),
        child: Text(texte,
            style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w800, color: c)),
      );
}

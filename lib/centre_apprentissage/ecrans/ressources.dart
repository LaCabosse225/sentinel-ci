// ============================================================================
//  SENTINEL CI — CENTRE D'APPRENTISSAGE
//  Back-office : contenu d'un chapitre (cours, exercices, quiz, videos...)
//  Fichier : lib/centre_apprentissage/ecrans/ressources.dart
//
//  Reserve aux administrateurs Sentinel. Reutilise AppColors, SCCard,
//  SectionTitle, showSnack et confirmerDialog de l'application.
//
//  Principe de saisie retenu : du TEXTE pour tout ce qui s explique avec des
//  mots, et des IMAGES la ou il faut une formule ou une figure geometrique.
//  Les videos ne sont jamais televersees : on ne garde que l identifiant
//  YouTube (cout de stockage nul).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../modeles/contenu.dart';
import '../services/contenu_service.dart';
import '../donnees/contenu_officiel.dart';

// ============================================================================
//  ECRAN — LISTE DES RESSOURCES D'UN CHAPITRE
// ============================================================================

class RessourcesPage extends StatefulWidget {
  final AppUser user;
  final Chapitre chapitre;
  final Matiere matiere;
  const RessourcesPage(
      {super.key,
      required this.user,
      required this.chapitre,
      required this.matiere});

  @override
  State<RessourcesPage> createState() => _RessourcesPageState();
}

class _RessourcesPageState extends State<RessourcesPage> {
  TypeRessource? _filtre;

  /// Portee affichee et publiee :
  ///  - '' : contenu NATIONAL, partage par toutes les ecoles ;
  ///  - id : contenu PRIVE de l'etablissement.
  /// Seule l'equipe Sentinel (role admin) peut basculer entre les deux.
  late String _portee;

  bool get _estSentinel => widget.user.role == UserRole.admin;

  @override
  void initState() {
    super.initState();
    _portee = _estSentinel ? '' : widget.user.school;
  }

  /// Types proposables dans un chapitre (les sujets d examen et l orientation
  /// ne sont pas rattaches a un chapitre : ils auront leur propre ecran).
  static const List<TypeRessource> _typesChapitre = [
    TypeRessource.cours,
    TypeRessource.renforcement,
    TypeRessource.exercice,
    TypeRessource.corrige,
    TypeRessource.fiche,
    TypeRessource.quiz,
    TypeRessource.video,
  ];

  Future<void> _choisirType() async {
    final t = await showModalBottomSheet<TypeRessource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Que voulez-vous ajouter ?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ),
          ),
          ..._typesChapitre.map((t) => ListTile(
                leading: Text(t.emoji, style: const TextStyle(fontSize: 22)),
                title: Text(t.libelle,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(_aide(t),
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textMuted)),
                onTap: () => Navigator.pop(ctx, t),
              )),
          const SizedBox(height: 12),
        ]),
      ),
    );
    if (t == null || !mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditeurRessourcePage(
                user: widget.user,
                chapitre: widget.chapitre,
                matiere: widget.matiere,
                type: t,
                portee: _portee)));
  }

  static String _aide(TypeRessource t) {
    switch (t) {
      case TypeRessource.cours:
        return 'La lecon telle qu elle est enseignee en classe';
      case TypeRessource.renforcement:
        return 'La meme notion expliquee autrement, pas a pas';
      case TypeRessource.exercice:
        return 'Un enonce avec sa solution detaillee';
      case TypeRessource.corrige:
        return 'Une correction seule, a rattacher a un enonce';
      case TypeRessource.fiche:
        return 'Un resume court : definitions, formules, pieges';
      case TypeRessource.quiz:
        return 'Des questions auto-corrigees avec explications';
      case TypeRessource.video:
        return 'Une video YouTube (lien a coller)';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapitre.titre,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  '${widget.matiere.nom} — ${NiveauxCI.libelle(widget.chapitre.niveau)}',
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textMuted)),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _choisirType,
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: Column(children: [
        // ---- Portee du contenu ----
        if (_estSentinel)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: '',
                    label: Text('National'),
                    icon: Icon(Icons.public_rounded, size: 16)),
                ButtonSegment(
                    value: '_ecole',
                    label: Text('Mon ecole'),
                    icon: Icon(Icons.school_rounded, size: 16)),
              ],
              selected: {_portee.isEmpty ? '' : '_ecole'},
              onSelectionChanged: (s) => setState(() =>
                  _portee = s.first == '' ? '' : widget.user.school),
              style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12))),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.blueBg,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: const [
                Icon(Icons.school_rounded, size: 16, color: AppColors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Vous ajoutez ici le contenu de votre etablissement. '
                      'Il reste visible par vos seuls eleves.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.blue)),
                ),
              ]),
            ),
          ),
        const SizedBox(height: 6),

        // ---- Filtre par type ----
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              _puce('Tout', _filtre == null, () => setState(() => _filtre = null)),
              ..._typesChapitre.map((t) => _puce('${t.emoji} ${t.libelle}',
                  _filtre == t, () => setState(() => _filtre = t))),
            ],
          ),
        ),
        const SizedBox(height: 6),

        Expanded(
          child: StreamBuilder<List<Ressource>>(
            stream: ContenuService.streamRessourcesChapitre(widget.chapitre.id,
                type: _filtre, portee: _portee),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snap.data!;
              if (list.isEmpty) {
                return _ChapitreVide(
                    user: widget.user, chapitre: widget.chapitre);
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _carte(list[i]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _puce(String texte, bool actif, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              color: actif ? AppColors.green : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: actif ? AppColors.green : AppColors.border)),
          child: Text(texte,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: actif ? Colors.white : AppColors.textMuted)),
        ),
      );

  Widget _carte(Ressource r) {
    return SCCard(
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EditeurRessourcePage(
                    user: widget.user,
                    chapitre: widget.chapitre,
                    matiere: widget.matiere,
                    type: r.type,
                    portee: r.ecoleId,
                    ressource: r))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.type.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.titre,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Text(r.type.libelle,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textMuted)),
                    if (r.type == TypeRessource.exercice) ...[
                      const Text('  ·  ',
                          style: TextStyle(
                              fontSize: 11.5, color: AppColors.textMuted)),
                      Text(Difficulte.etoiles(r.difficulte),
                          style: const TextStyle(fontSize: 10)),
                    ],
                    if (r.type == TypeRessource.quiz) ...[
                      const Text('  ·  ',
                          style: TextStyle(
                              fontSize: 11.5, color: AppColors.textMuted)),
                      Text('${r.questions.length} question(s)',
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 4, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: r.actif ? AppColors.greenBg : AppColors.goldBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(r.actif ? 'Publie ✓' : 'Brouillon',
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color:
                                  r.actif ? AppColors.green : AppColors.gold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: r.estNational
                              ? AppColors.blueBg
                              : AppColors.purpleBg,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(r.estNational ? 'National' : 'Mon ecole',
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: r.estNational
                                  ? AppColors.blue
                                  : AppColors.purple)),
                    ),
                  ]),
                ]),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                size: 20, color: AppColors.textMuted),
            onSelected: (v) async {
              if (v == 'publier') {
                await ContenuService.basculerPublication(r.id, !r.actif);
                if (context.mounted) {
                  showSnack(
                      context,
                      r.actif
                          ? 'Remis en brouillon.'
                          : 'Publie — visible par les eleves.');
                }
              } else if (v == 'supprimer') {
                final ok = await confirmerDialog(context,
                    'Supprimer « ${r.titre} » ?', 'Action irreversible.');
                if (ok) {
                  await ContenuService.supprimerRessource(r.id);
                  if (context.mounted) showSnack(context, 'Ressource supprimee.');
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'publier',
                  child: Row(children: [
                    Icon(
                        r.actif
                            ? Icons.visibility_off_rounded
                            : Icons.publish_rounded,
                        size: 18,
                        color: AppColors.green),
                    const SizedBox(width: 8),
                    Text(r.actif ? 'Remettre en brouillon' : 'Publier'),
                  ])),
              const PopupMenuItem(
                  value: 'supprimer',
                  child: Row(children: [
                    Icon(Icons.delete_rounded, size: 18, color: AppColors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: AppColors.red)),
                  ])),
            ],
          ),
        ]),
      ),
    );
  }
}

// ============================================================================
//  ETAT VIDE — INSTALLATION DU CONTENU PRET A L'EMPLOI
//
//  Quand un chapitre n a encore aucune ressource et qu un contenu redige
//  existe pour lui, un bouton l installe en entier. Tout arrive en
//  BROUILLON : rien n est visible par les eleves avant relecture.
// ============================================================================

class _ChapitreVide extends StatefulWidget {
  final AppUser user;
  final Chapitre chapitre;
  const _ChapitreVide({required this.user, required this.chapitre});
  @override
  State<_ChapitreVide> createState() => _ChapitreVideState();
}

class _ChapitreVideState extends State<_ChapitreVide> {
  bool _envoi = false;

  Future<void> _installer() async {
    final n = ContenuOfficiel.ressources(widget.chapitre.id).length;
    final ok = await confirmerDialog(
        context,
        'Installer le contenu de ce chapitre ?',
        '$n ressources seront creees en BROUILLON : cours, renforcement, '
        'exercices corriges, fiche de revision et quiz. Vous les relirez '
        'avant de les publier.');
    if (!ok || !mounted) return;
    setState(() => _envoi = true);
    try {
      final crees =
          await ContenuOfficiel.installer(widget.chapitre, widget.user.uid);
      if (!mounted) return;
      setState(() => _envoi = false);
      showSnack(context,
          '$crees ressource(s) installee(s) en brouillon. Relisez puis publiez.');
    } catch (e) {
      if (mounted) {
        setState(() => _envoi = false);
        showSnack(context, 'Erreur : $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dispo = widget.user.role == UserRole.admin &&
        ContenuOfficiel.existe(widget.chapitre.id);
    final n = ContenuOfficiel.ressources(widget.chapitre.id).length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inbox_rounded, size: 44, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text('Ce chapitre est encore vide.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
          if (dispo) ...[
            const SizedBox(height: 6),
            Text(
                'Un contenu redige est disponible : $n ressources pretes a '
                'etre installees en brouillon.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textMuted)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _envoi ? null : _installer,
                icon: _envoi
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.download_rounded, size: 18),
                label: Text(_envoi
                    ? 'Installation en cours...'
                    : 'Installer le contenu du chapitre'),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            const Text(
                'Commencez par le cours, puis ajoutez des exercices et un quiz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          ],
        ]),
      ),
    );
  }
}

// ============================================================================
//  ECRAN — EDITEUR D'UNE RESSOURCE
// ============================================================================

class EditeurRessourcePage extends StatefulWidget {
  final AppUser user;
  final Chapitre chapitre;
  final Matiere matiere;
  final TypeRessource type;
  final String portee; // '' = national, sinon identifiant de l'ecole
  final Ressource? ressource;
  const EditeurRessourcePage(
      {super.key,
      required this.user,
      required this.chapitre,
      required this.matiere,
      required this.type,
      this.portee = '',
      this.ressource});

  @override
  State<EditeurRessourcePage> createState() => _EditeurRessourcePageState();
}

class _EditeurRessourcePageState extends State<EditeurRessourcePage> {
  final _titre = TextEditingController();
  final _contenu = TextEditingController();
  final _enonce = TextEditingController();
  final _solution = TextEditingController();
  final _video = TextEditingController();
  final _pdf = TextEditingController();
  final _duree = TextEditingController(text: '0');
  final _ordre = TextEditingController(text: '0');

  int _difficulte = Difficulte.moyen;
  List<String> _images = [];
  List<QuestionQuiz> _questions = [];
  bool _envoi = false;
  bool _upload = false;

  bool get _creation => widget.ressource == null;
  TypeRessource get _t => widget.type;

  // Quels champs afficher selon le type de ressource
  bool get _aTexte => const [
        TypeRessource.cours,
        TypeRessource.renforcement,
        TypeRessource.fiche,
        TypeRessource.corrige,
      ].contains(_t);
  bool get _aEnonce => _t == TypeRessource.exercice;
  bool get _aVideo => _t == TypeRessource.video;
  bool get _aQuiz => _t == TypeRessource.quiz;
  bool get _aImages => !_aVideo;

  @override
  void initState() {
    super.initState();
    final r = widget.ressource;
    if (r != null) {
      _titre.text = r.titre;
      _contenu.text = r.contenu;
      _enonce.text = r.enonce;
      _solution.text = r.solution;
      _video.text = r.videoYoutubeId;
      _pdf.text = r.pdfUrl;
      _duree.text = r.dureeMinutes.toString();
      _ordre.text = r.ordre.toString();
      _difficulte = r.difficulte;
      _images = List<String>.from(r.imagesUrls);
      _questions = List<QuestionQuiz>.from(r.questions);
    }
  }

  @override
  void dispose() {
    _titre.dispose();
    _contenu.dispose();
    _enonce.dispose();
    _solution.dispose();
    _video.dispose();
    _pdf.dispose();
    _duree.dispose();
    _ordre.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  //  IMAGES
  // --------------------------------------------------------------------------

  Future<void> _ajouterImages() async {
    try {
      final imgs =
          await ImagePicker().pickMultiImage(imageQuality: 80, maxWidth: 1400);
      if (imgs.isEmpty) return;
      setState(() => _upload = true);
      for (final x in imgs) {
        final bytes = await x.readAsBytes();
        final url = await ContenuService.uploadImage(
            widget.chapitre.id, bytes, x.name);
        _images.add(url);
      }
      if (mounted) setState(() => _upload = false);
    } catch (_) {
      if (mounted) {
        setState(() => _upload = false);
        showSnack(context, 'Envoi de l image impossible.', error: true);
      }
    }
  }

  // --------------------------------------------------------------------------
  //  ENREGISTREMENT
  // --------------------------------------------------------------------------

  Future<void> _enregistrer({required bool publier}) async {
    final titre = _titre.text.trim();
    if (titre.isEmpty) {
      showSnack(context, 'Le titre est obligatoire', error: true);
      return;
    }
    String idVideo = '';
    if (_aVideo) {
      idVideo = Ressource.extraireIdYoutube(_video.text);
      if (idVideo.isEmpty) {
        showSnack(context, 'Lien YouTube non reconnu. Collez l adresse complete.',
            error: true);
        return;
      }
    }
    if (_aQuiz && publier && _questions.isEmpty) {
      showSnack(context, 'Ajoutez au moins une question avant de publier',
          error: true);
      return;
    }

    setState(() => _envoi = true);
    final r = Ressource(
      id: widget.ressource?.id ?? '',
      type: _t,
      titre: titre,
      ordre: int.tryParse(_ordre.text.trim()) ?? 0,
      chapitreId: widget.chapitre.id,
      niveau: widget.chapitre.niveau,
      matiereId: widget.chapitre.matiereId,
      ecoleId: widget.portee,
      contenu: _contenu.text.trim(),
      imagesUrls: _images,
      pdfUrl: _pdf.text.trim(),
      videoYoutubeId: idVideo,
      enonce: _enonce.text.trim(),
      solution: _solution.text.trim(),
      difficulte: _difficulte,
      questions: _questions,
      dureeMinutes: int.tryParse(_duree.text.trim()) ?? 0,
      actif: publier,
      auteur: widget.user.uid,
    );

    try {
      if (_creation) {
        final res = await ContenuService.creerRessource(r);
        if (res.startsWith('!')) {
          if (mounted) {
            setState(() => _envoi = false);
            showSnack(context, res.substring(1), error: true);
          }
          return;
        }
      } else {
        await ContenuService.modifierRessource(r);
      }
      if (mounted) {
        Navigator.pop(context);
        showSnack(context,
            publier ? 'Publie — visible par les eleves.' : 'Brouillon enregistre.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _envoi = false);
        showSnack(context, 'Erreur : $e', error: true);
      }
    }
  }

  // --------------------------------------------------------------------------
  //  QUIZ
  // --------------------------------------------------------------------------

  Future<void> _dialogQuestion({QuestionQuiz? question, int? index}) async {
    final enonce = TextEditingController(text: question?.enonce ?? '');
    final expl = TextEditingController(text: question?.explication ?? '');
    final choix = <TextEditingController>[];
    TypeQuestion type = question?.type ?? TypeQuestion.qcm;
    final bonnes = <int>{...(question?.bonnesReponses ?? const <int>[])};
    final courte =
        TextEditingController(text: question?.reponseAttendue ?? '');

    if (question != null && question.choix.isNotEmpty) {
      for (final c in question.choix) {
        choix.add(TextEditingController(text: c));
      }
    } else {
      choix.addAll([TextEditingController(), TextEditingController()]);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(question == null ? 'Nouvelle question' : 'Modifier la question',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<TypeQuestion>(
                    value: type,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: 'Type de question'),
                    items: const [
                      DropdownMenuItem(
                          value: TypeQuestion.qcm,
                          child: Text('Choix multiple (QCM)')),
                      DropdownMenuItem(
                          value: TypeQuestion.vraiFaux, child: Text('Vrai / Faux')),
                      DropdownMenuItem(
                          value: TypeQuestion.reponseCourte,
                          child: Text('Reponse courte')),
                    ],
                    onChanged: (v) => setSt(() {
                      type = v ?? TypeQuestion.qcm;
                      bonnes.clear();
                      if (type == TypeQuestion.vraiFaux) {
                        choix
                          ..clear()
                          ..addAll([
                            TextEditingController(text: 'Vrai'),
                            TextEditingController(text: 'Faux'),
                          ]);
                      }
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: enonce,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Question', alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 12),

                  if (type == TypeQuestion.reponseCourte)
                    TextField(
                      controller: courte,
                      decoration: const InputDecoration(
                          labelText: 'Reponse attendue',
                          helperText:
                              'La comparaison ignore les majuscules et les espaces'),
                    )
                  else ...[
                    const Text('Reponses — cochez la ou les bonnes',
                        style: TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    ...List.generate(choix.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          Checkbox(
                            value: bonnes.contains(i),
                            activeColor: AppColors.green,
                            onChanged: (v) => setSt(() {
                              if (v == true) {
                                if (type == TypeQuestion.vraiFaux) bonnes.clear();
                                bonnes.add(i);
                              } else {
                                bonnes.remove(i);
                              }
                            }),
                          ),
                          Expanded(
                            child: TextField(
                              controller: choix[i],
                              enabled: type != TypeQuestion.vraiFaux,
                              decoration: InputDecoration(
                                  labelText: 'Reponse ${i + 1}',
                                  isDense: true),
                            ),
                          ),
                          if (type == TypeQuestion.qcm && choix.length > 2)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close,
                                  size: 18, color: AppColors.textMuted),
                              onPressed: () => setSt(() {
                                choix.removeAt(i);
                                bonnes.remove(i);
                              }),
                            ),
                        ]),
                      );
                    }),
                    if (type == TypeQuestion.qcm && choix.length < 5)
                      TextButton.icon(
                        onPressed: () =>
                            setSt(() => choix.add(TextEditingController())),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Ajouter une reponse',
                            style: TextStyle(fontSize: 12)),
                      ),
                  ],

                  const SizedBox(height: 10),
                  TextField(
                    controller: expl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Explication montree apres correction',
                        alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (enonce.text.trim().isEmpty) {
                          showSnack(ctx, 'La question est obligatoire',
                              error: true);
                          return;
                        }
                        if (type == TypeQuestion.reponseCourte) {
                          if (courte.text.trim().isEmpty) {
                            showSnack(ctx, 'Indiquez la reponse attendue',
                                error: true);
                            return;
                          }
                        } else if (bonnes.isEmpty) {
                          showSnack(ctx, 'Cochez au moins une bonne reponse',
                              error: true);
                          return;
                        }
                        final q = QuestionQuiz(
                          id: question?.id ??
                              DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                          type: type,
                          enonce: enonce.text.trim(),
                          choix: type == TypeQuestion.reponseCourte
                              ? const []
                              : choix.map((c) => c.text.trim()).toList(),
                          bonnesReponses: type == TypeQuestion.reponseCourte
                              ? const []
                              : bonnes.toList(),
                          reponseAttendue: courte.text.trim(),
                          explication: expl.text.trim(),
                        );
                        setState(() {
                          if (index == null) {
                            _questions.add(q);
                          } else {
                            _questions[index] = q;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(question == null ? 'Ajouter' : 'Enregistrer'),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  AFFICHAGE
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_t.emoji}  ${_t.libelle}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.chapitre.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textMuted)),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: widget.portee.isEmpty
                    ? AppColors.blueBg
                    : AppColors.purpleBg,
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(
                  widget.portee.isEmpty
                      ? Icons.public_rounded
                      : Icons.school_rounded,
                  size: 16,
                  color: widget.portee.isEmpty
                      ? AppColors.blue
                      : AppColors.purple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    widget.portee.isEmpty
                        ? 'Contenu national — visible par toutes les ecoles'
                        : 'Contenu de votre etablissement — visible par vos eleves uniquement',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: widget.portee.isEmpty
                            ? AppColors.blue
                            : AppColors.purple)),
              ),
            ]),
          ),
          SCCard(
              child: Column(children: [
            TextField(
              controller: _titre,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            const SizedBox(height: 10),
            Row(children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _ordre,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Ordre'),
                ),
              ),
              if (_aQuiz) ...[
                const SizedBox(width: 10),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _duree,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Duree (min)'),
                  ),
                ),
              ],
            ]),
          ])),
          const SizedBox(height: 14),

          // ---- Texte principal ----
          if (_aTexte) ...[
            SectionTitle(_t == TypeRessource.fiche
                ? 'Contenu de la fiche'
                : 'Contenu de la lecon'),
            SCCard(
                child: TextField(
              controller: _contenu,
              maxLines: 14,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  labelText: 'Texte',
                  alignLabelWithHint: true,
                  helperText: _t == TypeRessource.renforcement
                      ? 'Expliquez autrement : methode pas a pas, erreurs frequentes, conseils'
                      : 'Pour les formules et les figures, ajoutez des images ci-dessous'),
            )),
            const SizedBox(height: 14),
          ],

          // ---- Exercice ----
          if (_aEnonce) ...[
            SectionTitle('Enonce'),
            SCCard(
                child: TextField(
              controller: _enonce,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Enonce de l exercice', alignLabelWithHint: true),
            )),
            const SizedBox(height: 14),
            SectionTitle('Solution detaillee'),
            SCCard(
                child: TextField(
              controller: _solution,
              maxLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Correction etape par etape',
                  alignLabelWithHint: true),
            )),
            const SizedBox(height: 14),
            SectionTitle('Difficulte'),
            SCCard(
                child: Column(children: [
              for (final d in [
                Difficulte.facile,
                Difficulte.moyen,
                Difficulte.difficile,
                Difficulte.examen
              ])
                RadioListTile<int>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: d,
                  groupValue: _difficulte,
                  activeColor: AppColors.green,
                  title: Text(
                      '${Difficulte.etoiles(d)}  ${Difficulte.libelle(d)}',
                      style: const TextStyle(fontSize: 13)),
                  onChanged: (v) => setState(() => _difficulte = v ?? _difficulte),
                ),
            ])),
            const SizedBox(height: 14),
          ],

          // ---- Video ----
          if (_aVideo) ...[
            SectionTitle('Video YouTube'),
            SCCard(
                child: Column(children: [
              TextField(
                controller: _video,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                    labelText: 'Lien de la video',
                    helperText:
                        'Collez l adresse YouTube. Mettez la video en « non repertoriee ».'),
              ),
              Builder(builder: (_) {
                final id = Ressource.extraireIdYoutube(_video.text);
                if (id.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                          'https://img.youtube.com/vi/$id/hqdefault.jpg',
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const SizedBox.shrink()),
                    ),
                    const SizedBox(height: 6),
                    Text('Identifiant reconnu : $id',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.green)),
                  ]),
                );
              }),
            ])),
            const SizedBox(height: 14),
          ],

          // ---- Quiz ----
          if (_aQuiz) ...[
            SectionTitle('Questions (${_questions.length})'),
            if (_questions.isEmpty)
              SCCard(
                  child: const Text('Aucune question pour le moment.',
                      style: TextStyle(color: AppColors.textMuted)))
            else
              ...List.generate(_questions.length, (i) {
                final q = _questions[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SCCard(
                    child: Row(children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.greenBg,
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.enonce,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  q.type == TypeQuestion.qcm
                                      ? 'QCM'
                                      : q.type == TypeQuestion.vraiFaux
                                          ? 'Vrai / Faux'
                                          : 'Reponse courte',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.textMuted)),
                            ]),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.textMuted),
                        onPressed: () =>
                            _dialogQuestion(question: q, index: i),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.red),
                        onPressed: () =>
                            setState(() => _questions.removeAt(i)),
                      ),
                    ]),
                  ),
                );
              }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _dialogQuestion(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter une question'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    side: const BorderSide(color: AppColors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ---- Images ----
          if (_aImages) ...[
            SectionTitle('Images — formules, schemas, figures'),
            SCCard(
                child: Column(children: [
              if (_images.isNotEmpty)
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(_images[i],
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                                width: 90,
                                height: 90,
                                color: AppColors.bg,
                                child: const Icon(Icons.broken_image_rounded,
                                    color: AppColors.textMuted))),
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(i)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              if (_images.isNotEmpty) const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _upload ? null : _ajouterImages,
                  icon: _upload
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.green))
                      : const Icon(Icons.add_photo_alternate_rounded, size: 18),
                  label: Text(_upload
                      ? 'Envoi en cours...'
                      : (_images.isEmpty
                          ? 'Ajouter des images'
                          : 'Ajouter d autres images')),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green,
                      side: const BorderSide(color: AppColors.green),
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                  'Photographiez la lecon manuscrite ou exportez vos formules en image.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ])),
            const SizedBox(height: 14),
            SCCard(
                child: TextField(
              controller: _pdf,
              decoration: const InputDecoration(
                  labelText: 'Lien PDF a telecharger (facultatif)',
                  helperText: 'Adresse d un PDF deja en ligne'),
            )),
            const SizedBox(height: 20),
          ],

          // ---- Boutons ----
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _envoi ? null : () => _enregistrer(publier: false),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Brouillon'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _envoi ? null : () => _enregistrer(publier: true),
                child: _envoi
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Publier'),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          const Text(
              'Un brouillon reste invisible pour les eleves. Vous pourrez le publier plus tard.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

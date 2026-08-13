// ============================================================================
//  SENTINEL CI — CENTRE D'APPRENTISSAGE
//  Espace eleve : lecture d'une ressource et quiz interactif
//  Fichier : lib/centre_apprentissage/ecrans/eleve_lecture.dart
//
//  Deux ecrans :
//   - LecteurRessourcePage : cours, renforcement, fiche, exercice, corrige,
//     video. La solution d'un exercice reste masquee tant que l'eleve ne
//     demande pas a la voir : il doit chercher d'abord.
//   - QuizPage : questions une par une, correction immediate, score final.
// ============================================================================

import 'package:flutter/material.dart';

import '../../main.dart';
// Ouverture d'URL : implementation conditionnelle web/mobile,
// exactement comme dans main.dart (dart:html interdit sur Android).
import '../../url_launcher_stub.dart'
    if (dart.library.html) '../../url_launcher_web.dart';
import '../modeles/contenu.dart';

// ============================================================================
//  ECRAN — LECTURE D'UNE RESSOURCE
// ============================================================================

class LecteurRessourcePage extends StatefulWidget {
  final Ressource ressource;
  const LecteurRessourcePage({super.key, required this.ressource});
  @override
  State<LecteurRessourcePage> createState() => _LecteurRessourcePageState();
}

class _LecteurRessourcePageState extends State<LecteurRessourcePage> {
  bool _solutionVisible = false;

  Ressource get r => widget.ressource;

  Future<void> _ouvrir(String url, String secours) async {
    try {
      await ouvrirUrlPlateforme(url);
    } catch (_) {
      if (mounted) showSnack(context, secours, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estExercice = r.type == TypeRessource.exercice;
    final estVideo = r.type == TypeRessource.video;

    return Scaffold(
      appBar: AppBar(
        title: Text(r.titre, maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${r.type.emoji}  ${r.type.libelle}',
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textMuted)),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ---- Difficulte (exercices) ----
          if (estExercice)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColors.goldBg,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                    '${Difficulte.etoiles(r.difficulte)}  ${Difficulte.libelle(r.difficulte)}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold)),
              ),
            ),

          // ---- Video ----
          if (estVideo && r.videoYoutubeId.isNotEmpty) ...[
            InkWell(
              onTap: () => _ouvrir(
                  'https://www.youtube.com/watch?v=${r.videoYoutubeId}',
                  'Impossible d ouvrir la video.'),
              borderRadius: BorderRadius.circular(14),
              child: Stack(alignment: Alignment.center, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(r.miniatureVideo,
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          height: 190,
                          color: AppColors.bg,
                          child: const Icon(Icons.videocam_off_rounded,
                              color: AppColors.textMuted))),
                ),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.55),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 34),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            const Text('Touche l image pour lancer la video',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            const SizedBox(height: 16),
          ],

          // ---- Enonce (exercice) ----
          if (estExercice && r.enonce.isNotEmpty) ...[
            SectionTitle('Enonce'),
            SCCard(
                child: SelectableText(r.enonce,
                    style: const TextStyle(
                        fontSize: 14, height: 1.6, color: AppColors.textMain))),
            const SizedBox(height: 16),
          ],

          // ---- Texte principal ----
          if (r.contenu.isNotEmpty) ...[
            SCCard(
                child: SelectableText(r.contenu,
                    style: const TextStyle(
                        fontSize: 14, height: 1.65, color: AppColors.textMain))),
            const SizedBox(height: 16),
          ],

          // ---- Images ----
          if (r.imagesUrls.isNotEmpty) ...[
            ...r.imagesUrls.map((url) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PhotoViewer(url: url))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(url,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (c, w, p) => p == null
                              ? w
                              : const SizedBox(
                                  height: 140,
                                  child: Center(
                                      child: CircularProgressIndicator())),
                          errorBuilder: (c, e, s) => Container(
                              height: 120,
                              color: AppColors.bg,
                              child: const Icon(Icons.broken_image_rounded,
                                  color: AppColors.textMuted))),
                    ),
                  ),
                )),
            const Text('Touche une image pour l agrandir',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            const SizedBox(height: 16),
          ],

          // ---- Solution (exercice) : masquee au depart ----
          if (estExercice && r.solution.isNotEmpty) ...[
            if (!_solutionVisible)
              Column(children: [
                const Text(
                    'Cherche d abord par toi-meme.\n'
                    'Tu apprendras beaucoup plus qu en lisant la correction tout de suite.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _solutionVisible = true),
                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                    label: const Text('Voir la correction'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        side: const BorderSide(color: AppColors.green),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ])
            else ...[
              SectionTitle('Correction detaillee'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.greenBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.green)),
                child: SelectableText(r.solution,
                    style: const TextStyle(
                        fontSize: 14, height: 1.65, color: AppColors.textMain)),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // ---- PDF ----
          if (r.pdfUrl.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _ouvrir(r.pdfUrl, 'Impossible d ouvrir le document.'),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: const Text('Telecharger le document PDF'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    side: const BorderSide(color: AppColors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 13)),
              ),
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 12),
          const Center(
            child: Text('Sentinel CI — Veiller, pas surveiller',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  ECRAN — QUIZ INTERACTIF
// ============================================================================

class QuizPage extends StatefulWidget {
  final Ressource ressource;
  const QuizPage({super.key, required this.ressource});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _index = 0;
  bool _corrige = false;
  bool _termine = false;
  int _points = 0;

  final Set<int> _choisis = {};
  final _reponseCourte = TextEditingController();
  final List<bool> _resultats = [];

  DateTime? _debut;

  List<QuestionQuiz> get _questions => widget.ressource.questions;
  QuestionQuiz get _q => _questions[_index];

  @override
  void initState() {
    super.initState();
    _debut = DateTime.now();
  }

  @override
  void dispose() {
    _reponseCourte.dispose();
    super.dispose();
  }

  void _valider() {
    final juste = _q.type == TypeQuestion.reponseCourte
        ? _q.estCorrecte(texte: _reponseCourte.text)
        : _q.estCorrecte(indexChoisis: _choisis.toList());
    setState(() {
      _corrige = true;
      _resultats.add(juste);
      if (juste) _points += _q.points;
    });
  }

  void _suivant() {
    if (_index + 1 >= _questions.length) {
      setState(() => _termine = true);
      return;
    }
    setState(() {
      _index++;
      _corrige = false;
      _choisis.clear();
      _reponseCourte.clear();
    });
  }

  void _recommencer() {
    setState(() {
      _index = 0;
      _corrige = false;
      _termine = false;
      _points = 0;
      _choisis.clear();
      _reponseCourte.clear();
      _resultats.clear();
      _debut = DateTime.now();
    });
  }

  bool get _peutValider => _q.type == TypeQuestion.reponseCourte
      ? _reponseCourte.text.trim().isNotEmpty
      : _choisis.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.ressource.titre)),
        body: const Center(
            child: Text('Ce quiz ne contient pas encore de question.',
                style: TextStyle(color: AppColors.textMuted))),
      );
    }

    if (_termine) return _ecranResultat();

    final total = widget.ressource.totalPoints;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ressource.titre,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(children: [
              ProgressBar(
                  value: (_index + (_corrige ? 1 : 0)) / _questions.length,
                  color: AppColors.green),
              const SizedBox(height: 6),
              Row(children: [
                Text('Question ${_index + 1} sur ${_questions.length}',
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textMuted)),
                const Spacer(),
                Text('$_points / $total pts',
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green)),
              ]),
            ]),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SCCard(
              child: Text(_q.enonce,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5, fontWeight: FontWeight.w600))),
          const SizedBox(height: 16),

          if (_q.imageUrl != null && _q.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(_q.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const SizedBox.shrink()),
            ),
            const SizedBox(height: 16),
          ],

          // ---- Reponse courte ----
          if (_q.type == TypeQuestion.reponseCourte)
            SCCard(
                child: TextField(
              controller: _reponseCourte,
              enabled: !_corrige,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Ta reponse'),
            ))
          else
            // ---- QCM et Vrai/Faux ----
            ...List.generate(_q.choix.length, (i) {
              final choisi = _choisis.contains(i);
              final bonne = _q.bonnesReponses.contains(i);
              Color bord = AppColors.border;
              Color fond = Colors.white;
              IconData? icone;
              Color? couleurIcone;

              if (_corrige) {
                if (bonne) {
                  bord = AppColors.green;
                  fond = AppColors.greenBg;
                  icone = Icons.check_circle_rounded;
                  couleurIcone = AppColors.green;
                } else if (choisi) {
                  bord = AppColors.red;
                  fond = AppColors.redBg;
                  icone = Icons.cancel_rounded;
                  couleurIcone = AppColors.red;
                }
              } else if (choisi) {
                bord = AppColors.green;
                fond = AppColors.greenBg;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: _corrige
                      ? null
                      : () => setState(() {
                            // Une seule reponse pour Vrai/Faux et pour un QCM
                            // a bonne reponse unique.
                            if (_q.type == TypeQuestion.vraiFaux ||
                                _q.bonnesReponses.length <= 1) {
                              _choisis
                                ..clear()
                                ..add(i);
                            } else if (choisi) {
                              _choisis.remove(i);
                            } else {
                              _choisis.add(i);
                            }
                          }),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: fond,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: bord,
                            width: (choisi || (_corrige && bonne)) ? 1.8 : 1)),
                    child: Row(children: [
                      Expanded(
                        child: Text(_q.choix[i],
                            style: const TextStyle(
                                fontSize: 14, height: 1.35)),
                      ),
                      if (icone != null)
                        Icon(icone, color: couleurIcone, size: 20)
                      else if (choisi)
                        const Icon(Icons.radio_button_checked_rounded,
                            color: AppColors.green, size: 20),
                    ]),
                  ),
                ),
              );
            }),

          const SizedBox(height: 8),

          // ---- Correction ----
          if (_corrige) ...[
            Builder(builder: (_) {
              final juste = _resultats.isNotEmpty && _resultats.last;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: juste ? AppColors.greenBg : AppColors.orangeBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: juste ? AppColors.green : AppColors.orange)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(
                            juste
                                ? Icons.check_circle_rounded
                                : Icons.info_rounded,
                            color: juste ? AppColors.green : AppColors.orange,
                            size: 20),
                        const SizedBox(width: 8),
                        Text(juste ? 'Bonne reponse !' : 'Pas tout a fait',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color:
                                    juste ? AppColors.green : AppColors.orange)),
                      ]),
                      if (_q.type == TypeQuestion.reponseCourte && !juste) ...[
                        const SizedBox(height: 6),
                        Text('Reponse attendue : ${_q.reponseAttendue}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                      if (_q.explication.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(_q.explication,
                            style: const TextStyle(fontSize: 13, height: 1.5)),
                      ],
                    ]),
              );
            }),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _corrige
                  ? _suivant
                  : (_peutValider ? _valider : null),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15)),
              child: Text(_corrige
                  ? (_index + 1 >= _questions.length
                      ? 'Voir mon resultat'
                      : 'Question suivante')
                  : 'Valider'),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  //  ECRAN DE RESULTAT
  // --------------------------------------------------------------------------

  Widget _ecranResultat() {
    final total = widget.ressource.totalPoints;
    final pourcent = total > 0 ? (_points * 100 / total).round() : 0;
    final duree = _debut == null
        ? Duration.zero
        : DateTime.now().difference(_debut!);
    final minutes = duree.inMinutes;
    final secondes = duree.inSeconds % 60;

    String message;
    Color couleur;
    String emoji;
    if (pourcent >= 80) {
      message = 'Excellent ! Tu maitrises ce chapitre.';
      couleur = AppColors.green;
      emoji = '🎉';
    } else if (pourcent >= 50) {
      message = 'Bien joue. Revois les questions manquees et recommence.';
      couleur = AppColors.gold;
      emoji = '👍';
    } else {
      message =
          'Ce n est pas encore acquis, et c est normal. Relis le cours de '
          'renforcement, puis retente ce quiz.';
      couleur = AppColors.orange;
      emoji = '💪';
    }

    final justes = _resultats.where((e) => e).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Ton resultat')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          Center(child: Text(emoji, style: const TextStyle(fontSize: 54))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: couleur.withOpacity(.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: couleur.withOpacity(.5))),
            child: Column(children: [
              Text('$_points / $total',
                  style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: couleur)),
              const SizedBox(height: 2),
              Text('$pourcent %',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: couleur)),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 16),
          SCCard(
              child: Column(children: [
            _ligne('Bonnes reponses', '$justes / ${_questions.length}'),
            const Divider(height: 18),
            _ligne('Temps passe',
                minutes > 0 ? '$minutes min $secondes s' : '$secondes s'),
          ])),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _recommencer,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Recommencer le quiz'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Retour au chapitre'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ligne(String label, String valeur) => Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600))),
        Text(valeur,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.green)),
      ]);
}

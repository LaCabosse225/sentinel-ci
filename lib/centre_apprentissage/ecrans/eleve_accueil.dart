// ============================================================================
//  SENTINEL CI — CENTRE D'APPRENTISSAGE
//  Espace eleve : accueil, matieres, chapitres, contenu d'un chapitre
//  Fichier : lib/centre_apprentissage/ecrans/eleve_accueil.dart
//
//  Visible par les eleves et par les parents (pour leur enfant).
//  Lecture seule : aucune ecriture dans Firestore depuis cet ecran.
//  Les lectures passent par le cache de ContenuService : un eleve qui
//  navigue longtemps ne consomme que quelques lectures Firestore.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../modeles/contenu.dart';
import '../services/contenu_service.dart';
import 'eleve_lecture.dart';

// ============================================================================
//  OUTIL — DEDUIRE LE NIVEAU SCOLAIRE
//
//  La classe de l'eleve porte un champ 'niveau' saisi librement par l'ecole
//  ("3eme", "Troisieme", "3e A"...). On le ramene aux codes du Centre
//  d'Apprentissage. Si la deduction echoue, l'eleve choisit son niveau
//  lui-meme et le choix est conserve sur l'appareil.
// ============================================================================

String? niveauDepuisTexte(String? texte) {
  if (texte == null) return null;
  var t = texte.toLowerCase().trim();
  const accents = {'e': 'éèêë', 'a': 'àâä', 'i': 'îï', 'o': 'ôö', 'u': 'ùûü'};
  accents.forEach((simple, groupe) {
    for (final ch in groupe.split('')) {
      t = t.replaceAll(ch, simple);
    }
  });
  if (t.contains('terminale') || t.contains('tle') || t.startsWith('t')) {
    return 'Tle';
  }
  if (t.contains('premiere') || t.contains('1ere') || t.startsWith('1')) {
    return '1ere';
  }
  if (t.contains('seconde') || t.contains('2nde') || t.startsWith('2')) {
    return '2nde';
  }
  if (t.contains('sixieme') || t.startsWith('6')) return '6e';
  if (t.contains('cinquieme') || t.startsWith('5')) return '5e';
  if (t.contains('quatrieme') || t.startsWith('4')) return '4e';
  if (t.contains('troisieme') || t.startsWith('3')) return '3e';
  return null;
}

// ============================================================================
//  ECRAN — ACCUEIL DU CENTRE D'APPRENTISSAGE
// ============================================================================

class CentreApprentissagePage extends StatefulWidget {
  final AppUser user;
  const CentreApprentissagePage({super.key, required this.user});
  @override
  State<CentreApprentissagePage> createState() =>
      _CentreApprentissagePageState();
}

class _CentreApprentissagePageState extends State<CentreApprentissagePage> {
  String? _niveau;
  bool _chargement = true;

  static const String _cleNiveau = 'ca_niveau_choisi';

  @override
  void initState() {
    super.initState();
    _determinerNiveau();
  }

  Future<void> _determinerNiveau() async {
    String? n;
    // 1. Choix deja fait sur cet appareil
    try {
      final p = await SharedPreferences.getInstance();
      n = p.getString('${_cleNiveau}_${widget.user.uid}');
    } catch (_) {}

    // 2. Sinon, deduction depuis la classe de l'eleve
    if (n == null && (widget.user.classeId ?? '').isNotEmpty) {
      try {
        final d = await FirebaseFirestore.instance
            .collection('classes')
            .doc(widget.user.classeId!)
            .get();
        final data = d.data();
        n = niveauDepuisTexte((data?['niveau'] ?? '').toString());
        n ??= niveauDepuisTexte((data?['nom'] ?? '').toString());
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _niveau = n;
        _chargement = false;
      });
    }
  }

  Future<void> _enregistrerNiveau(String n) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('${_cleNiveau}_${widget.user.uid}', n);
    } catch (_) {}
    if (mounted) setState(() => _niveau = n);
  }

  Future<void> _changerNiveau() async {
    final n = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Choisis ta classe',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ),
          ),
          ...NiveauxCI.tous.map((n) => ListTile(
                leading: Icon(
                    n == _niveau
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: n == _niveau ? AppColors.green : AppColors.textMuted),
                title: Text(NiveauxCI.libelle(n),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(ctx, n),
              )),
          const SizedBox(height: 12),
        ]),
      ),
    );
    if (n != null) _enregistrerNiveau(n);
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) {
      return const Center(child: CircularProgressIndicator());
    }

    // Aucun niveau connu : on demande a l'eleve de choisir sa classe.
    if (_niveau == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.school_rounded, size: 48, color: AppColors.green),
            const SizedBox(height: 14),
            const Text('Bienvenue au Centre d Apprentissage',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
                'Indique ta classe pour acceder aux cours, exercices et quiz '
                'de ton programme.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _changerNiveau, child: const Text('Choisir ma classe')),
            ),
          ]),
        ),
      );
    }

    final prenom = widget.user.role == UserRole.parent
        ? (widget.user.childName ?? '').split(' ').first
        : widget.user.name.split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ---- Bandeau d'accueil ----
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                widget.user.role == UserRole.parent
                    ? 'Le programme de ${prenom.isEmpty ? "votre enfant" : prenom}'
                    : 'Bonjour $prenom 👋',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Centre d Apprentissage',
                style: TextStyle(color: Colors.white70, fontSize: 12.5)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _changerNiveau,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.18),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Classe de ${NiveauxCI.libelle(_niveau!)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit_outlined,
                      color: Colors.white70, size: 14),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        SectionTitle('Mes matieres'),
        FutureBuilder<List<Matiere>>(
          future: ContenuService.matieres(niveau: _niveau),
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final mats = snap.data!;
            if (mats.isEmpty) {
              return SCCard(
                  child: const Text(
                      'Aucune matiere disponible pour ta classe pour le moment.',
                      style: TextStyle(color: AppColors.textMuted)));
            }
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: mats.map((m) {
                final couleur = _couleur(m.couleurHex);
                return InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChapitresElevePage(
                              user: widget.user,
                              niveau: _niveau!,
                              matiere: m))),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                color: couleur.withOpacity(.14),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.menu_book_rounded,
                                color: couleur, size: 20),
                          ),
                          const Spacer(),
                          Text(m.nom,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          _NbChapitresEleve(
                              niveau: _niveau!, matiereId: m.id),
                        ]),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _NbChapitresEleve extends StatelessWidget {
  final String niveau, matiereId;
  const _NbChapitresEleve({required this.niveau, required this.matiereId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Chapitre>>(
      future: ContenuService.chapitres(niveau, matiereId),
      builder: (ctx, s) {
        final n = s.hasData ? s.data!.length : null;
        return Text(
            n == null
                ? '...'
                : (n == 0 ? 'Bientot disponible' : '$n chapitre${n > 1 ? 's' : ''}'),
            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted));
      },
    );
  }
}

// ============================================================================
//  ECRAN — CHAPITRES D'UNE MATIERE (cote eleve)
// ============================================================================

class ChapitresElevePage extends StatelessWidget {
  final AppUser user;
  final String niveau;
  final Matiere matiere;
  const ChapitresElevePage(
      {super.key,
      required this.user,
      required this.niveau,
      required this.matiere});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(matiere.nom),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Classe de ${NiveauxCI.libelle(niveau)}',
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textMuted)),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Chapitre>>(
        future: ContenuService.chapitres(niveau, matiere.id),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chaps = snap.data!;
          if (chaps.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(28),
              child: Text('Les cours de cette matiere arrivent bientot.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted)),
            ));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chaps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = chaps[i];
              return SCCard(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ContenuChapitrePage(
                              user: user, chapitre: c, matiere: matiere))),
                  child: Row(children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('${c.ordre}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.green)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.titre,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            if (c.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(c.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ]),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================================
//  ECRAN — CONTENU D'UN CHAPITRE (cote eleve)
//
//  Le contenu est regroupe par type, dans l'ordre pedagogique :
//  d'abord comprendre, puis s'entrainer, puis se tester.
// ============================================================================

class ContenuChapitrePage extends StatelessWidget {
  final AppUser user;
  final Chapitre chapitre;
  final Matiere matiere;
  const ContenuChapitrePage(
      {super.key,
      required this.user,
      required this.chapitre,
      required this.matiere});

  /// Ordre d'affichage des sections pour l'eleve.
  static const List<TypeRessource> _ordre = [
    TypeRessource.cours,
    TypeRessource.renforcement,
    TypeRessource.fiche,
    TypeRessource.video,
    TypeRessource.exercice,
    TypeRessource.corrige,
    TypeRessource.quiz,
  ];

  static String _titreSection(TypeRessource t) {
    switch (t) {
      case TypeRessource.cours:
        return 'Le cours';
      case TypeRessource.renforcement:
        return 'Je ne comprends pas — explique-moi autrement';
      case TypeRessource.fiche:
        return 'Fiches de revision';
      case TypeRessource.video:
        return 'Videos';
      case TypeRessource.exercice:
        return 'Exercices';
      case TypeRessource.corrige:
        return 'Corriges';
      case TypeRessource.quiz:
        return 'Teste-toi';
      default:
        return t.libelle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chapitre.titre, maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(matiere.nom,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textMuted)),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Ressource>>(
        future: ContenuService.ressourcesChapitre(chapitre.id),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final toutes = snap.data!;
          if (toutes.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(28),
              child: Text('Le contenu de ce chapitre arrive bientot.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted)),
            ));
          }

          final sections = <Widget>[];
          for (final t in _ordre) {
            final list = toutes.where((r) => r.type == t).toList();
            if (list.isEmpty) continue;
            sections.add(Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: Row(children: [
                Text(t.emoji, style: const TextStyle(fontSize: 17)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_titreSection(t),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ]),
            ));
            for (final r in list) {
              sections.add(Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _carte(context, r),
              ));
            }
            sections.add(const SizedBox(height: 8));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              if (chapitre.description.isNotEmpty) ...[
                SCCard(
                    child: Text(chapitre.description,
                        style: const TextStyle(
                            fontSize: 13, height: 1.5, color: AppColors.textMain))),
                const SizedBox(height: 16),
              ],
              ...sections,
            ],
          );
        },
      ),
    );
  }

  Widget _carte(BuildContext context, Ressource r) {
    final estQuiz = r.type == TypeRessource.quiz;
    return SCCard(
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => estQuiz
                    ? QuizPage(ressource: r)
                    : LecteurRessourcePage(ressource: r))),
        child: Row(children: [
          if (r.type == TypeRessource.video && r.miniatureVideo.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(r.miniatureVideo,
                  width: 74,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox.shrink()),
            )
          else
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
              child: Text(r.type.emoji, style: const TextStyle(fontSize: 18)),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.titre,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  if (r.type == TypeRessource.exercice)
                    Text(
                        '${Difficulte.etoiles(r.difficulte)}  ${Difficulte.libelle(r.difficulte)}',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textMuted))
                  else if (estQuiz)
                    Text(
                        '${r.questions.length} question(s)'
                        '${r.dureeMinutes > 0 ? '  ·  ${r.dureeMinutes} min' : ''}',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textMuted)),
                ]),
          ),
          Icon(estQuiz ? Icons.play_circle_fill_rounded : Icons.chevron_right_rounded,
              color: estQuiz ? AppColors.green : AppColors.textMuted),
        ]),
      ),
    );
  }
}

// ============================================================================
//  OUTIL
// ============================================================================

Color _couleur(String hex) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return AppColors.green;
  }
}

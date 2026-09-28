import 'package:flutter/material.dart';

import '../../main.dart';
import '../modeles/contenu.dart';
import '../services/contenu_service.dart';
import 'eleve_lecture.dart';

/// Espace d'apprentissage PUBLIC.
/// Aucun compte Sentinel n'est nécessaire.
/// Les ressources affichées passent par ecoleId == '' : elles sont nationales.
class ApprentissagePublicPage extends StatefulWidget {
  const ApprentissagePublicPage({super.key});

  @override
  State<ApprentissagePublicPage> createState() => _ApprentissagePublicPageState();
}

class _ApprentissagePublicPageState extends State<ApprentissagePublicPage> {
  String? _niveau;
  Matiere? _matiere;
  Chapitre? _chapitre;

  Future<List<Matiere>> _matieres() =>
      ContenuService.matieres(niveau: _niveau);

  Future<List<Chapitre>> _chapitres() =>
      ContenuService.chapitres(_niveau!, _matiere!.id);

  Future<List<Ressource>> _ressources() =>
      ContenuService.ressourcesChapitre(_chapitre!.id, ecoleId: '');

  void _niveauChoisi(String value) {
    setState(() {
      _niveau = value;
      _matiere = null;
      _chapitre = null;
    });
  }

  void _matiereChoisie(Matiere value) {
    setState(() {
      _matiere = value;
      _chapitre = null;
    });
  }

  void _chapitreChoisi(Chapitre value) {
    setState(() => _chapitre = value);
  }

  void _retourNiveaux() {
    setState(() {
      _niveau = null;
      _matiere = null;
      _chapitre = null;
    });
  }

  void _retourMatieres() {
    setState(() {
      _matiere = null;
      _chapitre = null;
    });
  }

  void _retourChapitres() {
    setState(() => _chapitre = null);
  }

  Widget _bandeau() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.green, Color(0xFF0E6D14)],
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/motif.png'),
          repeat: ImageRepeat.repeat,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: Colors.white, size: 26),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Apprentissage libre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Apprends, révise et entraîne-toi gratuitement, sans compte.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (_niveau != null)
                _Filtre(
                  label: NiveauxCI.libelle(_niveau!),
                  onTap: _retourNiveaux,
                ),
              if (_matiere != null)
                _Filtre(
                  label: _matiere!.nom,
                  onTap: _retourMatieres,
                ),
              if (_chapitre != null)
                _Filtre(
                  label: _chapitre!.titre,
                  onTap: _retourChapitres,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(String titre, String sousTitre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sousTitre,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carte(String titre, String? sousTitre, IconData icon,
      Color couleur, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SCCard(
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: couleur.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: couleur),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (sousTitre != null && sousTitre.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      sousTitre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.8,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(String message) {
    return SCCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenu() {
    if (_niveau == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section(
            'Choisis ta classe',
            'Du collège au lycée : sélectionne ton niveau pour commencer.',
          ),
          ...NiveauxCI.tous.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _carte(
                NiveauxCI.libelle(n),
                null,
                Icons.school_rounded,
                AppColors.green,
                () => _niveauChoisi(n),
              ),
            ),
          ),
        ],
      );
    }

    if (_matiere == null) {
      return FutureBuilder<List<Matiere>>(
        future: _matieres(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError) {
            return _message('Impossible de charger les matières pour le moment.');
          }
          final mats = snap.data ?? const <Matiere>[];
          if (mats.isEmpty) {
            return _message('Aucune matière n’est encore disponible pour ce niveau.');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section(
                'Choisis une matière',
                NiveauxCI.libelle(_niveau!),
              ),
              ...mats.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _carte(
                    m.nom,
                    null,
                    Icons.menu_book_rounded,
                    AppColors.green,
                    () => _matiereChoisie(m),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    if (_chapitre == null) {
      return FutureBuilder<List<Chapitre>>(
        future: _chapitres(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError) {
            return _message('Impossible de charger les chapitres pour le moment.');
          }
          final chaps = snap.data ?? const <Chapitre>[];
          if (chaps.isEmpty) {
            return _message('Les chapitres de cette matière seront bientôt disponibles.');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section(
                'Choisis un chapitre',
                _matiere!.nom + ' · ' + NiveauxCI.libelle(_niveau!),
              ),
              ...chaps.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _carte(
                    c.titre,
                    c.description,
                    Icons.bookmark_border_rounded,
                    AppColors.blue,
                    () => _chapitreChoisi(c),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return FutureBuilder<List<Ressource>>(
      future: _ressources(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return _message('Impossible de charger les contenus de ce chapitre.');
        }
        final ressources = snap.data ?? const <Ressource>[];
        if (ressources.isEmpty) {
          return _message(
            'Aucun contenu national n’est encore publié pour ce chapitre.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              _chapitre!.titre,
              _matiere!.nom + ' · ' + NiveauxCI.libelle(_niveau!),
            ),
            ...ressources.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _carte(
                  r.titre,
                  r.type.libelle,
                  _icone(r.type),
                  _couleur(r.type),
                  () => _ouvrirRessource(r),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _icone(TypeRessource type) {
    switch (type) {
      case TypeRessource.cours:
        return Icons.menu_book_rounded;
      case TypeRessource.exercice:
        return Icons.edit_note_rounded;
      case TypeRessource.renforcement:
        return Icons.fitness_center_rounded;
      case TypeRessource.quiz:
        return Icons.quiz_rounded;
      case TypeRessource.fiche:
        return Icons.fact_check_rounded;
      case TypeRessource.video:
        return Icons.play_circle_outline_rounded;
    }
  }

  Color _couleur(TypeRessource type) {
    switch (type) {
      case TypeRessource.cours:
        return AppColors.green;
      case TypeRessource.exercice:
        return AppColors.blue;
      case TypeRessource.renforcement:
        return AppColors.orange;
      case TypeRessource.quiz:
        return AppColors.purple;
      case TypeRessource.fiche:
        return AppColors.gold;
      case TypeRessource.video:
        return AppColors.red;
    }
  }

  void _ouvrirRessource(Ressource ressource) {
    if (ressource.type == TypeRessource.quiz) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPage(ressource: ressource),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LecteurRessourcePage(ressource: ressource),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apprentissage'),
        actions: [
          IconButton(
            tooltip: 'Se connecter',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.login_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _bandeau(),
          const SizedBox(height: 20),
          _contenu(),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Contenus nationaux · Sentinel CI — Veiller, pas surveiller',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _Filtre extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Filtre({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

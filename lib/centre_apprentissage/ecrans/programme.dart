// ============================================================================
//  SENTINEL CI — CENTRE D'APPRENTISSAGE
//  Back-office : construction du programme (niveaux → matieres → chapitres)
//  Fichier : lib/centre_apprentissage/ecrans/programme.dart
//
//  Reserve aux administrateurs Sentinel (role 'admin', super admin et
//  co-admins). Reutilise les composants existants de l'application :
//  AppColors, SCCard, SectionTitle, showSnack, confirmerDialog.
// ============================================================================

import 'package:flutter/material.dart';

import '../../main.dart';
import '../modeles/contenu.dart';
import '../services/contenu_service.dart';

// ============================================================================
//  ECRAN 1 — NIVEAUX ET MATIERES
// ============================================================================

class ProgrammePage extends StatefulWidget {
  final AppUser user;
  const ProgrammePage({super.key, required this.user});
  @override
  State<ProgrammePage> createState() => _ProgrammePageState();
}

class _ProgrammePageState extends State<ProgrammePage> {
  String _niveau = NiveauxCI.tous.first;
  bool _installation = false;

  Future<void> _installerCourantes() async {
    setState(() => _installation = true);
    final n = await ContenuService.installerMatieresCourantes();
    if (!mounted) return;
    setState(() => _installation = false);
    showSnack(
        context,
        n == 0
            ? 'Les matieres courantes sont deja presentes.'
            : '$n matiere(s) ajoutee(s).');
  }

  @override
  Widget build(BuildContext context) {
    // Securite d'affichage. Les regles Firestore refusent de toute facon
    // l'ecriture aux autres roles : ceci evite simplement un ecran inutile.
    if (widget.user.role != UserRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Programme')),
        body: const Center(
            child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
              'Cet espace est reserve a l equipe Sentinel CI.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted)),
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Programme')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _dialogMatiere(context),
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.add),
        label: const Text('Matiere'),
      ),
      body: Column(children: [
        // ---- Compteurs de contenu ----
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: FutureBuilder<({int chapitres, int ressources, int brouillons})>(
            future: ContenuService.statistiques(),
            builder: (ctx, s) {
              final d = s.data;
              String v(int? x) => s.hasData ? '${x ?? 0}' : '...';
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.green, Color(0xFF0E6D14)]),
                    image: const DecorationImage(
                        image: AssetImage('assets/images/motif.png'),
                        repeat: ImageRepeat.repeat),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  _compteur('Chapitres', v(d?.chapitres)),
                  _compteur('Ressources', v(d?.ressources)),
                  _compteur('Brouillons', v(d?.brouillons)),
                ]),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // ---- Choix du niveau ----
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: NiveauxCI.tous.length,
            itemBuilder: (_, i) {
              final n = NiveauxCI.tous[i];
              final sel = n == _niveau;
              return GestureDetector(
                onTap: () => setState(() => _niveau = n),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                      color: sel ? AppColors.green : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: sel ? AppColors.green : AppColors.border)),
                  child: Text(NiveauxCI.libelle(n),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : AppColors.textMuted)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // ---- Matieres du niveau choisi ----
        Expanded(
          child: StreamBuilder<List<Matiere>>(
            stream: ContenuService.streamMatieres(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              // Une matiere sans liste de niveaux est enseignee partout.
              final mats = snap.data!
                  .where((m) =>
                      m.actif &&
                      (m.niveaux.isEmpty || m.niveaux.contains(_niveau)))
                  .toList();

              if (snap.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.menu_book_rounded,
                          size: 44, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text('Aucune matiere pour le moment.',
                          style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _installation ? null : _installerCourantes,
                          icon: _installation
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.playlist_add_check_rounded,
                                  size: 18),
                          label: const Text('Installer les matieres courantes'),
                        ),
                      ),
                    ]),
                  ),
                );
              }
              if (mats.isEmpty) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                      'Aucune matiere n est rattachee a ce niveau.\n'
                      'Modifiez une matiere pour y ajouter ce niveau.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted)),
                ));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                itemCount: mats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final m = mats[i];
                  final couleur = _couleur(m.couleurHex);
                  return SCCard(
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChapitresPage(
                                  user: widget.user,
                                  niveau: _niveau,
                                  matiere: m))),
                      child: Row(children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: couleur.withOpacity(.14),
                              borderRadius: BorderRadius.circular(11)),
                          child: Icon(Icons.menu_book_rounded,
                              color: couleur, size: 21),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.nom,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                                _NbChapitres(niveau: _niveau, matiereId: m.id),
                              ]),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Modifier la matiere',
                          onPressed: () => _dialogMatiere(context, matiere: m),
                          icon: const Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.textMuted),
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
        ),
      ]),
    );
  }

  Widget _compteur(String label, String valeur) => Expanded(
        child: Column(children: [
          Text(valeur,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
        ]),
      );
}

/// Compte les chapitres d'une matiere pour un niveau (ligne secondaire).
class _NbChapitres extends StatelessWidget {
  final String niveau, matiereId;
  const _NbChapitres({required this.niveau, required this.matiereId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Chapitre>>(
      stream: ContenuService.streamChapitres(niveau, matiereId: matiereId),
      builder: (ctx, s) {
        final n = s.hasData ? s.data!.length : null;
        return Text(
            n == null
                ? '...'
                : (n == 0 ? 'Aucun chapitre' : '$n chapitre${n > 1 ? 's' : ''}'),
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted));
      },
    );
  }
}

// ============================================================================
//  ECRAN 2 — CHAPITRES D'UNE MATIERE
// ============================================================================

class ChapitresPage extends StatelessWidget {
  final AppUser user;
  final String niveau;
  final Matiere matiere;
  const ChapitresPage(
      {super.key,
      required this.user,
      required this.niveau,
      required this.matiere});

  Future<void> _supprimer(BuildContext context, Chapitre c) async {
    final ok = await confirmerDialog(
        context,
        'Supprimer « ${c.titre} » ?',
        'Le chapitre sera supprime ainsi que TOUTES ses ressources : cours, '
        'exercices, quiz, fiches et videos rattaches. Action irreversible.');
    if (!ok || !context.mounted) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
                content: Row(children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Suppression en cours...')),
            ])));
    try {
      final n = await ContenuService.supprimerChapitre(c.id);
      if (context.mounted) {
        Navigator.pop(context);
        showSnack(context, 'Chapitre supprime ($n element(s) efface(s)).');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        showSnack(context, 'Erreur : $e', error: true);
      }
    }
  }

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _dialogChapitre(context, niveau, matiere),
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.add),
        label: const Text('Chapitre'),
      ),
      body: StreamBuilder<List<Chapitre>>(
        stream: ContenuService.streamChapitres(niveau, matiereId: matiere.id),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chaps = snap.data!;
          if (chaps.isEmpty) {
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(28),
              child: Text(
                  'Aucun chapitre.\nCommencez par le chapitre 1 du programme officiel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted)),
            ));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: chaps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = chaps[i];
              return SCCard(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: c.actif ? AppColors.greenBg : AppColors.bg,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${c.ordre}',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: c.actif
                                ? AppColors.green
                                : AppColors.textMuted)),
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
                          const SizedBox(height: 4),
                          Text(c.id,
                              style: const TextStyle(
                                  fontSize: 10.5, color: AppColors.textMuted)),
                        ]),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded,
                        size: 20, color: AppColors.textMuted),
                    onSelected: (v) async {
                      if (v == 'modifier') {
                        _dialogChapitre(context, niveau, matiere, chapitre: c);
                      } else if (v == 'masquer') {
                        await ContenuService.modifierChapitre(
                            c.copierAvec(actif: !c.actif));
                        if (context.mounted) {
                          showSnack(
                              context,
                              c.actif
                                  ? 'Chapitre masque aux eleves.'
                                  : 'Chapitre visible par les eleves.');
                        }
                      } else if (v == 'supprimer') {
                        await _supprimer(context, c);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'modifier',
                          child: Row(children: [
                            Icon(Icons.edit_rounded,
                                size: 18, color: AppColors.green),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ])),
                      PopupMenuItem(
                          value: 'masquer',
                          child: Row(children: [
                            Icon(
                                c.actif
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 18,
                                color: AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(c.actif ? 'Masquer' : 'Rendre visible'),
                          ])),
                      const PopupMenuItem(
                          value: 'supprimer',
                          child: Row(children: [
                            Icon(Icons.delete_rounded,
                                size: 18, color: AppColors.red),
                            SizedBox(width: 8),
                            Text('Supprimer',
                                style: TextStyle(color: AppColors.red)),
                          ])),
                    ],
                  ),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================================
//  FORMULAIRE — CREER / MODIFIER UNE MATIERE
// ============================================================================

Future<void> _dialogMatiere(BuildContext context, {Matiere? matiere}) async {
  final creation = matiere == null;
  final idCtrl = TextEditingController(text: matiere?.id ?? '');
  final nomCtrl = TextEditingController(text: matiere?.nom ?? '');
  final ordreCtrl =
      TextEditingController(text: (matiere?.ordre ?? 0).toString());
  final niveaux = <String>{...(matiere?.niveaux ?? const <String>[])};
  String couleur = matiere?.couleurHex ?? '1B9D21';
  bool envoi = false;

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
                Text(creation ? 'Ajouter une matiere' : 'Modifier la matiere',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: nomCtrl,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) {
                    if (creation) idCtrl.text = _slug(v);
                    setSt(() {});
                  },
                  decoration: const InputDecoration(
                      labelText: 'Nom (ex. Mathematiques)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: idCtrl,
                  enabled: creation, // l'identifiant ne change jamais
                  decoration: InputDecoration(
                      labelText: 'Identifiant court',
                      helperText: creation
                          ? 'Lettres minuscules, sans espace. Ex. math, franc, pc'
                          : 'L identifiant ne peut plus etre modifie'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: ordreCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Ordre d affichage'),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Couleur',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: _palette.map((hex) {
                    final sel = hex == couleur;
                    return GestureDetector(
                      onTap: () => setSt(() => couleur = hex),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                            color: _couleur(hex),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: sel ? AppColors.textMain : Colors.white,
                                width: sel ? 2.5 : 2)),
                        child: sel
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Niveaux concernes',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                const Text('Aucun coche = matiere enseignee a tous les niveaux.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: NiveauxCI.tous.map((n) {
                    return FilterChip(
                      label: Text(NiveauxCI.libelle(n)),
                      selected: niveaux.contains(n),
                      onSelected: (v) => setSt(() {
                        if (v) {
                          niveaux.add(n);
                        } else {
                          niveaux.remove(n);
                        }
                      }),
                      selectedColor: AppColors.greenBg,
                      checkmarkColor: AppColors.green,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: envoi
                        ? null
                        : () async {
                            final nom = nomCtrl.text.trim();
                            final id = _slug(idCtrl.text);
                            if (nom.isEmpty || id.isEmpty) {
                              showSnack(ctx, 'Nom et identifiant obligatoires',
                                  error: true);
                              return;
                            }
                            setSt(() => envoi = true);
                            final m = Matiere(
                              id: id,
                              nom: nom,
                              couleurHex: couleur,
                              ordre: int.tryParse(ordreCtrl.text.trim()) ?? 0,
                              niveaux: niveaux.toList(),
                              actif: matiere?.actif ?? true,
                            );
                            if (creation) {
                              final err = await ContenuService.creerMatiere(m);
                              if (!ctx.mounted) return;
                              if (err != null) {
                                setSt(() => envoi = false);
                                showSnack(ctx, err, error: true);
                                return;
                              }
                            } else {
                              await ContenuService.modifierMatiere(m);
                            }
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              showSnack(
                                  context,
                                  creation
                                      ? 'Matiere ajoutee.'
                                      : 'Matiere mise a jour.');
                            }
                          },
                    child: envoi
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(creation ? 'Creer la matiere' : 'Enregistrer'),
                  ),
                ),
              ]),
        ),
      ),
    ),
  );
}

// ============================================================================
//  FORMULAIRE — CREER / MODIFIER UN CHAPITRE
// ============================================================================

Future<void> _dialogChapitre(
    BuildContext context, String niveau, Matiere matiere,
    {Chapitre? chapitre}) async {
  final creation = chapitre == null;
  final titreCtrl = TextEditingController(text: chapitre?.titre ?? '');
  final descCtrl = TextEditingController(text: chapitre?.description ?? '');
  final ordreCtrl =
      TextEditingController(text: (chapitre?.ordre ?? 1).toString());
  bool envoi = false;

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
                Text(creation ? 'Ajouter un chapitre' : 'Modifier le chapitre',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${matiere.nom} — ${NiveauxCI.libelle(niveau)}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: ordreCtrl,
                    keyboardType: TextInputType.number,
                    enabled: creation, // l'ordre fabrique l'identifiant
                    decoration: InputDecoration(
                        labelText: 'Numero du chapitre',
                        helperText: creation ? null : 'Non modifiable'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titreCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Titre (ex. Theoreme de Pythagore)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Description courte (facultatif)',
                      alignLabelWithHint: true),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: envoi
                        ? null
                        : () async {
                            final titre = titreCtrl.text.trim();
                            final ordre =
                                int.tryParse(ordreCtrl.text.trim()) ?? 0;
                            if (titre.isEmpty || ordre <= 0) {
                              showSnack(ctx,
                                  'Numero et titre obligatoires (numero a partir de 1)',
                                  error: true);
                              return;
                            }
                            setSt(() => envoi = true);
                            final c = Chapitre(
                              id: chapitre?.id ?? '',
                              niveau: niveau,
                              matiereId: matiere.id,
                              titre: titre,
                              description: descCtrl.text.trim(),
                              ordre: creation ? ordre : chapitre.ordre,
                              actif: chapitre?.actif ?? true,
                            );
                            if (creation) {
                              final res = await ContenuService.creerChapitre(c);
                              if (!ctx.mounted) return;
                              if (res.startsWith('!')) {
                                setSt(() => envoi = false);
                                showSnack(ctx, res.substring(1), error: true);
                                return;
                              }
                            } else {
                              await ContenuService.modifierChapitre(c);
                            }
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              showSnack(
                                  context,
                                  creation
                                      ? 'Chapitre ajoute.'
                                      : 'Chapitre mis a jour.');
                            }
                          },
                    child: envoi
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(creation ? 'Creer le chapitre' : 'Enregistrer'),
                  ),
                ),
              ]),
        ),
      ),
    ),
  );
}

// ============================================================================
//  OUTILS
// ============================================================================

/// Palette reprise des couleurs de l'application.
const List<String> _palette = [
  '1B9D21', '1565C0', 'F57C00', 'D32F2F',
  '6A1B9A', 'F9A825', '00897B', '455A64',
];

Color _couleur(String hex) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return AppColors.green;
  }
}

/// Transforme un nom en identifiant court : "Physique-Chimie" -> "physiquech".
String _slug(String v) {
  var s = v.toLowerCase().trim();
  const accents = {
    'a': 'àâä', 'e': 'éèêë', 'i': 'îï', 'o': 'ôö', 'u': 'ùûü', 'c': 'ç',
  };
  accents.forEach((simple, groupe) {
    for (final ch in groupe.split('')) {
      s = s.replaceAll(ch, simple);
    }
  });
  s = s.replaceAll(RegExp(r'[^a-z0-9]'), '');
  return s.length > 10 ? s.substring(0, 10) : s;
}

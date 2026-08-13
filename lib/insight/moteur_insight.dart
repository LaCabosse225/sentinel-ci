// ============================================================================
//  SENTINEL CI — SENTINELLE INSIGHT
//  Moteur d'analyse : detection precoce des difficultes scolaires
//  Fichier : lib/insight/moteur_insight.dart
//
//  PRINCIPE
//  Insight ne note pas un enfant. Il repere des SIGNAUX dans des donnees que
//  l'ecole possede deja (notes, absences, retards) et les presente a un
//  adulte pour declencher une conversation.
//
//  Trois regles non negociables, inscrites dans le code :
//   1. Aucun score chiffre attribue a un eleve : un niveau d'attention et
//      des raisons explicites, toujours lisibles et contestables.
//   2. Chaque signal indique POURQUOI il s'est declenche. Jamais de boite
//      noire : un adulte doit pouvoir verifier et ne pas etre d'accord.
//   3. Aucune decision automatique. Insight alerte, l'humain decide.
//
//  Ce fichier ne depend que de cloud_firestore : aucun import de main.dart,
//  aucune ecriture dans la base. Lecture seule.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
//  1. NIVEAU D'ATTENTION
// ============================================================================

enum NiveauAttention {
  aucun, // rien a signaler
  surveiller, // un signal isole
  prioritaire, // plusieurs signaux, ou un signal grave
}

extension NiveauAttentionX on NiveauAttention {
  String get libelle {
    switch (this) {
      case NiveauAttention.aucun:
        return 'Rien a signaler';
      case NiveauAttention.surveiller:
        return 'A surveiller';
      case NiveauAttention.prioritaire:
        return 'Accompagnement prioritaire';
    }
  }

  String get emoji {
    switch (this) {
      case NiveauAttention.aucun:
        return '🟢';
      case NiveauAttention.surveiller:
        return '🟡';
      case NiveauAttention.prioritaire:
        return '🔴';
    }
  }
}

// ============================================================================
//  2. SIGNAL
//
//  Un signal est une observation datee, expliquee et rattachee a une action
//  concrete. Il n'est jamais un jugement sur l'eleve.
// ============================================================================

enum TypeSignal {
  matiereFragile,
  matiereEnBaisse,
  moyenneBasse,
  absencesRepetees,
  retardsRepetes,
  progres, // signal POSITIF : on le montre aussi
}

class Signal {
  final TypeSignal type;
  final String titre;
  final String explication; // pourquoi ce signal s'est declenche
  final String? matiere;
  final int poids; // 0 = information, 1 = signal, 2 = signal grave

  const Signal({
    required this.type,
    required this.titre,
    required this.explication,
    this.matiere,
    this.poids = 1,
  });

  bool get estPositif => type == TypeSignal.progres;
}

// ============================================================================
//  3. ANALYSE D'UN ELEVE
// ============================================================================

class AnalyseEleve {
  final String eleveId;
  final String eleveNom;
  final double moyenneGenerale;
  final Map<String, double> moyennesParMatiere;
  final int nbNotes;
  final int absencesNonJustifiees;
  final int retards;
  final List<Signal> signaux;
  final NiveauAttention niveau;

  const AnalyseEleve({
    required this.eleveId,
    required this.eleveNom,
    required this.moyenneGenerale,
    required this.moyennesParMatiere,
    required this.nbNotes,
    required this.absencesNonJustifiees,
    required this.retards,
    required this.signaux,
    required this.niveau,
  });

  List<Signal> get alertes => signaux.where((s) => !s.estPositif).toList();
  List<Signal> get encouragements =>
      signaux.where((s) => s.estPositif).toList();

  /// Les matieres ou l'eleve est en difficulte : point d'entree de la
  /// revision personnalisee du Centre d'Apprentissage.
  List<String> get matieresADeployer => alertes
      .where((s) => s.matiere != null)
      .map((s) => s.matiere!)
      .toSet()
      .toList();
}

// ============================================================================
//  4. SEUILS
//
//  Regroupes ici pour etre relus, discutes et ajustes par un pedagogue.
//  Ils ne doivent JAMAIS etre disperses dans le code.
// ============================================================================

class SeuilsInsight {
  /// En dessous de cette moyenne, une matiere est consideree fragile.
  static const double matiereFragile = 10.0;

  /// Chute en points entre les notes recentes et les precedentes.
  static const double chuteSignificative = 3.0;

  /// En dessous de cette moyenne generale, le signal est grave.
  static const double moyenneGeneraleGrave = 8.0;

  /// Progres en points salue comme un encouragement.
  static const double progresSignificatif = 3.0;

  /// Nombre minimum de notes dans une matiere pour juger d'une tendance.
  static const int notesMinimumTendance = 4;

  /// Fenetre d'observation des absences, en jours.
  static const int fenetreAbsencesJours = 30;

  /// Absences non justifiees declenchant une alerte grave.
  static const int absencesAlerte = 4;

  /// Retards declenchant une alerte.
  static const int retardsAlerte = 5;
}

// ============================================================================
//  5. MOTEUR
// ============================================================================

class MoteurInsight {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --------------------------------------------------------------------------
  //  Analyse d'un eleve
  // --------------------------------------------------------------------------

  static Future<AnalyseEleve> analyserEleve({
    required String eleveId,
    required String eleveNom,
  }) async {
    // ---- Notes ----
    QuerySnapshot? notesSnap;
    try {
      notesSnap =
          await _db.collection('notes').where('eleveId', isEqualTo: eleveId).get();
    } catch (_) {}
    final notes = notesSnap?.docs ?? [];

    // Regroupement par matiere, tout ramene sur 20
    final Map<String, List<_NoteSimple>> parMatiere = {};
    for (final d in notes) {
      final m = d.data() as Map<String, dynamic>;
      final matiere = (m['matiere'] ?? 'Autre').toString();
      final sur = (m['sur'] as num?)?.toDouble() ?? 20;
      final brute = (m['note'] as num?)?.toDouble() ?? 0;
      final valeur = sur > 0 ? brute * 20 / sur : brute;
      final coef = (m['coefficient'] as num?)?.toDouble() ?? 1;
      final date = (m['date'] ?? '').toString();
      (parMatiere[matiere] ??= []).add(_NoteSimple(valeur, coef, date));
    }

    // Moyennes ponderees
    final Map<String, double> moyennes = {};
    double totalPoints = 0, totalCoefs = 0;
    parMatiere.forEach((matiere, liste) {
      double p = 0, c = 0;
      for (final n in liste) {
        p += n.valeur * n.coef;
        c += n.coef;
      }
      if (c > 0) moyennes[matiere] = p / c;
      totalPoints += p;
      totalCoefs += c;
    });
    final moyenneGenerale = totalCoefs > 0 ? totalPoints / totalCoefs : 0.0;

    // ---- Absences sur la fenetre d'observation ----
    int absences = 0;
    int retards = 0;
    try {
      final absSnap = await _db
          .collection('absences')
          .where('eleveId', isEqualTo: eleveId)
          .get();
      final limite = DateTime.now()
          .subtract(const Duration(days: SeuilsInsight.fenetreAbsencesJours));
      final limiteIso = _iso(limite);
      for (final d in absSnap.docs) {
        final m = d.data();
        final date = (m['date'] ?? '').toString();
        if (date.length != 10 || date.compareTo(limiteIso) < 0) continue;
        if (m['statut'] == 'retard') {
          retards++;
        } else if (m['justifie'] != true) {
          absences++;
        }
      }
    } catch (_) {}

    // ---- Signaux ----
    final signaux = <Signal>[];

    // Moyenne generale basse
    if (notes.isNotEmpty && moyenneGenerale < SeuilsInsight.moyenneGeneraleGrave) {
      signaux.add(Signal(
        type: TypeSignal.moyenneBasse,
        titre: 'Moyenne generale en difficulte',
        explication:
            'Moyenne generale de ${moyenneGenerale.toStringAsFixed(2)}/20, '
            'calculee sur ${notes.length} note(s).',
        poids: 2,
      ));
    }

    // Analyse matiere par matiere
    moyennes.forEach((matiere, moyenne) {
      final liste = parMatiere[matiere]!;

      if (moyenne < SeuilsInsight.matiereFragile) {
        signaux.add(Signal(
          type: TypeSignal.matiereFragile,
          titre: 'Difficulte en $matiere',
          explication:
              'Moyenne de ${moyenne.toStringAsFixed(2)}/20 sur ${liste.length} note(s).',
          matiere: matiere,
        ));
      }

      // Tendance : deux dernieres notes contre les precedentes
      if (liste.length >= SeuilsInsight.notesMinimumTendance) {
        final triees = List<_NoteSimple>.from(liste)
          ..sort((a, b) => a.date.compareTo(b.date));
        final recentes = triees.sublist(triees.length - 2);
        final anciennes = triees.sublist(0, triees.length - 2);
        final moyRecente =
            recentes.map((n) => n.valeur).reduce((a, b) => a + b) / recentes.length;
        final moyAncienne =
            anciennes.map((n) => n.valeur).reduce((a, b) => a + b) /
                anciennes.length;
        final ecart = moyAncienne - moyRecente;

        if (ecart >= SeuilsInsight.chuteSignificative) {
          signaux.add(Signal(
            type: TypeSignal.matiereEnBaisse,
            titre: 'Baisse recente en $matiere',
            explication:
                'Les 2 dernieres notes sont a ${moyRecente.toStringAsFixed(1)}/20, '
                'contre ${moyAncienne.toStringAsFixed(1)}/20 auparavant '
                '(-${ecart.toStringAsFixed(1)} points).',
            matiere: matiere,
            poids: 2,
          ));
        } else if (-ecart >= SeuilsInsight.progresSignificatif) {
          signaux.add(Signal(
            type: TypeSignal.progres,
            titre: 'Progres en $matiere',
            explication:
                'Les 2 dernieres notes sont a ${moyRecente.toStringAsFixed(1)}/20, '
                'contre ${moyAncienne.toStringAsFixed(1)}/20 auparavant '
                '(+${(-ecart).toStringAsFixed(1)} points). A saluer.',
            matiere: matiere,
            poids: 0,
          ));
        }
      }
    });

    // Absences
    if (absences >= SeuilsInsight.absencesAlerte) {
      signaux.add(Signal(
        type: TypeSignal.absencesRepetees,
        titre: 'Absences repetees',
        explication:
            '$absences absence(s) non justifiee(s) sur les '
            '${SeuilsInsight.fenetreAbsencesJours} derniers jours.',
        poids: 2,
      ));
    }
    if (retards >= SeuilsInsight.retardsAlerte) {
      signaux.add(Signal(
        type: TypeSignal.retardsRepetes,
        titre: 'Retards frequents',
        explication:
            '$retards retard(s) sur les ${SeuilsInsight.fenetreAbsencesJours} '
            'derniers jours.',
      ));
    }

    return AnalyseEleve(
      eleveId: eleveId,
      eleveNom: eleveNom,
      moyenneGenerale: moyenneGenerale,
      moyennesParMatiere: moyennes,
      nbNotes: notes.length,
      absencesNonJustifiees: absences,
      retards: retards,
      signaux: signaux,
      niveau: _niveau(signaux, notes.isEmpty),
    );
  }

  // --------------------------------------------------------------------------
  //  Analyse d'une classe entiere
  //
  //  Les eleves sont classes du plus prioritaire au moins prioritaire :
  //  la direction voit d'abord qui a besoin d'aide.
  // --------------------------------------------------------------------------

  static Future<List<AnalyseEleve>> analyserClasse({
    required String ecoleId,
    required String classeId,
  }) async {
    final snap = await _db
        .collection('utilisateurs')
        .where('ecoleId', isEqualTo: ecoleId)
        .get();

    final eleves = snap.docs.where((d) {
      final m = d.data();
      return (m['role'] ?? '') == 'eleve' && m['classeId'] == classeId;
    }).toList();

    final out = <AnalyseEleve>[];
    for (final e in eleves) {
      final nom = ((e.data())['nom'] ?? '').toString();
      out.add(await analyserEleve(eleveId: e.id, eleveNom: nom));
    }

    out.sort((a, b) {
      final n = b.niveau.index.compareTo(a.niveau.index);
      if (n != 0) return n;
      final s = b.alertes.length.compareTo(a.alertes.length);
      if (s != 0) return s;
      return a.moyenneGenerale.compareTo(b.moyenneGenerale);
    });
    return out;
  }

  // --------------------------------------------------------------------------
  //  Regle d'attribution du niveau
  // --------------------------------------------------------------------------

  static NiveauAttention _niveau(List<Signal> signaux, bool aucuneNote) {
    // Sans note, on ne conclut rien. L'absence de donnee n'est pas un signal.
    if (aucuneNote) return NiveauAttention.aucun;

    final alertes = signaux.where((s) => !s.estPositif).toList();
    if (alertes.isEmpty) return NiveauAttention.aucun;

    final graves = alertes.where((s) => s.poids >= 2).length;
    if (graves >= 1 || alertes.length >= 3) {
      return NiveauAttention.prioritaire;
    }
    return NiveauAttention.surveiller;
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

// ============================================================================
//  OUTIL INTERNE
// ============================================================================

class _NoteSimple {
  final double valeur; // ramenee sur 20
  final double coef;
  final String date; // AAAA-MM-JJ
  const _NoteSimple(this.valeur, this.coef, this.date);
}

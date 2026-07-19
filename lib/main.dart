// ============================================================
//  SENTINEL CI — Version Firebase
//  Connexion réelle + Firestore + Notifications Push
// ============================================================

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// ── NOTIFICATIONS SONORES ──
// Canal Android haute priorité : son, vibration et bannière qui surgit,
// même quand l'application est ouverte. Les messages FCM reçus en arrière-plan
// utilisent ce canal grâce au réglage ajouté dans AndroidManifest.xml.
final FlutterLocalNotificationsPlugin kNotifLocales =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel kCanalImportant = AndroidNotificationChannel(
  'sentinel_important',
  'Alertes Sentinel CI',
  description: 'Devoirs, notes, agenda, messages : alertes importantes.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

Future<void> initialiserNotificationsSonores() async {
  if (kIsWeb) return;
  try {
    await kNotifLocales.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')));
    await kNotifLocales
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(kCanalImportant);
  } catch (e) {
    print('Canal de notification indisponible : $e');
  }
}

// Affiche une vraie notification (son + bannière) quand un message
// push arrive alors que l'application est ouverte.
void afficherNotificationSonore(String? titre, String? corps) {
  if (kIsWeb) return;
  try {
    kNotifLocales.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      titre ?? 'Sentinel CI',
      corps ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sentinel_important',
          'Alertes Sentinel CI',
          channelDescription:
              'Devoirs, notes, agenda, messages : alertes importantes.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  } catch (_) {}
}


// ── Configuration Firebase pour la VERSION WEB (console Firebase, app Web) ──
// Ces valeurs sont publiques par conception ; la sécurité vient des règles
// Firestore/Storage déjà déployées.
const FirebaseOptions kFirebaseWebOptions = FirebaseOptions(
  apiKey: 'AIzaSyC76Vz7DjxjRKpdQ6thnusgaBZMS9u-_hg',
  authDomain: 'sentinel-ci-c7592.firebaseapp.com',
  projectId: 'sentinel-ci-c7592',
  storageBucket: 'sentinel-ci-c7592.firebasestorage.app',
  messagingSenderId: '777104094412',
  appId: '1:777104094412:web:e27ecf7b65e0505081be69',
  measurementId: 'G-4FJ1WY200C',
);

// ── PASTILLES ROUGES « du nouveau » ──
// Chaque section memorise la derniere consultation ; un point rouge
// apparait sur l'onglet des qu'un contenu plus recent existe.
final ValueNotifier<int> kPastillesVersion = ValueNotifier<int>(0);

Future<void> marquerSectionVue(String uid, String section) async {
  try {
    final p = await SharedPreferences.getInstance();
    await p.setInt('vu_${section}_$uid', DateTime.now().millisecondsSinceEpoch);
    kPastillesVersion.value++;
  } catch (_) {}
}

int tsMaxDocs(QuerySnapshot s) {
  int m = 0;
  for (final d in s.docs) {
    final data = d.data() as Map<String, dynamic>? ?? {};
    for (final k in const ['createdAt', 'dateMAJ', 'updatedAt']) {
      final v = data[k];
      if (v is Timestamp) {
        final t = v.millisecondsSinceEpoch;
        if (t > m) m = t;
      }
    }
  }
  return m;
}

class IconePastille extends StatelessWidget {
  final IconData icone;
  final Query? requete;
  final String uid;
  final String section;
  const IconePastille({super.key, required this.icone,
      required this.requete, required this.uid, required this.section});

  @override
  Widget build(BuildContext context) {
    if (requete == null) return Icon(icone);
    return ValueListenableBuilder<int>(
      valueListenable: kPastillesVersion,
      builder: (_, __, ___) => FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (c, prefsSnap) {
          final vu = prefsSnap.data?.getInt('vu_${section}_$uid') ?? 0;
          return StreamBuilder<QuerySnapshot>(
            stream: requete!.snapshots(),
            builder: (c, s) {
              final nouveau = s.hasData && tsMaxDocs(s.data!) > vu;
              return Stack(clipBehavior: Clip.none, children: [
                Icon(icone),
                if (nouveau)
                  Positioned(right: -2, top: -2,
                      child: Container(width: 10, height: 10,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle))),
              ]);
            });
        }),
    );
  }
}


  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      // Sur le web, la config doit être fournie dans le code ;
      // sur Android/iOS, elle vient de google-services.json.
      if (kIsWeb) {
        await Firebase.initializeApp(options: kFirebaseWebOptions);
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      print('Erreur Firebase: $e');
    }
    await initialiserNotificationsSonores();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const SentinelCIApp());
  }
// ══════════════════════════════════════════
class AppColors {
  static const green     = Color(0xFF1B9D21);
  static const green2    = Color(0xFF1DAC27);
  static const greenBg   = Color(0xFFE7F6E5);
  static const orange    = Color(0xFFF57C00);
  static const orangeBg  = Color(0xFFFFF3E0);
  static const red       = Color(0xFFD32F2F);
  static const redBg     = Color(0xFFFFEBEE);
  static const blue      = Color(0xFF1565C0);
  static const blueBg    = Color(0xFFE3F0FF);
  static const gold      = Color(0xFFF9A825);
  static const goldBg    = Color(0xFFFFFDE7);
  static const purple    = Color(0xFF6A1B9A);
  static const purpleBg  = Color(0xFFF3E5F5);
  static const bg        = Color(0xFFF4F6F9);
  static const border    = Color(0xFFE0E4EC);
  static const textMain  = Color(0xFF1A1D23);
  static const textMuted = Color(0xFF6B7280);
}

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: AppColors.bg,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.textMain,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
        color: AppColors.textMain, fontSize: 17, fontWeight: FontWeight.w700),
  ),
  cardTheme: CardThemeData(
    color: Colors.white, elevation: 0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border)),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.green, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.green, foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  ),
);

// ══════════════════════════════════════════
//  MODÈLES
// ══════════════════════════════════════════
enum UserRole { admin, directeur, prof, eleve, parent }

// Convertit le rôle stocké en base en UserRole (sécurité : inconnu => accès minimal)
UserRole roleFromString(String? r) {
  switch (r) {
    case 'admin':
    case 'super_admin': return UserRole.admin;
    case 'directeur':   return UserRole.directeur;
    case 'prof':        return UserRole.prof;
    case 'eleve':       return UserRole.eleve;
    case 'parent':      return UserRole.parent;
    default:            return UserRole.eleve;
  }
}

class AppUser {
  final String name, initials, email, school, uid;
  final UserRole role;
  final String? childId;   // pour un parent : UID de son enfant (1er enfant)
  final String? classeId;  // élève : sa classe ; parent : la classe de son enfant
  final String? matiere;          // prof : sa matière
  final List<String> classes;     // prof : les classes qu'il enseigne (ids)
  final bool estPrincipal;        // prof principal ?
  final String? classePrincipale; // prof principal : classe dont il est responsable
  final int enfantsCount;         // parent : nombre d'enfants (réduction famille)
  final String? lien;             // parent : papa / maman / tuteur
  final String? childName;        // parent : nom de l'enfant actif
  final bool coAdmin;             // admin de terrain : configure/ajoute mais ne supprime pas
  const AppUser({required this.name, required this.initials,
    required this.email, required this.school,
    required this.role, required this.uid, this.childId, this.classeId,
    this.matiere, this.classes = const [], this.estPrincipal = false,
    this.classePrincipale, this.enfantsCount = 1, this.lien, this.childName,
    this.coAdmin = false});

  // Vrai seulement pour le SUPER admin (celui qui peut bloquer/supprimer)
  bool get estSuperAdmin => role == UserRole.admin && !coAdmin;

  AppUser copyWith({String? childId, String? classeId, int? enfantsCount, String? childName}) => AppUser(
        name: name, initials: initials, email: email, school: school,
        role: role, uid: uid,
        childId: childId ?? this.childId,
        classeId: classeId ?? this.classeId,
        matiere: matiere, classes: classes, estPrincipal: estPrincipal,
        classePrincipale: classePrincipale,
        enfantsCount: enfantsCount ?? this.enfantsCount,
        lien: lien,
        childName: childName ?? this.childName,
        coAdmin: coAdmin,
      );
}

// Calcule la moyenne générale et par matière à partir d'une liste de notes.
({double generale, Map<String,double> parMatiere}) calculerMoyennes(List docs) {
  final Map<String,double> pts = {};
  final Map<String,double> cfs = {};
  for (final d in docs) {
    final m = (d.data() as Map);
    final mat = (m['matiere'] ?? 'Autre').toString();
    final sur = (m['sur'] as num?)?.toDouble() ?? 20;
    final brut = (m['note'] as num?)?.toDouble() ?? 0;
    final nt = sur > 0 ? brut * 20 / sur : brut;   // tout ramené sur 20
    final cf = (m['coefficient'] as num?)?.toDouble() ?? 1;
    pts[mat] = (pts[mat] ?? 0) + nt*cf;
    cfs[mat] = (cfs[mat] ?? 0) + cf;
  }
  double tp = 0, tc = 0;
  pts.forEach((k,v) => tp += v);
  cfs.forEach((k,v) => tc += v);
  final parMatiere = <String,double>{};
  for (final mat in pts.keys) {
    final c = cfs[mat] ?? 0;
    parMatiere[mat] = c > 0 ? pts[mat]!/c : 0;
  }
  return (generale: tc > 0 ? tp/tc : 0.0, parMatiere: parMatiere);
}

// Mention ivoirienne d'après la moyenne /20
String mentionDe(double m) {
  if (m >= 16) return 'Excellent';
  if (m >= 14) return 'Tres Bien';
  if (m >= 12) return 'Bien';
  if (m >= 10) return 'Assez Bien';
  if (m >= 8)  return 'Passable';
  return 'Insuffisant';
}

// Appréciation bienveillante d'après la moyenne /20
String appreciationDe(double m) {
  if (m >= 16) return 'Travail remarquable. Continue ainsi, tu es sur une excellente voie !';
  if (m >= 14) return 'Tres bon trimestre. Poursuis tes efforts, c est tres encourageant.';
  if (m >= 12) return 'Bon ensemble. Avec un peu plus de regularite, tu iras encore plus haut.';
  if (m >= 10) return 'Resultats corrects. Accroche-toi, tu as les capacites pour progresser.';
  if (m >= 8)  return 'Trimestre en demi-teinte. Des efforts cibles te feront vite remonter.';
  return 'Trimestre difficile, mais ne te decourage pas. On est la pour t aider a rebondir.';
}

// Appréciation automatique d'UNE note, selon le barème (/10 ou /20)
String appreciationNote(double note, int sur) {
  if (sur == 10) {
    if (note < 2)  return 'Des efforts importants sont necessaires';
    if (note < 4)  return 'Resultats insuffisants';
    if (note < 5)  return 'Peut mieux faire';
    if (note < 6)  return 'Resultats satisfaisants';
    if (note < 8)  return 'Bon travail';
    if (note < 10) return 'Excellent travail';
    return 'Performance remarquable';
  }
  if (note < 5)  return 'Des efforts importants sont necessaires';
  if (note < 8)  return 'Resultats insuffisants';
  if (note < 10) return 'Peut mieux faire';
  if (note < 12) return 'Resultats satisfaisants';
  if (note < 14) return 'Bon travail';
  if (note < 16) return 'Tres bon travail';
  if (note < 18) return 'Excellent travail';
  return 'Performance remarquable';
}

// ---- NOUVEAU MODÈLE : c'est l'ÉCOLE qui paie un forfait selon son nombre d'élèves ----
// Tarif unique selon la taille (palier), par élève et par mois.
//   1 à 200 élèves    -> 1000 F / élève
//   201 à 500 élèves  ->  750 F / élève
//   plus de 500       ->  500 F / élève
int prixParEleve(int nb) {
  if (nb <= 200) return 1000;
  if (nb <= 500) return 750;
  return 500;
}

// Montant total à payer par une école pour un mois donné.
int forfaitMensuelEcole(int nbEleves) => nbEleves * prixParEleve(nbEleves);

// Formate un montant avec des espaces : 225000 -> "225 000" (plus lisible).
String fmtF(num n) {
  final s = n.round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    b.write(s[i]);
    final reste = s.length - 1 - i;
    if (reste > 0 && reste % 3 == 0) b.write(' ');
  }
  return b.toString();
}

// ---- SUIVI DES PAIEMENTS (l'école paie son forfait) ----
const List<String> kMoisFr = ['Janvier','Fevrier','Mars','Avril','Mai','Juin',
  'Juillet','Aout','Septembre','Octobre','Novembre','Decembre'];

// Code d'un mois : "2026-07" (sert d'identifiant de paiement).
String moisCode(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}';

// Libellé : "Juillet 2026".
String moisLabelFr(DateTime d) => '${kMoisFr[d.month-1]} ${d.year}';

// Les N derniers mois (mois courant en premier) pour le choix à l'encaissement.
List<DateTime> derniersMois(int n) {
  final now = DateTime.now();
  return List.generate(n, (i) => DateTime(now.year, now.month - i, 1));
}

// Reçu de paiement officiel (PDF partageable).
Future<Uint8List> genererRecuPdf(Map<String,dynamic> p) async {
  final doc = pw.Document();
  pw.MemoryImage? logo;
  try {
    final data = await rootBundle.load('assets/icon/logo.png');
    logo = pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) {}
  final vert = PdfColor.fromInt(0xFF1B9D21);
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a5,
    build: (ctx) => pw.Padding(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Row(children: [
            if (logo != null) pw.Image(logo, width: 34, height: 34),
            pw.SizedBox(width: 8),
            pw.Text('SentinelCI', style: pw.TextStyle(
                fontSize: 18, fontWeight: pw.FontWeight.bold, color: vert)),
          ]),
          pw.Text(p['numeroRecu'] ?? '', style: pw.TextStyle(
              fontSize: 13, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.SizedBox(height: 6),
        pw.Text('Veiller, pas surveiller',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.Divider(color: vert, thickness: 1.5),
        pw.SizedBox(height: 8),
        pw.Center(child: pw.Text('RECU DE PAIEMENT',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold))),
        pw.SizedBox(height: 14),
        pw.Text('Ecole : ${p['ecoleNom'] ?? ''}', style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 4),
        pw.Text('Periode : ${p['moisLabel'] ?? ''}', style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 4),
        pw.Text('Methode : ${p['methode'] ?? ''}'
            '${(p['reference'] ?? '').toString().isNotEmpty ? '  (ref. ${p['reference']})' : ''}',
            style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 4),
        pw.Text('Date : ${p['dateStr'] ?? ''}', style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 16),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE7F6E5),
              borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Column(children: [
            pw.Text('Montant recu', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Text('${fmtF((p['montant'] as num?) ?? 0)} FCFA',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: vert)),
          ]),
        ),
        pw.Spacer(),
        pw.Text('Enregistre par : ${p['saisiPar'] ?? ''}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 2),
        pw.Text('Sentinel CI - Forfait de suivi scolaire. Merci de votre confiance.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
      ]),
    ),
  ));
  return doc.save();
}

// Libellé du palier tarifaire d'une école.
String libellePalier(int nb) {
  if (nb <= 200) return '1 a 200 eleves';
  if (nb <= 500) return '201 a 500 eleves';
  return 'plus de 500 eleves';
}

// Calcule (une fois) la liste classée des élèves d'une classe avec leur moyenne.
Future<List<({String nom, double moy})>> calculerMoyennesClasse(
    String ecoleId, String classeId) async {
  final elevesSnap = await FirebaseService.getElevesEcole(ecoleId);
  final classmates = elevesSnap.docs
      .where((d)=>(d.data() as Map)['classeId'] == classeId).toList();
  final List<({String nom, double moy})> res = [];
  for (final c in classmates) {
    final notes = await FirebaseService.getNotesEleve(c.id);
    final m = calculerMoyennes(notes.docs);
    res.add((nom: ((c.data() as Map)['nom'] ?? '').toString(), moy: m.generale));
  }
  res.sort((a,b)=>b.moy.compareTo(a.moy));
  return res;
}

// Classement de TOUTES les classes d'une école par moyenne générale (pour le rang).
// Renvoie chaque classe avec sa moyenne (moyenne des moyennes des élèves) triée du meilleur au moins bon.
Future<List<({String id, String nom, double moy, int nbEleves})>> classementClasses(
    String ecoleId) async {
  final elevesSnap  = await FirebaseService.getElevesEcole(ecoleId);
  final classesSnap = await FirebaseService.streamClasses(ecoleId).first;
  // Regroupe les élèves par classe (1 seule lecture de tous les élèves)
  final Map<String, List> parClasse = {};
  for (final e in elevesSnap.docs) {
    final cid = (e.data() as Map)['classeId']?.toString();
    if (cid == null || cid.isEmpty) continue;
    (parClasse[cid] ??= []).add(e);
  }
  final out = <({String id, String nom, double moy, int nbEleves})>[];
  for (final c in classesSnap.docs) {
    final membres = parClasse[c.id] ?? [];
    double somme = 0; int n = 0;
    for (final m in membres) {
      final notes = await FirebaseService.getNotesEleve(m.id);
      if (notes.docs.isEmpty) continue;
      somme += calculerMoyennes(notes.docs).generale;
      n++;
    }
    out.add((
      id: c.id,
      nom: ((c.data() as Map)['nom'] ?? '').toString(),
      moy: n > 0 ? somme / n : 0.0,
      nbEleves: membres.length,
    ));
  }
  out.sort((a,b)=>b.moy.compareTo(a.moy));
  return out;
}

// Compte, pour une classe et une matière, le nombre de notes de chaque élève.
// Sert à repérer les élèves qui ont MOINS de notes que les autres (note oubliée / absence).
Future<List<({String id, String nom, int nb})>> comptageNotesMatiere(
    String ecoleId, String classeId, String matiere) async {
  final elevesSnap = await FirebaseService.getElevesEcole(ecoleId);
  final membres = elevesSnap.docs
      .where((d)=>(d.data() as Map)['classeId'] == classeId).toList();
  final out = <({String id, String nom, int nb})>[];
  for (final m in membres) {
    final notes = await FirebaseService.getNotesEleve(m.id);
    final nb = notes.docs.where((d)=>(d.data() as Map)['matiere'] == matiere).length;
    out.add((id: m.id, nom: ((m.data() as Map)['nom'] ?? '').toString(), nb: nb));
  }
  // du plus complet au moins complet
  out.sort((a,b)=>b.nb.compareTo(a.nb));
  return out;
}

// ---- Génération PDF ----
pw.Widget _pdfEntete(String ecoleNom) => pw.Column(children:[
  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children:[
    pw.Text('SENTINEL CI',
        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
    pw.Text(ecoleNom, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
  ]),
  pw.Divider(color: PdfColors.green800),
]);

Future<Uint8List> buildBulletinPdf({
  required String ecoleNom, required String classeNom, required String eleveNom,
  required double generale, required Map<String,double> parMatiere,
  required int rang, required int total,
}) async {
  final doc = pw.Document();
  final matieres = parMatiere.keys.toList()..sort();
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(28),
    build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
      _pdfEntete(ecoleNom),
      pw.SizedBox(height: 10),
      pw.Text(eleveNom, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.Text('Classe : $classeNom', style: const pw.TextStyle(color: PdfColors.grey700)),
      pw.Text('Bulletin scolaire', style: const pw.TextStyle(color: PdfColors.grey700)),
      pw.SizedBox(height: 16),
      pw.TableHelper.fromTextArray(
        headers: ['Matiere', 'Moyenne /20'],
        data: matieres.map((m)=>[m, parMatiere[m]!.toStringAsFixed(2)]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
        cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      pw.SizedBox(height: 18),
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
            color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children:[
          pw.Text('Moyenne generale : ${generale.toStringAsFixed(2)}/20',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Rang : ${total > 0 ? '$rang / $total' : '-'}'),
          pw.Text('Mention : ${mentionDe(generale)}'),
        ])),
      pw.SizedBox(height: 14),
      pw.Text('Appreciation :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      pw.Text(appreciationDe(generale)),
      pw.Spacer(),
      pw.Text('Genere par Sentinel CI — Veiller, pas surveiller',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
    ]),
  ));
  return doc.save();
}

Future<Uint8List> buildClassePdf({
  required String ecoleNom, required String classeNom,
  required List<({String nom, double moy})> eleves,
}) async {
  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(28),
    build: (ctx) => [
      _pdfEntete(ecoleNom),
      pw.SizedBox(height: 10),
      pw.Text('Moyennes de la classe', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.Text('Classe : $classeNom', style: const pw.TextStyle(color: PdfColors.grey700)),
      pw.SizedBox(height: 14),
      pw.TableHelper.fromTextArray(
        headers: ['Rang', 'Eleve', 'Moyenne /20'],
        data: List.generate(eleves.length, (i)=>[
          '${i+1}', eleves[i].nom,
          eleves[i].moy > 0 ? eleves[i].moy.toStringAsFixed(2) : '-',
        ]),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
        cellAlignments: {0: pw.Alignment.center, 1: pw.Alignment.centerLeft, 2: pw.Alignment.centerRight},
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      pw.SizedBox(height: 16),
      pw.Text('Genere par Sentinel CI — Veiller, pas surveiller',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
    ],
  ));
  return doc.save();
}

// ══════════════════════════════════════════
//  SERVICE FIREBASE
// ══════════════════════════════════════════
class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  // Connexion
    static Future<UserCredential?> signIn(String email, String password) async {
      try {
        final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        return result;
      } on FirebaseAuthException catch (e) {
        print('CODE ERREUR AUTH: ${e.code}');
        print('MESSAGE: ${e.message}');
        return null;
      } catch (e) {
        print('ERREUR GENERALE CONNEXION: $e');
        return null;
      }
    }


  // Déconnexion
  static Future<void> signOut() async => await _auth.signOut();

  // Récupérer profil utilisateur
  static String? lastProfileError;

  static Future<Map<String,dynamic>?> getUserProfile(String uid, String email) async {
    lastProfileError = null;
    for (int essai = 1; essai <= 3; essai++) {
      try {
        // 1) Recherche par identifiant de document
        final doc = await _db.collection('utilisateurs').doc(uid)
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 10));
        if (doc.exists && doc.data() != null) {
          return doc.data();
        }
        // 2) Repli robuste : recherche par email (champ interne, sans piège)
        if (email.isNotEmpty) {
          final q = await _db.collection('utilisateurs')
              .where('email', isEqualTo: email)
              .limit(1)
              .get(const GetOptions(source: Source.server))
              .timeout(const Duration(seconds: 10));
          if (q.docs.isNotEmpty) {
            // On garde l'identifiant réel de la fiche (utile pour les élèves
            // dont le compte de connexion a un UID différent de leur fiche).
            final m = Map<String, dynamic>.from(q.docs.first.data() as Map);
            m['_docId'] = q.docs.first.id;
            return m;
          }
        }
        lastProfileError = 'Aucun document trouve (UID: $uid / email: $email)';
        print('getUserProfile essai $essai : aucun document');
      } catch (e) {
        lastProfileError = e.toString();
        print('getUserProfile essai $essai : echec ($e)');
      }
      await Future.delayed(const Duration(milliseconds: 800));
    }
    return null;
  }

  // Stream notes élève en temps réel
  static Stream<QuerySnapshot> streamNotes(String eleveId) =>
      _db.collection('notes')
          .where('eleveId', isEqualTo: eleveId)
          .orderBy('date', descending: true)
          .snapshots();

  // Ajouter une note
  static Future<void> ajouterNote(Map<String,dynamic> note) async {
    await _db.collection('notes').add({
      ...note,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Créer une alerte pour le parent
    final sur = (note['sur'] as num?)?.toInt() ?? 20;
    final noteVal = (note['note'] as num?)?.toDouble() ?? 0;
    await _db.collection('alertes').add({
      'titre': 'Nouvelle note — ${note['matiere']}',
      'corps': '${note['note']}/$sur en ${note['type']}',
      'type': noteVal >= sur / 2 ? 'success' : 'danger',
      'eleveId': note['eleveId'],
      'ecoleId': note['ecoleId'],
      'lu': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream devoirs
  static Stream<QuerySnapshot> streamDevoirs(String ecoleId, String classe) =>
      _db.collection('devoirs')
          .where('ecoleId', isEqualTo: ecoleId)
          .where('classe', isEqualTo: classe)
          .orderBy('createdAt', descending: true)
          .snapshots();

  // Devoirs d'une classe précise (1 seul filtre => pas d'index requis ; tri côté app)
  static Stream<QuerySnapshot> streamDevoirsParClasse(String classeId) =>
      _db.collection('devoirs')
          .where('classeId', isEqualTo: classeId)
          .snapshots();

  // Récupère la classe d'un élève (pour le parent : la classe de son enfant)
  static Future<String?> getClasseIdEleve(String eleveUid) async {
    try {
      final d = await _db.collection('utilisateurs').doc(eleveUid).get();
      if (d.exists) return (d.data()?['classeId'] as String?);
    } catch (_) {}
    return null;
  }

  // ---- ABSENCES / PRÉSENCES ----
  // Enregistre une absence ou un retard (présent = pas d'enregistrement)
  static Future<void> ajouterAbsence(Map<String,dynamic> abs) async {
    // Un seul enregistrement par élève et par date : on utilise un identifiant
    // déterministe, donc re-signaler le même jour REMPLACE (pas de doublon).
    final eleveId = (abs['eleveId'] ?? '').toString();
    final date = (abs['date'] ?? '').toString();
    final id = '${eleveId}_$date'.replaceAll(RegExp(r'[\/\s]'), '_');
    await _db.collection('absences').doc(id).set({
      ...abs,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Absences d'un élève (1 filtre => pas d'index ; tri côté app)
  static Stream<QuerySnapshot> streamAbsencesEleve(String eleveId) =>
      _db.collection('absences')
          .where('eleveId', isEqualTo: eleveId)
          .snapshots();

  // Absences/retards d'une classe (pour le tableau de bord du prof)
  static Stream<QuerySnapshot> streamAbsencesClasse(String classeId) =>
      _db.collection('absences')
          .where('classeId', isEqualTo: classeId)
          .snapshots();

  // ---- NOTES MANQUANTES : décision (absence justifiée / rattrapage) ----
  // Un seul enregistrement par élève et par matière (id déterministe => pas de doublon).
  static Future<void> enregistrerRattrapage(Map<String,dynamic> data) async {
    final id = '${data['eleveId']}_${data['matiere']}'
        .replaceAll(RegExp(r'[\/\s]'), '_');
    await _db.collection('rattrapages').doc(id).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Décisions notes manquantes d'une classe (1 filtre => pas d'index)
  static Stream<QuerySnapshot> streamRattrapagesClasse(String classeId) =>
      _db.collection('rattrapages')
          .where('classeId', isEqualTo: classeId)
          .snapshots();

  // Récupère une fois toutes les notes d'un élève (pour le prof principal)
  static Future<QuerySnapshot> getNotesEleve(String eleveId) =>
      _db.collection('notes').where('eleveId', isEqualTo: eleveId).get();

  // Récupère une fois les élèves d'une école (pour le rang dans le bulletin)
  static Future<QuerySnapshot> getElevesEcole(String ecoleId) =>
      _db.collection('utilisateurs')
          .where('role', isEqualTo: 'eleve')
          .where('ecoleId', isEqualTo: ecoleId)
          .get();

  // Publier devoir
  static Future<void> publierDevoir(Map<String,dynamic> devoir) async {
    await _db.collection('devoirs').add({
      ...devoir,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('alertes').add({
      'titre': 'Nouveau devoir — ${devoir['matiere']}',
      'corps': '${devoir['titre']} — à rendre le ${devoir['date']}',
      'type': 'info',
      'ecoleId': devoir['ecoleId'],
      'classe': devoir['classe'],
      'lu': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream alertes
  static Stream<QuerySnapshot> streamAlertes(String eleveId) =>
      _db.collection('alertes')
          .where('eleveId', isEqualTo: eleveId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots();

  // Stream messages
  static Stream<QuerySnapshot> streamMessages(String userId) =>
      _db.collection('messages')
          .where('vers', isEqualTo: userId)
          .orderBy('createdAt', descending: false)
          .snapshots();

  // Envoyer message
  static Future<void> envoyerMessage(Map<String,dynamic> msg) async {
    await _db.collection('messages').add({
      ...msg,
      'lu': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Identifiant unique d'une conversation entre 2 personnes (ordre stable)
  static String convId(String a, String b) {
    final p = [a, b]..sort();
    return '${p[0]}__${p[1]}';
  }

  // Fil d'une conversation — 1 filtre (conversationId), tri côté client, pas d'index
  static Stream<QuerySnapshot> streamConversation(String conversationId) =>
      _db.collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .snapshots();

  // Tous les messages reçus par un utilisateur (pour les badges non lus) — 1 filtre
  static Stream<QuerySnapshot> streamMessagesRecus(String userId) =>
      _db.collection('messages')
          .where('vers', isEqualTo: userId)
          .snapshots();

  // Marque comme lus les messages d'une conversation reçus par moi
  static Future<void> marquerConversationLue(String conversationId, String monUid) async {
    final snap = await _db.collection('messages')
        .where('conversationId', isEqualTo: conversationId).get();
    final batch = _db.batch();
    var nb = 0;
    for (final d in snap.docs) {
      final m = d.data();
      if (m['vers'] == monUid && m['lu'] != true) { batch.update(d.reference, {'lu': true}); nb++; }
    }
    if (nb > 0) await batch.commit();
  }

  // Statistiques pour les tableaux de bord (plateforme si ecoleId == null, sinon une école)
  // Nouveau modèle : le revenu = somme des forfaits mensuels des écoles.
  static Future<({int ecoles, int eleves, int abonnes, int encaisse, int impayes, int total})>
      statsGlobales({String? ecoleId}) async {
    Query<Map<String,dynamic>> usersQ = _db.collection('utilisateurs');
    if (ecoleId != null) usersQ = usersQ.where('ecoleId', isEqualTo: ecoleId);
    final usersSnap = await usersQ.get();
    final eleves = usersSnap.docs.where((d)=> (d.data())['role']=='eleve').length;

    int ecoles, encaisse;
    if (ecoleId == null) {
      // Plateforme : additionne le forfait de chaque école.
      final ecolesSnap = await _db.collection('ecoles').get();
      ecoles = ecolesSnap.docs.length;
      encaisse = 0;
      for (final e in ecolesSnap.docs) {
        final data = e.data();
        final auto = usersSnap.docs.where((d)=>
            d.data()['ecoleId']==e.id && d.data()['role']=='eleve').length;
        final nb = (data['elevesFactures'] is num)
            ? (data['elevesFactures'] as num).toInt() : auto;
        encaisse += forfaitMensuelEcole(nb);
      }
    } else {
      // Une école : son propre forfait.
      ecoles = 1;
      final ecoleDoc = await _db.collection('ecoles').doc(ecoleId).get();
      final data = ecoleDoc.data();
      final over = (data != null && data['elevesFactures'] is num)
          ? (data['elevesFactures'] as num).toInt() : null;
      encaisse = forfaitMensuelEcole(over ?? eleves);
    }
    return (ecoles: ecoles, eleves: eleves, abonnes: eleves,
        encaisse: encaisse, impayes: 0, total: ecoles);
  }

  // Stream lecons
  static Stream<QuerySnapshot> streamLecons(String ecoleId, String classe) =>
      _db.collection('lecons')
          .where('ecoleId', isEqualTo: ecoleId)
          .where('classe', isEqualTo: classe)
          .snapshots();

  // Mettre à jour lecon
  static Future<void> updateLecon(String docId, Map<String,dynamic> data) async {
    await _db.collection('lecons').doc(docId).update({
      ...data,
      'dateMAJ': FieldValue.serverTimestamp(),
    });
  }

  // Progression d'une classe (toutes matières) — 1 filtre, pas d'index
  static Stream<QuerySnapshot> streamLeconsParClasse(String classeId) =>
      _db.collection('lecons').where('classeId', isEqualTo: classeId).snapshots();

  // Enregistre / met à jour la progression d'une matière pour une classe (upsert)
  static Future<void> setLecon(String classeId, String matiere,
      {required String chapitre, required double avancement, String? ecoleId}) {
    final id = '${classeId}__${matiere.replaceAll(RegExp(r'[^A-Za-z0-9]'), '')}';
    return _db.collection('lecons').doc(id).set({
      'classeId': classeId,
      'matiere': matiere,
      'chapitre': chapitre,
      'avancement': avancement,
      if (ecoleId != null) 'ecoleId': ecoleId,
      'dateMAJ': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Stream écoles (admin)
  static Stream<QuerySnapshot> streamEcoles() =>
      _db.collection('ecoles').orderBy('nom').snapshots();

  // Ajouter école
  static Future<void> ajouterEcole(Map<String,dynamic> ecole) async {
    await _db.collection('ecoles').add({
      ...ecole,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ---- Facturation école (forfait selon nb d'élèves) ----
  // Nombre réel d'élèves d'une école (comptage auto, 1 filtre => pas d'index).
  static Future<int> compterEleves(String ecoleId) async {
    final snap = await _db.collection('utilisateurs')
        .where('ecoleId', isEqualTo: ecoleId).get();
    return snap.docs.where((d)=> (d.data())['role'] == 'eleve').length;
  }

  static Future<DocumentSnapshot> getEcole(String ecoleId) =>
      _db.collection('ecoles').doc(ecoleId).get();

  // Enregistre un nombre d'élèves facturés corrigé à la main (null = revenir à l'auto).
  static Future<void> setElevesFactures(String ecoleId, int? nb) =>
      _db.collection('ecoles').doc(ecoleId)
          .set({'elevesFactures': nb}, SetOptions(merge: true));

  // Forfait mensuel de chaque école (pour la page Revenus du super admin).
  static Future<List<({String id, String nom, int nb, bool corrige, int prix, int total})>>
      forfaitsParEcole() async {
    final ecolesSnap = await _db.collection('ecoles').get();
    final usersSnap  = await _db.collection('utilisateurs').get();
    final res = <({String id, String nom, int nb, bool corrige, int prix, int total})>[];
    for (final e in ecolesSnap.docs) {
      final data = e.data();
      final auto = usersSnap.docs.where((d)=>
          d.data()['ecoleId']==e.id && d.data()['role']=='eleve').length;
      final over = (data['elevesFactures'] is num) ? (data['elevesFactures'] as num).toInt() : null;
      final nb = over ?? auto;
      res.add((id: e.id, nom: (data['nom'] ?? e.id).toString(), nb: nb,
          corrige: over != null, prix: prixParEleve(nb), total: forfaitMensuelEcole(nb)));
    }
    res.sort((a,b)=> b.total.compareTo(a.total));
    return res;
  }

  // Stream paiements
  static Stream<QuerySnapshot> streamPaiements() =>
      _db.collection('paiements')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots();

  // ---- SUIVI DES PAIEMENTS DES ECOLES ----
  // Enregistre un paiement de forfait : numéro de reçu séquentiel (REC-ANNEE-0001)
  // via un compteur transactionnel, puis fiche paiement (1 par école et par mois).
  static Future<String> enregistrerPaiement({
    required String ecoleId, required String ecoleNom,
    required String mois, required String moisLabel,
    required int montant, required String methode,
    required String reference, required String saisiPar,
  }) async {
    final annee = mois.substring(0, 4);
    final compteurRef = _db.collection('compteurs').doc('recus_$annee');
    final payRef = _db.collection('paiements').doc('${ecoleId}_$mois');
    final numero = await _db.runTransaction<String>((tx) async {
      final c = await tx.get(compteurRef);
      final n = ((c.data()?['n'] as num?) ?? 0).toInt() + 1;
      final numeroRecu = 'REC-$annee-${n.toString().padLeft(4, '0')}';
      tx.set(compteurRef, {'n': n});
      final now = DateTime.now();
      tx.set(payRef, {
        'ecoleId': ecoleId, 'ecoleNom': ecoleNom,
        'mois': mois, 'moisLabel': moisLabel,
        'montant': montant, 'methode': methode, 'reference': reference,
        'numeroRecu': numeroRecu, 'saisiPar': saisiPar,
        'dateStr': '${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return numeroRecu;
    });
    return numero;
  }

  // Historique des paiements d'une école (1 filtre => pas d'index ; tri côté app).
  static Future<List<Map<String,dynamic>>> paiementsEcole(String ecoleId) async {
    final snap = await _db.collection('paiements')
        .where('ecoleId', isEqualTo: ecoleId).get();
    final l = snap.docs.map((d) => d.data()).toList()
      ..sort((a,b) => (b['mois'] ?? '').toString().compareTo((a['mois'] ?? '').toString()));
    return l;
  }

  // Paiements d'un mois donné, indexés par école (badges Payé / En attente).
  static Future<Map<String, Map<String,dynamic>>> paiementsDuMois(String mois) async {
    final snap = await _db.collection('paiements')
        .where('mois', isEqualTo: mois).get();
    return { for (final d in snap.docs) (d.data()['ecoleId'] ?? '').toString(): d.data() };
  }

  // Stream agenda (1 filtre => pas d'index ; tri côté app)
  static Stream<QuerySnapshot> streamAgenda(String ecoleId) =>
      _db.collection('agenda')
          .where('ecoleId', isEqualTo: ecoleId)
          .snapshots();

  // Ajouter événement agenda
  static Future<void> ajouterEvenement(Map<String,dynamic> evt) async {
    await _db.collection('agenda').add({
      ...evt,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> supprimerEvenement(String id) =>
      _db.collection('agenda').doc(id).delete();

  // Stream emploi du temps
  static Stream<QuerySnapshot> streamEmploiDuTemps(String ecoleId, String classe) =>
      _db.collection('emploiDuTemps')
          .where('ecoleId', isEqualTo: ecoleId)
          .where('classe', isEqualTo: classe)
          .snapshots();

  // Emploi du temps d'une classe (1 filtre => pas d'index ; tri côté app)
  static Stream<QuerySnapshot> streamEmploiDuTempsParClasse(String classeId) =>
      _db.collection('emploiDuTemps')
          .where('classeId', isEqualTo: classeId)
          .snapshots();

  static Future<void> ajouterCreneau(Map<String,dynamic> data) =>
      _db.collection('emploiDuTemps').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });

  static Future<void> supprimerCreneau(String id) =>
      _db.collection('emploiDuTemps').doc(id).delete();

  // Stream utilisateurs (admin)
  static Stream<QuerySnapshot> streamUtilisateurs() =>
      _db.collection('utilisateurs').orderBy('nom').snapshots();

  // Toutes les écoles, sans tri (robuste : inclut meme les fiches sans 'nom')
  static Stream<QuerySnapshot> streamToutesEcoles() =>
      _db.collection('ecoles').snapshots();

  // Utilisateurs d'une école précise (pour le directeur) — pas de tri => pas d'index requis
  static Stream<QuerySnapshot> streamUtilisateursParEcole(String ecoleId) =>
      _db.collection('utilisateurs')
          .where('ecoleId', isEqualTo: ecoleId)
          .snapshots();

  // Stream des élèves d'une école (pour la saisie de notes)
  static Stream<QuerySnapshot> streamEleves(String ecoleId) =>
      _db.collection('utilisateurs')
          .where('role', isEqualTo: 'eleve')
          .where('ecoleId', isEqualTo: ecoleId)
          .snapshots();

  // Stream des classes d'une école (pour le formulaire d'ajout d'élève)
  static Stream<QuerySnapshot> streamClasses(String ecoleId) =>
      _db.collection('classes')
          .where('ecoleId', isEqualTo: ecoleId)
          .snapshots();

  // Crée une classe (écrite par l'app => collection propre)
  static Future<void> creerClasse(Map<String, dynamic> data) =>
      _db.collection('classes').add(data);

  // Matières d'une école (1 filtre => pas d'index)
  static Stream<QuerySnapshot> streamMatieres(String ecoleId) =>
      _db.collection('matieres')
          .where('ecoleId', isEqualTo: ecoleId)
          .snapshots();

  static Future<void> creerMatiere(Map<String, dynamic> data) =>
      _db.collection('matieres').add(data);

  // Crée un compte (eleve, prof ou parent) : connexion + fiche, SANS déconnecter l'admin.
  // 'champs' contient role, ecoleId et les champs propres au rôle.
  // Retourne null si succès, ou un message d'erreur lisible sinon.
  // Trouve un élève par son code (auto-inscription parent) — 1 filtre, pas d'index
  static Future<QuerySnapshot> findEleveParCode(String code) =>
      _db.collection('utilisateurs')
          .where('codeParent', isEqualTo: code.trim().toUpperCase())
          .get();

  // Liste les enfants d'un parent (nom + classe), pour le multi-enfants
  static Future<List<({String id, String nom, String? classeId})>> getEnfants(String parentId) async {
    final parent = await _db.collection('utilisateurs').doc(parentId).get();
    final data = parent.data();
    final ids = (data?['enfants'] is List)
        ? List<String>.from((data!['enfants'] as List).map((e) => e.toString()))
        : <String>[];
    final out = <({String id, String nom, String? classeId})>[];
    for (final id in ids) {
      final d = await _db.collection('utilisateurs').doc(id).get();
      if (d.exists) {
        final m = d.data()!;
        out.add((id: id, nom: (m['nom'] ?? 'Enfant').toString(), classeId: m['classeId'] as String?));
      }
    }
    return out;
  }

  // Rattache un enfant supplémentaire au compte parent (sans doublon)
  static Future<void> ajouterEnfant(String parentId, String childId) =>
      _db.collection('utilisateurs').doc(parentId).update({
        'enfants': FieldValue.arrayUnion([childId]),
      });

  // Auto-inscription d'un parent (il devient connecté) rattaché à son enfant
  static Future<String?> inscrireParent({
    required String nom, required String email, required String motDePasse,
    required String code, String lien = 'parent',
  }) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(), password: motDePasse.trim());
      // Maintenant connecté : on peut chercher l'enfant par son code
      final snap = await findEleveParCode(code);
      final eleves = snap.docs.where((d) => (d.data() as Map)['role'] == 'eleve').toList();
      if (eleves.isEmpty) {
        await cred.user?.delete();
        return 'Code introuvable. Verifiez aupres de l ecole.';
      }
      final e = eleves.first;
      final data = e.data() as Map<String, dynamic>;
      await _db.collection('utilisateurs').doc(cred.user!.uid).set({
        'nom': nom.trim(), 'email': email.trim(), 'role': 'parent',
        'ecoleId': data['ecoleId'], 'enfants': [e.id], 'lien': lien,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Cet email est deja utilise.';
      if (e.code == 'weak-password') return 'Mot de passe trop faible (6 caracteres min).';
      if (e.code == 'invalid-email') return 'Adresse email invalide.';
      return 'Erreur : ${e.code}';
    } catch (e) {
      return 'Erreur : $e';
    }
  }

  // Auto-inscription d'un élève : crée son compte (il devient connecté) puis le
  // relie à sa fiche existante via son code. Fiche, notes et code restent intacts.
  static Future<String?> inscrireEleve({
    required String code, required String email, required String motDePasse,
  }) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(), password: motDePasse.trim());
      final snap = await findEleveParCode(code);
      final eleves = snap.docs.where((d) => (d.data() as Map)['role'] == 'eleve').toList();
      if (eleves.isEmpty) {
        await cred.user?.delete();
        return 'Code introuvable. Verifiez aupres de ton ecole.';
      }
      final e = eleves.first;
      final data = e.data() as Map<String, dynamic>;
      if ((data['email'] ?? '').toString().trim().isNotEmpty) {
        await cred.user?.delete();
        return 'Cet eleve a deja un compte. Utilise "Mot de passe oublie".';
      }
      await _db.collection('utilisateurs').doc(e.id).update({'email': email.trim()});
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Cet email est deja utilise.';
      if (e.code == 'weak-password') return 'Mot de passe trop faible (6 caracteres min).';
      if (e.code == 'invalid-email') return 'Adresse email invalide.';
      return 'Erreur : ${e.code}';
    } catch (e) {
      return 'Erreur : $e';
    }
  }

  // Réinitialisation du mot de passe par e-mail (lien envoyé par Firebase)
  static Future<String?> reinitialiserMotDePasse(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') return 'Adresse e-mail invalide.';
      if (e.code == 'user-not-found') return 'Aucun compte avec cet e-mail.';
      return 'Erreur : ${e.code}';
    } catch (e) {
      return 'Erreur : $e';
    }
  }

  static Future<String?> creerCompte({
    required String nom,
    required String email,
    required String motDePasse,
    required Map<String, dynamic> champs,
  }) async {
    FirebaseApp? appSecondaire;
    try {
      // Session secondaire isolée : crée le compte sans toucher à celle de l'admin
      appSecondaire = await Firebase.initializeApp(
        name: 'createur_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final cred = await FirebaseAuth.instanceFor(app: appSecondaire)
          .createUserWithEmailAndPassword(
              email: email.trim(), password: motDePasse.trim());
      final uid = cred.user!.uid;
      // Fiche écrite par l'app => collection 'utilisateurs' propre, garantie
      final fiche = <String, dynamic>{
        'nom': nom.trim(),
        'email': email.trim(),
        ...champs,
      };
      // Un élève reçoit un code unique que l'école communique à sa famille
      if (champs['role'] == 'eleve' && champs['codeParent'] == null) {
        fiche['codeParent'] = uid.substring(0, 6).toUpperCase();
      }
      await _db.collection('utilisateurs').doc(uid).set(fiche);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Cet email est deja utilise.';
      if (e.code == 'weak-password') return 'Mot de passe trop faible (6 caracteres min).';
      if (e.code == 'invalid-email') return 'Adresse email invalide.';
      return 'Erreur : ${e.code}';
    } catch (e) {
      return 'Erreur : $e';
    } finally {
      await appSecondaire?.delete();
    }
  }

  // Renvoie le NOM du prof déjà principal d'une classe (ou null). 1 filtre => pas d'index.
  static Future<String?> profPrincipalDe(String ecoleId, String classeId) async {
    final snap = await _db.collection('utilisateurs')
        .where('ecoleId', isEqualTo: ecoleId).get();
    for (final d in snap.docs) {
      final m = d.data();
      if (m['role']=='prof' && m['estPrincipal']==true && m['classePrincipale']==classeId) {
        return (m['nom'] ?? 'Un professeur').toString();
      }
    }
    return null;
  }

  // Bloquer / débloquer un compte (réservé au super admin)
  static Future<void> bloquerUtilisateur(String userDocId, bool bloque) =>
      _db.collection('utilisateurs').doc(userDocId).update({'bloque': bloque});

  // Supprimer la fiche d'un compte (réservé au super admin)
  static Future<void> supprimerUtilisateur(String userDocId) =>
      _db.collection('utilisateurs').doc(userDocId).delete();

  // ---------- ESPACE VIE SCOLAIRE (blog photos) ----------
  // Envoie une photo dans Firebase Storage et renvoie son URL de téléchargement.
  static Future<String> uploadPhotoVieScolaire(String ecoleId, Uint8List bytes, String nom) async {
    final chemin = 'vieScolaire/$ecoleId/${DateTime.now().millisecondsSinceEpoch}_$nom';
    final ref = FirebaseStorage.instance.ref(chemin);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  static Future<void> publierArticleVieScolaire(Map<String,dynamic> data) async {
    await _db.collection('vieScolaire').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Articles d'une école (1 filtre => pas d'index ; tri côté app)
  static Stream<QuerySnapshot> streamVieScolaireEcole(String ecoleId) =>
      _db.collection('vieScolaire').where('ecoleId', isEqualTo: ecoleId).snapshots();

  // Tous les articles (pour le super admin qui voit toutes les écoles)
  static Stream<QuerySnapshot> streamVieScolaireTout() =>
      _db.collection('vieScolaire').snapshots();

  static Future<void> supprimerArticleVieScolaire(String id) =>
      _db.collection('vieScolaire').doc(id).delete();
  // chacune avec un code parent automatique. Renvoie le nombre créé.
  static Future<int> importerEleves({
    required String ecoleId,
    required String classeId,
    required List<String> noms,
  }) async {
    final propres = noms.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    int total = 0;
    for (var i = 0; i < propres.length; i += 400) {
      final fin = (i + 400) < propres.length ? (i + 400) : propres.length;
      final lot = propres.sublist(i, fin);
      final batch = _db.batch();
      for (final nom in lot) {
        final ref = _db.collection('utilisateurs').doc();
        batch.set(ref, {
          'nom': nom,
          'email': '',
          'role': 'eleve',
          'ecoleId': ecoleId,
          'classeId': classeId,
          'codeParent': ref.id.substring(0, 6).toUpperCase(),
          'importe': true,
        });
        total++;
      }
      await batch.commit();
    }
    return total;
  }

  // Donne un accès de connexion à un élève importé : crée un compte (e-mail +
  // mot de passe) et le relie à la fiche existante via l'e-mail (repli de
  // getUserProfile). La fiche, ses notes et son code parent restent intacts.
  static Future<String?> creerAccesEleve({
    required String eleveDocId,
    required String email,
    required String motDePasse,
  }) async {
    FirebaseApp? appSec;
    try {
      // Refuse si l'élève a déjà un compte (évite les doublons)
      final fiche = await _db.collection('utilisateurs').doc(eleveDocId).get();
      if ((fiche.data()?['email'] ?? '').toString().trim().isNotEmpty) {
        return 'Cet eleve a deja un compte.';
      }
      appSec = await Firebase.initializeApp(
        name: 'acces_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      await FirebaseAuth.instanceFor(app: appSec)
          .createUserWithEmailAndPassword(
              email: email.trim(), password: motDePasse.trim());
      await _db.collection('utilisateurs').doc(eleveDocId)
          .update({'email': email.trim()});
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return 'Cet email est deja utilise.';
      if (e.code == 'weak-password') return 'Mot de passe trop faible (6 caracteres min).';
      if (e.code == 'invalid-email') return 'Adresse email invalide.';
      return 'Erreur : ${e.code}';
    } catch (e) {
      return 'Erreur : $e';
    } finally {
      await appSec?.delete();
    }
  }
}

// Construit l'AppUser à partir d'un profil Firestore (connexion ET inscription).
Future<AppUser> construireAppUser(Map<String,dynamic> profile, String uid, String email) async {
  String? childId;
  int enfantsCount = 1;
  final enfants = profile['enfants'];
  if (enfants is List && enfants.isNotEmpty) {
    childId = enfants.first.toString();
    enfantsCount = enfants.length;
  }
  String? classeId = profile['classeId'] as String?;
  if (classeId == null && childId != null) {
    classeId = await FirebaseService.getClasseIdEleve(childId);
  }
  final String? matiere = profile['matiere'] as String?;
  final List<String> classes = (profile['classes'] is List)
      ? List<String>.from((profile['classes'] as List).map((e) => e.toString()))
      : <String>[];
  return AppUser(
    name: profile['nom'] ?? 'Utilisateur',
    initials: (profile['nom'] ?? 'U').toString().substring(0,1).toUpperCase() + 'A',
    email: email,
    school: profile['ecoleId'] ?? 'sentinel_ci',
    role: roleFromString(profile['role']),
    uid: (profile['_docId'] as String?) ?? uid,
    childId: childId,
    classeId: classeId,
    matiere: matiere,
    classes: classes,
    estPrincipal: profile['estPrincipal'] == true,
    classePrincipale: profile['classePrincipale'] as String?,
    enfantsCount: enfantsCount,
    lien: profile['lien'] as String?,
    coAdmin: profile['coAdmin'] == true,
  );
}

// Calcule la liste des contacts autorisés selon les règles de messagerie.
List<({String uid, String nom, UserRole role, String? matiere})> contactsMessagerie(
    AppUser me, List<QueryDocumentSnapshot> docs) {
  Map<String,dynamic> dataOf(QueryDocumentSnapshot d) => d.data() as Map<String,dynamic>;
  UserRole roleOf(Map m) => roleFromString(m['role']);
  final out = <({String uid, String nom, UserRole role, String? matiere})>[];
  void add(QueryDocumentSnapshot d) {
    final m = dataOf(d);
    out.add((uid: d.id, nom: (m['nom'] ?? 'Utilisateur').toString(),
        role: roleOf(m), matiere: m['matiere'] as String?));
  }

  switch (me.role) {
    case UserRole.eleve:
      // Camarades de sa classe + son/ses parent(s)
      for (final d in docs) {
        if (d.id == me.uid) continue;
        final m = dataOf(d); final r = roleOf(m);
        if (r == UserRole.eleve && m['classeId'] == me.classeId) add(d);
        else if (r == UserRole.parent && m['enfants'] is List &&
            (m['enfants'] as List).contains(me.uid)) add(d);
      }
      break;
    case UserRole.parent:
      // Son enfant + les profs de la classe de l'enfant
      for (final d in docs) {
        final m = dataOf(d); final r = roleOf(m);
        if (d.id == me.childId) add(d);
        else if (r == UserRole.prof && m['classes'] is List &&
            (m['classes'] as List).contains(me.classeId)) add(d);
      }
      break;
    case UserRole.prof:
      // Élèves des classes du prof -> leurs parents + le directeur
      final studentIds = <String>{};
      for (final d in docs) {
        final m = dataOf(d);
        if (roleOf(m) == UserRole.eleve && me.classes.contains(m['classeId'])) {
          studentIds.add(d.id);
        }
      }
      for (final d in docs) {
        final m = dataOf(d); final r = roleOf(m);
        if (r == UserRole.directeur) add(d);
        else if (r == UserRole.parent && m['enfants'] is List &&
            (m['enfants'] as List).any((e) => studentIds.contains(e))) add(d);
      }
      break;
    case UserRole.directeur:
    case UserRole.admin:
      for (final d in docs) {
        final r = roleOf(dataOf(d));
        if (r == UserRole.prof || r == UserRole.parent) add(d);
      }
      break;
  }
  out.sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
  return out;
}

// ══════════════════════════════════════════
//  APP
// ══════════════════════════════════════════
const String kPolitiqueTxt = r'''
Sentinel CI
POLITIQUE DE CONFIDENTIALITÉ
Préambule

Chez Sentinel nous considérons que la protection des données personnelles constitue un engagement fondamental.

Notre mission est d'accompagner les établissements scolaires, les enseignants, les parents et les élèves dans un environnement numérique fondé sur la confiance.

Parce que Sentinel traite principalement des informations relatives à des élèves, dont une grande partie sont mineurs, nous appliquons des principes exigeants de confidentialité, de sécurité et de transparence.

Notre philosophie reste la même :

Veiller, pas surveiller

Article 1 – Objet de la présente politique

La présente Politique de confidentialité explique :

quelles données sont collectées ;
pourquoi elles sont collectées ;
comment elles sont utilisées ;
qui peut y accéder ;
comment elles sont protégées ;
quels sont les droits des utilisateurs concernant leurs données.

Article 2 – Les données que nous collectons

Selon les services utilisés par l'établissement, Sentinel peut traiter les catégories de données suivantes :

A. Informations relatives à l'élève

nom et prénom ;
identifiant scolaire ;
classe ;
niveau d'études ;
photographie (si l'établissement choisit de l'utiliser) ;
date de naissance (si nécessaire au fonctionnement du service).

B. Informations relatives aux parents ou représentants légaux

nom et prénom ;
numéro de téléphone ;
adresse électronique ;
lien avec l'élève ;
préférences de communication.

C. Informations pédagogiques

notes ;
appréciations ;
bulletins ;
progression scolaire ;
compétences évaluées ;
devoirs ;
travaux remis.

D. Vie scolaire

absences ;
retards ;
sanctions disciplinaires ;
récompenses ;
observations éducatives.

E. Informations techniques

Lors de l'utilisation de Sentinel, certaines informations techniques peuvent être enregistrées afin d'assurer la sécurité et le bon fonctionnement du service, telles que :

date et heure de connexion ;
type d'appareil ;
système d'exploitation ;
version de l'application ;
adresse IP ou identifiant technique de connexion lorsque cela est nécessaire pour la sécurité.

Article 3 – Pourquoi utilisons-nous ces données ?

Les données sont utilisées exclusivement afin de :

assurer le suivi pédagogique des élèves ;
faciliter la communication entre les familles et l'établissement ;
produire les bulletins et relevés scolaires ;
envoyer des notifications importantes ;
améliorer les fonctionnalités de Sentinel ;
assurer la sécurité des comptes ;
respecter les obligations légales applicables.

Sentinel n'utilise pas les données des élèves pour des campagnes publicitaires.

Article 4 – Notre engagement

Sentinel s'engage à :

ne jamais vendre les données personnelles ;
ne jamais louer les données personnelles ;
ne jamais céder les données à des fins commerciales sans base légale appropriée ou consentement lorsque celui-ci est requis ;
limiter strictement l'accès aux personnes autorisées.

Article 5 – Qui peut consulter les données ?

L'accès est limité selon le rôle de chaque utilisateur.

Les parents

Accèdent uniquement aux informations concernant leur(s) enfant(s).

Les enseignants

Accèdent uniquement aux élèves des classes dont ils ont la responsabilité.

Les responsables d'établissement

Accèdent uniquement aux informations relevant de leur établissement.

Les administrateurs techniques de Sentinel

Ils n'accèdent aux données que lorsque cela est nécessaire pour :

assurer la maintenance ;
résoudre un incident technique ;
sécuriser la plateforme ;

et uniquement selon des procédures internes encadrées.

Article 6 – Sécurité des données

Sentinel met en œuvre des mesures de sécurité adaptées afin de protéger les informations contre :

les accès non autorisés ;
la perte de données ;
les modifications frauduleuses ;
les destructions accidentelles.

Ces mesures peuvent notamment inclure :

le chiffrement des communications ;
le stockage sécurisé des informations ;
l'authentification des utilisateurs ;
des sauvegardes régulières ;
la journalisation des actions importantes ;
des mises à jour de sécurité régulières.

Aucun système informatique n'étant infaillible, Sentinel s'engage à améliorer en permanence son niveau de sécurité et à réagir rapidement en cas d'incident.

Article 7 – Durée de conservation

Les données personnelles sont conservées uniquement pendant la durée nécessaire aux finalités pour lesquelles elles ont été collectées, ou conformément aux obligations légales et aux besoins de l'établissement.

À l'issue de cette période, elles sont supprimées, anonymisées ou archivées lorsque la réglementation l'exige.

Article 8 – Intelligence artificielle

Certaines fonctionnalités utilisent une intelligence artificielle afin d'aider les élèves dans leurs apprentissages.

Cette intelligence artificielle :

n'attribue jamais les notes officielles ;
ne prend aucune décision disciplinaire ;
ne remplace pas les enseignants ;
ne se substitue pas aux décisions de l'établissement.

Elle constitue un outil d'accompagnement pédagogique.

---

Article 9 – Vos droits

Les parents, représentants légaux et autres utilisateurs disposent, selon la réglementation applicable, de droits concernant leurs données personnelles.

Ils peuvent notamment demander :

* l'accès aux données les concernant ;
* la rectification de données inexactes ;
* la suppression de certaines données lorsque cela est possible ;
* la limitation de certains traitements ;
* des informations sur l'utilisation de leurs données.

Les demandes peuvent être adressées à Sentinel ou à l'établissement concerné selon leur nature.

Article 10 – Gestion des incidents de sécurité

En cas d'incident de sécurité susceptible d'affecter les données personnelles, Sentinel s'engage à :

analyser rapidement la situation ;
mettre en œuvre les mesures correctives nécessaires ;
informer les établissements concernés lorsque cela est requis ;
coopérer avec les autorités compétentes conformément à la réglementation applicable.

Article 11 – Cookies et technologies similaires

Lorsque Sentinel est utilisé via un navigateur internet, des cookies ou technologies similaires peuvent être utilisés pour :

maintenir la connexion de l'utilisateur ;
améliorer l'expérience d'utilisation ;
assurer la sécurité du service.

Les utilisateurs peuvent gérer leurs préférences conformément aux paramètres proposés par la plateforme.

Article 12 – Évolution de la présente politique

La présente Politique de confidentialité peut être modifiée afin de tenir compte :

des évolutions de Sentinel ;
des évolutions législatives ;
des nouvelles exigences de sécurité.

Les utilisateurs seront informés des modifications importantes.

Article 13 – Contact

Pour toute question relative à la protection des données personnelles, les utilisateurs peuvent contacter l'équipe Sentinel par les coordonnées indiquées dans l'application ou sur le site officiel.

Notre engagement envers les familles

Chaque note, chaque appréciation, chaque absence, chaque progrès représente une partie du parcours d'un enfant.
Ces informations méritent le plus grand respect.
Chez Sentinel, nous ne considérons jamais les données scolaires comme de simples données informatiques.
Nous les considérons comme une responsabilité.
Notre priorité est de protéger la confiance que les familles, les enseignants et les établissements nous accordent chaque jour.

Sentinel CI - Veiller, pas surveiller.
''';

const String kCguTxt = r'''
Sentinel CI
CONDITIONS GÉNÉRALES D'UTILISATION (CGU)
Préambule

Bienvenue sur Sentinel,

Sentinel est une plateforme numérique dédiée au suivi scolaire et à l'accompagnement des élèves, des familles, des enseignants et des établissements scolaires.

Notre mission est simple :

« Veiller, pas surveiller »

Nous croyons qu'un meilleur suivi favorise la réussite scolaire lorsqu'il est fondé sur la confiance, la bienveillance et la collaboration entre tous les acteurs de l'éducation.

Les présentes Conditions Générales d'Utilisation définissent les règles applicables à l'utilisation de la plateforme Sentinel. Toute utilisation de Sentinel implique l'acceptation des présentes conditions.

Article 1 – Objet

Les présentes Conditions Générales d'Utilisation ont pour objet de définir les conditions dans lesquelles Sentinel met à disposition ses services numériques de suivi scolaire.

Ces services peuvent notamment comprendre :

le suivi des résultats scolaires ;
le suivi des absences et retards ;
le suivi du comportement scolaire ;
la communication entre l'établissement, les enseignants et les familles ;
la consultation des emplois du temps ;
les notifications et alertes ;
les outils pédagogiques et d'accompagnement ;
Les fonctionnalités reposant sur l'intelligence artificielle destinées à soutenir les apprentissages.

Article 2 – Définitions

Aux fins des présentes Conditions :

Sentinel CI désigne la plateforme numérique.

Établissement désigne toute école, collège, lycée ou structure éducative utilisant Sentinel.

Parent désigne le parent ou représentant légal d'un élève.

Élève désigne toute personne inscrite dans un établissement utilisant Sentinel.

Enseignant désigne toute personne autorisée à assurer un enseignement au sein d'un établissement.

Administrateur désigne toute personne habilitée à gérer les comptes et paramètres de son établissement.

Article 3 – Acceptation des Conditions

L'utilisation de Sentinel vaut acceptation pleine et entière des présentes Conditions Générales d'Utilisation.

Pour les élèves mineurs, cette acceptation est réalisée par le parent ou le représentant légal lorsque cela est requis.

Article 4 – Création des comptes

Les comptes sont créés par l'établissement ou par Sentinel selon les modalités convenues.

Chaque utilisateur reçoit un accès personnel.

Chaque utilisateur s'engage à :

conserver la confidentialité de ses identifiants ;
choisir un mot de passe robuste lorsqu'il lui appartient d'en créer un ;
signaler immédiatement toute utilisation suspecte de son compte.

Le prêt ou le partage d'un compte est interdit.

Article 5 – Rôles et droits d'accès

Chaque utilisateur accède uniquement aux informations nécessaires à sa mission.

Parent

Le parent peut notamment :

consulter les informations concernant son ou ses enfants ;
consulter les informations concernant l’école de son ou ses enfants ;
recevoir des notifications ;
communiquer avec l'établissement dans les limites prévues.

Professeur

Le Professeur peut :

saisir les notes, devoirs et informations relatives à sa ou ses classes ;
enregistrer les retards ou absences ;
compléter les observations pédagogiques ;
consulter uniquement la ou les classes dont il a la charge.

Directeur ( Administration )

Le Directeur dispose des droits nécessaires à la gestion de son établissement.

Élève

Lorsque cette fonctionnalité est activée par l'établissement, l'élève peut consulter les informations qui le concernent suite à l’autorisation du parent ou tuteur légal.

Article 6 – Utilisation responsable

Chaque utilisateur s'engage à utiliser Sentinel :

dans le respect des lois applicables ;
avec honnêteté ;
dans le respect des autres utilisateurs ;
sans porter atteinte au fonctionnement de la plateforme.

Sont notamment interdits :

toute tentative d'accès non autorisé ;
toute modification frauduleuse des données ;
l'usurpation d'identité ;
la diffusion de contenus injurieux, diffamatoires ou illicites ;
toute utilisation visant à perturber le service.

Article 7 – Exactitude des informations

Chaque établissement demeure responsable des informations qu'il saisit dans Sentinel.

Les parents sont invités à signaler toute erreur constatée afin qu'elle puisse être corrigée dans les meilleurs délais.

Article 8 – Intelligence artificielle

Certaines fonctionnalités reposent sur une intelligence artificielle destinée à accompagner les apprentissages.

Ces fonctionnalités ont uniquement un rôle d'assistance.

Les réponses générées ne remplacent ni l'enseignant, ni les décisions pédagogiques de l'établissement.

L'utilisateur demeure libre d'exercer son jugement.

Article 9 – Sécurité des comptes

Chaque utilisateur est responsable de la confidentialité de ses identifiants.

En cas de perte, de vol ou de suspicion d'accès frauduleux, il appartient à l'utilisateur d'en informer rapidement l'établissement ou Sentinel.

Sentinel met en œuvre des mesures techniques destinées à protéger les comptes contre les accès non autorisés.

Article 10 – Disponibilité du service

Sentinel s'efforce d'assurer la disponibilité continue de ses services.

Toutefois, des interruptions temporaires peuvent intervenir notamment pour :

la maintenance ;
les mises à jour ;
des incidents techniques ;
des circonstances indépendantes de sa volonté.

Article 11 – Protection des données

Le traitement des données personnelles est régi par la Politique de Confidentialité de Sentinel, qui fait partie intégrante des présentes Conditions.

Article 12 – Propriété intellectuelle

Les logiciels, textes, illustrations, logos, éléments graphiques, interfaces et contenus composant Sentinel sont protégés par les lois relatives à la propriété intellectuelle.

Toute reproduction ou utilisation non autorisée est interdite.

Article 13 – Suspension ou suppression d'un compte

Sentinel ou l'établissement peuvent suspendre un compte en cas notamment :

d'utilisation frauduleuse ;
de violation des présentes Conditions ;
d'atteinte à la sécurité du système ;
d'obligation légale.

Article 14 – Évolutions de la plateforme

Sentinel pourra faire évoluer ses fonctionnalités afin d'améliorer le service.

Les présentes Conditions pourront être mises à jour. Les utilisateurs seront informés des modifications importantes.

Article 15 – Responsabilité

Sentinel met tout en œuvre pour fournir un service fiable.

Toutefois, Sentinel ne saurait être tenue responsable :

des erreurs de saisie effectuées par les établissements ;
des décisions pédagogiques prises par les établissements ;
des interruptions indépendantes de sa volonté ;
d'une mauvaise utilisation de la plateforme par un utilisateur.

Article 16 – Résiliation

Chaque établissement peut mettre fin à son utilisation de Sentinel conformément au contrat conclu avec Sentinel.

Les comptes utilisateurs seront alors désactivés selon les modalités prévues par ce contrat et la Politique de Confidentialité.

Article 17 – Droit applicable

Les présentes Conditions sont régies par le droit applicable dans le pays où Sentinel est exploité, sous réserve des règles impératives applicables dans les pays où la plateforme est utilisée.

En cas de différend, les parties privilégieront une résolution amiable avant toute procédure judiciaire.

Article 18 – Contact

Pour toute question relative aux présentes Conditions Générales d'Utilisation, les utilisateurs peuvent contacter l'équipe Sentinel par les coordonnées communiquées dans l'application ou sur le site officiel.

Notre engagement

Sentinel est conçu avec une conviction forte :

« Les données scolaires ne sont pas une marchandise »

Elles existent pour accompagner les élèves, renforcer le dialogue entre les familles et les établissements, et contribuer à la réussite éducative.

Notre priorité est de protéger ces informations avec le plus haut niveau d'exigence raisonnablement possible, dans un esprit de transparence, de confiance et de respect des personnes.
''';

const String kCharteTxt = r'''
Sentinel CI
CHARTE DE PROTECTION DES ENFANTS
Préambule

Chez Sentinel CI, nous sommes convaincus qu'un enfant ne doit jamais être réduit à une note, une moyenne ou une statistique.
Chaque élève est une personne en devenir, avec son propre rythme, ses forces, ses difficultés et son potentiel.
Notre mission est d'accompagner cette progression en créant un environnement numérique sûr, bienveillant et respectueux des droits de l'enfant.

Notre engagement est résumé par notre devise :

Veiller, pas surveiller.

Notre vision

Nous croyons qu'une technologie éducative doit servir l'humain avant tout.

Sentinel a été conçu pour renforcer la collaboration entre les familles, les enseignants et les établissements scolaires, sans porter atteinte à la dignité ni à la vie privée des élèves.

Chaque décision prise dans le développement de la plateforme est guidée par une question simple :

Cette fonctionnalité est-elle réellement dans l'intérêt de l'enfant ?

Si la réponse n'est pas clairement oui, nous la repensons.

Nos 10 engagements

1. L'intérêt de l'enfant avant tout

Toutes les fonctionnalités de Sentinel sont conçues pour favoriser la réussite, le bien-être et le développement de l'élève.

2. Le respect de la vie privée

Nous limitons la collecte de données aux informations réellement nécessaires au suivi scolaire.
Nous refusons toute collecte excessive.

3. La confidentialité des informations

Les données scolaires sont confidentielles.
Elles ne sont accessibles qu'aux personnes autorisées selon leur rôle.

4. Aucune vente des données

Sentinel ne vend jamais les données personnelles des élèves.

Nous ne les louons pas.

Nous ne les exploitons pas à des fins publicitaires.

Les informations confiées par les familles ne constituent pas une source de revenus.

5. Une IA au service de l'apprentissage

L'intelligence artificielle intégrée à Sentinel est conçue pour :

expliquer ;
accompagner ;
encourager ;
guider.

Elle ne remplace jamais un enseignant et ne prend jamais de décision concernant un élève.

6. Le droit à l'erreur

Un enfant apprend en faisant des erreurs.
Sentinel encourage une approche éducative qui valorise les progrès plutôt que les échecs.

Les outils proposés visent à identifier les difficultés afin de permettre un accompagnement adapté.

7. Le dialogue avant la sanction

Nous croyons que la communication entre l'école et la famille est essentielle.

Sentinel favorise les échanges constructifs afin de rechercher des solutions avant que les difficultés ne s'aggravent.

8. La transparence

Les familles doivent comprendre :

quelles informations sont enregistrées ;
pourquoi elles le sont ;
qui peut y accéder ;
comment elles sont protégées.

Nous nous engageons à communiquer de manière claire et compréhensible.

---

9. Une sécurité en amélioration continue

La sécurité n'est jamais définitivement acquise.
Nous améliorons régulièrement nos pratiques afin de protéger les données confiées à Sentinel contre les risques connus et les nouvelles menaces.

10. Une technologie au service de l'humain

Sentinel ne cherche pas à remplacer les relations humaines.
Au contraire, notre ambition est de faciliter les échanges entre les élèves, les familles, les enseignants et les établissements.
La technologie doit rapprocher les personnes, jamais les éloigner.

Notre promesse aux familles

Lorsque vous confiez les informations scolaires de votre enfant à Sentinel, vous nous accordez votre confiance.

Nous avons pleinement conscience de cette responsabilité.
C'est pourquoi nous nous engageons à agir avec intégrité, transparence et respect dans chacune de nos décisions.

Notre promesse aux écoles

Nous aidons les écoles à mieux accompagner leurs élèves.
Nous ne cherchons jamais à nous substituer à leur mission éducative.
Sentinel est un outil au service de la communauté éducative.

Notre promesse aux professeurs

Nous savons que rien ne remplace le regard, l'expérience et l'engagement d'un enseignant.
Sentinel est conçu pour vous faire gagner du temps, améliorer la communication avec les familles et vous fournir des outils utiles, sans remettre en cause votre liberté pédagogique.

Notre promesse aux élèves

Tu n'es pas une moyenne.
Tu n'es pas une série de notes.
Tu es une personne avec des talents, des rêves, des difficultés et un avenir.
Sentinel est là pour t'aider à progresser, à comprendre tes réussites comme tes difficultés, et à te donner les moyens de révéler le meilleur de toi-même.

Notre signature

Chez Sentinel, nous croyons qu'une technologie éducative ne vaut que par la confiance qu'elle inspire.
C'est pourquoi nous continuerons à développer une plateforme respectueuse des élèves, des familles et des établissements, en plaçant toujours l'humain au cœur de l'innovation.

Sentinel CI - Veiller, pas surveiller.
''';

// ══════════════════════════════════════════
//  CONSENTEMENT — 1er lancement
// ══════════════════════════════════════════
const String kConsentKey = 'consentement_accepte_v1';

class DemarrageGate extends StatefulWidget {
  const DemarrageGate({super.key});
  @override State<DemarrageGate> createState() => _DemarrageGateState();
}

class _DemarrageGateState extends State<DemarrageGate> {
  bool? _accepte;   // null = lecture en cours

  @override
  void initState() {
    super.initState();
    _verifier();
  }

  Future<void> _verifier() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) setState(()=> _accepte = prefs.getBool(kConsentKey) ?? false);
    } catch (_) {
      if (mounted) setState(()=> _accepte = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_accepte == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_accepte == true) return const PorteSession();
    return ConsentScreen(onAccept: () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(kConsentKey, true);
      } catch (_) {}
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }
}

class ConsentScreen extends StatefulWidget {
  final Future<void> Function() onAccept;
  const ConsentScreen({super.key, required this.onAccept});
  @override State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _coche = false;
  bool _envoi = false;

  void _ouvrir(String titre, String texte) {
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => DocumentViewer(titre: titre, texte: texte)));
  }

  Widget _lienDoc(String titre, IconData icon, VoidCallback onTap) => Card(
    elevation: 0,
    color: AppColors.greenBg,
    margin: const EdgeInsets.only(bottom:8),
    child: ListTile(
      leading: Icon(icon, color: AppColors.green),
      title: Text(titre, style: const TextStyle(fontSize:13, fontWeight:FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          const SizedBox(height: 12),
          Center(child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset('assets/icon/logo.png', width:96, height:96))),
          const SizedBox(height: 16),
          const Center(child: Text('Bienvenue sur Sentinel CI',
              style: TextStyle(fontSize:22, fontWeight:FontWeight.w800))),
          const SizedBox(height: 6),
          const Center(child: Text('Veiller, pas surveiller',
              style: TextStyle(fontSize:13, color:AppColors.green, fontWeight:FontWeight.w700))),
          const SizedBox(height: 20),
          const Text(
            'Sentinel CI protege les donnees des eleves, des familles et des ecoles. '
            'Avant de commencer, merci de prendre connaissance de nos documents et de les accepter.',
            style: TextStyle(fontSize:13.5, height:1.5, color:AppColors.textMain)),
          const SizedBox(height: 16),
          _lienDoc('Politique de confidentialite', Icons.privacy_tip_rounded,
              ()=>_ouvrir('Politique de confidentialite', kPolitiqueTxt)),
          _lienDoc('Conditions generales d utilisation', Icons.description_rounded,
              ()=>_ouvrir('Conditions generales d utilisation', kCguTxt)),
          _lienDoc('Charte de protection des enfants', Icons.shield_rounded,
              ()=>_ouvrir('Charte de protection des enfants', kCharteTxt)),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children:[
            Checkbox(value:_coche, onChanged:(v)=>setState(()=>_coche = v ?? false),
                activeColor: AppColors.green),
            Expanded(child: GestureDetector(
              onTap: ()=>setState(()=>_coche = !_coche),
              child: const Text(
                  'J accepte la politique de confidentialite, les conditions generales d utilisation et la charte de protection des enfants.',
                  style: TextStyle(fontSize:12.5, height:1.4)))),
          ]),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: (_coche && !_envoi) ? () async {
              setState(()=>_envoi = true);
              await widget.onAccept();
            } : null,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical:15)),
            child: _envoi
                ? const SizedBox(height:20, width:20,
                    child: CircularProgressIndicator(strokeWidth:2, color:Colors.white))
                : const Text('Continuer', style: TextStyle(fontSize:15, fontWeight:FontWeight.w700)))),
          const SizedBox(height: 12),
        ]),
      )),
    );
  }
}

class DocumentViewer extends StatelessWidget {
  final String titre, texte;
  const DocumentViewer({super.key, required this.titre, required this.texte});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(texte, style: const TextStyle(fontSize:13, height:1.55, color:AppColors.textMain)),
      ),
    );
  }
}


class SentinelCIApp extends StatelessWidget {
  const SentinelCIApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sentinel CI',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: const SplashScreen(),
  );
}

// ══════════════════════════════════════════
//  ÉCRAN D'ACCUEIL (splash de bienvenue)
// ══════════════════════════════════════════
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        // Photo plein écran
        Image.asset('assets/images/accueil.jpg', fit: BoxFit.cover,
            errorBuilder: (c,e,s)=> Container(color: AppColors.green)),
        // Dégradés sombres en haut et en bas pour la lisibilité du texte
        DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.50),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.82),
          ],
          stops: const [0.0, 0.30, 0.58, 1.0],
        ))),
        SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          child: Column(children: [
            const SizedBox(height: 10),
            // Slogan en haut
            const Text('Veiller, pas surveiller',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 26,
                    fontWeight: FontWeight.w800, height: 1.25,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0,2))])),
            const Spacer(),
            // Signature : logo + nom
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset('assets/icon/logo.png', width: 40, height: 40,
                  errorBuilder: (c,e,s)=> const SizedBox.shrink()),
              const SizedBox(width: 10),
              const Text('SentinelCI',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6)])),
            ]),
            const SizedBox(height: 18),
            // Bouton Suivant
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const DemarrageGate())),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Suivant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
            const SizedBox(height: 6),
          ]),
        )),
      ]),
    );
  }
}


// ── SESSION PERSISTANTE ──
// Si un compte est deja connecte sur cet appareil (web comme Android),
// on entre directement dans l'application, sans re-saisir le mot de passe.
// La deconnexion se fait par le bouton prevu a cet effet.
class PorteSession extends StatefulWidget {
  const PorteSession({super.key});
  @override State<PorteSession> createState() => _PorteSessionState();
}

class _PorteSessionState extends State<PorteSession> {
  AppUser? _user;
  bool _pret = false;

  @override
  void initState() {
    super.initState();
    _restaurer();
  }

  Future<void> _restaurer() async {
    try {
      final u = FirebaseAuth.instance.currentUser;
      if (u != null) {
        final p = await FirebaseService.getUserProfile(u.uid, u.email ?? '');
        if (p != null) {
          _user = await construireAppUser(p, u.uid, u.email ?? '');
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _pret = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_pret) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user != null) return MainShell(user: _user!);
    return const LoginScreen();
  }
}

// ══════════════════════════════════════════
//  LOGIN SCREEN — FIREBASE AUTH
// ══════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();
  bool _loading    = false;
  String? _error;

  Future<void> _motDePasseOublie() async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mot de passe oublie'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Entrez votre e-mail : vous recevrez un lien pour choisir un nouveau mot de passe.',
              style: TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          TextField(controller: ctrl, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final email = ctrl.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              final err = await FirebaseService.reinitialiserMotDePasse(email);
              if (!mounted) return;
              showSnack(context,
                  err ?? 'E-mail envoye ! Verifiez votre boite mail (et les spams).',
                  error: err != null);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });

    UserCredential? cred;
    try {
      cred = await FirebaseService.signIn(
          _emailCtrl.text.trim(), _pwCtrl.text.trim())
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Délai dépassé — vérifiez votre connexion réseau');
      });
    } on TimeoutException catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = '⏱ ${e.message}'; });
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = 'Erreur inattendue: $e'; });
      return;
    }

    if (!mounted) return;
    if (cred == null) {
      setState(() { _loading = false; _error = 'Email ou mot de passe incorrect.'; });
      return;
    }
    // Récupérer le profil
    final profile = await FirebaseService.getUserProfile(cred.user!.uid, cred.user!.email ?? '');
    if (!mounted) return;
    if (profile == null) {
      setState(() {
        _loading = false;
        _error = 'Profil introuvable. Contactez l administrateur.';
      });
      return;
    }
    // Compte suspendu par le super admin
    if (profile['bloque'] == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Votre compte a ete suspendu. Contactez l administration.';
      });
      return;
    }
    if (!mounted) return;
    final user = await construireAppUser(profile, cred.user!.uid, cred.user!.email ?? '');
    if (!mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => MainShell(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF062E1A), AppColors.green, AppColors.green2],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(.25),
                      blurRadius: 40, offset: const Offset(0,16))],
                ),
                padding: const EdgeInsets.all(28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Logo
                  Row(children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset('assets/icon/logo.png', width:50, height:50, fit: BoxFit.cover)),
                    const SizedBox(width:12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Sentinel CI', style: TextStyle(
                          fontSize:22, fontWeight:FontWeight.w800, color:AppColors.green)),
                      Text('Suivi scolaire intelligent',
                          style: TextStyle(fontSize:11, color:Colors.grey[500])),
                    ]),
                  ]),
                  const SizedBox(height:28),
                  const Text('Connexion', style: TextStyle(fontSize:20, fontWeight:FontWeight.w800)),
                  const SizedBox(height:4),
                  Text('Entrez vos identifiants', style: TextStyle(fontSize:13, color:Colors.grey[500])),
                  const SizedBox(height:20),

                  // Champs
                  TextField(controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height:12),
                  TextField(controller: _pwCtrl, obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mot de passe')),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _motDePasseOublie,
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: const Text('Mot de passe oublie ?',
                          style: TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height:10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.redBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize:13)),
                    ),
                  ],
                  const SizedBox(height:20),

                  SizedBox(width: double.infinity,
                      child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(width:20, height:20,
                              child: CircularProgressIndicator(color:Colors.white, strokeWidth:2))
                              : const Text('Acceder a mon espace →'))),
                  const SizedBox(height:12),
                  Center(child: Text('🔒 Connexion chiffree SSL',
                      style: TextStyle(fontSize:11, color:Colors.grey[400]))),
                  const Divider(height:28),
                  Center(child: Column(children: [
                    Text('Vous etes un parent ?',
                        style: TextStyle(fontSize:12, color: Colors.grey[600])),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const InscriptionParentPage())),
                      child: const Text('Creer un compte parent',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.green)),
                    ),
                    Text('Tu es un eleve ?',
                        style: TextStyle(fontSize:12, color: Colors.grey[600])),
                    TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const InscriptionElevePage())),
                      child: const Text('Creer mon compte eleve',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.blue)),
                    ),
                  ])),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  INSCRIPTION PARENT (auto-inscription + code enfant)
// ══════════════════════════════════════════
class InscriptionParentPage extends StatefulWidget {
  const InscriptionParentPage({super.key});
  @override State<InscriptionParentPage> createState() => _InscriptionParentPageState();
}

class _InscriptionParentPageState extends State<InscriptionParentPage> {
  final _codeCtrl  = TextEditingController();
  final _nomCtrl   = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();

  bool _loading = false;
  String? _error;
  String _lien = 'papa';

  @override
  void dispose() { _codeCtrl.dispose(); _nomCtrl.dispose(); _emailCtrl.dispose(); _pwCtrl.dispose(); super.dispose(); }

  Future<void> _creerCompte() async {
    if (_codeCtrl.text.trim().isEmpty) { setState(()=>_error='Entrez le code de votre enfant'); return; }
    if (_nomCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _pwCtrl.text.trim().length < 6) {
      setState(()=>_error='Remplissez tous les champs (mot de passe 6 caracteres min).'); return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await FirebaseService.inscrireParent(
      nom: _nomCtrl.text, email: _emailCtrl.text, motDePasse: _pwCtrl.text,
      code: _codeCtrl.text, lien: _lien,
    );
    if (!mounted) return;
    if (err != null) { setState(() { _loading = false; _error = err; }); return; }
    // Connecté automatiquement : on charge le profil et on entre
    final u = FirebaseAuth.instance.currentUser!;
    final profile = await FirebaseService.getUserProfile(u.uid, u.email ?? '');
    if (!mounted) return;
    if (profile == null) { setState(() { _loading = false; _error = 'Profil introuvable.'; }); return; }
    final user = await construireAppUser(profile, u.uid, u.email ?? '');
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainShell(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creer un compte parent')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Rattachez votre enfant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Saisissez le code que l ecole vous a communique pour votre enfant.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 16),

          SCCard(child: Column(children: [
            TextField(controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Code de l enfant')),
            const SizedBox(height: 12),
            TextField(controller: _nomCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Votre nom complet')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                value: _lien,
                decoration: const InputDecoration(labelText: 'Vous etes'),
                items: const [
                  DropdownMenuItem(value:'papa',   child: Text('Papa')),
                  DropdownMenuItem(value:'maman',  child: Text('Maman')),
                  DropdownMenuItem(value:'tuteur', child: Text('Tuteur / Tutrice')),
                ],
                onChanged: (v) => setState(() => _lien = v ?? 'papa')),
            const SizedBox(height: 12),
            TextField(controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _pwCtrl, obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe (6 caracteres min)')),
          ])),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.redBg, borderRadius: BorderRadius.circular(8)),
              child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
            ),
          ],

          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _loading ? null : _creerCompte,
            child: _loading
                ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color:Colors.white, strokeWidth:2))
                : const Text('Creer mon compte et demarrer'),
          )),
        ]),
      ),
    );
  }
}

// Auto-inscription d'un élève (crée son compte et le relie à sa fiche)
class InscriptionElevePage extends StatefulWidget {
  const InscriptionElevePage({super.key});
  @override State<InscriptionElevePage> createState() => _InscriptionElevePageState();
}

class _InscriptionElevePageState extends State<InscriptionElevePage> {
  final _codeCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _codeCtrl.dispose(); _emailCtrl.dispose(); _pwCtrl.dispose(); super.dispose(); }

  Future<void> _creerCompte() async {
    if (_codeCtrl.text.trim().isEmpty) { setState(()=>_error='Entre ton code eleve'); return; }
    if (_emailCtrl.text.trim().isEmpty || _pwCtrl.text.trim().length < 6) {
      setState(()=>_error='Remplis tous les champs (mot de passe 6 caracteres min).'); return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await FirebaseService.inscrireEleve(
      code: _codeCtrl.text, email: _emailCtrl.text, motDePasse: _pwCtrl.text,
    );
    if (!mounted) return;
    if (err != null) { setState(() { _loading = false; _error = err; }); return; }
    final u = FirebaseAuth.instance.currentUser!;
    final profile = await FirebaseService.getUserProfile(u.uid, u.email ?? '');
    if (!mounted) return;
    if (profile == null) { setState(() { _loading = false; _error = 'Profil introuvable.'; }); return; }
    final user = await construireAppUser(profile, u.uid, u.email ?? '');
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainShell(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creer mon compte eleve')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cree ton acces eleve',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Saisis le code que ton ecole t a communique, puis choisis un e-mail '
              'et un mot de passe pour te connecter.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          SCCard(child: Column(children: [
            TextField(controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Ton code eleve')),
            const SizedBox(height: 12),
            TextField(controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _pwCtrl, obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe (6 caracteres min)')),
          ])),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.redBg, borderRadius: BorderRadius.circular(8)),
              child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _loading ? null : _creerCompte,
            child: _loading
                ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color:Colors.white, strokeWidth:2))
                : const Text('Creer mon compte et entrer'),
          )),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  WIDGETS COMMUNS
// ══════════════════════════════════════════
class SCCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const SCCard({super.key, required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child));
}

class StatCard extends StatelessWidget {
  final String value, label, sub;
  final IconData icon;
  final Color color, iconBg;
  const StatCard({super.key, required this.value, required this.label,
    required this.sub, required this.icon, required this.color, required this.iconBg});
  @override
  Widget build(BuildContext context) => SCCard(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children:[
    Container(width:38, height:38,
        decoration: BoxDecoration(color:iconBg, borderRadius:BorderRadius.circular(10)),
        child: Icon(icon, color:color, size:20)),
    const SizedBox(height:8),
    // FittedBox : le chiffre retrecit tout seul s'il est tres long (ex. 1 225 000)
    FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: Text(value, maxLines:1,
            style: const TextStyle(fontSize:24, fontWeight:FontWeight.w800))),
    Text(label, maxLines:1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize:12, color:AppColors.textMuted)),
    const SizedBox(height:4),
    Text(sub, maxLines:1, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize:12, fontWeight:FontWeight.w600, color:color)),
  ]));
}

class NotePill extends StatelessWidget {
  final double note;
  final int sur;
  const NotePill({super.key, required this.note, this.sur = 20});
  double get _n => sur>0 ? note*20/sur : note;
  Color get _bg => _n>=16 ? AppColors.greenBg : _n>=13 ? AppColors.blueBg : _n>=10 ? AppColors.goldBg : AppColors.redBg;
  Color get _fg => _n>=16 ? AppColors.green   : _n>=13 ? AppColors.blue   : _n>=10 ? AppColors.gold   : AppColors.red;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
      decoration: BoxDecoration(color:_bg, borderRadius:BorderRadius.circular(20)),
      child: Text('${note.toString().replaceAll('.0','')}/$sur', style: TextStyle(fontSize:12, fontWeight:FontWeight.w800, color:_fg)));
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const ProgressBar({super.key, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
          value: value, minHeight: 7,
          backgroundColor: AppColors.bg,
          valueColor: AlwaysStoppedAnimation(color)));
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom:12),
      child: Text(text, style:const TextStyle(fontSize:14, fontWeight:FontWeight.w800)));
}

void showSnack(BuildContext ctx, String msg, {bool error = false}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.red : AppColors.green));
}

// ══════════════════════════════════════════
//  MAIN SHELL
// ══════════════════════════════════════════
class MainShell extends StatefulWidget {
  final AppUser user;
  const MainShell({super.key, required this.user});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  // Multi-enfants (parent)
  List<({String id, String nom, String? classeId})> _enfants = [];
  int _enfantActif = 0;

  // Utilisateur « effectif » : pour un parent, pointe vers l'enfant sélectionné
  // et reflète le nombre réel d'enfants (réduction famille).
  AppUser get _userEffectif {
    if (widget.user.role == UserRole.parent && _enfants.isNotEmpty) {
      final e = _enfants[_enfantActif.clamp(0, _enfants.length - 1)];
      return widget.user.copyWith(
        childId: e.id, classeId: e.classeId, enfantsCount: _enfants.length,
        childName: e.nom);
    }
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
    if (widget.user.role == UserRole.parent) {
      _chargerEnfants();
    }
    _initNotificationsPush();
  }

  // ---------- NOTIFICATIONS PUSH (FCM) ----------
  // Demande la permission, puis abonne ce téléphone :
  //  - au canal général "tous" (annonces Sentinel CI)
  //  - au canal de son école "ecole_<id>" (annonces ciblées)
  //  - au canal de son rôle "role_<role>" (ex. cibler uniquement les parents)
  Future<void> _initNotificationsPush() async {
    // Version web : notifications push réservées à l'app mobile pour l'instant.
    if (kIsWeb) return;
    try {
      final fm = FirebaseMessaging.instance;
      await fm.requestPermission();
      String propre(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9_.~%-]'), '_');
      await fm.subscribeToTopic('tous');
      await fm.subscribeToTopic('ecole_${propre(widget.user.school)}');
      await fm.subscribeToTopic('role_${widget.user.role.name}');
      // Canaux de classe : élèves et parents reçoivent les devoirs,
      // cours et événements de LEUR classe uniquement (pas de spam).
      try {
        if (widget.user.role == UserRole.eleve &&
            (widget.user.classeId ?? '').isNotEmpty) {
          await fm.subscribeToTopic('classe_${propre(widget.user.classeId!)}');
        }
        if (widget.user.role == UserRole.parent) {
          final enfants = await FirebaseService.getEnfants(widget.user.uid);
          for (final e in enfants) {
            if ((e.classeId ?? '').isNotEmpty) {
              await fm.subscribeToTopic('classe_${propre(e.classeId!)}');
            }
          }
        }
      } catch (_) {}
      // Carte d'identité push de cet appareil : les robots serveurs (Cloud
      // Functions) l'utilisent pour les notifications ciblées (messages, notes).
      try {
        final token = await fm.getToken();
        if (token != null && token.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('utilisateurs')
              .doc(widget.user.uid)
              .set({'fcmTokens': FieldValue.arrayUnion([token])},
                  SetOptions(merge: true));
        }
        fm.onTokenRefresh.listen((t) {
          FirebaseFirestore.instance
              .collection('utilisateurs')
              .doc(widget.user.uid)
              .set({'fcmTokens': FieldValue.arrayUnion([t])},
                  SetOptions(merge: true));
        });
      } catch (_) {}
      // App ouverte : vraie notification avec son et bannière (plus un simple bandeau).
      FirebaseMessaging.onMessage.listen((m) {
        final n = m.notification;
        if (n != null) {
          afficherNotificationSonore(n.title, n.body);
        }
      });
    } catch (_) {
      // Sans permission ou hors ligne : l'app continue normalement.
    }
  }

  Future<void> _chargerEnfants() async {
    try {
      final e = await FirebaseService.getEnfants(widget.user.uid);
      if (mounted) setState(() {
        _enfants = e;
        if (_enfantActif >= e.length) _enfantActif = 0;
      });
    } catch (_) {}
  }

  // Requete « du nouveau ? » pour la pastille rouge d'un onglet (parents/eleves).
  Query? _requetePastille(String label) {
    final r = widget.user.role;
    if (r != UserRole.parent && r != UserRole.eleve) return null;
    final db = FirebaseFirestore.instance;
    switch (label) {
      case 'Notes':
        final cible = r == UserRole.eleve ? widget.user.uid : widget.user.childId;
        if (cible == null) return null;
        return db.collection('notes').where('eleveId', isEqualTo: cible);
      case 'Devoirs':
        if ((widget.user.classeId ?? '').isEmpty) return null;
        return db.collection('devoirs').where('classeId', isEqualTo: widget.user.classeId);
      case 'Cours':
        if ((widget.user.classeId ?? '').isEmpty) return null;
        return db.collection('lecons').where('classeId', isEqualTo: widget.user.classeId);
      case 'Agenda':
        return db.collection('agenda').where('ecoleId', isEqualTo: widget.user.school);
    }
    return null;
  }

  List<_NavItem> get _navItems {
    switch(widget.user.role){
      case UserRole.admin: return [
        _NavItem(Icons.dashboard_rounded,      'Accueil'),
        _NavItem(Icons.school_rounded,         'Ecoles'),
        _NavItem(Icons.people_rounded,         'Membres'),
        _NavItem(Icons.credit_card_rounded,    'Revenus'),
        _NavItem(Icons.notifications_rounded,  'Alertes'),
        _NavItem(Icons.calendar_month_rounded, 'Agenda'),
        _NavItem(Icons.photo_library_rounded,  'Actus'),
      ];
      case UserRole.directeur: return [
        _NavItem(Icons.dashboard_rounded,      'Accueil'),
        _NavItem(Icons.people_rounded,         'Membres'),
        _NavItem(Icons.card_membership_rounded,'Forfait'),
        _NavItem(Icons.notifications_rounded,  'Alertes'),
        _NavItem(Icons.calendar_month_rounded, 'Agenda'),
        _NavItem(Icons.photo_library_rounded,  'Actus'),
      ];
      case UserRole.prof: return [
        _NavItem(Icons.dashboard_rounded,      'Accueil'),
        _NavItem(Icons.edit_rounded,           'Notes'),
        _NavItem(Icons.assignment_rounded,     'Devoirs'),
        _NavItem(Icons.how_to_reg_rounded,     'Absence'),
        _NavItem(Icons.menu_book_rounded,      'Lecons'),
        _NavItem(Icons.calendar_month_rounded, 'Agenda'),
        _NavItem(Icons.photo_library_rounded,  'Actus'),
      ];
      case UserRole.eleve:
      case UserRole.parent: return [
        _NavItem(Icons.dashboard_rounded,      'Accueil'),
        _NavItem(Icons.bar_chart_rounded,      'Notes'),
        _NavItem(Icons.assignment_rounded,     'Devoirs'),
        _NavItem(Icons.how_to_reg_rounded,     'Absence'),
        _NavItem(Icons.menu_book_rounded,      'Cours'),
        _NavItem(Icons.notifications_rounded,  'Alertes'),
        _NavItem(Icons.calendar_month_rounded, 'Agenda'),
        _NavItem(Icons.photo_library_rounded,  'Actus'),
      ];
    }
  }

  List<Widget> get _pages {
    switch(widget.user.role){
      case UserRole.admin: return [
        DashboardPage(user: widget.user),
        EcolesPage(user: widget.user),
        UtilisateursPage(user: widget.user),
        RevenusPage(user: widget.user),
        AlertesPage(user: widget.user),
        AgendaPage(user: widget.user),
        VieScolairePage(user: widget.user),
      ];
      case UserRole.directeur: return [
        DashboardPage(user: widget.user),
        UtilisateursPage(user: widget.user),
        AbonnementsDirecteurPage(user: widget.user),
        AlertesPage(user: widget.user),
        AgendaPage(user: widget.user),
        VieScolairePage(user: widget.user),
      ];
      case UserRole.prof: return [
        DashboardPage(user: widget.user),
        NotesPage(user: widget.user),
        DevoirsPage(user: widget.user),
        AbsencesPage(user: widget.user),
        LeconsPage(user: widget.user),
        AgendaPage(user: widget.user),
        VieScolairePage(user: widget.user),
      ];
      case UserRole.eleve:
      case UserRole.parent:
        final u = _userEffectif;
        return [
          DashboardPage(user: u, onEnfantsMaj: _chargerEnfants),
          NotesPage(user: u),
          DevoirsPage(user: u),
          AbsencesPage(user: u),
          LeconsPage(user: u),
          AlertesPage(user: u),
          AgendaPage(user: u),
          VieScolairePage(user: u),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      UserRole.admin:     AppColors.purple,
      UserRole.directeur: AppColors.gold,
      UserRole.prof:      AppColors.orange,
      UserRole.eleve:     AppColors.green,
      UserRole.parent:    AppColors.blue,
    };
    final roleLabels = {
      UserRole.admin:     'Super Admin',
      UserRole.directeur: 'Directeur',
      UserRole.prof:      'Professeur',
      UserRole.eleve:     'Eleve',
      UserRole.parent:    'Parent',
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Row(mainAxisSize: MainAxisSize.min, children:[
          RichText(text: const TextSpan(children:[
            TextSpan(text:'Sentinel', style:TextStyle(color:AppColors.green, fontWeight:FontWeight.w800, fontSize:18)),
            TextSpan(text:'CI', style:TextStyle(color:AppColors.green, fontWeight:FontWeight.w800, fontSize:18)),
          ])),
          const SizedBox(width:8),
          Flexible(child: Container(
            padding: const EdgeInsets.symmetric(horizontal:8, vertical:3),
            decoration: BoxDecoration(
                color: roleColors[widget.user.role]!.withOpacity(.12),
                borderRadius: BorderRadius.circular(20)),
            child: Text(widget.user.coAdmin ? 'Co-Administrateur' : roleLabels[widget.user.role]!,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize:10, fontWeight:FontWeight.w800,
                    color:roleColors[widget.user.role], letterSpacing:.5)),
          )),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: (){},
              style: IconButton.styleFrom(foregroundColor:AppColors.textMain)),
          Padding(
              padding: const EdgeInsets.only(right:4),
              child: CircleAvatar(
                  radius:16, backgroundColor:AppColors.green,
                  child: Text(widget.user.initials,
                      style:const TextStyle(color:Colors.white, fontSize:11, fontWeight:FontWeight.w800)))),
          if (widget.user.role == UserRole.prof)
            IconButton(
              tooltip: 'Classement de ma classe',
              icon: const Icon(Icons.leaderboard_rounded, size:20),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ClassementClassePage(user: widget.user)))),
          IconButton(
              icon: const Icon(Icons.logout_rounded, size:20),
              onPressed: () async {
                await FirebaseService.signOut();
                if (!mounted) return;
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              style: IconButton.styleFrom(foregroundColor:AppColors.red),
              tooltip: 'Deconnexion'),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height:1, color:AppColors.border)),
      ),
      body: Column(children: [
        // Sélecteur d'enfant (parent avec 2 enfants ou plus)
        if (widget.user.role == UserRole.parent && _enfants.length > 1)
          Container(
            color: AppColors.greenBg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Icon(Icons.family_restroom_rounded, size: 18, color: AppColors.green),
              const SizedBox(width: 10),
              const Text('Enfant :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green)),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _enfantActif.clamp(0, _enfants.length - 1),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textMain),
                    items: [
                      for (int i = 0; i < _enfants.length; i++)
                        DropdownMenuItem(value: i, child: Text(_enfants[i].nom)),
                    ],
                    onChanged: (v) => setState(() => _enfantActif = v ?? 0),
                  ),
                ),
              ),
            ]),
          ),
        // Contenu
        Expanded(
          child: _pages[_idx.clamp(0, _pages.length-1)],
        ),
      ]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 66,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          iconTheme: WidgetStateProperty.all(
            const IconThemeData(size: 20)),
        ),
        child: NavigationBar(
          selectedIndex: _idx,
          onDestinationSelected: (i) {
            final idx = i.clamp(0, _pages.length-1);
            marquerSectionVue(widget.user.uid, _navItems[idx].label);
            setState(() => _idx = idx);
          },
          backgroundColor: Colors.white,
          indicatorColor: AppColors.greenBg,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: _navItems.map((n) => NavigationDestination(
              icon: IconePastille(icone: n.icon,
                  requete: _requetePastille(n.label),
                  uid: widget.user.uid, section: n.label),
              label: n.label)).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// ══════════════════════════════════════════
//  DASHBOARD
// ══════════════════════════════════════════
class DashboardPage extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onEnfantsMaj;
  const DashboardPage({super.key, required this.user, this.onEnfantsMaj});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        // Bannière pub
        Container(
            width: double.infinity, height: 52,
            margin: const EdgeInsets.only(bottom:16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(colors:[Color(0xFF1A1A2E), Color(0xFF16213E)]),
                borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('Espace publicitaire — Votre annonce ici',
                style: TextStyle(color:Colors.white, fontSize:12, fontWeight:FontWeight.w600)))),

        Text(
            user.role == UserRole.parent
              ? (() {
                  final lien = (user.lien == null || user.lien!.isEmpty) ? 'parent' : user.lien!;
                  final enfant = (user.childName ?? '').trim();
                  return enfant.isNotEmpty
                      ? 'Bonjour, $lien de $enfant 👋'
                      : 'Bonjour, cher $lien 👋';
                })()
              : 'Bonjour, ${user.name.split(' ').first} 👋',
            style: const TextStyle(fontSize:20, fontWeight:FontWeight.w800)),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.streamToutesEcoles(),
          builder: (ctx, snap) {
            String nom = user.school;
            if (snap.hasData) {
              for (final d in snap.data!.docs) {
                if (d.id == user.school) {
                  nom = ((d.data() as Map)['nom'] ?? user.school).toString();
                  break;
                }
              }
            }
            return Text(nom, style: const TextStyle(fontSize:13, color:AppColors.textMuted));
          }),
        const SizedBox(height:20),

        // Carte "Prof principal" : acces aux moyennes de sa classe
        if (user.role == UserRole.prof && user.estPrincipal && user.classePrincipale != null) ...[
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => MoyennesClassePage(user: user))),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors:[AppColors.green, Color(0xFF0E9F5B)]),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(children: const [
                Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
                SizedBox(width:12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                  Text('Professeur principal',
                      style: TextStyle(color: Colors.white, fontSize:15, fontWeight: FontWeight.w800)),
                  Text('Voir les moyennes de ma classe',
                      style: TextStyle(color: Colors.white70, fontSize:12)),
                ])),
                Icon(Icons.chevron_right_rounded, color: Colors.white),
              ]),
            ),
          ),
          const SizedBox(height:20),
        ],

        // Carte "Mes enfants" (parent)
        if (user.role == UserRole.parent) ...[
          InkWell(
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MesEnfantsPage(user: user)));
              onEnfantsMaj?.call();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border)),
              child: Row(children: const [
                CircleAvatar(radius: 22, backgroundColor: AppColors.greenBg,
                    child: Icon(Icons.family_restroom_rounded, color: AppColors.green, size: 24)),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Mes enfants',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textMain)),
                  Text('Ajouter ou gerer vos enfants',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ])),
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ]),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Carte "Messages" (prof, directeur, élève, parent)
        if (user.role == UserRole.prof || user.role == UserRole.directeur ||
            user.role == UserRole.eleve || user.role == UserRole.parent) ...[
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamMessagesRecus(user.uid),
            builder: (ctx, msnap) {
              final nonLus = msnap.hasData
                  ? msnap.data!.docs.where((d)=>(d.data() as Map)['lu'] != true).length
                  : 0;
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MessageriePage(user: user))),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: nonLus>0 ? AppColors.green : AppColors.border,
                          width: nonLus>0 ? 1.5 : 1)),
                  child: Row(children: [
                    Stack(clipBehavior: Clip.none, children: [
                      const Icon(Icons.forum_rounded, color: AppColors.green, size: 26),
                      if (nonLus > 0) Positioned(right: -8, top: -8, child: _PastilleNonLus(n: nonLus)),
                    ]),
                    const SizedBox(width:12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                      const Text('Messages',
                          style: TextStyle(fontSize:15, fontWeight: FontWeight.w800)),
                      Text(nonLus > 0
                              ? '$nonLus nouveau${nonLus>1?'x':''} message${nonLus>1?'s':''}'
                              : 'Discuter avec vos contacts',
                          style: TextStyle(
                              color: nonLus>0 ? AppColors.green : AppColors.textMuted,
                              fontSize:12,
                              fontWeight: nonLus>0 ? FontWeight.w700 : FontWeight.w400)),
                    ])),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ]),
                ),
              );
            }),
          const SizedBox(height:20),
        ],

        if(user.role == UserRole.admin || user.role == UserRole.directeur) ...[
          FutureBuilder<({int ecoles, int eleves, int abonnes, int encaisse, int impayes, int total})>(
            future: FirebaseService.statsGlobales(
                ecoleId: user.role == UserRole.directeur ? user.school : null),
            builder: (ctx, s) {
              final d = s.data;
              String v(int? x) => s.hasData ? '${x ?? 0}' : '...';
              return GridView.count(crossAxisCount:2, shrinkWrap:true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio:0.95,
                  children:[
                    StatCard(value:v(d?.eleves), label:'Eleves inscrits', sub:'Total',
                        icon:Icons.school_rounded, color:AppColors.purple, iconBg:AppColors.purpleBg),
                    if (user.role == UserRole.admin)
                      StatCard(value:v(d?.ecoles), label:'Ecoles partenaires', sub:'Total',
                          icon:Icons.account_balance_rounded, color:AppColors.orange, iconBg:AppColors.orangeBg),
                    StatCard(value:s.hasData?fmtF(d!.encaisse):'...',
                        label: user.role == UserRole.admin ? 'Revenu mensuel' : 'Forfait mensuel',
                        sub: user.role == UserRole.admin ? 'FCFA · Forfaits ecoles' : 'FCFA · Votre ecole',
                        icon:Icons.payments_rounded, color:AppColors.green, iconBg:AppColors.greenBg),
                  ]);
            }),
        ] else if (user.role == UserRole.prof) ...[
          Builder(builder: (context) {
            final laClasseId = user.classePrincipale ??
                (user.classes.isNotEmpty ? user.classes.first : null);
            if (laClasseId == null) {
              return SCCard(child: const Text(
                  'Aucune classe ne vous est encore assignee. Contactez la direction pour voir vos statistiques.',
                  style: TextStyle(color: AppColors.textMuted)));
            }
            final aujourdhui = DateTime.now().toString().substring(0,10);
            return FutureBuilder<List<({String id, String nom, double moy, int nbEleves})>>(
              future: classementClasses(user.school),
              builder: (ctx, s) {
                String moyVal='...', moySub='Calcul...', rangVal='...', rangSub='';
                if (s.hasData) {
                  final liste = s.data!;
                  final idx = liste.indexWhere((c)=>c.id==laClasseId);
                  if (idx >= 0) {
                    final laClasse = liste[idx];
                    if (laClasse.moy > 0) {
                      moyVal = laClasse.moy.toStringAsFixed(2); moySub = laClasse.nom;
                      final rang = 1 + liste.where((c)=>c.moy > laClasse.moy).length;
                      rangVal = '$rang${rang==1?'er':'e'}'; rangSub = 'sur ${liste.length} classes';
                    } else {
                      moyVal='--'; moySub='Aucune note'; rangVal='--'; rangSub='${liste.length} classes';
                    }
                  } else { moyVal='--'; moySub='Classe introuvable'; rangVal='--'; }
                }
                return GridView.count(crossAxisCount:2, shrinkWrap:true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio:0.95,
                    children:[
                      StatCard(value:moyVal, label:'Moyenne classe', sub:moySub,
                          icon:Icons.bar_chart_rounded, color:AppColors.green, iconBg:AppColors.greenBg),
                      StatCard(value:rangVal, label:'Rang classe', sub:rangSub,
                          icon:Icons.emoji_events_rounded, color:AppColors.gold, iconBg:AppColors.goldBg),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseService.streamDevoirsParClasse(laClasseId),
                        builder: (ctx, ds){
                          String v='...';
                          if (ds.hasData) {
                            final prog = ds.data!.docs.where((d){
                              final dt = ((d.data() as Map)['date'] ?? '').toString();
                              return dt.length==10 && dt.compareTo(aujourdhui) >= 0;
                            }).length;
                            v = '$prog';
                          }
                          return StatCard(value:v, label:'Devoirs', sub:'Programmes',
                              icon:Icons.assignment_rounded, color:AppColors.orange, iconBg:AppColors.orangeBg);
                        }),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseService.streamAbsencesClasse(laClasseId),
                        builder: (ctx, abss){
                          final n = abss.hasData ? abss.data!.docs.length : null;
                          return StatCard(value:n==null?'...':'$n', label:'Absences/retards', sub:'Ma classe',
                              icon:Icons.notifications_rounded, color:AppColors.red, iconBg:AppColors.redBg);
                        }),
                    ]);
              });
          }),
          const SizedBox(height:20),
          SectionTitle('Absences & retards recents'),
          Builder(builder:(context){
            final laClasseId = user.classePrincipale ??
                (user.classes.isNotEmpty ? user.classes.first : null);
            if (laClasseId == null) return const SizedBox.shrink();
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.streamAbsencesClasse(laClasseId),
              builder: (ctx, snap){
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = [...snap.data!.docs];
                docs.sort((a,b)=>((b.data() as Map)['date']??'').toString()
                    .compareTo(((a.data() as Map)['date']??'').toString()));
                final top = docs.take(4).toList();
                if (top.isEmpty) {
                  return const Text('Aucune absence signalee dans votre classe. 👍',
                      style: TextStyle(color:AppColors.textMuted));
                }
                return Column(children: top.map((d){
                  final data = d.data() as Map<String,dynamic>;
                  final retard = data['statut']=='retard';
                  return Container(
                      margin: const EdgeInsets.only(bottom:8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: retard ? AppColors.orangeBg : AppColors.redBg,
                          border: Border(left: BorderSide(color: retard?AppColors.orange:AppColors.red, width:4)),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(children:[
                        Icon(retard?Icons.schedule_rounded:Icons.event_busy_rounded, size:18,
                            color: retard?AppColors.orange:AppColors.red),
                        const SizedBox(width:10),
                        Expanded(child: Text('${data['eleveNom'] ?? 'Eleve'} — ${retard?'Retard':'Absent'}',
                            style: const TextStyle(fontSize:13, fontWeight:FontWeight.w700))),
                        Text('${data['date'] ?? ''}', style: const TextStyle(fontSize:11, color:AppColors.textMuted)),
                      ]));
                }).toList());
              });
          }),
        ] else ...[
          GridView.count(crossAxisCount:2, shrinkWrap:true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio:0.95,
              children:[
                Builder(builder: (context){
                  final cibleId = user.role == UserRole.parent ? user.childId
                                : (user.role == UserRole.eleve ? user.uid : null);
                  if (cibleId == null) {
                    return StatCard(value:'--', label:'Moyenne generale', sub:'-', icon:Icons.bar_chart_rounded, color:AppColors.green, iconBg:AppColors.greenBg);
                  }
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseService.getNotesEleve(cibleId),
                    builder: (ctx, s){
                      String val = '...'; String sub = 'Calcul...';
                      if (s.hasData) {
                        if (s.data!.docs.isEmpty) { val = '--'; sub = 'Aucune note'; }
                        else { val = calculerMoyennes(s.data!.docs).generale.toStringAsFixed(2); sub = 'Sur 20'; }
                      }
                      return StatCard(value:val, label:'Moyenne generale', sub:sub, icon:Icons.bar_chart_rounded, color:AppColors.green, iconBg:AppColors.greenBg);
                    });
                }),
                Builder(builder: (context){
                  final cibleId = user.role == UserRole.parent ? user.childId
                                : (user.role == UserRole.eleve ? user.uid : null);
                  if (cibleId == null || user.classeId == null) {
                    return StatCard(value:'--', label:'Rang classe', sub:'-', icon:Icons.emoji_events_rounded, color:AppColors.gold, iconBg:AppColors.goldBg);
                  }
                  return FutureBuilder<List<dynamic>>(
                    future: Future.wait([
                      calculerMoyennesClasse(user.school, user.classeId!),
                      FirebaseService.getNotesEleve(cibleId),
                    ]),
                    builder: (ctx, s){
                      String val = '...'; String sub = 'Calcul...';
                      if (s.hasData) {
                        final liste = s.data![0] as List<({String nom, double moy})>;
                        final notes = s.data![1] as QuerySnapshot;
                        if (notes.docs.isEmpty || liste.isEmpty) { val = '--'; sub = 'Aucune note'; }
                        else {
                          final maMoy = calculerMoyennes(notes.docs).generale;
                          final rang = 1 + liste.where((e)=>e.moy > maMoy).length;
                          val = '$rang${rang==1?'er':'e'}'; sub = 'sur ${liste.length}';
                        }
                      }
                      return StatCard(value:val, label:'Rang classe', sub:sub, icon:Icons.emoji_events_rounded, color:AppColors.gold, iconBg:AppColors.goldBg);
                    });
                }),
                (user.classeId == null)
                  ? StatCard(value:'--', label:'Devoirs', sub:'-', icon:Icons.assignment_late_rounded, color:AppColors.orange, iconBg:AppColors.orangeBg)
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseService.streamDevoirsParClasse(user.classeId!),
                      builder: (ctx, ds){
                        final n = ds.hasData ? ds.data!.docs.length : null;
                        return StatCard(value: n==null?'...':'$n', label:'Devoirs', sub:'A faire', icon:Icons.assignment_late_rounded, color:AppColors.orange, iconBg:AppColors.orangeBg);
                      }),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseService.streamAlertes(user.uid),
                    builder: (ctx, as_){
                      final n = as_.hasData ? as_.data!.docs.where((d)=>(d.data() as Map)['lu'] != true).length : null;
                      return StatCard(value: n==null?'...':'$n', label:'Alertes', sub:'Non lues', icon:Icons.notifications_rounded, color:AppColors.red, iconBg:AppColors.redBg);
                    }),
              ]),
          const SizedBox(height:20),
          SectionTitle('Dernieres alertes'),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.streamAlertes(user.uid),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs.take(3).toList();
                if (docs.isEmpty) return const Text('Aucune alerte', style: TextStyle(color:AppColors.textMuted));
                return Column(children: docs.map((d) {
                  final data = d.data() as Map<String,dynamic>;
                  return Container(
                      margin: const EdgeInsets.only(bottom:8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppColors.blueBg,
                          border: const Border(left: BorderSide(color:AppColors.blue, width:4)),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                        Text(data['titre'] ?? '', style:const TextStyle(fontSize:13, fontWeight:FontWeight.w700)),
                        const SizedBox(height:2),
                        Text(data['corps'] ?? '', style:const TextStyle(fontSize:12, color:AppColors.textMuted)),
                      ]));
                }).toList());
              }),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════
//  NOTES PAGE — TEMPS REEL
// ══════════════════════════════════════════
class NotesPage extends StatefulWidget {
  final AppUser user;
  const NotesPage({super.key, required this.user});
  @override State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _noteCtrl  = TextEditingController();
  final _appreCtrl = TextEditingController();
  final _coefCtrl  = TextEditingController(text: '1');
  String _selMat   = 'Mathematiques';
  String? _selEleve;
  String? _selEleveClasse;   // classe de l'élève choisi (pour le prof principal)
  String _selType  = 'Toutes';
  int _selSur = 20;          // barème : /10 ou /20

  // Le prof est verrouillé sur sa matière (si définie)
  bool get _matiereVerrouillee =>
      widget.user.matiere != null && widget.user.matiere!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_matiereVerrouillee) _selMat = widget.user.matiere!;
  }

  final _matieres = ['Mathematiques','Physique-Chimie','SVT','Francais','Anglais','Histoire-Geo','EPS'];
  final _types = ['Devoir surveille','Interrogation','Devoir de maison',
                  'Conduite','Participation','Cahier','Autre'];

  Future<void> _saisir() async {
    if (_selEleve == null) {
      showSnack(context, 'Choisissez un eleve', error:true); return;
    }
    if (_selType == 'Toutes') {
      showSnack(context, 'Choisissez un type de note (Devoir, Interrogation...) pour enregistrer', error:true); return;
    }
    final n = double.tryParse(_noteCtrl.text.replaceAll(',', '.'));
    if (n == null || n < 0 || n > _selSur) {
      showSnack(context, 'Note invalide (0-$_selSur)', error:true); return;
    }
    final appre = _appreCtrl.text.trim().isNotEmpty
        ? _appreCtrl.text.trim()
        : appreciationNote(n, _selSur);
    await FirebaseService.ajouterNote({
      'eleveId':      _selEleve,
      'matiere':      _selMat,
      'type':         _selType,
      'note':         n,
      'sur':          _selSur,
      'coefficient':  double.tryParse(_coefCtrl.text) ?? 1,
      'appreciation': appre,
      'ecoleId':      widget.user.school,
      'date':         DateTime.now().toString().substring(0,10),
      'professeurId': widget.user.uid,
    });
    _noteCtrl.clear(); _appreCtrl.clear();
    if (mounted) showSnack(context, 'Note enregistree — Parent notifie ! 📲');
  }

  @override
  Widget build(BuildContext context) {
    final isProf = widget.user.role == UserRole.prof || widget.user.role == UserRole.admin;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        if (isProf) ...[
          SectionTitle('Saisir une note'),
          SCCard(child: Column(children:[
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.streamEleves(widget.user.school),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Padding(
                        padding: EdgeInsets.symmetric(vertical:8),
                        child: Text('Chargement des eleves...',
                            style: TextStyle(color:AppColors.textMuted)));
                  }
                  // Si le prof a des classes assignées, on limite à SES classes
                  final classesProf = widget.user.classes;
                  final eleves = classesProf.isEmpty
                      ? snap.data!.docs
                      : snap.data!.docs.where((d)=>
                          classesProf.contains((d.data() as Map)['classeId'])).toList();
                  if (eleves.isEmpty) {
                    return const Padding(
                        padding: EdgeInsets.symmetric(vertical:8),
                        child: Text('Aucun eleve dans vos classes.',
                            style: TextStyle(color:AppColors.textMuted)));
                  }
                  return DropdownButtonFormField<String>(
                      value: _selEleve,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Eleve'),
                      hint: const Text('Choisir un eleve'),
                      items: eleves.map((doc) {
                        final data = doc.data() as Map<String,dynamic>;
                        return DropdownMenuItem(
                            value: doc.id,
                            child: Text(data['nom'] ?? 'Sans nom'));
                      }).toList(),
                      onChanged: (v) => setState(() {
                        _selEleve = v;
                        final doc = eleves.firstWhere((d)=>d.id==v, orElse:()=>eleves.first);
                        _selEleveClasse = (doc.data() as Map)['classeId'] as String?;
                      }));
                }),
            const SizedBox(height:10),
            if (_matiereVerrouillee)
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Matiere'),
                child: Text(_selMat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))
            else
              DropdownButtonFormField<String>(
                  value: _selMat,
                  decoration: const InputDecoration(labelText: 'Matiere'),
                  items: _matieres.map((m) => DropdownMenuItem(value:m, child:Text(m))).toList(),
                  onChanged: (v) => setState(() => _selMat = v!)),
            const SizedBox(height:10),
            DropdownButtonFormField<String>(
                value: _selType,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Type de note (et filtre d affichage)'),
                items: [
                  const DropdownMenuItem(value:'Toutes', child: Text('Toutes les notes')),
                  ..._types.map((t) => DropdownMenuItem(value:t, child:Text(t))),
                ],
                onChanged: (v) => setState(() => _selType = v!)),
            const SizedBox(height:10),
            Row(children:[
              Expanded(child: TextField(controller:_noteCtrl, keyboardType:const TextInputType.numberWithOptions(decimal:true),
                  onChanged: (v) {
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n != null && n >= 0 && n <= _selSur) {
                      _appreCtrl.text = appreciationNote(n, _selSur);
                    }
                  },
                  decoration:InputDecoration(labelText:'Note (/$_selSur)'))),
              const SizedBox(width:10),
              SizedBox(width:96, child: DropdownButtonFormField<int>(
                  value: _selSur,
                  decoration: const InputDecoration(labelText:'Bareme'),
                  items: const [
                    DropdownMenuItem(value:20, child: Text('/ 20')),
                    DropdownMenuItem(value:10, child: Text('/ 10')),
                  ],
                  onChanged: (v) => setState(() {
                    _selSur = v ?? 20;
                    final n = double.tryParse(_noteCtrl.text.replaceAll(',', '.'));
                    if (n != null && n >= 0 && n <= _selSur) {
                      _appreCtrl.text = appreciationNote(n, _selSur);
                    }
                  }))),
            ]),
            const SizedBox(height:10),
            SizedBox(width:130, child: TextField(controller:_coefCtrl, keyboardType:TextInputType.number,
                decoration:const InputDecoration(labelText:'Coefficient'))),
            const SizedBox(height:10),
            TextField(controller:_appreCtrl, maxLines: 2,
                decoration:const InputDecoration(labelText:'Appreciation (auto, modifiable)')),
            const SizedBox(height:14),
            SizedBox(width:double.infinity, child:ElevatedButton(
                onPressed:_saisir,
                child:const Text('Enregistrer — Notifier parents 📲'))),
          ])),
          const SizedBox(height:20),
          // ---- Notes manquantes (Lot 3 - partie 2) ----
          if ((widget.user.matiere ?? '').isNotEmpty) ...[
            SectionTitle('Notes manquantes'),
            NotesManquantesSection(user: widget.user),
            const SizedBox(height:20),
          ],
        ],

        SectionTitle('Notes en temps reel'),
        if (isProf && _selEleve == null)
          SCCard(child:const Text('Choisissez un eleve pour voir ses notes.',
              style:TextStyle(color:AppColors.textMuted)))
        else if (widget.user.role == UserRole.parent && widget.user.childId == null)
          SCCard(child:const Text('Aucun enfant rattache a ce compte.',
              style:TextStyle(color:AppColors.textMuted)))
        else
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamNotes(
                isProf
                    ? _selEleve!
                    : (widget.user.role == UserRole.parent
                        ? widget.user.childId!
                        : widget.user.uid)),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.docs.isEmpty)
                return SCCard(child:const Text('Aucune note enregistree.',
                    style:TextStyle(color:AppColors.textMuted)));
              var docs = snap.data!.docs;
              // Un professeur ne voit que SA matière, sauf s'il est principal de cette classe
              if (isProf && (widget.user.matiere ?? '').isNotEmpty) {
                final principalIci = widget.user.classePrincipale != null
                    && widget.user.classePrincipale == _selEleveClasse;
                if (!principalIci) {
                  docs = docs.where((d)=>(d.data() as Map)['matiere'] == widget.user.matiere).toList();
                }
              }
              if (docs.isEmpty) {
                return SCCard(child:const Text('Aucune note dans votre matiere pour cet eleve.',
                    style:TextStyle(color:AppColors.textMuted)));
              }
              // ---- Calcul automatique des moyennes (note x coefficient, tout sur 20) ----
              final Map<String,double> pts = {}; // matiere -> somme(note*coef)
              final Map<String,double> cfs = {}; // matiere -> somme(coef)
              for (final d in docs) {
                final m = d.data() as Map<String,dynamic>;
                final mat = (m['matiere'] ?? 'Autre').toString();
                final surN = (m['sur'] as num?)?.toDouble() ?? 20;
                final nt = ((m['note'] as num?)?.toDouble() ?? 0) * (surN>0?20/surN:1);
                final cf = (m['coefficient'] as num?)?.toDouble() ?? 1;
                pts[mat] = (pts[mat] ?? 0) + nt*cf;
                cfs[mat] = (cfs[mat] ?? 0) + cf;
              }
              double totPts = 0, totCfs = 0;
              pts.forEach((k,v) => totPts += v);
              cfs.forEach((k,v) => totCfs += v);
              final moyGen = totCfs > 0 ? totPts/totCfs : 0.0;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                // ---- Carte Moyennes ----
                SCCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                  Row(children:[
                    const Expanded(child: Text('Moyenne generale',
                        style: TextStyle(fontSize:14, fontWeight: FontWeight.w800))),
                    Text('${moyGen.toStringAsFixed(2)}/20',
                        style: TextStyle(fontSize:18, fontWeight: FontWeight.w800,
                            color: moyGen>=10?AppColors.green:AppColors.red)),
                  ]),
                  const Divider(height:20),
                  ...pts.keys.map((mat){
                    final moy = (cfs[mat] ?? 0) > 0 ? pts[mat]!/cfs[mat]! : 0.0;
                    return Padding(padding: const EdgeInsets.symmetric(vertical:4),
                      child: Row(children:[
                        Expanded(child: Text(mat, style: const TextStyle(fontSize:12.5))),
                        Text('${moy.toStringAsFixed(2)}/20',
                            style: TextStyle(fontSize:12.5, fontWeight: FontWeight.w700,
                                color: moy>=10?AppColors.green:AppColors.red)),
                      ]));
                  }),
                ])),
                const SizedBox(height:12),
                // ---- Simulateur (eleve / parent) ----
                if (!isProf) ...[
                  // Bouton bulletin (élève / parent) si une classe est connue
                  if (widget.user.classeId != null) ...[
                    SizedBox(width: double.infinity, child: OutlinedButton.icon(
                      onPressed: () {
                        final cible = widget.user.role == UserRole.parent
                            ? widget.user.childId : widget.user.uid;
                        Navigator.push(context, MaterialPageRoute(builder: (_) =>
                          BulletinPage(
                            eleveId: cible!,
                            eleveNom: widget.user.role == UserRole.parent ? 'Mon enfant' : widget.user.name,
                            classeId: widget.user.classeId!,
                            ecoleId: widget.user.school)));
                      },
                      icon: const Icon(Icons.description_rounded, size: 18),
                      label: const Text('Voir le bulletin (rang + mention)'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.green,
                          side: const BorderSide(color: AppColors.green),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    )),
                    const SizedBox(height:12),
                  ],
                  SimulateurMoyenne(points: pts, coefs: cfs),
                  const SizedBox(height:12),
                ],
                // ---- Filtre d'affichage par type (eleve/parent ; le prof utilise le menu du formulaire) ----
                if (!isProf) ...[
                  Row(children:[
                    const Icon(Icons.filter_list_rounded, size:18, color:AppColors.textMuted),
                    const SizedBox(width:8),
                    Expanded(child: DropdownButtonFormField<String>(
                        value: _selType,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Afficher',
                            isDense: true, contentPadding: EdgeInsets.symmetric(horizontal:12, vertical:8)),
                        items: [
                          const DropdownMenuItem(value:'Toutes', child: Text('Toutes les notes')),
                          ..._types.map((t)=>DropdownMenuItem(value:t, child: Text(t))),
                        ],
                        onChanged: (v)=>setState(()=>_selType = v ?? 'Toutes'))),
                  ]),
                  const SizedBox(height:10),
                ],
                // ---- Detail des notes ----
                Builder(builder: (context){
                  final docsAffiches = _selType=='Toutes'
                      ? docs
                      : docs.where((d)=>(d.data() as Map)['type']==_selType).toList();
                  if (docsAffiches.isEmpty) {
                    return SCCard(child: Text('Aucune note de type « $_selType ».',
                        style: const TextStyle(color:AppColors.textMuted)));
                  }
                  return SCCard(padding:EdgeInsets.zero, child:Column(
                    children: docsAffiches.asMap().entries.map((e) {
                      final data = e.value.data() as Map<String,dynamic>;
                      final note = (data['note'] as num?)?.toDouble() ?? 0;
                      final last = e.key == docsAffiches.length - 1;
                      return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              border: last ? null : const Border(
                                  bottom: BorderSide(color:AppColors.bg))),
                          child: Row(children:[
                            Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                              Text(data['matiere'] ?? '',
                                  style:const TextStyle(fontSize:13, fontWeight:FontWeight.w600)),
                              Text('${data['type'] ?? ''}${data['coefficient'] != null ? ' · coef ${(data['coefficient'] as num).toString().replaceAll('.0','')}' : ''} · ${data['date'] ?? ''}',
                                  style:const TextStyle(fontSize:11, color:AppColors.textMuted)),
                              if ((data['appreciation'] ?? '').isNotEmpty)
                                Text(data['appreciation'],
                                    style:const TextStyle(fontSize:11, color:AppColors.textMuted)),
                            ])),
                            NotePill(note:note, sur: (data['sur'] as num?)?.toInt() ?? 20),
                          ]));
                    }).toList()));
                }),
              ]);
            }),
      ]),
    );
  }
}

// ══════════════════════════════════════════
//  NOTES MANQUANTES (Lot 3 - partie 2)
// ══════════════════════════════════════════
class NotesManquantesSection extends StatelessWidget {
  final AppUser user;
  const NotesManquantesSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final classeId = user.classePrincipale ??
        (user.classes.isNotEmpty ? user.classes.first : null);
    final matiere = user.matiere ?? '';
    if (classeId == null || matiere.isEmpty) {
      return SCCard(child: const Text(
          'Le suivi des notes manquantes sera disponible une fois votre classe et votre matiere definies.',
          style: TextStyle(color: AppColors.textMuted)));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.streamRattrapagesClasse(classeId),
      builder: (ctx, rs) {
        final Map<String, Map<String,dynamic>> decisions = {};
        if (rs.hasData) {
          for (final d in rs.data!.docs) {
            final m = d.data() as Map<String,dynamic>;
            if (m['matiere'] == matiere) decisions[(m['eleveId']??'').toString()] = m;
          }
        }
        return FutureBuilder<List<({String id, String nom, int nb})>>(
          future: comptageNotesMatiere(user.school, classeId, matiere),
          builder: (ctx2, s) {
            if (!s.hasData) {
              return const Padding(padding: EdgeInsets.symmetric(vertical:8),
                  child: Text('Analyse des notes en cours...',
                      style: TextStyle(color:AppColors.textMuted)));
            }
            final liste = s.data!;
            final maxNb = liste.fold<int>(0, (a,e)=> e.nb>a ? e.nb : a);
            final manquants = liste.where((e)=>e.nb < maxNb).toList();
            if (maxNb == 0) {
              return SCCard(child: Text('Aucune note en $matiere pour l instant.',
                  style: const TextStyle(color:AppColors.textMuted)));
            }
            if (manquants.isEmpty) {
              return SCCard(child: Row(children:const [
                Icon(Icons.check_circle_rounded, color:AppColors.green, size:18),
                SizedBox(width:8),
                Expanded(child: Text('Tous les eleves ont le meme nombre de notes. 👍',
                    style: TextStyle(fontSize:12.5))),
              ]));
            }
            return Column(children: manquants.map((e)=>
              _LigneManquant(
                user: user, classeId: classeId, matiere: matiere,
                eleveId: e.id, eleveNom: e.nom, nb: e.nb, maxNb: maxNb,
                decision: decisions[e.id],
              )).toList());
          });
      });
  }
}

class _LigneManquant extends StatelessWidget {
  final AppUser user;
  final String classeId, matiere, eleveId, eleveNom;
  final int nb, maxNb;
  final Map<String,dynamic>? decision;
  const _LigneManquant({required this.user, required this.classeId,
      required this.matiere, required this.eleveId, required this.eleveNom,
      required this.nb, required this.maxNb, this.decision});

  Future<void> _decider(BuildContext context, String choix) async {
    await FirebaseService.enregistrerRattrapage({
      'eleveId': eleveId, 'eleveNom': eleveNom,
      'matiere': matiere, 'classeId': classeId, 'ecoleId': user.school,
      'decision': choix, 'professeurId': user.uid,
    });
    if (context.mounted) {
      showSnack(context, choix=='justifie'
          ? '$eleveNom : absence justifiee, moyenne calculee sans cette note.'
          : '$eleveNom : rattrapage a prevoir.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dec = decision?['decision'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom:10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orangeBg,
        border: const Border(left: BorderSide(color: AppColors.orange, width:4)),
        borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Row(children:[
          Expanded(child: Text(eleveNom,
              style: const TextStyle(fontSize:13, fontWeight:FontWeight.w700))),
          Text('$nb / $maxNb notes',
              style: const TextStyle(fontSize:12, fontWeight:FontWeight.w800, color:AppColors.orange)),
        ]),
        const SizedBox(height:2),
        Text('$matiere — ${maxNb-nb} note(s) en moins que la classe',
            style: const TextStyle(fontSize:11, color:AppColors.textMuted)),
        const SizedBox(height:8),
        if (dec == null)
          Row(children:[
            Expanded(child: OutlinedButton(
              onPressed: ()=>_decider(context, 'justifie'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green),
                  padding: const EdgeInsets.symmetric(vertical:8)),
              child: const Text('Absence justifiee', style: TextStyle(fontSize:11.5)))),
            const SizedBox(width:8),
            Expanded(child: OutlinedButton(
              onPressed: ()=>_decider(context, 'rattrapage'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.blue,
                  side: const BorderSide(color: AppColors.blue),
                  padding: const EdgeInsets.symmetric(vertical:8)),
              child: const Text('Rattrapage a prevoir', style: TextStyle(fontSize:11.5)))),
          ])
        else
          Row(children:[
            Icon(dec=='justifie'?Icons.check_circle_rounded:Icons.event_repeat_rounded,
                size:16, color: dec=='justifie'?AppColors.green:AppColors.blue),
            const SizedBox(width:6),
            Expanded(child: Text(dec=='justifie'
                ? 'Absence justifiee — moyenne calculee sans cette note'
                : 'Rattrapage a prevoir',
                style: TextStyle(fontSize:11.5, fontWeight: FontWeight.w600,
                    color: dec=='justifie'?AppColors.green:AppColors.blue))),
            TextButton(onPressed: ()=>_decider(context, dec=='justifie'?'rattrapage':'justifie'),
                child: const Text('Changer', style: TextStyle(fontSize:11))),
          ]),
      ]));
  }
}

// ══════════════════════════════════════════
//  SIMULATEUR DE MOYENNE (espace élève)
// ══════════════════════════════════════════
class SimulateurMoyenne extends StatefulWidget {
  final Map<String,double> points; // matiere -> somme(note*coef)
  final Map<String,double> coefs;  // matiere -> somme(coef)
  const SimulateurMoyenne({super.key, required this.points, required this.coefs});
  @override State<SimulateurMoyenne> createState() => _SimulateurMoyenneState();
}

class _SimulateurMoyenneState extends State<SimulateurMoyenne> {
  String? _matiere;
  final _cibleCtrl = TextEditingController(text: '10');
  final _coefCtrl  = TextEditingController(text: '1');
  String? _resultat;
  Color _resColor = AppColors.green;

  @override
  void dispose() { _cibleCtrl.dispose(); _coefCtrl.dispose(); super.dispose(); }

  void _calculer() {
    if (_matiere == null) {
      showSnack(context, 'Choisis une matiere', error:true); return;
    }
    final S = widget.points[_matiere] ?? 0;     // points actuels
    final C = widget.coefs[_matiere] ?? 0;      // coefs actuels
    final M = double.tryParse(_cibleCtrl.text.replaceAll(',', '.')) ?? 10; // cible
    final k = double.tryParse(_coefCtrl.text.replaceAll(',', '.')) ?? 1;   // coef du prochain
    if (k <= 0) { showSnack(context, 'Coefficient invalide', error:true); return; }

    final x = (M*(C+k) - S) / k; // note necessaire
    String msg; Color col;
    if (x <= 0) {
      msg = 'Bonne nouvelle : la moyenne de ${M.toStringAsFixed(0)} est deja assuree, '
            'meme avec 0 au prochain ! 🎉';
      col = AppColors.green;
    } else if (x > 20) {
      msg = 'Avec une seule note, atteindre ${M.toStringAsFixed(0)} ne sera pas possible ce coup-ci '
            '(il faudrait plus de 20/20). Mais chaque note compte — accroche-toi ! 💪';
      col = AppColors.red;
    } else {
      msg = 'Il te faut au moins ${x.toStringAsFixed(2)}/20 au prochain '
            '(coef ${k.toString().replaceAll('.0','')}) pour atteindre ${M.toStringAsFixed(0)} de moyenne en $_matiere. Tu peux le faire ! 💪';
      col = x <= 12 ? AppColors.green : AppColors.gold;
    }
    setState(() { _resultat = msg; _resColor = col; });
  }

  @override
  Widget build(BuildContext context) {
    final matieres = widget.points.keys.toList()..sort();
    return SCCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Row(children: const [
        Icon(Icons.calculate_rounded, size:18, color: AppColors.green),
        SizedBox(width:8),
        Text('Simulateur de moyenne', style: TextStyle(fontSize:14, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height:4),
      const Text('Quelle note te faut-il au prochain devoir ?',
          style: TextStyle(fontSize:12, color: AppColors.textMuted)),
      const SizedBox(height:12),
      DropdownButtonFormField<String>(
          value: _matiere, isExpanded: true,
          decoration: const InputDecoration(labelText: 'Matiere'),
          hint: const Text('Choisir une matiere'),
          items: matieres.map((m)=>DropdownMenuItem(value:m, child:Text(m))).toList(),
          onChanged: (v)=>setState((){ _matiere = v; _resultat = null; })),
      const SizedBox(height:10),
      Row(children:[
        Expanded(child: TextField(controller:_cibleCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Moyenne visee'))),
        const SizedBox(width:10),
        Expanded(child: TextField(controller:_coefCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Coef du prochain'))),
      ]),
      const SizedBox(height:12),
      SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _calculer, child: const Text('Calculer'))),
      if (_resultat != null) ...[
        const SizedBox(height:12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: _resColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _resColor.withOpacity(0.4))),
          child: Text(_resultat!, style: TextStyle(fontSize:13, fontWeight: FontWeight.w600, color: _resColor)),
        ),
      ],
    ]));
  }
}

// ══════════════════════════════════════════
//  PROF PRINCIPAL — MOYENNES DE LA CLASSE
// ══════════════════════════════════════════
class MoyennesClassePage extends StatelessWidget {
  final AppUser user;
  const MoyennesClassePage({super.key, required this.user});

  Future<void> _exporterClasse(BuildContext context, {required bool imprimer}) async {
    showDialog(context: context, barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      // Nom de la classe
      String classeNom = '';
      String ecoleNom = user.school;
      try {
        final clSnap = await FirebaseService.streamClasses(user.school).first;
        for (final d in clSnap.docs) {
          if (d.id == user.classePrincipale) { classeNom = ((d.data() as Map)['nom'] ?? '').toString(); break; }
        }
        final ecSnap = await FirebaseService.streamToutesEcoles().first;
        for (final d in ecSnap.docs) {
          if (d.id == user.school) { ecoleNom = ((d.data() as Map)['nom'] ?? user.school).toString(); break; }
        }
      } catch (_) {}
      final eleves = await calculerMoyennesClasse(user.school, user.classePrincipale!);
      final bytes = await buildClassePdf(ecoleNom: ecoleNom, classeNom: classeNom, eleves: eleves);
      if (context.mounted) Navigator.pop(context); // ferme le loader
      if (imprimer) {
        await Printing.layoutPdf(onLayout: (_) async => bytes);
      } else {
        await Printing.sharePdf(bytes: bytes, filename: 'moyennes_classe.pdf');
      }
    } catch (e) {
      if (context.mounted) { Navigator.pop(context); showSnack(context, 'Erreur PDF : $e', error: true); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moyennes de ma classe'), actions: [
        IconButton(
            tooltip: 'Partager en PDF',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _exporterClasse(context, imprimer: false)),
        IconButton(
            tooltip: 'Imprimer',
            icon: const Icon(Icons.print_rounded),
            onPressed: () => _exporterClasse(context, imprimer: true)),
      ]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.streamEleves(user.school),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final eleves = (snap.data?.docs ?? [])
              .where((d)=>(d.data() as Map)['classeId'] == user.classePrincipale)
              .toList();
          if (eleves.isEmpty)
            return const Center(child: Text('Aucun eleve dans cette classe.'));
          eleves.sort((a,b)=>((a.data() as Map)['nom']??'').toString()
              .toLowerCase().compareTo(((b.data() as Map)['nom']??'').toString().toLowerCase()));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: eleves.length,
            separatorBuilder: (_,__)=>const SizedBox(height:10),
            itemBuilder: (_, i) {
              final data = eleves[i].data() as Map<String,dynamic>;
              final nom = (data['nom'] ?? '').toString();
              final eleveId = eleves[i].id;
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseService.getNotesEleve(eleveId),
                builder: (ctx, ns) {
                  String moyTxt = '...';
                  Color col = AppColors.textMuted;
                  if (ns.hasData) {
                    if (ns.data!.docs.isEmpty) {
                      moyTxt = 'Aucune note';
                    } else {
                      final m = calculerMoyennes(ns.data!.docs);
                      moyTxt = '${m.generale.toStringAsFixed(2)}/20';
                      col = m.generale >= 10 ? AppColors.green : AppColors.red;
                    }
                  }
                  return InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => MoyenneEleveDetailPage(eleveNom: nom, eleveId: eleveId,
                            classeId: user.classePrincipale, ecoleId: user.school))),
                    borderRadius: BorderRadius.circular(14),
                    child: SCCard(child: Row(children:[
                      CircleAvatar(radius:18, backgroundColor: AppColors.greenBg,
                          child: Text(nom.isNotEmpty ? nom[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800))),
                      const SizedBox(width:12),
                      Expanded(child: Text(nom,
                          style: const TextStyle(fontSize:13, fontWeight: FontWeight.w700))),
                      Text(moyTxt, style: TextStyle(fontSize:14, fontWeight: FontWeight.w800, color: col)),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ])),
                  );
                });
            });
        }),
    );
  }
}

class MoyenneEleveDetailPage extends StatelessWidget {
  final String eleveNom;
  final String eleveId;
  final String? classeId;
  final String? ecoleId;
  const MoyenneEleveDetailPage({super.key, required this.eleveNom, required this.eleveId,
      this.classeId, this.ecoleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eleveNom)),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseService.getNotesEleve(eleveId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || snap.data!.docs.isEmpty)
            return const Center(child: Text('Aucune note pour cet eleve.'));
          final m = calculerMoyennes(snap.data!.docs);
          final matieres = m.parMatiere.keys.toList()..sort();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              SCCard(child: Row(children:[
                const Expanded(child: Text('Moyenne generale',
                    style: TextStyle(fontSize:14, fontWeight: FontWeight.w800))),
                Text('${m.generale.toStringAsFixed(2)}/20',
                    style: TextStyle(fontSize:18, fontWeight: FontWeight.w800,
                        color: m.generale >= 10 ? AppColors.green : AppColors.red)),
              ])),
              const SizedBox(height:12),
              SectionTitle('Moyennes par matiere'),
              SCCard(child: Column(children: matieres.map((mat){
                final moy = m.parMatiere[mat] ?? 0;
                return Padding(padding: const EdgeInsets.symmetric(vertical:5),
                  child: Row(children:[
                    Expanded(child: Text(mat, style: const TextStyle(fontSize:13))),
                    Text('${moy.toStringAsFixed(2)}/20',
                        style: TextStyle(fontSize:13, fontWeight: FontWeight.w700,
                            color: moy >= 10 ? AppColors.green : AppColors.red)),
                  ]));
              }).toList())),
              if (classeId != null && ecoleId != null) ...[
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                    BulletinPage(eleveId: eleveId, eleveNom: eleveNom,
                        classeId: classeId!, ecoleId: ecoleId!))),
                  icon: const Icon(Icons.description_rounded, size: 18),
                  label: const Text('Voir le bulletin complet'),
                )),
              ],
            ]),
          );
        }),
    );
  }
}

// ══════════════════════════════════════════
//  BULLETIN (moyennes + rang + mention + appréciation)
// ══════════════════════════════════════════
class BulletinPage extends StatelessWidget {
  final String eleveId, eleveNom, classeId, ecoleId;
  const BulletinPage({super.key, required this.eleveId, required this.eleveNom,
      required this.classeId, required this.ecoleId});

  Future<Map<String,dynamic>> _calcul() async {
    // Nom de l'école
    String ecoleNom = ecoleId;
    try {
      final ecSnap = await FirebaseService.streamToutesEcoles().first;
      for (final d in ecSnap.docs) {
        if (d.id == ecoleId) { ecoleNom = ((d.data() as Map)['nom'] ?? ecoleId).toString(); break; }
      }
    } catch (_) {}
    // Nom de la classe
    String classeNom = '';
    try {
      final clSnap = await FirebaseService.streamClasses(ecoleId).first;
      for (final d in clSnap.docs) {
        if (d.id == classeId) { classeNom = ((d.data() as Map)['nom'] ?? '').toString(); break; }
      }
    } catch (_) {}
    // Roster de la classe + moyenne de chacun (pour le rang)
    final elevesSnap = await FirebaseService.getElevesEcole(ecoleId);
    final classmates = elevesSnap.docs
        .where((d)=>(d.data() as Map)['classeId'] == classeId).toList();
    final List<MapEntry<String,double>> liste = [];
    Map<String,double> maMat = {};
    double maMoy = 0;
    String nomCible = eleveNom;
    for (final c in classmates) {
      final notes = await FirebaseService.getNotesEleve(c.id);
      final m = calculerMoyennes(notes.docs);
      liste.add(MapEntry(c.id, m.generale));
      if (c.id == eleveId) {
        maMoy = m.generale; maMat = m.parMatiere;
        nomCible = ((c.data() as Map)['nom'] ?? eleveNom).toString();
      }
    }
    liste.sort((a,b)=>b.value.compareTo(a.value));
    final rang = liste.indexWhere((e)=>e.key == eleveId) + 1;
    return {
      'ecoleNom': ecoleNom, 'classeNom': classeNom, 'eleveNom': nomCible,
      'generale': maMoy, 'parMatiere': maMat,
      'rang': rang, 'total': classmates.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bulletin')),
      body: FutureBuilder<Map<String,dynamic>>(
        future: _calcul(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final moy = (d['generale'] as double);
          final parMat = (d['parMatiere'] as Map<String,double>);
          final rang = d['rang'] as int;
          final total = d['total'] as int;
          final matieres = parMat.keys.toList()..sort();
          final aDesNotes = parMat.isNotEmpty;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              // En-tête
              SCCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                Row(children:[
                  const Text('SENTINEL ', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.green, fontSize: 16)),
                  const Text('CI', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.green, fontSize: 16)),
                  const Spacer(),
                  Text(d['ecoleNom'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ]),
                const Divider(height: 18),
                Text(d['eleveNom'] ?? eleveNom, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('Classe : ${d['classeNom'] ?? ''}', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                const Text('Bulletin scolaire', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ])),
              const SizedBox(height: 12),

              if (!aDesNotes)
                SCCard(child: const Text('Aucune note enregistree pour le moment.',
                    style: TextStyle(color: AppColors.textMuted)))
              else ...[
                // Tableau des moyennes par matière
                SectionTitle('Moyennes par matiere'),
                SCCard(padding: EdgeInsets.zero, child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.bg))),
                    child: Row(children: const [
                      Expanded(child: Text('Matiere', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted))),
                      Text('Moyenne', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                    ]),
                  ),
                  ...matieres.map((mat){
                    final mm = parMat[mat] ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.bg))),
                      child: Row(children:[
                        Expanded(child: Text(mat, style: const TextStyle(fontSize: 13))),
                        Text('${mm.toStringAsFixed(2)}/20',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: mm >= 10 ? AppColors.green : AppColors.red)),
                      ]),
                    );
                  }),
                ])),
                const SizedBox(height: 12),

                // Synthèse : moyenne générale, rang, mention
                SCCard(child: Column(children:[
                  _ligneSynthese('Moyenne generale', '${moy.toStringAsFixed(2)}/20',
                      moy >= 10 ? AppColors.green : AppColors.red),
                  const Divider(height: 18),
                  _ligneSynthese('Rang', total > 0 ? '$rang e / $total' : '-', AppColors.textMain),
                  const Divider(height: 18),
                  _ligneSynthese('Mention', mentionDe(moy),
                      moy >= 10 ? AppColors.green : AppColors.red),
                ])),
                const SizedBox(height: 12),

                // Appréciation
                SectionTitle('Appreciation'),
                SCCard(child: Text(appreciationDe(moy),
                    style: const TextStyle(fontSize: 13, height: 1.4))),
                const SizedBox(height: 16),

                // Partager / Imprimer
                Row(children:[
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () async {
                      final bytes = await buildBulletinPdf(
                        ecoleNom: d['ecoleNom'] ?? '', classeNom: d['classeNom'] ?? '',
                        eleveNom: d['eleveNom'] ?? eleveNom,
                        generale: moy, parMatiere: parMat, rang: rang, total: total);
                      await Printing.sharePdf(bytes: bytes,
                          filename: 'bulletin_${(d['eleveNom'] ?? eleveNom).toString().replaceAll(' ', '_')}.pdf');
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Partager'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () async {
                      final bytes = await buildBulletinPdf(
                        ecoleNom: d['ecoleNom'] ?? '', classeNom: d['classeNom'] ?? '',
                        eleveNom: d['eleveNom'] ?? eleveNom,
                        generale: moy, parMatiere: parMat, rang: rang, total: total);
                      await Printing.layoutPdf(onLayout: (_) async => bytes);
                    },
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Imprimer'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        side: const BorderSide(color: AppColors.green),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  )),
                ]),
              ],
            ]),
          );
        }),
    );
  }

  Widget _ligneSynthese(String label, String valeur, Color col) {
    return Row(children:[
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
      Text(valeur, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: col)),
    ]);
  }
}

// ══════════════════════════════════════════
//  ABONNEMENTS — TABLEAU DE BORD (directeur)
// ══════════════════════════════════════════
class AbonnementsDirecteurPage extends StatefulWidget {
  final AppUser user;
  const AbonnementsDirecteurPage({super.key, required this.user});
  @override State<AbonnementsDirecteurPage> createState() => _AbonnementsDirecteurPageState();
}

class _AbonnementsDirecteurPageState extends State<AbonnementsDirecteurPage> {
  bool _loading = true;
  int _auto = 0;        // élèves comptés automatiquement
  int? _override;       // nombre corrigé à la main (null = auto)
  bool _saving = false;
  final _ctrl = TextEditingController();

  @override
  void initState() { super.initState(); _charger(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _charger() async {
    try {
      final auto = await FirebaseService.compterEleves(widget.user.school);
      final ecole = await FirebaseService.getEcole(widget.user.school);
      final data = ecole.data() as Map<String,dynamic>?;
      final over = (data != null && data['elevesFactures'] is num)
          ? (data['elevesFactures'] as num).toInt() : null;
      if (!mounted) return;
      setState(() {
        _auto = auto; _override = over;
        _ctrl.text = '${over ?? auto}';
        _loading = false;
      });
    } catch (_) { if (mounted) setState(()=> _loading = false); }
  }

  int get _nbFacture {
    final v = int.tryParse(_ctrl.text.trim());
    return (v == null || v < 0) ? _auto : v;
  }

  Future<void> _enregistrer() async {
    final v = int.tryParse(_ctrl.text.trim());
    if (v == null || v < 0) { showSnack(context, 'Entrez un nombre valide', error:true); return; }
    setState(()=> _saving = true);
    try {
      // Si le nombre = comptage auto, on efface l'override (retour au mode auto).
      await FirebaseService.setElevesFactures(widget.user.school, v == _auto ? null : v);
      if (!mounted) return;
      setState(() { _override = (v == _auto) ? null : v; _saving = false; });
      showSnack(context, 'Nombre d eleves enregistre.');
    } catch (_) {
      if (mounted) { setState(()=> _saving = false); showSnack(context, 'Erreur d enregistrement.', error:true); }
    }
  }

  Future<void> _revenirAuto() async { _ctrl.text = '$_auto'; await _enregistrer(); }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final nb = _nbFacture;
    final prix = prixParEleve(nb);
    final total = forfaitMensuelEcole(nb);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        SectionTitle('Forfait de votre ecole'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors:[AppColors.green, Color(0xFF0E9F5B)]),
              borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            const Text('A payer ce mois',
                style: TextStyle(color: Colors.white70, fontSize:13, fontWeight: FontWeight.w600)),
            const SizedBox(height:4),
            Text('${fmtF(total)} FCFA',
                style: const TextStyle(color: Colors.white, fontSize:30, fontWeight: FontWeight.w800)),
            const SizedBox(height:6),
            Text('$nb eleves  x  ${fmtF(prix)} F / eleve',
                style: const TextStyle(color: Colors.white, fontSize:12.5)),
          ]),
        ),
        const SizedBox(height:16),

        SectionTitle('Grille tarifaire'),
        SCCard(child: Column(children:[
          _ligneP('1 a 200 eleves',      '1 000 F / eleve', nb <= 200),
          const Divider(height:16),
          _ligneP('201 a 500 eleves',    '750 F / eleve',   nb > 200 && nb <= 500),
          const Divider(height:16),
          _ligneP('Plus de 500 eleves',  '500 F / eleve',   nb > 500),
        ])),
        const SizedBox(height:16),

        SectionTitle('Nombre d eleves factures'),
        SCCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text('Compte automatiquement : $_auto eleves inscrits'
               '${_override != null ? '  (corrige a la main)' : ''}',
              style: const TextStyle(fontSize:12.5, color: AppColors.textMuted)),
          const SizedBox(height:10),
          Row(children:[
            Expanded(child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              onChanged: (_)=> setState((){}),
              decoration: const InputDecoration(labelText: 'Nombre d eleves', isDense: true),
            )),
            const SizedBox(width:10),
            ElevatedButton(
              onPressed: _saving ? null : _enregistrer,
              child: _saving
                  ? const SizedBox(height:18,width:18,child: CircularProgressIndicator(strokeWidth:2, color:Colors.white))
                  : const Text('Enregistrer')),
          ]),
          const SizedBox(height:6),
          TextButton.icon(
            onPressed: _saving ? null : _revenirAuto,
            icon: const Icon(Icons.autorenew_rounded, size:18),
            label: Text('Revenir au comptage auto ($_auto)')),
        ])),
        const SizedBox(height:16),

        SectionTitle('Paiements de votre ecole'),
        FutureBuilder<List<Map<String,dynamic>>>(
          future: FirebaseService.paiementsEcole(widget.user.school),
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final l = snap.data!;
            final moisNow = moisCode(DateTime.now());
            final payeCeMois = l.any((p) => p['mois'] == moisNow);
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom:10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: payeCeMois ? AppColors.greenBg : AppColors.goldBg,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children:[
                  Icon(payeCeMois ? Icons.check_circle_rounded : Icons.hourglass_bottom_rounded,
                      size: 18, color: payeCeMois ? AppColors.green : AppColors.gold),
                  const SizedBox(width:8),
                  Expanded(child: Text(
                      payeCeMois
                          ? '${moisLabelFr(DateTime.now())} : paye. Merci ! ✓'
                          : '${moisLabelFr(DateTime.now())} : en attente de paiement.',
                      style: TextStyle(fontSize:12.5, fontWeight: FontWeight.w800,
                          color: payeCeMois ? AppColors.green : AppColors.gold))),
                ]),
              ),
              if (l.isEmpty)
                SCCard(child: const Text('Aucun paiement enregistre pour le moment.',
                    style: TextStyle(color: AppColors.textMuted)))
              else
                ...l.take(12).map((p) => Container(
                  margin: const EdgeInsets.only(bottom:8),
                  padding: const EdgeInsets.symmetric(horizontal:12, vertical:10),
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                  child: Row(children:[
                    const Icon(Icons.receipt_long_rounded, size:18, color: AppColors.green),
                    const SizedBox(width:10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                      Text('${p['moisLabel'] ?? ''}',
                          style: const TextStyle(fontSize:12.5, fontWeight: FontWeight.w700)),
                      Text('${p['numeroRecu'] ?? ''} · ${p['methode'] ?? ''} · ${p['dateStr'] ?? ''}',
                          style: const TextStyle(fontSize:11, color: AppColors.textMuted)),
                    ])),
                    Text('${fmtF((p['montant'] as num?) ?? 0)} F',
                        style: const TextStyle(fontSize:12.5, fontWeight: FontWeight.w800, color: AppColors.green)),
                    IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Telecharger le recu',
                        onPressed: () async {
                          final bytes = await genererRecuPdf(p);
                          await Printing.sharePdf(bytes: bytes,
                              filename: '${p['numeroRecu'] ?? 'recu'}.pdf');
                        },
                        icon: const Icon(Icons.ios_share_rounded, size:16, color: AppColors.blue)),
                  ]),
                )),
            ]);
          }),
        const SizedBox(height:16),

        SCCard(child: const Row(children:[
          Icon(Icons.info_outline_rounded, size:18, color: AppColors.blue),
          SizedBox(width:10),
          Expanded(child: Text(
              'Le paiement en ligne du forfait arrive bientot. '
              'En attendant, ce montant sert de reference pour la facturation.',
              style: TextStyle(fontSize:12, color: AppColors.textMuted))),
        ])),
      ]),
    );
  }

  Widget _ligneP(String palier, String prix, bool actif) => Row(children:[
    Icon(actif ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
        size:18, color: actif ? AppColors.green : AppColors.textMuted),
    const SizedBox(width:10),
    Expanded(child: Text(palier, style: TextStyle(fontSize:13,
        fontWeight: actif ? FontWeight.w800 : FontWeight.w500,
        color: actif ? AppColors.textMain : AppColors.textMuted))),
    Text(prix, style: TextStyle(fontSize:12.5, fontWeight: FontWeight.w700,
        color: actif ? AppColors.green : AppColors.textMuted)),
  ]);
}

// ══════════════════════════════════════════
//  MES ENFANTS (multi-enfants, parent)
// ══════════════════════════════════════════
class MesEnfantsPage extends StatefulWidget {
  final AppUser user;
  const MesEnfantsPage({super.key, required this.user});
  @override State<MesEnfantsPage> createState() => _MesEnfantsPageState();
}

class _MesEnfantsPageState extends State<MesEnfantsPage> {
  List<({String id, String nom, String? classeId})> _enfants = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    setState(() => _loading = true);
    final e = await FirebaseService.getEnfants(widget.user.uid);
    if (mounted) setState(() { _enfants = e; _loading = false; });
  }

  Future<void> _ajouterDialog() async {
    final codeCtrl = TextEditingController();
    Map<String,dynamic>? trouve; String? trouveId;
    await showDialog(context: context, builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setD) {
        Future<void> verifier() async {
          final snap = await FirebaseService.findEleveParCode(codeCtrl.text);
          final eleves = snap.docs.where((d) => (d.data() as Map)['role'] == 'eleve').toList();
          if (eleves.isEmpty) { if (mounted) showSnack(context, 'Code introuvable', error: true); return; }
          setD(() { trouve = eleves.first.data() as Map<String,dynamic>; trouveId = eleves.first.id; });
        }
        return AlertDialog(
          title: const Text('Ajouter un enfant'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Saisissez le code que l ecole vous a remis pour cet enfant.',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            TextField(controller: codeCtrl, textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Code de l enfant')),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: OutlinedButton(onPressed: verifier,
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.green, side: const BorderSide(color: AppColors.green)),
                child: const Text('Verifier le code'))),
            if (trouve != null) Padding(padding: const EdgeInsets.only(top: 10),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Enfant : ${trouve!['nom'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.green))),
                ])),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: trouve == null ? null : () async {
                if (_enfants.any((e) => e.id == trouveId)) {
                  if (mounted) showSnack(context, 'Cet enfant est deja rattache', error: true); return;
                }
                await FirebaseService.ajouterEnfant(widget.user.uid, trouveId!);
                if (!mounted) return;
                Navigator.pop(ctx);
                showSnack(context, 'Enfant ajoute ! 🎉');
                _charger();
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes enfants')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterDialog, backgroundColor: AppColors.green,
        icon: const Icon(Icons.person_add_rounded), label: const Text('Ajouter')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              ..._enfants.map((e) => Container(
                    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(radius: 18, backgroundColor: AppColors.greenBg,
                            child: Text(e.nom.isNotEmpty ? e.nom[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(e.nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                        const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                      ]),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: OutlinedButton.icon(
                        onPressed: () => dialogCreerAccesEleve(context, e.id, ''),
                        icon: const Icon(Icons.vpn_key_rounded, size: 15),
                        label: const Text('Creer l acces de mon enfant', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.blue,
                            side: const BorderSide(color: AppColors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                      )),
                    ]),
                  )),
              if (_enfants.isEmpty) const Text('Aucun enfant rattache.', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 80),
            ]),
    );
  }
}

// ══════════════════════════════════════════
//  DEVOIRS PAGE — TEMPS REEL
// ══════════════════════════════════════════
class DevoirsPage extends StatefulWidget {
  final AppUser user;
  const DevoirsPage({super.key, required this.user});
  @override State<DevoirsPage> createState() => _DevoirsPageState();
}

class _DevoirsPageState extends State<DevoirsPage> {
  final _titreCtrl = TextEditingController();
  final _dateCtrl  = TextEditingController();
  String _selMat   = 'Mathematiques';
  String _selTypeDevoir = 'Devoir programme';
  String? _selClasseId;     // classe choisie par le prof
  String? _selClasseNom;

  final _typesDevoir = ['Devoir programme','Devoir de maison','Interrogation'];

  bool get _matiereVerrouillee =>
      widget.user.matiere != null && widget.user.matiere!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_matiereVerrouillee) _selMat = widget.user.matiere!;
  }

  @override
  void dispose() { _titreCtrl.dispose(); _dateCtrl.dispose(); super.dispose(); }

  Future<void> _publier() async {
    if (_selClasseId == null) {
      showSnack(context, 'Choisissez une classe', error:true); return;
    }
    if (_titreCtrl.text.isEmpty) {
      showSnack(context, 'Renseignez le devoir', error:true); return;
    }
    await FirebaseService.publierDevoir({
      'titre':        _titreCtrl.text,
      'matiere':      _selMat,
      'typeDevoir':   _selTypeDevoir,
      'date':         _dateCtrl.text.isEmpty ? 'A definir' : _dateCtrl.text,
      'ecoleId':      widget.user.school,
      'classeId':     _selClasseId,
      'classe':       _selClasseNom ?? '',
      'professeurId': widget.user.uid,
    });
    _titreCtrl.clear(); _dateCtrl.clear();
    if (mounted) showSnack(context, 'Devoir publie — Eleves et parents notifies 📲');
  }

  @override
  Widget build(BuildContext context) {
    final isProf = widget.user.role==UserRole.prof || widget.user.role==UserRole.admin;
    // Classe à afficher : le prof voit celle qu'il choisit, l'élève/parent la sienne
    final classeAffichee = isProf ? _selClasseId : widget.user.classeId;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        if (isProf) ...[
          SectionTitle('Publier un devoir'),
          SCCard(child: Column(children:[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.streamClasses(widget.user.school),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Text('Chargement des classes...',
                      style: TextStyle(color: AppColors.textMuted));
                }
                // Limiter aux classes du prof (si assignées)
                final classesProf = widget.user.classes;
                final classes = classesProf.isEmpty
                    ? snap.data!.docs
                    : snap.data!.docs.where((c)=>classesProf.contains(c.id)).toList();
                if (classes.isEmpty) {
                  return const Text('Aucune classe assignee.',
                      style: TextStyle(color: AppColors.textMuted));
                }
                return DropdownButtonFormField<String>(
                    value: _selClasseId, isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Classe'),
                    hint: const Text('Choisir une classe'),
                    items: classes.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(value: doc.id, child: Text(d['nom'] ?? doc.id));
                    }).toList(),
                    onChanged: (v) {
                      final doc = classes.firstWhere((c) => c.id == v);
                      final d = doc.data() as Map<String, dynamic>;
                      setState(() { _selClasseId = v; _selClasseNom = d['nom'] ?? v; });
                    });
              }),
            const SizedBox(height:10),
            if (_matiereVerrouillee)
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Matiere'),
                child: Text(_selMat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))
            else
              DropdownButtonFormField<String>(
                  value: _selMat,
                  decoration: const InputDecoration(labelText: 'Matiere'),
                  items: ['Mathematiques','Physique-Chimie','SVT','Francais','Anglais','Histoire-Geo']
                      .map((m) => DropdownMenuItem(value:m, child:Text(m))).toList(),
                  onChanged: (v) => setState(() => _selMat = v!)),
            const SizedBox(height:10),
            DropdownButtonFormField<String>(
                value: _selTypeDevoir,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Type de devoir'),
                items: _typesDevoir.map((t) => DropdownMenuItem(value:t, child:Text(t))).toList(),
                onChanged: (v) => setState(() => _selTypeDevoir = v!)),
            const SizedBox(height:10),
            TextField(controller:_titreCtrl,
                decoration:const InputDecoration(labelText:'Description du devoir')),
            const SizedBox(height:10),
            TextField(controller:_dateCtrl,
                decoration:const InputDecoration(labelText:'Date limite (JJ/MM/AAAA)')),
            const SizedBox(height:14),
            SizedBox(width:double.infinity, child:ElevatedButton(
                onPressed:_publier,
                child:const Text('Publier — Notifier parents et eleves 📲'))),
          ])),
          const SizedBox(height:20),
        ],

        SectionTitle('Devoirs en cours'),
        if (classeAffichee == null)
          SCCard(child: Text(
              isProf ? 'Choisissez une classe pour voir ses devoirs.'
                     : 'Aucune classe rattachee a ce compte.',
              style: const TextStyle(color:AppColors.textMuted)))
        else
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamDevoirsParClasse(classeAffichee),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.docs.isEmpty)
                return SCCard(child: const Text('Aucun devoir publie.',
                    style:TextStyle(color:AppColors.textMuted)));
              final docs = snap.data!.docs.toList()
                ..sort((a,b){
                  final ta = (a.data() as Map)['createdAt'];
                  final tb = (b.data() as Map)['createdAt'];
                  if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
                  return 0;
                });
              return SCCard(child: Column(
                  children: docs.map((d) {
                    final data = d.data() as Map<String,dynamic>;
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical:8),
                        child: Row(children:[
                          Container(width:8, height:8,
                              decoration: const BoxDecoration(
                                  color:AppColors.orange, shape:BoxShape.circle)),
                          const SizedBox(width:10),
                          Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                            Text(data['titre'] ?? '',
                                style:const TextStyle(fontSize:13, fontWeight:FontWeight.w600)),
                            Text('${data['matiere'] ?? ''}${data['typeDevoir'] != null ? ' · ${data['typeDevoir']}' : ''}',
                                style:const TextStyle(fontSize:12, color:AppColors.textMuted)),
                          ])),
                          Text(data['date'] ?? '',
                              style:const TextStyle(fontSize:12, fontWeight:FontWeight.w700, color:AppColors.orange)),
                        ]));
                  }).toList()));
            }),
      ]),
    );
  }
}

// ══════════════════════════════════════════
//  ABSENCES / PRÉSENCES
// ══════════════════════════════════════════
class AbsencesPage extends StatefulWidget {
  final AppUser user;
  const AbsencesPage({super.key, required this.user});
  @override State<AbsencesPage> createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  String? _selClasseId;
  late final TextEditingController _dateCtrl;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final d = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
    _dateCtrl = TextEditingController(text: d);
  }

  @override
  void dispose() { _dateCtrl.dispose(); super.dispose(); }

  Future<void> _marquer(String eleveId, String eleveNom, String statut) async {
    if (_selClasseId == null) { showSnack(context, 'Choisissez une classe', error:true); return; }
    final date = _dateCtrl.text.trim().isEmpty
        ? DateTime.now().toString().substring(0,10)
        : _dateCtrl.text.trim();
    await FirebaseService.ajouterAbsence({
      'eleveId': eleveId,
      'eleveNom': eleveNom,
      'ecoleId': widget.user.school,
      'classeId': _selClasseId,
      'date': date,
      'statut': statut, // 'absent' ou 'retard'
      'justifie': false,
      'professeurId': widget.user.uid,
    });
    if (mounted) {
      showSnack(context, '$eleveNom : ${statut == 'absent' ? 'absent' : 'en retard'} le $date');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProf = widget.user.role==UserRole.prof || widget.user.role==UserRole.admin;

    if (isProf) {
      // ---- PROF : faire l'appel ----
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          SectionTitle('Faire l appel'),
          SCCard(child: Column(children:[
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.streamClasses(widget.user.school),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Text('Chargement des classes...',
                      style: TextStyle(color: AppColors.textMuted));
                }
                final classesProf = widget.user.classes;
                final classes = classesProf.isEmpty
                    ? snap.data!.docs
                    : snap.data!.docs.where((c)=>classesProf.contains(c.id)).toList();
                if (classes.isEmpty) {
                  return const Text('Aucune classe assignee.',
                      style: TextStyle(color: AppColors.textMuted));
                }
                return DropdownButtonFormField<String>(
                    value: _selClasseId, isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Classe'),
                    hint: const Text('Choisir une classe'),
                    items: classes.map((doc) {
                      final d = doc.data() as Map<String,dynamic>;
                      return DropdownMenuItem(value: doc.id, child: Text(d['nom'] ?? doc.id));
                    }).toList(),
                    onChanged: (v)=>setState(()=>_selClasseId=v));
              }),
            const SizedBox(height:10),
            TextField(controller: _dateCtrl,
                decoration: const InputDecoration(labelText: 'Date (AAAA-MM-JJ)')),
          ])),
          const SizedBox(height:20),
          SectionTitle('Eleves de la classe'),
          if (_selClasseId == null)
            SCCard(child: const Text('Choisissez une classe ci-dessus.',
                style: TextStyle(color: AppColors.textMuted)))
          else
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamEleves(widget.user.school),
            builder: (ctx, snap) {
              if (snap.connectionState==ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              final eleves = (snap.data?.docs ?? [])
                  .where((d)=>(d.data() as Map)['classeId']==_selClasseId).toList();
              if (eleves.isEmpty)
                return SCCard(child: const Text('Aucun eleve dans cette classe.',
                    style: TextStyle(color: AppColors.textMuted)));
              return Column(children: eleves.map((d){
                final data = d.data() as Map<String,dynamic>;
                final nom = (data['nom'] ?? '').toString();
                return Padding(
                  padding: const EdgeInsets.only(bottom:10),
                  child: SCCard(child: Row(children:[
                    Expanded(child: Text(nom,
                        style: const TextStyle(fontSize:13, fontWeight: FontWeight.w700))),
                    OutlinedButton(
                        onPressed: ()=>_marquer(d.id, nom, 'retard'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gold,
                            side: const BorderSide(color: AppColors.gold),
                            padding: const EdgeInsets.symmetric(horizontal:10, vertical:6)),
                        child: const Text('Retard', style: TextStyle(fontSize:12))),
                    const SizedBox(width:8),
                    ElevatedButton(
                        onPressed: ()=>_marquer(d.id, nom, 'absent'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            padding: const EdgeInsets.symmetric(horizontal:10, vertical:8)),
                        child: const Text('Absent', style: TextStyle(fontSize:12))),
                  ])),
                );
              }).toList());
            }),
        ]),
      );
    }

    // ---- ÉLÈVE / PARENT : consulter ----
    final cible = widget.user.role == UserRole.parent ? widget.user.childId : widget.user.uid;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        SectionTitle('Absences et retards'),
        if (cible == null)
          SCCard(child: const Text('Aucun eleve rattache a ce compte.',
              style: TextStyle(color: AppColors.textMuted)))
        else
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.streamAbsencesEleve(cible),
          builder: (ctx, snap) {
            if (snap.connectionState==ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (!snap.hasData || snap.data!.docs.isEmpty)
              return SCCard(child: const Text('Aucune absence enregistree. 👍',
                  style: TextStyle(color: AppColors.textMuted)));
            final docs = snap.data!.docs.toList()
              ..sort((a,b)=>((b.data() as Map)['date']??'').toString()
                  .compareTo(((a.data() as Map)['date']??'').toString()));
            return Column(children: docs.map((d){
              final data = d.data() as Map<String,dynamic>;
              final retard = data['statut']=='retard';
              final justifie = data['justifie']==true;
              return Padding(padding: const EdgeInsets.only(bottom:10),
                child: SCCard(child: Row(children:[
                  Container(width:40,height:40,
                      decoration: BoxDecoration(
                          color: retard?AppColors.goldBg:AppColors.redBg,
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(retard?Icons.schedule_rounded:Icons.event_busy_rounded,
                          color: retard?AppColors.gold:AppColors.red, size:20)),
                  const SizedBox(width:12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    Text(retard?'Retard':'Absence',
                        style: const TextStyle(fontSize:13, fontWeight: FontWeight.w700)),
                    Text(data['date']??'',
                        style: const TextStyle(fontSize:12, color: AppColors.textMuted)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:3),
                      decoration: BoxDecoration(
                          color: justifie?AppColors.greenBg:AppColors.bg,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(justifie?'Justifie':'Non justifie',
                          style: TextStyle(fontSize:10, fontWeight: FontWeight.w800,
                              color: justifie?AppColors.green:AppColors.textMuted))),
                ])),
              );
            }).toList());
          }),
      ]),
    );
  }
}

// ══════════════════════════════════════════
//  LECONS PAGE — TEMPS REEL
// ══════════════════════════════════════════
class LeconsPage extends StatefulWidget {
  final AppUser user;
  const LeconsPage({super.key, required this.user});
  @override State<LeconsPage> createState() => _LeconsPageState();
}

class _LeconsPageState extends State<LeconsPage> {
  final _chapCtrl = TextEditingController();
  final _pctCtrl  = TextEditingController();
  String _selMat  = 'Mathematiques';
  String? _selClasseId;
  String? _selClasseNom;

  bool get _matiereVerrouillee =>
      widget.user.matiere != null && widget.user.matiere!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_matiereVerrouillee) _selMat = widget.user.matiere!;
  }

  @override
  void dispose() { _chapCtrl.dispose(); _pctCtrl.dispose(); super.dispose(); }

  Future<void> _enregistrer() async {
    if (_selClasseId == null) { showSnack(context, 'Choisis d abord une classe', error:true); return; }
    if (_chapCtrl.text.trim().isEmpty) { showSnack(context, 'Indique le chapitre en cours', error:true); return; }
    final pct = (double.tryParse(_pctCtrl.text.trim().replaceAll(',', '.')) ?? 0).clamp(0, 100).toDouble();
    await FirebaseService.setLecon(
      _selClasseId!, _selMat,
      chapitre: _chapCtrl.text.trim(),
      avancement: pct,
      ecoleId: widget.user.school,
    );
    if (!mounted) return;
    _chapCtrl.clear(); _pctCtrl.clear();
    showSnack(context, 'Progression mise a jour 📲');
  }

  // Affiche la progression (lecture seule) d'une classe, matière par matière
  Widget _affichage(String? classeId) {
    if (classeId == null) {
      return SCCard(child: const Text('Aucune classe definie pour le moment.',
          style: TextStyle(color: AppColors.textMuted)));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.streamLeconsParClasse(classeId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()));
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return SCCard(child: const Text('Aucune progression enregistree pour le moment.',
              style: TextStyle(color: AppColors.textMuted)));
        }
        final docs = snap.data!.docs.toList()
          ..sort((a,b)=>((a.data() as Map)['matiere'] ?? '').toString()
              .compareTo(((b.data() as Map)['matiere'] ?? '').toString()));
        return SCCard(child: Column(children: docs.map((d) {
          final data = d.data() as Map<String,dynamic>;
          final pct = (data['avancement'] as num?)?.toDouble() ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom:14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
                Text(data['matiere'] ?? '',
                    style: const TextStyle(fontSize:13, fontWeight: FontWeight.w700)),
                Text('${pct.toInt()}%',
                    style: const TextStyle(fontSize:12, fontWeight: FontWeight.w800, color: AppColors.green)),
              ]),
              const SizedBox(height:2),
              Text(data['chapitre'] ?? '',
                  style: const TextStyle(fontSize:11, color: AppColors.textMuted)),
              const SizedBox(height:5),
              ProgressBar(value: (pct/100).clamp(0,1).toDouble(), color: AppColors.green),
            ]),
          );
        }).toList()));
      });
  }

  @override
  Widget build(BuildContext context) {
    final isProf = widget.user.role == UserRole.prof;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        SectionTitle('Avancement du programme'),

        if (isProf) ...[
          // Le prof choisit l'une de ses classes
          SCCard(child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamClasses(widget.user.school),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Text('Chargement des classes...',
                    style: TextStyle(color: AppColors.textMuted));
              }
              final classesProf = widget.user.classes;
              final classes = classesProf.isEmpty
                  ? snap.data!.docs
                  : snap.data!.docs.where((c)=>classesProf.contains(c.id)).toList();
              if (classes.isEmpty) {
                return const Text('Aucune classe assignee.',
                    style: TextStyle(color: AppColors.textMuted));
              }
              return DropdownButtonFormField<String>(
                  value: _selClasseId, isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Classe'),
                  hint: const Text('Choisir une classe'),
                  items: classes.map((doc) {
                    final d = doc.data() as Map<String,dynamic>;
                    return DropdownMenuItem(value: doc.id, child: Text(d['nom'] ?? doc.id));
                  }).toList(),
                  onChanged: (v) {
                    final doc = classes.firstWhere((c)=>c.id==v);
                    final d = doc.data() as Map<String,dynamic>;
                    setState(() { _selClasseId = v; _selClasseNom = d['nom'] ?? v; });
                  });
            })),
          const SizedBox(height:14),
          if (_selClasseId != null) _affichage(_selClasseId),

          const SizedBox(height:20),
          SectionTitle('Mettre a jour ma matiere'),
          SCCard(child:Column(children:[
            if (_matiereVerrouillee)
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Matiere'),
                child: Text(_selMat, style: const TextStyle(fontSize:14, fontWeight: FontWeight.w600)))
            else
              DropdownButtonFormField<String>(
                  value: _selMat,
                  decoration: const InputDecoration(labelText:'Matiere'),
                  items:['Mathematiques','Physique-Chimie','SVT','Francais','Anglais','Histoire-Geo']
                      .map((m)=>DropdownMenuItem(value:m,child:Text(m))).toList(),
                  onChanged:(v)=>setState(()=>_selMat=v!)),
            const SizedBox(height:10),
            TextField(controller:_chapCtrl,
                decoration:const InputDecoration(labelText:'Chapitre / lecon en cours')),
            const SizedBox(height:10),
            TextField(controller:_pctCtrl, keyboardType:TextInputType.number,
                decoration:const InputDecoration(labelText:'Avancement (%)')),
            const SizedBox(height:14),
            SizedBox(width:double.infinity, child:ElevatedButton(
                onPressed:_enregistrer,
                child:const Text('Mettre a jour 📲'))),
          ])),
        ]
        else ...[
          // Élève / parent : progression de leur classe (lecture seule)
          _affichage(widget.user.classeId),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════
//  ALERTES PAGE — TEMPS REEL
// ══════════════════════════════════════════
class AlertesPage extends StatefulWidget {
  final AppUser user;
  const AlertesPage({super.key, required this.user});
  @override State<AlertesPage> createState() => _AlertesPageState();
}

class _AlertesPageState extends State<AlertesPage> {
  final _msgCtrl = TextEditingController();
  String _selType = 'info';

  Future<void> _publier() async {
    if (_msgCtrl.text.isEmpty) {
      showSnack(context, 'Redigez un message', error:true); return;
    }
    await FirebaseService.ajouterEvenement({
      'titre':   _selType,
      'corps':   _msgCtrl.text,
      'type':    _selType,
      'ecoleId': widget.user.school,
      'lu':      false,
    });
    _msgCtrl.clear();
    if (mounted) showSnack(context, 'Alerte envoyee — Notification push 📲');
  }

  @override
  Widget build(BuildContext context) {
    final isProf = widget.user.role==UserRole.prof || widget.user.role==UserRole.admin;
    final typeColors = {
      'info':    (AppColors.blue,   AppColors.blueBg),
      'danger':  (AppColors.red,    AppColors.redBg),
      'success': (AppColors.green,  AppColors.greenBg),
      'warn':    (AppColors.gold,   AppColors.goldBg),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        if (isProf) ...[
          SectionTitle('Publier une alerte'),
          SCCard(child:Column(children:[
            DropdownButtonFormField<String>(
                value: _selType,
                decoration: const InputDecoration(labelText:'Type'),
                items: {
                  'info':'Information',
                  'danger':'Sanction',
                  'success':'Felicitations',
                  'warn':'Avertissement',
                }.entries.map((e)=>DropdownMenuItem(value:e.key,child:Text(e.value))).toList(),
                onChanged:(v)=>setState(()=>_selType=v!)),
            const SizedBox(height:10),
            TextField(controller:_msgCtrl, maxLines:3,
                decoration:const InputDecoration(
                    labelText:'Message', alignLabelWithHint:true)),
            const SizedBox(height:14),
            SizedBox(width:double.infinity, child:ElevatedButton(
                onPressed:_publier,
                child:const Text('Envoyer — Notification push immediate 📲'))),
          ])),
          const SizedBox(height:20),
        ],

        SectionTitle('Toutes les alertes'),
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamAlertes(widget.user.uid),
            builder:(ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child:CircularProgressIndicator());
              if (!snap.hasData || snap.data!.docs.isEmpty)
                return SCCard(child:const Text('Aucune alerte.',
                    style:TextStyle(color:AppColors.textMuted)));
              return Column(children: snap.data!.docs.map((d) {
                final data = d.data() as Map<String,dynamic>;
                final tc = typeColors[data['type']] ?? (AppColors.blue, AppColors.blueBg);
                return Container(
                    margin: const EdgeInsets.only(bottom:8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: tc.$2,
                        border: Border(left:BorderSide(color:tc.$1, width:4)),
                        borderRadius: BorderRadius.circular(10)),
                    child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                      Text(data['titre'] ?? '',
                          style:const TextStyle(fontSize:13, fontWeight:FontWeight.w700)),
                      const SizedBox(height:2),
                      Text(data['corps'] ?? '',
                          style:const TextStyle(fontSize:12, color:AppColors.textMuted)),
                    ]));
              }).toList());
            }),
      ]),
    );
  }
}

// ══════════════════════════════════════════
//  MESSAGERIE — TEMPS REEL
// ══════════════════════════════════════════
// Couleur / libellé par rôle (réutilisables)
final Map<UserRole, Color> kRoleCouleur = {
  UserRole.admin: AppColors.purple, UserRole.directeur: AppColors.gold,
  UserRole.prof: AppColors.orange, UserRole.eleve: AppColors.green, UserRole.parent: AppColors.blue,
};
final Map<UserRole, String> kRoleNom = {
  UserRole.admin:'Super Admin', UserRole.directeur:'Directeur',
  UserRole.prof:'Professeur', UserRole.eleve:'Eleve', UserRole.parent:'Parent',
};

// Pastille rouge avec compteur de messages non lus
class _PastilleNonLus extends StatelessWidget {
  final int n;
  const _PastilleNonLus({required this.n});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18),
      decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1.5)),
      child: Text(n > 9 ? '9+' : '$n',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

class MessageriePage extends StatelessWidget {
  final AppUser user;
  const MessageriePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messagerie')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.streamMessagesRecus(user.uid),
        builder: (ctx, msnap) {
          // Expéditeurs dont j'ai des messages non lus
          final nonLusParExp = <String,int>{};
          if (msnap.hasData) {
            for (final d in msnap.data!.docs) {
              final m = d.data() as Map;
              if (m['lu'] != true && m['de'] != null) {
                final de = m['de'].toString();
                nonLusParExp[de] = (nonLusParExp[de] ?? 0) + 1;
              }
            }
          }
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamUtilisateursParEcole(user.school),
            builder: (ctx2, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final contacts = contactsMessagerie(user, snap.data!.docs);
              if (contacts.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(28),
                    child: Text('Aucun contact disponible pour le moment.',
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted))));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: contacts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final c = contacts[i];
                  final col = kRoleCouleur[c.role] ?? AppColors.green;
                  final nl = nonLusParExp[c.uid] ?? 0;
                  return SCCard(child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ConversationPage(
                            user: user, contactUid: c.uid, contactNom: c.nom, contactRole: c.role))),
                    child: Row(children: [
                      Stack(clipBehavior: Clip.none, children: [
                        CircleAvatar(radius: 20, backgroundColor: col.withOpacity(.15),
                            child: Text(c.nom.isNotEmpty ? c.nom[0].toUpperCase() : '?',
                                style: TextStyle(color: col, fontWeight: FontWeight.w800))),
                        if (nl > 0) Positioned(right: -4, top: -4, child: _PastilleNonLus(n: nl)),
                      ]),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.nom, style: TextStyle(fontSize: 14,
                            fontWeight: nl>0 ? FontWeight.w800 : FontWeight.w700)),
                        Text(
                            c.role == UserRole.prof && (c.matiere ?? '').isNotEmpty
                                ? 'Professeur · ${c.matiere}'
                                : (kRoleNom[c.role] ?? ''),
                            style: TextStyle(fontSize: 11.5, color: col, fontWeight: FontWeight.w600)),
                      ])),
                      if (nl > 0)
                        const Icon(Icons.circle, color: AppColors.red, size: 10)
                      else
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ]),
                  ));
                });
            });
        }),
    );
  }
}

class ConversationPage extends StatefulWidget {
  final AppUser user;
  final String contactUid, contactNom;
  final UserRole contactRole;
  const ConversationPage({super.key, required this.user,
      required this.contactUid, required this.contactNom, required this.contactRole});
  @override State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _ctrl = TextEditingController();
  late final String _convId = FirebaseService.convId(widget.user.uid, widget.contactUid);

  @override
  void initState() {
    super.initState();
    // Ouvrir la conversation = marquer ses messages comme lus
    FirebaseService.marquerConversationLue(_convId, widget.user.uid);
  }

  Future<void> _send() async {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    _ctrl.clear();
    await FirebaseService.envoyerMessage({
      'de': widget.user.uid,
      'vers': widget.contactUid,
      'conversationId': _convId,
      'texte': v,
      'ecoleId': widget.user.school,
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contactNom)),
      body: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.streamConversation(_convId),
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs.toList()
              ..sort((a, b) {
                final ta = (a.data() as Map)['createdAt'];
                final tb = (b.data() as Map)['createdAt'];
                if (ta is Timestamp && tb is Timestamp) return ta.compareTo(tb);
                return 0;
              });
            if (docs.isEmpty) {
              return const Center(child: Text('Demarrez la conversation 👋',
                  style: TextStyle(color: AppColors.textMuted)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (_, i) {
                final m = docs[i].data() as Map<String, dynamic>;
                final moi = m['de'] == widget.user.uid;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: moi ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .72),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: moi ? AppColors.green : Colors.white,
                          border: moi ? null : Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(moi ? 14 : 4),
                            bottomRight: Radius.circular(moi ? 4 : 14))),
                        child: Text(m['texte'] ?? '',
                            style: TextStyle(fontSize: 13, color: moi ? Colors.white : AppColors.textMain)),
                      ),
                    ]),
                );
              });
          })),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Expanded(child: TextField(controller: _ctrl,
                decoration: const InputDecoration(hintText: 'Votre message...', border: InputBorder.none),
                onSubmitted: (_) => _send())),
            IconButton(icon: const Icon(Icons.send_rounded),
                color: AppColors.green, onPressed: _send),
          ])),
      ]),
    );
  }
}


// ══════════════════════════════════════════
//  ECOLES PAGE (ADMIN) — TEMPS REEL
// ══════════════════════════════════════════
class EcolesPage extends StatefulWidget {
  final AppUser user;
  const EcolesPage({super.key, required this.user});
  @override State<EcolesPage> createState() => _EcolesPageState();
}

class _EcolesPageState extends State<EcolesPage> {
  final _nomCtrl  = TextEditingController();
  final _nbCtrl   = TextEditingController();
  String _commune = 'Cocody';

  void _showAdd() {
    showModalBottomSheet(context:context, isScrollControlled:true,
        shape:const RoundedRectangleBorder(
            borderRadius:BorderRadius.vertical(top:Radius.circular(20))),
        builder:(_)=>StatefulBuilder(builder:(ctx, ss)=>Padding(
            padding:EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(context).viewInsets.bottom+20),
            child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
              const Text('Ajouter une ecole',
                  style:TextStyle(fontSize:17,fontWeight:FontWeight.w800)),
              const SizedBox(height:16),
              TextField(controller:_nomCtrl,
                  decoration:const InputDecoration(labelText:"Nom de l ecole")),
              const SizedBox(height:10),
              Row(children:[
                Expanded(child:DropdownButtonFormField<String>(value:_commune,
                    decoration:const InputDecoration(labelText:'Commune'),
                    items:['Cocody','Marcory','Plateau','Yopougon','Abobo','Adjame']
                        .map((c)=>DropdownMenuItem(value:c,child:Text(c))).toList(),
                    onChanged:(v)=>ss(()=>_commune=v!))),
              ]),
              const SizedBox(height:10),
              TextField(controller:_nbCtrl, keyboardType:TextInputType.number,
                  decoration:const InputDecoration(labelText:"Nombre d eleves")),
              const SizedBox(height:16),
              SizedBox(width:double.infinity, child:ElevatedButton(
                  onPressed:() async {
                    if (_nomCtrl.text.isEmpty) return;
                    await FirebaseService.ajouterEcole({
                      'nom':     _nomCtrl.text,
                      'commune': _commune,
                      'eleves':  int.tryParse(_nbCtrl.text)??0,
                      'statut':  'actif',
                    });
                    _nomCtrl.clear(); _nbCtrl.clear();
                    if (mounted) {
                      Navigator.pop(context);
                      showSnack(context, 'Ecole ajoutee avec succes !');
                    }
                  },
                  child:const Text('Creer l ecole'))),
            ]))));
  }

  @override
  Widget build(BuildContext context) => Column(children:[
    Padding(padding:const EdgeInsets.all(16),
        child:Row(children:[
          Expanded(child:ElevatedButton.icon(
              onPressed:_showAdd,
              icon:const Icon(Icons.add), label:const Text('Ajouter une ecole'))),
        ])),
    Expanded(child:StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.streamEcoles(),
        builder:(ctx, snap){
          if (snap.connectionState==ConnectionState.waiting)
            return const Center(child:CircularProgressIndicator());
          if (!snap.hasData||snap.data!.docs.isEmpty)
            return const Center(child:Text('Aucune ecole enregistree.'));
          return ListView.separated(
              padding:const EdgeInsets.fromLTRB(16,0,16,16),
              itemCount:snap.data!.docs.length,
              separatorBuilder:(_,__)=>const SizedBox(height:12),
              itemBuilder:(_,i){
                final data = snap.data!.docs[i].data() as Map<String,dynamic>;
                final actif = data['statut']=='actif';
                return SCCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Row(children:[
                    Container(width:40,height:40,
                        decoration:BoxDecoration(color:AppColors.greenBg,borderRadius:BorderRadius.circular(10)),
                        child:const Center(child:Icon(Icons.school_rounded,color:AppColors.green))),
                    const SizedBox(width:12),
                    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                      Text(data['nom']??'',
                          style:const TextStyle(fontSize:14,fontWeight:FontWeight.w700)),
                      Text('${data['commune']??''} · ${data['eleves']??0} eleves',
                          style:const TextStyle(fontSize:12,color:AppColors.textMuted)),
                    ])),
                    Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
                        decoration:BoxDecoration(
                            color:actif?AppColors.greenBg:AppColors.goldBg,
                            borderRadius:BorderRadius.circular(20)),
                        child:Text(actif?'Actif':'Inactif',
                            style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,
                                color:actif?AppColors.green:AppColors.gold))),
                  ]),
                ]));
              });
        })),
  ]);
}

// ══════════════════════════════════════════
//  UTILISATEURS PAGE (ADMIN)
// ══════════════════════════════════════════
Future<void> dialogCreerAccesEleve(BuildContext context, String eleveDocId, String code) async {
  final emailCtrl = TextEditingController(
      text: code.isNotEmpty ? 'eleve.${code.toLowerCase()}@sentinelci.ci' : '');
  final pwCtrl = TextEditingController(text: code.isNotEmpty ? code : '');
  bool loading = false;
  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => AlertDialog(
      title: const Text('Creer un acces eleve'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text(
            'Donnez a cet eleve un identifiant et un mot de passe pour qu il puisse '
            'se connecter. Ses notes et son code parent restent inchanges.',
            style: TextStyle(fontSize: 13)),
        const SizedBox(height: 12),
        TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail de connexion')),
        const SizedBox(height: 8),
        TextField(controller: pwCtrl,
            decoration: const InputDecoration(labelText: 'Mot de passe (6 caracteres min)')),
      ]),
      actions: [
        TextButton(onPressed: loading ? null : () => Navigator.pop(ctx),
            child: const Text('Annuler')),
        ElevatedButton(
          onPressed: loading ? null : () async {
            final email = emailCtrl.text.trim();
            final pw = pwCtrl.text.trim();
            if (email.isEmpty || pw.length < 6) {
              showSnack(context, 'E-mail requis et mot de passe 6 caracteres min', error: true);
              return;
            }
            setSt(() => loading = true);
            final err = await FirebaseService.creerAccesEleve(
                eleveDocId: eleveDocId, email: email, motDePasse: pw);
            if (!ctx.mounted) return;
            if (err == null) {
              Navigator.pop(ctx);
              showSnack(context, 'Acces cree ! L eleve peut se connecter avec cet e-mail.');
            } else {
              setSt(() => loading = false);
              showSnack(context, err, error: true);
            }
          },
          child: Text(loading ? '...' : 'Creer'),
        ),
      ],
    )),
  );
}

class ImportElevesPage extends StatefulWidget {
  final AppUser user;
  const ImportElevesPage({super.key, required this.user});
  @override State<ImportElevesPage> createState() => _ImportElevesPageState();
}

class _ImportElevesPageState extends State<ImportElevesPage> {
  String? _classeId;
  final _noms = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _noms.dispose(); super.dispose(); }

  Future<void> _importer() async {
    if (_classeId == null) { showSnack(context, 'Choisissez une classe', error: true); return; }
    final lignes = _noms.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (lignes.isEmpty) { showSnack(context, 'Collez au moins un nom', error: true); return; }
    setState(() => _loading = true);
    try {
      final n = await FirebaseService.importerEleves(
          ecoleId: widget.user.school, classeId: _classeId!, noms: lignes);
      if (!mounted) return;
      setState(() => _loading = false);
      showSnack(context, '$n eleve(s) importe(s) avec succes !');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showSnack(context, 'Erreur : $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nb = _noms.text.split('\n').where((e) => e.trim().isNotEmpty).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Importer des eleves')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SCCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Importez toute une classe d un coup',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            SizedBox(height: 6),
            Text('Choisissez la classe, puis collez les noms des eleves (un par ligne). '
                'Chaque eleve recevra automatiquement un code parent, visible dans la liste des utilisateurs.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ])),
          const SizedBox(height: 12),
          SCCard(child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.streamClasses(widget.user.school),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Text('Chargement des classes...',
                      style: TextStyle(color: AppColors.textMuted));
                }
                final classes = snap.data!.docs;
                if (classes.isEmpty) {
                  return const Text('Aucune classe. Creez d abord une classe.',
                      style: TextStyle(color: AppColors.textMuted));
                }
                return DropdownButtonFormField<String>(
                    value: _classeId, isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Classe de destination'),
                    hint: const Text('Choisir une classe'),
                    items: classes.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(value: doc.id, child: Text(d['nom'] ?? doc.id));
                    }).toList(),
                    onChanged: (v) => setState(() => _classeId = v));
              })),
          const SizedBox(height: 12),
          SCCard(child: TextField(
            controller: _noms,
            maxLines: 12,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Noms des eleves (un par ligne)',
              hintText: 'Konan Amani\nYao Marie\nTraore Ibrahim',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          )),
          const SizedBox(height: 8),
          Text('$nb eleve(s) a importer',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _loading ? null : _importer,
            icon: _loading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.upload_file_rounded, size: 18),
            label: Text(_loading ? 'Import en cours...' : 'Importer'),
          )),
        ]),
      ),
    );
  }
}

class UtilisateursPage extends StatelessWidget {
  final AppUser user;
  const UtilisateursPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      'eleve':     (AppColors.green,  AppColors.greenBg),
      'parent':    (AppColors.blue,   AppColors.blueBg),
      'prof':      (AppColors.orange, AppColors.orangeBg),
      'directeur': (AppColors.gold,   AppColors.goldBg),
      'admin':     (AppColors.purple, AppColors.purpleBg),
    };
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(children: [
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AjouterUtilisateurPage(user: user))),
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Ajouter un utilisateur'),
          )),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ClassesPage(user: user))),
              icon: const Icon(Icons.class_rounded, size: 18),
              label: const Text('Classes'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MatieresPage(user: user))),
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: const Text('Matieres'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            )),
          ]),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ImportElevesPage(user: user))),
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: const Text('Importer des eleves'),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                side: const BorderSide(color: AppColors.blue),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          )),
        ]),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.streamToutesEcoles(),
          builder: (ctx, ecSnap) {
            // Table de correspondance ecoleId -> nom lisible
            final Map<String, String> noms = {};
            if (ecSnap.hasData) {
              for (final d in ecSnap.data!.docs) {
                final m = d.data() as Map<String, dynamic>;
                noms[d.id] = (m['nom'] ?? d.id).toString();
              }
            }
            return StreamBuilder<QuerySnapshot>(
              stream: user.role == UserRole.directeur
                  ? FirebaseService.streamUtilisateursParEcole(user.school)
                  : FirebaseService.streamUtilisateurs(),
              builder:(ctx, snap){
                if (snap.connectionState==ConnectionState.waiting)
                  return const Center(child:CircularProgressIndicator());
                if (!snap.hasData)
                  return const Center(child:Text('Aucun utilisateur.'));
                var docs = snap.data!.docs.toList();
                // Le directeur ne gère que eleves/profs/parents (pas l'admin ni les autres directeurs)
                if (user.role == UserRole.directeur) {
                  docs = docs.where((d){
                    final r = (d.data() as Map)['role'] ?? 'eleve';
                    return r=='eleve' || r=='prof' || r=='parent';
                  }).toList();
                }
                docs.sort((a,b)=>((a.data() as Map)['nom']??'').toString()
                    .toLowerCase()
                    .compareTo(((b.data() as Map)['nom']??'').toString().toLowerCase()));
                if (docs.isEmpty)
                  return const Center(child:Text('Aucun utilisateur.'));
                return ListView.separated(
                    padding:const EdgeInsets.all(16),
                    itemCount:docs.length,
                    separatorBuilder:(_,__)=>const SizedBox(height:10),
                    itemBuilder:(_,i){
                      final data = docs[i].data() as Map<String,dynamic>;
                      final role = data['role']??'eleve';
                      final rc = roleColors[role]??(AppColors.green,AppColors.greenBg);
                      final ecoleNom = noms[data['ecoleId']] ?? (data['ecoleId'] ?? '');
                      return SCCard(child:Row(children:[
                        CircleAvatar(radius:20, backgroundColor:rc.$1,
                            child:Text((data['nom']??'?')[0].toUpperCase(),
                                style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800))),
                        const SizedBox(width:12),
                        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                          Text(data['nom']??'',
                              style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700)),
                          Text(ecoleNom,
                              style:const TextStyle(fontSize:11,color:AppColors.textMuted)),
                          if (role=='admin' && data['coAdmin']==true)
                            const Padding(padding: EdgeInsets.only(top:3),
                              child: Text('Co-Administrateur (agent Sentinel)',
                                  style: TextStyle(fontSize:11, fontWeight: FontWeight.w700, color: AppColors.purple))),
                          if (role=='prof' && (data['matiere']??'').toString().isNotEmpty)
                            Padding(padding: const EdgeInsets.only(top:3),
                              child: Text('Matiere : ${data['matiere']}',
                                  style: const TextStyle(fontSize:11, fontWeight: FontWeight.w700, color: AppColors.blue))),
                          if (role=='eleve' && (data['codeParent']??'').toString().isNotEmpty)
                            Padding(padding: const EdgeInsets.only(top:3),
                              child: Text('Code parent : ${data['codeParent']}',
                                  style: const TextStyle(fontSize:11, fontWeight: FontWeight.w800, color: AppColors.green))),
                          if (role=='eleve' && (data['email']??'').toString().trim().isEmpty)
                            Padding(padding: const EdgeInsets.only(top:5),
                              child: OutlinedButton.icon(
                                onPressed: () => dialogCreerAccesEleve(
                                    context, docs[i].id, (data['codeParent']??'').toString()),
                                icon: const Icon(Icons.vpn_key_rounded, size: 13),
                                label: const Text('Creer un acces', style: TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.blue,
                                    side: const BorderSide(color: AppColors.blue),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    minimumSize: const Size(0, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              )),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children:[
                          Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:3),
                              decoration:BoxDecoration(color:rc.$2,borderRadius:BorderRadius.circular(8)),
                              child:Text(role,
                                  style:TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:rc.$1))),
                          if (data['bloque']==true)
                            const Padding(padding: EdgeInsets.only(top:4),
                              child: Text('Bloque', style: TextStyle(fontSize:10, fontWeight: FontWeight.w800, color: AppColors.red))),
                        ]),
                        if (user.estSuperAdmin && docs[i].id != user.uid)
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                            onSelected: (v) async {
                              if (v == 'bloquer') {
                                final b = data['bloque'] != true;
                                await FirebaseService.bloquerUtilisateur(docs[i].id, b);
                                if (context.mounted) {
                                  showSnack(context, b ? 'Compte bloque.' : 'Compte debloque.');
                                }
                              } else if (v == 'supprimer') {
                                final ok = await showDialog<bool>(context: context, builder: (dctx) => AlertDialog(
                                  title: const Text('Supprimer ce compte ?'),
                                  content: Text('La fiche de "${data['nom'] ?? ''}" sera definitivement supprimee. '
                                      'Action irreversible.'),
                                  actions: [
                                    TextButton(onPressed: ()=>Navigator.pop(dctx,false), child: const Text('Annuler')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                                      onPressed: ()=>Navigator.pop(dctx,true), child: const Text('Supprimer')),
                                  ],
                                ));
                                if (ok == true) {
                                  await FirebaseService.supprimerUtilisateur(docs[i].id);
                                  if (context.mounted) showSnack(context, 'Compte supprime.');
                                }
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(value:'bloquer',
                                  child: Text(data['bloque']==true ? 'Debloquer' : 'Bloquer')),
                              const PopupMenuItem(value:'supprimer',
                                  child: Text('Supprimer', style: TextStyle(color: AppColors.red))),
                            ],
                          ),
                      ]));
                    });
              });
          }),
      ),
    ]);
  }
}

// ══════════════════════════════════════════
//  CLASSES (ADMIN) — liste + création
// ══════════════════════════════════════════
class ClassesPage extends StatefulWidget {
  final AppUser user;
  const ClassesPage({super.key, required this.user});
  @override State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  final _nom = TextEditingController();
  final _niveau = TextEditingController();
  final _annee = TextEditingController(text: '2025-2026');

  @override
  void dispose() { _nom.dispose(); _niveau.dispose(); _annee.dispose(); super.dispose(); }

  void _showAdd() {
    showModalBottomSheet(context: context, isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ajouter une classe',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(controller: _nom,
                  decoration: const InputDecoration(labelText: 'Nom de la classe (ex: Terminale C)')),
              const SizedBox(height: 10),
              TextField(controller: _niveau,
                  decoration: const InputDecoration(labelText: 'Niveau (ex: Terminale)')),
              const SizedBox(height: 10),
              TextField(controller: _annee,
                  decoration: const InputDecoration(labelText: 'Annee scolaire')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () async {
                    if (_nom.text.trim().isEmpty) {
                      showSnack(context, 'Renseignez le nom de la classe', error: true); return;
                    }
                    await FirebaseService.creerClasse({
                      'nom': _nom.text.trim(),
                      'niveau': _niveau.text.trim(),
                      'anneeScolaire': _annee.text.trim(),
                      'ecoleId': widget.user.school,
                    });
                    _nom.clear(); _niveau.clear();
                    if (mounted) {
                      Navigator.pop(context);
                      showSnack(context, 'Classe ajoutee avec succes !');
                    }
                  },
                  child: const Text('Creer la classe'))),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _showAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ajouter une classe'),
          )),
        ),
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.streamClasses(widget.user.school),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (!snap.hasData || snap.data!.docs.isEmpty)
              return const Center(child: Text('Aucune classe. Ajoutez-en une.'));
            return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: snap.data!.docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final d = snap.data!.docs[i].data() as Map<String, dynamic>;
                  return SCCard(child: Row(children: [
                    Container(width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.class_rounded, color: AppColors.green, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d['nom'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('${d['niveau'] ?? ''}  •  ${d['anneeScolaire'] ?? ''}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ])),
                  ]));
                });
          })),
      ]),
    );
  }
}

// ══════════════════════════════════════════
//  MATIÈRES (ADMIN / DIRECTEUR) — liste + création
// ══════════════════════════════════════════
class MatieresPage extends StatefulWidget {
  final AppUser user;
  const MatieresPage({super.key, required this.user});
  @override State<MatieresPage> createState() => _MatieresPageState();
}

class _MatieresPageState extends State<MatieresPage> {
  final _nom = TextEditingController();

  // Liste de démarrage rapide (matières courantes en Côte d'Ivoire)
  static const _courantes = [
    'Mathematiques','Physique-Chimie','SVT','Francais','Anglais',
    'Histoire-Geographie','EPS','Philosophie','Allemand','Espagnol',
    'Informatique','Education civique et morale','Arts plastiques','Musique',
  ];

  @override
  void dispose() { _nom.dispose(); super.dispose(); }

  void _showAdd() {
    showModalBottomSheet(context: context, isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ajouter une matiere',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(controller: _nom, textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nom de la matiere')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () async {
                    if (_nom.text.trim().isEmpty) {
                      showSnack(context, 'Renseignez le nom', error: true); return;
                    }
                    await FirebaseService.creerMatiere({
                      'nom': _nom.text.trim(),
                      'ecoleId': widget.user.school,
                    });
                    _nom.clear();
                    if (mounted) {
                      Navigator.pop(context);
                      showSnack(context, 'Matiere ajoutee !');
                    }
                  },
                  child: const Text('Creer la matiere'))),
            ])));
  }

  Future<void> _seedCourantes(List<String> existantes) async {
    int ajoutees = 0;
    for (final m in _courantes) {
      if (!existantes.contains(m.toLowerCase())) {
        await FirebaseService.creerMatiere({'nom': m, 'ecoleId': widget.user.school});
        ajoutees++;
      }
    }
    if (mounted) {
      showSnack(context, ajoutees == 0
          ? 'Les matieres courantes sont deja presentes.'
          : '$ajoutees matiere(s) ajoutee(s).');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matieres')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.streamMatieres(widget.user.school),
        builder: (ctx, snap) {
          final docs = snap.hasData ? snap.data!.docs.toList() : [];
          docs.sort((a,b)=>((a.data() as Map)['nom']??'').toString()
              .toLowerCase().compareTo(((b.data() as Map)['nom']??'').toString().toLowerCase()));
          final existantes = docs.map((d)=>((d.data() as Map)['nom']??'').toString().toLowerCase()).toList();
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: _showAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter une matiere'),
                )),
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: OutlinedButton.icon(
                  onPressed: () => _seedCourantes(existantes),
                  icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                  label: const Text('Ajouter les matieres courantes'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green,
                      side: const BorderSide(color: AppColors.green),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                )),
              ]),
            ),
            Expanded(child: !snap.hasData
                ? const Center(child: CircularProgressIndicator())
                : docs.isEmpty
                  ? const Center(child: Text('Aucune matiere. Ajoutez-en une.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        return SCCard(child: Row(children: [
                          Container(width: 38, height: 38,
                              decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.menu_book_rounded, color: AppColors.green, size: 19)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(d['nom'] ?? '',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
                        ]));
                      })),
          ]);
        }),
    );
  }
}

// ══════════════════════════════════════════
//  AJOUTER UN UTILISATEUR (ADMIN) — élève / prof / parent
// ══════════════════════════════════════════
class AjouterUtilisateurPage extends StatefulWidget {
  final AppUser user;
  const AjouterUtilisateurPage({super.key, required this.user});
  @override State<AjouterUtilisateurPage> createState() => _AjouterUtilisateurPageState();
}

class _AjouterUtilisateurPageState extends State<AjouterUtilisateurPage> {
  String _role = 'eleve';
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _matricule = TextEditingController();
  final _matiere = TextEditingController();
  String? _profMatiere;            // prof : matière choisie
  final Set<String> _profClasses = {}; // prof : classes enseignées (ids)
  bool _profPrincipal = false;          // prof principal ?
  String? _profClassePrincipale;        // classe principale (id)
  String? _classeId;   // pour un élève
  String? _enfantId;   // pour un parent
  String? _ecoleId;    // école cible
  bool _loading = false;

  final _matieresProf = ['Mathematiques','Physique-Chimie','SVT','Francais',
                         'Anglais','Histoire-Geo','EPS','Philosophie','Allemand','Espagnol'];

  bool get _estSuperAdmin => widget.user.role == UserRole.admin;

  @override
  void initState() {
    super.initState();
    // Le directeur est verrouillé sur SON école ; le super admin choisit.
    if (!_estSuperAdmin) _ecoleId = widget.user.school;
  }

  @override
  void dispose() {
    _nom.dispose(); _email.dispose(); _pw.dispose();
    _matricule.dispose(); _matiere.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (_nom.text.trim().isEmpty) { showSnack(context, 'Renseignez le nom', error:true); return; }
    if (_email.text.trim().isEmpty) { showSnack(context, 'Renseignez l email', error:true); return; }
    if (_pw.text.trim().length < 6) { showSnack(context, 'Mot de passe : 6 caracteres min', error:true); return; }
    if (_ecoleId == null) { showSnack(context, 'Choisissez une ecole', error:true); return; }

    // Champs propres à chaque rôle
    final Map<String, dynamic> champs = {
      'role': _role == 'coadmin' ? 'admin' : _role,
      'ecoleId': _ecoleId,
    };
    // Un Co-Administrateur est un admin de terrain : il configure et ajoute,
    // mais ne peut ni bloquer ni supprimer de données (réservé au super admin).
    if (_role == 'coadmin') {
      champs['coAdmin'] = true;
    }
    if (_role == 'eleve') {
      if (_classeId == null) { showSnack(context, 'Choisissez une classe', error:true); return; }
      champs['classeId'] = _classeId;
      champs['matricule'] = _matricule.text.trim();
    } else if (_role == 'parent') {
      if (_enfantId == null) { showSnack(context, 'Choisissez l enfant', error:true); return; }
      champs['enfants'] = [_enfantId];
    } else if (_role == 'prof') {
      if (_profMatiere == null) { showSnack(context, 'Choisissez la matiere du prof', error:true); return; }
      if (_profClasses.isEmpty) { showSnack(context, 'Choisissez au moins une classe', error:true); return; }
      champs['matiere'] = _profMatiere;
      champs['classes'] = _profClasses.toList();
      if (_profPrincipal && _profClassePrincipale != null) {
        final dejaP = await FirebaseService.profPrincipalDe(_ecoleId!, _profClassePrincipale!);
        if (dejaP != null) {
          showSnack(context, 'Cette classe a deja un professeur principal ($dejaP). Retirez-le d abord.', error:true);
          return;
        }
        champs['estPrincipal'] = true;
        champs['classePrincipale'] = _profClassePrincipale;
      }
    }

    setState(() => _loading = true);
    final erreur = await FirebaseService.creerCompte(
      nom: _nom.text, email: _email.text, motDePasse: _pw.text, champs: champs,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (erreur == null) {
      showSnack(context, 'Compte cree avec succes !');
      Navigator.pop(context);
    } else {
      showSnack(context, erreur, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un utilisateur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SCCard(child: DropdownButtonFormField<String>(
            value: _role,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Type de compte'),
            items: [
              const DropdownMenuItem(value: 'eleve',  child: Text('Eleve')),
              const DropdownMenuItem(value: 'prof',   child: Text('Professeur')),
              const DropdownMenuItem(value: 'parent', child: Text('Parent')),
              // Seul le Super Admin peut créer un Directeur ou un Co-Administrateur
              if (widget.user.estSuperAdmin) ...[
                const DropdownMenuItem(value: 'directeur', child: Text('Directeur')),
                const DropdownMenuItem(value: 'coadmin', child: Text('Co-Administrateur (agent Sentinel)')),
              ],
            ],
            onChanged: (v) => setState(() {
              _role = v!; _classeId = null; _enfantId = null;
            }),
          )),
          const SizedBox(height: 16),

          // ---- Choix de l'école : visible uniquement pour le Super Admin ----
          if (_estSuperAdmin) ...[
            SCCard(child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.streamToutesEcoles(),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Text('Chargement des ecoles...',
                      style: TextStyle(color: AppColors.textMuted));
                }
                final ecoles = snap.data!.docs;
                if (ecoles.isEmpty) {
                  return const Text('Aucune ecole. Creez d abord une ecole.',
                      style: TextStyle(color: AppColors.textMuted));
                }
                return DropdownButtonFormField<String>(
                    value: _ecoleId, isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Ecole'),
                    hint: const Text('Choisir l ecole'),
                    items: ecoles.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      return DropdownMenuItem(value: doc.id,
                          child: Text(d['nom'] ?? doc.id));
                    }).toList(),
                    onChanged: (v) => setState(() {
                      _ecoleId = v; _classeId = null; _enfantId = null;
                    }));
              })),
            const SizedBox(height: 16),
          ],

          SectionTitle('Informations'),
          SCCard(child: Column(children: [
            TextField(controller: _nom, textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nom complet')),

            // ---- Champs spécifiques ÉLÈVE ----
            if (_role == 'eleve') ...[
              const SizedBox(height: 10),
              if (_ecoleId == null)
                const Padding(padding: EdgeInsets.symmetric(vertical:8),
                    child: Text('Choisissez d abord une ecole.',
                        style: TextStyle(color: AppColors.textMuted)))
              else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.streamClasses(_ecoleId!),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical:8),
                        child: Text('Chargement des classes...',
                            style: TextStyle(color: AppColors.textMuted)));
                  }
                  final classes = snap.data!.docs;
                  if (classes.isEmpty) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical:8),
                        child: Text('Aucune classe. Creez d abord une classe.',
                            style: TextStyle(color: AppColors.textMuted)));
                  }
                  return DropdownButtonFormField<String>(
                      value: _classeId, isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Classe'),
                      hint: const Text('Choisir une classe'),
                      items: classes.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem(value: doc.id, child: Text(d['nom'] ?? doc.id));
                      }).toList(),
                      onChanged: (v) => setState(() => _classeId = v));
                }),
              const SizedBox(height: 10),
              TextField(controller: _matricule,
                  decoration: const InputDecoration(labelText: 'Matricule (ex: EL002)')),
            ],

            // ---- Champ spécifique PARENT (choix de l'enfant) ----
            if (_role == 'parent') ...[
              const SizedBox(height: 10),
              if (_ecoleId == null)
                const Padding(padding: EdgeInsets.symmetric(vertical:8),
                    child: Text('Choisissez d abord une ecole.',
                        style: TextStyle(color: AppColors.textMuted)))
              else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.streamEleves(_ecoleId!),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical:8),
                        child: Text('Chargement des eleves...',
                            style: TextStyle(color: AppColors.textMuted)));
                  }
                  final eleves = snap.data!.docs;
                  if (eleves.isEmpty) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical:8),
                        child: Text('Aucun eleve. Creez d abord un eleve.',
                            style: TextStyle(color: AppColors.textMuted)));
                  }
                  return DropdownButtonFormField<String>(
                      value: _enfantId, isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Enfant (eleve)'),
                      hint: const Text('Choisir l enfant'),
                      items: eleves.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem(value: doc.id, child: Text(d['nom'] ?? doc.id));
                      }).toList(),
                      onChanged: (v) => setState(() => _enfantId = v));
                }),
            ],

            // ---- Champs PROF : matière (obligatoire) + classes enseignées ----
            if (_role == 'prof') ...[
              const SizedBox(height: 10),
              if (_ecoleId == null)
                const Text('Choisissez d abord une ecole.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12))
              else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.streamMatieres(_ecoleId!),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Text('Chargement des matieres...',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12));
                  }
                  final mats = snap.data!.docs;
                  if (mats.isEmpty) {
                    return const Text('Aucune matiere. Ajoutez-en via le bouton "Matieres".',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12));
                  }
                  final noms = mats.map((d)=>((d.data() as Map)['nom']??'').toString()).toList()..sort();
                  return DropdownButtonFormField<String>(
                      value: _profMatiere, isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Matiere enseignee'),
                      hint: const Text('Choisir la matiere'),
                      items: noms.map((m)=>DropdownMenuItem(value:m, child:Text(m))).toList(),
                      onChanged: (v)=>setState(()=>_profMatiere=v));
                }),
              const SizedBox(height: 14),
              const Text('Classes enseignees',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              if (_ecoleId == null)
                const Text('Choisissez d abord une ecole.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12))
              else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.streamClasses(_ecoleId!),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Text('Chargement des classes...',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12));
                  }
                  final classes = snap.data!.docs;
                  if (classes.isEmpty) {
                    return const Text('Aucune classe. Creez d abord une classe.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12));
                  }
                  return Wrap(spacing: 8, runSpacing: 4, children: classes.map((doc){
                    final d = doc.data() as Map<String,dynamic>;
                    final sel = _profClasses.contains(doc.id);
                    return FilterChip(
                      label: Text(d['nom'] ?? doc.id),
                      selected: sel,
                      onSelected: (v)=>setState((){
                        if (v) { _profClasses.add(doc.id); }
                        else { _profClasses.remove(doc.id);
                               if (_profClassePrincipale == doc.id) _profClassePrincipale = null; }
                      }),
                      selectedColor: AppColors.greenBg,
                      checkmarkColor: AppColors.green,
                    );
                  }).toList());
                }),
              const SizedBox(height:12),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Professeur principal',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                subtitle: const Text('Acces a toutes les moyennes d une classe',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                value: _profPrincipal,
                activeColor: AppColors.green,
                onChanged: (v)=>setState(()=> _profPrincipal = v),
              ),
              if (_profPrincipal) ...[
                if (_profClasses.isEmpty)
                  const Text('Cochez d abord la classe dont il est responsable ci-dessus.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12))
                else
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.streamClasses(_ecoleId!),
                  builder: (ctx, snap) {
                    if (!snap.hasData) return const SizedBox.shrink();
                    // Choix limité aux classes qu'il enseigne
                    final mesClasses = snap.data!.docs
                        .where((c)=>_profClasses.contains(c.id)).toList();
                    return DropdownButtonFormField<String>(
                        value: _profClassePrincipale, isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Classe principale'),
                        hint: const Text('Choisir sa classe'),
                        items: mesClasses.map((doc){
                          final d = doc.data() as Map<String,dynamic>;
                          return DropdownMenuItem(value: doc.id, child: Text(d['nom'] ?? doc.id));
                        }).toList(),
                        onChanged: (v)=>setState(()=> _profClassePrincipale = v));
                  }),
              ],
            ],
          ])),
          const SizedBox(height: 16),

          SectionTitle('Identifiants de connexion'),
          SCCard(child: Column(children: [
            TextField(controller: _email, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 10),
            TextField(controller: _pw,
                decoration: const InputDecoration(labelText: 'Mot de passe (6 caracteres min)')),
          ])),
          const SizedBox(height: 20),

          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _loading ? null : _enregistrer,
            child: _loading
                ? const SizedBox(height:18, width:18,
                    child: CircularProgressIndicator(strokeWidth:2, color:Colors.white))
                : const Text('Creer le compte'),
          )),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════
//  REVENUS PAGE (ADMIN)
// ══════════════════════════════════════════
class RevenusPage extends StatefulWidget {
  final AppUser user;
  const RevenusPage({super.key, required this.user});
  @override State<RevenusPage> createState() => _RevenusPageState();
}

class _RevenusPageState extends State<RevenusPage> {
  AppUser get user => widget.user;

  // Ajuster à la main le nombre d'élèves facturés d'une école.
  Future<void> _ajusterEcole(String id, String nom, int nbActuel, bool corrige) async {
    final ctrl = TextEditingController(text: '$nbActuel');
    bool saving = false;
    await showDialog(context: context, builder: (dctx) =>
      StatefulBuilder(builder: (dctx, setSt) => AlertDialog(
        title: Text(nom, style: const TextStyle(fontSize: 17)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Nombre d eleves a facturer pour cette ecole. '
              'Laissez le comptage automatique ou corrigez a la main.',
              style: TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          TextField(controller: ctrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nombre d eleves',
                  prefixIcon: Icon(Icons.school_rounded, size: 20))),
        ]),
        actions: [
          if (corrige)
            TextButton(
              onPressed: saving ? null : () async {
                setSt(()=> saving = true);
                await FirebaseService.setElevesFactures(id, null);
                if (dctx.mounted) Navigator.pop(dctx);
              },
              child: const Text('Revenir au comptage auto')),
          TextButton(onPressed: ()=> Navigator.pop(dctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: saving ? null : () async {
              final v = int.tryParse(ctrl.text.trim());
              if (v == null || v < 0) return;
              setSt(()=> saving = true);
              await FirebaseService.setElevesFactures(id, v);
              if (dctx.mounted) Navigator.pop(dctx);
            },
            child: const Text('Enregistrer')),
        ],
      )));
    if (mounted) setState((){}); // recharge les chiffres
  }

  // Encaisser le forfait d'une école : mois, montant, méthode, référence -> reçu.
  Future<void> _encaisserDialog(String id, String nom, int montantDefaut) async {
    final mCtrl = TextEditingController(text: '$montantDefaut');
    final refCtrl = TextEditingController();
    final moisChoix = derniersMois(6);
    DateTime moisSel = moisChoix.first;
    String methode = 'Mobile Money';
    bool saving = false;
    await showDialog(context: context, builder: (dctx) =>
      StatefulBuilder(builder: (dctx, setSt) => AlertDialog(
        title: Text('Encaisser - $nom', style: const TextStyle(fontSize: 16.5)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<DateTime>(
            value: moisSel, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Mois concerne',
                prefixIcon: Icon(Icons.calendar_month_rounded, size: 20)),
            items: moisChoix.map((d) => DropdownMenuItem(
                value: d, child: Text(moisLabelFr(d)))).toList(),
            onChanged: (v) => setSt(() => moisSel = v ?? moisSel)),
          const SizedBox(height: 10),
          TextField(controller: mCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant recu (FCFA)',
                  prefixIcon: Icon(Icons.payments_rounded, size: 20))),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: methode, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Methode de paiement',
                prefixIcon: Icon(Icons.account_balance_wallet_rounded, size: 20)),
            items: const ['Mobile Money','Virement','Especes','Cheque']
                .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setSt(() => methode = v ?? methode)),
          const SizedBox(height: 10),
          TextField(controller: refCtrl,
              decoration: const InputDecoration(
                  labelText: 'Reference (n. transaction, cheque...)',
                  prefixIcon: Icon(Icons.tag_rounded, size: 20))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: saving ? null : () async {
              final montant = int.tryParse(mCtrl.text.trim());
              if (montant == null || montant <= 0) return;
              setSt(() => saving = true);
              try {
                final numero = await FirebaseService.enregistrerPaiement(
                  ecoleId: id, ecoleNom: nom,
                  mois: moisCode(moisSel), moisLabel: moisLabelFr(moisSel),
                  montant: montant, methode: methode,
                  reference: refCtrl.text.trim(), saisiPar: user.name);
                if (dctx.mounted) Navigator.pop(dctx);
                if (mounted) showSnack(context, 'Paiement enregistre - recu $numero 🧾');
              } catch (_) {
                setSt(() => saving = false);
                if (dctx.mounted) showSnack(dctx, 'Erreur d enregistrement.', error: true);
              }
            },
            child: saving
                ? const SizedBox(height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enregistrer le paiement')),
        ],
      )));
    if (mounted) setState((){});
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        FutureBuilder<({int ecoles, int eleves, int abonnes, int encaisse, int impayes, int total})>(
          future: FirebaseService.statsGlobales(),
          builder: (ctx, s) {
            final d = s.data;
            String v(int? x) => s.hasData ? '${x ?? 0}' : '...';
            return GridView.count(crossAxisCount:2, shrinkWrap:true,
                physics:const NeverScrollableScrollPhysics(),
                crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio:0.95,
                children:[
                  StatCard(value:s.hasData?fmtF(d!.encaisse):'...', label:'Revenu mensuel', sub:'FCFA · Tous forfaits',
                      icon:Icons.payments_rounded, color:AppColors.green, iconBg:AppColors.greenBg),
                  StatCard(value:v(d?.ecoles), label:'Ecoles', sub:'Partenaires',
                      icon:Icons.account_balance_rounded, color:AppColors.orange, iconBg:AppColors.orangeBg),
                  StatCard(value:v(d?.eleves), label:'Eleves', sub:'Total plateforme',
                      icon:Icons.school_rounded, color:AppColors.purple, iconBg:AppColors.purpleBg),
                ]);
          }),
        const SizedBox(height:20),

        SectionTitle('Forfait par ecole - ${moisLabelFr(DateTime.now())}'),
        FutureBuilder<({List<({String id, String nom, int nb, bool corrige, int prix, int total})> forfaits,
                        Map<String, Map<String,dynamic>> payes})>(
          future: () async {
            final f = await FirebaseService.forfaitsParEcole();
            final p = await FirebaseService.paiementsDuMois(moisCode(DateTime.now()));
            return (forfaits: f, payes: p);
          }(),
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child:CircularProgressIndicator());
            final list = snap.data!.forfaits;
            final payes = snap.data!.payes;
            if (list.isEmpty) {
              return SCCard(child: const Text('Aucune ecole enregistree.',
                  style: TextStyle(color: AppColors.textMuted)));
            }
            final attendu = list.fold<int>(0, (s,e)=> s + e.total);
            final encaisse = payes.values.fold<int>(0, (s,p)=> s + ((p['montant'] as num?)?.toInt() ?? 0));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              // Bandeau encaissé / attendu du mois
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom:12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: encaisse >= attendu && attendu > 0 ? AppColors.greenBg : AppColors.goldBg,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children:[
                  Icon(encaisse >= attendu && attendu > 0
                      ? Icons.check_circle_rounded : Icons.hourglass_bottom_rounded,
                      size: 20,
                      color: encaisse >= attendu && attendu > 0 ? AppColors.green : AppColors.gold),
                  const SizedBox(width:10),
                  Expanded(child: Text(
                      'Encaisse ce mois : ${fmtF(encaisse)} F  /  ${fmtF(attendu)} F attendus',
                      style: TextStyle(fontSize:13, fontWeight: FontWeight.w800,
                          color: encaisse >= attendu && attendu > 0 ? AppColors.green : AppColors.gold))),
                ]),
              ),
              ...list.map((e){
                final paye = payes[e.id];
                return Container(
                  margin: const EdgeInsets.only(bottom:10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: Column(children:[
                    Row(children:[
                      Container(width:40,height:40,
                          decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(10)),
                          child: const Center(child: Icon(Icons.school_rounded, color: AppColors.green))),
                      const SizedBox(width:12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                        Text(e.nom, style: const TextStyle(fontSize:13.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height:2),
                        Text('${e.nb} eleves${e.corrige ? ' (ajuste)' : ''}  x  ${fmtF(e.prix)} F',
                            style: const TextStyle(fontSize:12, color: AppColors.textMuted)),
                      ])),
                      Text('${fmtF(e.total)} F',
                          style: const TextStyle(fontSize:14, fontWeight: FontWeight.w800, color: AppColors.green)),
                    ]),
                    const SizedBox(height:10),
                    // Badge du mois courant (ligne 1)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
                        decoration: BoxDecoration(
                            color: paye != null ? AppColors.greenBg : AppColors.goldBg,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(paye != null
                            ? 'Paye ✓  ${paye['numeroRecu'] ?? ''}'
                            : 'En attente',
                            style: TextStyle(fontSize:11, fontWeight: FontWeight.w800,
                                color: paye != null ? AppColors.green : AppColors.gold))),
                    ),
                    const SizedBox(height:6),
                    // Actions (ligne 2, alignées à droite)
                    Row(children:[
                      const Spacer(),
                      if (paye != null)
                        TextButton.icon(
                            style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact, foregroundColor: AppColors.blue),
                            onPressed: () async {
                              final bytes = await genererRecuPdf(paye);
                              await Printing.sharePdf(bytes: bytes,
                                  filename: '${paye['numeroRecu'] ?? 'recu'}.pdf');
                            },
                            icon: const Icon(Icons.receipt_long_rounded, size:16),
                            label: const Text('Recu', style: TextStyle(fontSize:12))),
                      TextButton.icon(
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact, foregroundColor: AppColors.green),
                          onPressed: ()=> _encaisserDialog(e.id, e.nom, e.total),
                          icon: const Icon(Icons.point_of_sale_rounded, size:16),
                          label: const Text('Encaisser', style: TextStyle(fontSize:12))),
                      IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Ajuster le nombre d eleves',
                          onPressed: ()=> _ajusterEcole(e.id, e.nom, e.nb, e.corrige),
                          icon: const Icon(Icons.edit_rounded, size:18, color: AppColors.textMuted)),
                    ]),
                  ]),
                );
              }),
            ]);
          }),
        const SizedBox(height:16),

        SectionTitle('Derniers paiements'),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseService.streamPaiements().first,
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child:CircularProgressIndicator());
            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return SCCard(child: const Text('Aucun paiement enregistre pour le moment.',
                  style: TextStyle(color: AppColors.textMuted)));
            }
            return Column(children: docs.take(15).map((d){
              final p = d.data() as Map<String,dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom:8),
                padding: const EdgeInsets.symmetric(horizontal:12, vertical:10),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Row(children:[
                  const Icon(Icons.receipt_long_rounded, size:18, color: AppColors.green),
                  const SizedBox(width:10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    Text('${p['ecoleNom'] ?? ''} - ${p['moisLabel'] ?? ''}',
                        style: const TextStyle(fontSize:12.5, fontWeight: FontWeight.w700)),
                    Text('${p['numeroRecu'] ?? ''} · ${p['methode'] ?? ''} · ${p['dateStr'] ?? ''}',
                        style: const TextStyle(fontSize:11, color: AppColors.textMuted)),
                  ])),
                  Text('${fmtF((p['montant'] as num?) ?? 0)} F',
                      style: const TextStyle(fontSize:12.5, fontWeight: FontWeight.w800, color: AppColors.green)),
                  IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Partager le recu',
                      onPressed: () async {
                        final bytes = await genererRecuPdf(p);
                        await Printing.sharePdf(bytes: bytes,
                            filename: '${p['numeroRecu'] ?? 'recu'}.pdf');
                      },
                      icon: const Icon(Icons.ios_share_rounded, size:16, color: AppColors.blue)),
                ]),
              );
            }).toList());
          }),
        const SizedBox(height:16),

        SCCard(child: const Row(children:[
          Icon(Icons.info_outline_rounded, size:18, color: AppColors.blue),
          SizedBox(width:10),
          Expanded(child: Text(
              'Encaissez le forfait des qu une ecole paie : un recu numerote est genere '
              'et l historique est conserve. Le paiement en ligne arrive bientot.',
              style: TextStyle(fontSize:12, color: AppColors.textMuted))),
        ])),
      ]));
}

// ══════════════════════════════════════════
//  AGENDA PAGE — TEMPS REEL
// ══════════════════════════════════════════
class AgendaPage extends StatefulWidget {
  final AppUser user;
  const AgendaPage({super.key, required this.user});
  @override State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _selectedDay = 'Lundi';
  final _jours = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi'];

  // Agenda
  final _titreCtrl = TextEditingController();
  final _dateCtrl  = TextEditingController();
  String _selType  = 'evenement';
  String? _evtClasseId;    // prof : classe concernée par l'événement
  String? _evtClasseNom;

  // Emploi du temps
  String? _edtClasseId;     // classe affichée / remplie
  String? _edtClasseNom;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length:2, vsync:this);
    // Élève / parent : emploi du temps de leur propre classe
    if (widget.user.role==UserRole.eleve || widget.user.role==UserRole.parent) {
      _edtClasseId = widget.user.classeId;
    }
  }

  @override
  void dispose() { _tab.dispose(); _titreCtrl.dispose(); _dateCtrl.dispose(); super.dispose(); }

  // L'administration gère le calendrier ET l'emploi du temps. Le prof peut aussi poster au calendrier.
  bool get _canEditAgenda =>
      widget.user.role==UserRole.directeur || widget.user.role==UserRole.admin || widget.user.role==UserRole.prof;
  bool get _canEditEdt =>
      widget.user.role==UserRole.directeur || widget.user.role==UserRole.admin;
  bool get _choisitClasse =>
      widget.user.role==UserRole.directeur || widget.user.role==UserRole.admin || widget.user.role==UserRole.prof;
  // Supprimer des données est réservé au super admin et au directeur (PAS aux co-admins)
  bool get _peutSupprimer =>
      widget.user.estSuperAdmin || widget.user.role==UserRole.directeur;

  Future<void> _ajouterEvt() async {
    if (_titreCtrl.text.isEmpty||_dateCtrl.text.isEmpty) {
      showSnack(context,'Remplissez titre et date',error:true); return;
    }
    final estStaff = widget.user.role==UserRole.admin || widget.user.role==UserRole.directeur;
    if (!estStaff && _evtClasseId == null) {
      showSnack(context, 'Choisissez la classe concernee', error:true); return;
    }
    await FirebaseService.ajouterEvenement({
      'titre':    _titreCtrl.text,
      'date':     _dateCtrl.text,
      'type':     _selType,
      'ecoleId':  widget.user.school,
      'portee':   estStaff ? 'ecole' : 'classe',
      'classeId': estStaff ? '' : _evtClasseId,
      'classe':   estStaff ? '' : (_evtClasseNom ?? ''),
      'notifie':  false,
    });
    _titreCtrl.clear(); _dateCtrl.clear();
    if (mounted) {
      showSnack(context, estStaff
          ? 'Evenement publie — Toute l ecole notifiee 📲'
          : 'Evenement publie pour votre classe 📲');
    }
  }

  void _ajouterCreneau() {
    final heureCtrl = TextEditingController();
    final salleCtrl = TextEditingController();
    String jour = _selectedDay;
    String? matiere;
    String? profNom;
    showModalBottomSheet(context: context, isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => StatefulBuilder(builder: (ctx, setSheet) => Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ajouter un creneau — $_edtClasseNom',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                  value: jour, isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Jour'),
                  items: _jours.map((j)=>DropdownMenuItem(value:j, child:Text(j))).toList(),
                  onChanged: (v)=>setSheet(()=>jour=v!)),
              const SizedBox(height: 10),
              TextField(controller: heureCtrl,
                  decoration: const InputDecoration(labelText: 'Heure (ex. 08h - 10h)')),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.streamUtilisateursParEcole(widget.user.school),
                builder: (cP, sP) {
                  final profs = sP.hasData
                      ? sP.data!.docs.where((d)=>(d.data() as Map)['role']=='prof').toList()
                      : <QueryDocumentSnapshot>[];
                  // Prof de la matière affecté à CETTE classe (repli : tout prof de la matière)
                  String? profDeLaMatiere(String? mat) {
                    if (mat == null) return null;
                    final exact = profs.where((d){
                      final m = d.data() as Map;
                      final cls = (m['classes'] is List) ? List<String>.from(m['classes']) : const <String>[];
                      return (m['matiere']??'')==mat && cls.contains(_edtClasseId);
                    }).toList();
                    if (exact.isNotEmpty) return ((exact.first.data() as Map)['nom']??'').toString();
                    final any = profs.where((d)=>((d.data() as Map)['matiere']??'')==mat).toList();
                    return any.isNotEmpty ? ((any.first.data() as Map)['nom']??'').toString() : null;
                  }
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseService.streamMatieres(widget.user.school),
                      builder: (c, s) {
                        final noms = s.hasData
                            ? (s.data!.docs.map((d)=>((d.data() as Map)['nom']??'').toString()).toList()..sort())
                            : <String>[];
                        return DropdownButtonFormField<String>(
                            value: matiere, isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Matiere'),
                            hint: const Text('Choisir'),
                            items: noms.map((m)=>DropdownMenuItem(value:m, child:Text(m))).toList(),
                            onChanged: (v)=>setSheet((){
                              matiere = v;
                              profNom = profDeLaMatiere(v);   // sélection auto du prof
                            }));
                      }),
                    const SizedBox(height: 10),
                    TextField(controller: salleCtrl,
                        decoration: const InputDecoration(labelText: 'Salle (optionnel)')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                        value: profs.any((d)=>((d.data() as Map)['nom']??'')==profNom) ? profNom : null,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Professeur (auto, modifiable)'),
                        hint: const Text('Choisir'),
                        items: profs.map((d){
                          final n = ((d.data() as Map)['nom']??'').toString();
                          return DropdownMenuItem(value:n, child:Text(n));
                        }).toList(),
                        onChanged: (v)=>setSheet(()=>profNom=v)),
                  ]);
                }),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () async {
                    if (matiere == null || heureCtrl.text.trim().isEmpty) {
                      showSnack(context, 'Heure et matiere obligatoires', error: true); return;
                    }
                    await FirebaseService.ajouterCreneau({
                      'ecoleId': widget.user.school,
                      'classeId': _edtClasseId,
                      'classe': _edtClasseNom,
                      'jour': jour,
                      'heure': heureCtrl.text.trim(),
                      'matiere': matiere,
                      'salle': salleCtrl.text.trim(),
                      'profNom': profNom ?? '',
                    });
                    if (context.mounted) { Navigator.pop(context); showSnack(context, 'Creneau ajoute !'); }
                  },
                  child: const Text('Ajouter le creneau'))),
            ])))));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children:[
      Container(color:Colors.white, child:TabBar(
          controller:_tab,
          labelColor:AppColors.green,
          unselectedLabelColor:AppColors.textMuted,
          indicatorColor:AppColors.green,
          tabs:const[
            Tab(icon:Icon(Icons.calendar_view_week_rounded), text:'Emploi du temps'),
            Tab(icon:Icon(Icons.event_rounded), text:'Calendrier scolaire'),
          ])),
      Expanded(child:TabBarView(controller:_tab, children:[

        // ===== EMPLOI DU TEMPS =====
        SingleChildScrollView(
            padding:const EdgeInsets.all(16),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[

              // Sélecteur de classe (staff) — auto pour élève/parent
              if (_choisitClasse)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.streamClasses(widget.user.school),
                  builder: (ctx, snap) {
                    if (!snap.hasData) return const Text('Chargement des classes...',
                        style: TextStyle(color: AppColors.textMuted));
                    var classes = snap.data!.docs;
                    // Le prof ne voit que ses classes (si assignées)
                    if (widget.user.role==UserRole.prof && widget.user.classes.isNotEmpty) {
                      classes = classes.where((c)=>widget.user.classes.contains(c.id)).toList();
                    }
                    if (classes.isEmpty) return const Text('Aucune classe.',
                        style: TextStyle(color: AppColors.textMuted));
                    return DropdownButtonFormField<String>(
                        value: _edtClasseId, isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Classe'),
                        hint: const Text('Choisir une classe'),
                        items: classes.map((doc){
                          final d = doc.data() as Map<String,dynamic>;
                          return DropdownMenuItem(value: doc.id, child: Text(d['nom'] ?? doc.id));
                        }).toList(),
                        onChanged: (v){
                          final doc = classes.firstWhere((c)=>c.id==v);
                          setState((){ _edtClasseId=v; _edtClasseNom=((doc.data() as Map)['nom']??'').toString(); });
                        });
                  }),
              if (_choisitClasse) const SizedBox(height:14),

              if (_edtClasseId == null)
                const Padding(padding: EdgeInsets.only(top:20),
                    child: Text('Choisissez une classe pour voir son emploi du temps.',
                        style: TextStyle(color: AppColors.textMuted)))
              else ...[
                if (_canEditEdt) ...[
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(
                    onPressed: _ajouterCreneau,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter un creneau'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        side: const BorderSide(color: AppColors.green),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  )),
                  const SizedBox(height:14),
                ],
                // Sélecteur de jour
                SizedBox(height:44, child:ListView.builder(
                    scrollDirection:Axis.horizontal,
                    itemCount:_jours.length,
                    itemBuilder:(_,i){
                      final j=_jours[i]; final sel=j==_selectedDay;
                      return GestureDetector(
                          onTap:()=>setState(()=>_selectedDay=j),
                          child:Container(
                              margin:const EdgeInsets.only(right:8),
                              padding:const EdgeInsets.symmetric(horizontal:18,vertical:10),
                              decoration:BoxDecoration(
                                  color:sel?AppColors.green:Colors.white,
                                  borderRadius:BorderRadius.circular(22),
                                  border:Border.all(color:sel?AppColors.green:AppColors.border)),
                              child:Text(j,style:TextStyle(fontSize:13,fontWeight:FontWeight.w700,
                                  color:sel?Colors.white:AppColors.textMuted))));
                    })),
                const SizedBox(height:16),
                StreamBuilder<QuerySnapshot>(
                    stream:FirebaseService.streamEmploiDuTempsParClasse(_edtClasseId!),
                    builder:(ctx,snap){
                      if (!snap.hasData) return const Center(child:CircularProgressIndicator());
                      final docs = snap.data!.docs
                          .where((d)=>(d.data() as Map)['jour']==_selectedDay).toList()
                        ..sort((a,b)=>((a.data() as Map)['heure']??'').toString()
                            .compareTo(((b.data() as Map)['heure']??'').toString()));
                      if (docs.isEmpty)
                        return const Text('Aucun cours ce jour.',
                            style:TextStyle(color:AppColors.textMuted));
                      return Column(children:docs.map((d){
                        final data=d.data() as Map<String,dynamic>;
                        return Container(
                            margin:const EdgeInsets.only(bottom:10),
                            decoration:BoxDecoration(
                                color:Colors.white,
                                borderRadius:BorderRadius.circular(12),
                                border:Border.all(color:AppColors.border)),
                            child:Row(children:[
                              Container(width:5,height:80,
                                  decoration:const BoxDecoration(
                                      color:AppColors.green,
                                      borderRadius:BorderRadius.only(
                                          topLeft:Radius.circular(12),bottomLeft:Radius.circular(12)))),
                              Expanded(child: Padding(padding:const EdgeInsets.all(14),child:Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,children:[
                                Text(data['heure']??'',
                                    style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:AppColors.green)),
                                const SizedBox(height:3),
                                Text(data['matiere']??'',
                                    style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800)),
                                const SizedBox(height:3),
                                Text([
                                  if ((data['salle']??'').toString().isNotEmpty) 'Salle ${data['salle']}',
                                  if ((data['profNom']??'').toString().isNotEmpty) '${data['profNom']}',
                                ].join(' · '),
                                    style:const TextStyle(fontSize:12,color:AppColors.textMuted)),
                              ]))),
                              if (_peutSupprimer)
                                IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
                                    onPressed: () => FirebaseService.supprimerCreneau(d.id)),
                            ]));
                      }).toList());
                    }),
              ],
            ])),

        // ===== CALENDRIER SCOLAIRE =====
        SingleChildScrollView(
            padding:const EdgeInsets.all(16),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              if (_canEditAgenda)...[
                SectionTitle('Ajouter un evenement'),
                SCCard(child:Column(children:[
                  TextField(controller:_titreCtrl,
                      decoration:const InputDecoration(labelText:"Titre de l evenement")),
                  const SizedBox(height:10),
                  TextField(controller:_dateCtrl,
                      decoration:const InputDecoration(labelText:'Date (JJ/MM/AAAA)')),
                  const SizedBox(height:10),
                  DropdownButtonFormField<String>(
                      value:_selType,
                      decoration:const InputDecoration(labelText:'Type'),
                      items:{
                        'evenement':'Evenement','reunion':'Reunion',
                        'exam':'Examen','sortie':'Sortie scolaire',
                        'conge':'Conge','info':'Information',
                      }.entries.map((e)=>DropdownMenuItem(value:e.key,child:Text(e.value))).toList(),
                      onChanged:(v)=>setState(()=>_selType=v!)),
                  if (widget.user.role == UserRole.prof) ...[
                    const SizedBox(height:10),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseService.streamClasses(widget.user.school),
                      builder: (c, s) {
                        final mesClasses = s.hasData
                            ? s.data!.docs.where((d)=>widget.user.classes.contains(d.id)).toList()
                            : <QueryDocumentSnapshot>[];
                        return DropdownButtonFormField<String>(
                            value: _evtClasseId, isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Classe concernee'),
                            hint: const Text('Choisir votre classe'),
                            items: mesClasses.map((d)=>DropdownMenuItem(
                                value:d.id, child: Text(((d.data() as Map)['nom']??'').toString()))).toList(),
                            onChanged: (v)=>setState((){
                              _evtClasseId=v;
                              final doc = mesClasses.where((d)=>d.id==v).toList();
                              _evtClasseNom = doc.isNotEmpty ? ((doc.first.data() as Map)['nom']??'').toString() : null;
                            }));
                      }),
                  ] else
                    const Padding(padding: EdgeInsets.only(top:10),
                      child: Text('Cet evenement sera visible par toute l ecole.',
                          style: TextStyle(fontSize:12, color:AppColors.textMuted))),
                  const SizedBox(height:14),
                  SizedBox(width:double.infinity,child:ElevatedButton(
                      onPressed:_ajouterEvt,
                      child: Text(widget.user.role == UserRole.prof
                          ? 'Publier pour ma classe 📲'
                          : 'Publier — Notifier tout le monde 📲'))),
                ])),
                const SizedBox(height:20),
              ],
              SectionTitle('Evenements & Calendrier'),
              StreamBuilder<QuerySnapshot>(
                  stream:FirebaseService.streamAgenda(widget.user.school),
                  builder:(ctx,snap){
                    if (snap.hasError)
                      return const Text('Impossible de charger le calendrier.',
                          style:TextStyle(color:AppColors.textMuted));
                    if (!snap.hasData) return const Center(child:CircularProgressIndicator());
                    // Chacun voit : les événements "école" + ceux de SES classes
                    final role = widget.user.role;
                    final estStaff = role==UserRole.admin || role==UserRole.directeur;
                    final visibles = snap.data!.docs.where((d){
                      final m = d.data() as Map;
                      final portee = (m['portee'] ?? 'ecole').toString();
                      if (portee == 'ecole') return true;
                      if (estStaff) return true;
                      final cid = (m['classeId'] ?? '').toString();
                      if (role==UserRole.prof) return widget.user.classes.contains(cid);
                      return cid == widget.user.classeId;
                    }).toList();
                    if (visibles.isEmpty)
                      return const Text('Aucun evenement.',
                          style:TextStyle(color:AppColors.textMuted));
                    final docs = visibles
                      ..sort((a,b){
                        final ta=(a.data() as Map)['createdAt'];
                        final tb=(b.data() as Map)['createdAt'];
                        if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
                        return 0;
                      });
                    return Column(children:docs.map((d){
                      final data=d.data() as Map<String,dynamic>;
                      final icons={'reunion':'👨‍👩‍👧','exam':'📝','sortie':'🎭',
                        'conge':'🏖️','rentree':'🎒','info':'📢','evenement':'📅'};
                      return Container(
                          margin:const EdgeInsets.only(bottom:10),
                          padding:const EdgeInsets.all(14),
                          decoration:BoxDecoration(color:Colors.white,
                              borderRadius:BorderRadius.circular(12),
                              border:Border.all(color:AppColors.border)),
                          child:Row(children:[
                            Container(width:48,height:48,
                                decoration:BoxDecoration(color:AppColors.greenBg,
                                    borderRadius:BorderRadius.circular(12)),
                                child:Center(child:Text(
                                    icons[data['type']]??'📅',
                                    style:const TextStyle(fontSize:22)))),
                            const SizedBox(width:12),
                            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                              Text(data['titre']??'',
                                  style:const TextStyle(fontSize:14,fontWeight:FontWeight.w700)),
                              const SizedBox(height:3),
                              Text(data['date']??'',
                                  style:const TextStyle(fontSize:12,color:AppColors.textMuted)),
                              if ((data['portee'] ?? 'ecole')=='classe' && (data['classe']??'').toString().isNotEmpty)
                                Padding(padding: const EdgeInsets.only(top:4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal:8, vertical:2),
                                    decoration: BoxDecoration(color: AppColors.blueBg, borderRadius: BorderRadius.circular(20)),
                                    child: Text('Classe : ${data['classe']}',
                                        style: const TextStyle(fontSize:10.5, fontWeight: FontWeight.w700, color: AppColors.blue))))
                              else if ((data['portee'] ?? 'ecole')=='ecole')
                                Padding(padding: const EdgeInsets.only(top:4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal:8, vertical:2),
                                    decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(20)),
                                    child: const Text('Toute l ecole',
                                        style: TextStyle(fontSize:10.5, fontWeight: FontWeight.w700, color: AppColors.green)))),
                            ])),
                            if (_peutSupprimer
                                || (widget.user.role==UserRole.prof
                                    && (data['portee']??'ecole')=='classe'
                                    && widget.user.classes.contains((data['classeId']??'').toString())))
                              IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
                                  onPressed: () => FirebaseService.supprimerEvenement(d.id)),
                          ]));
                    }).toList());
                  }),
            ])),
      ])),
    ]);
  }
}

// ══════════════════════════════════════════
//  ESPACE VIE SCOLAIRE (blog photos)
// ══════════════════════════════════════════
class VieScolairePage extends StatefulWidget {
  final AppUser user;
  const VieScolairePage({super.key, required this.user});
  @override State<VieScolairePage> createState() => _VieScolairePageState();
}

class _VieScolairePageState extends State<VieScolairePage> {
  final _titreCtrl = TextEditingController();
  final _texteCtrl = TextEditingController();
  final List<XFile> _photos = [];
  bool _envoi = false;
  String? _ecoleSel; // école choisie (super admin / co-admin)

  // Agent Sentinel = super admin ou co-admin (rôle admin) : gère plusieurs écoles
  bool get _estAgentSentinel => widget.user.role == UserRole.admin;

  // Seuls l'admin et le directeur publient ; suppression : super admin ou directeur
  bool get _peutPublier =>
      widget.user.role == UserRole.admin || widget.user.role == UserRole.directeur;
  bool get _peutSupprimer =>
      widget.user.estSuperAdmin || widget.user.role == UserRole.directeur;

  @override
  void dispose() { _titreCtrl.dispose(); _texteCtrl.dispose(); super.dispose(); }

  Future<void> _choisirPhotos() async {
    try {
      final imgs = await ImagePicker().pickMultiImage(imageQuality: 70, maxWidth: 1600);
      if (imgs.isNotEmpty) setState(()=> _photos.addAll(imgs));
    } catch (_) {
      if (mounted) showSnack(context, 'Impossible d ouvrir la galerie.', error:true);
    }
  }

  Future<void> _publier() async {
    if (_titreCtrl.text.trim().isEmpty) { showSnack(context, 'Ajoutez un titre', error:true); return; }
    if (_photos.isEmpty && _texteCtrl.text.trim().isEmpty) {
      showSnack(context, 'Ajoutez du texte ou des photos', error:true); return;
    }
    // L'agent Sentinel doit choisir l'école ; le directeur publie pour la sienne.
    final ecoleCible = _estAgentSentinel ? _ecoleSel : widget.user.school;
    if (_estAgentSentinel && (ecoleCible == null || ecoleCible.isEmpty)) {
      showSnack(context, 'Choisissez l ecole concernee', error:true); return;
    }
    setState(()=> _envoi = true);
    try {
      final urls = <String>[];
      for (final x in _photos) {
        final bytes = await x.readAsBytes();
        final url = await FirebaseService.uploadPhotoVieScolaire(ecoleCible!, bytes, x.name);
        urls.add(url);
      }
      await FirebaseService.publierArticleVieScolaire({
        'titre': _titreCtrl.text.trim(),
        'texte': _texteCtrl.text.trim(),
        'images': urls,
        'ecoleId': ecoleCible,
        'auteur': widget.user.name,
        'date': DateTime.now().toString().substring(0,10),
      });
      if (!mounted) return;
      _titreCtrl.clear(); _texteCtrl.clear();
      setState(() { _photos.clear(); _envoi = false; });
      showSnack(context, 'Article publie ! 🎉');
    } catch (_) {
      if (mounted) { setState(()=> _envoi = false); showSnack(context, 'Erreur lors de la publication.', error:true); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = _estAgentSentinel
        ? FirebaseService.streamVieScolaireTout()
        : FirebaseService.streamVieScolaireEcole(widget.user.school);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        if (_peutPublier) ...[
          SectionTitle('Publier un article'),
          SCCard(child: Column(children:[
            if (_estAgentSentinel) ...[
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.streamEcoles(),
                builder: (c, snap) {
                  final docs = snap.data?.docs ?? [];
                  return DropdownButtonFormField<String>(
                    value: _ecoleSel,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'Ecole concernee',
                        prefixIcon: Icon(Icons.school_rounded, size:20)),
                    hint: const Text('Choisir l ecole'),
                    items: docs.map((d){
                      final nom = (d.data() as Map)['nom'] ?? d.id;
                      return DropdownMenuItem(value: d.id, child: Text('$nom', overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (v)=> setState(()=> _ecoleSel = v),
                  );
                }),
              const SizedBox(height:10),
            ],
            TextField(controller: _titreCtrl,
                decoration: const InputDecoration(labelText: 'Titre (ex. Fete de fin d annee)')),
            const SizedBox(height:10),
            TextField(controller: _texteCtrl, maxLines: 3,
                decoration: const InputDecoration(labelText: 'Texte (court)')),
            const SizedBox(height:10),
            if (_photos.isNotEmpty)
              SizedBox(height: 82, child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_,__)=>const SizedBox(width:8),
                itemBuilder: (_, i) => Stack(children:[
                  ClipRRect(borderRadius: BorderRadius.circular(8),
                      child: FutureBuilder<Uint8List>(
                        future: _photos[i].readAsBytes(),
                        builder: (c, snap) => snap.hasData
                            ? Image.memory(snap.data!, width:80, height:80, fit: BoxFit.cover)
                            : Container(width:80, height:80, color: AppColors.greenBg,
                                child: const Center(child: SizedBox(width:16, height:16,
                                    child: CircularProgressIndicator(strokeWidth:2)))),
                      )),
                  Positioned(right:2, top:2, child: GestureDetector(
                    onTap: ()=>setState(()=>_photos.removeAt(i)),
                    child: Container(padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size:14, color: Colors.white)))),
                ]),
              )),
            if (_photos.isNotEmpty) const SizedBox(height:10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: _envoi ? null : _choisirPhotos,
              icon: const Icon(Icons.add_photo_alternate_rounded, size:18),
              label: Text(_photos.isEmpty ? 'Ajouter des photos' : 'Ajouter d autres photos'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green), padding: const EdgeInsets.symmetric(vertical:12)))),
            const SizedBox(height:10),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _envoi ? null : _publier,
              child: _envoi
                  ? const SizedBox(height:20,width:20,child: CircularProgressIndicator(strokeWidth:2, color:Colors.white))
                  : const Text('Publier — Notifier les familles 📲'))),
          ])),
          const SizedBox(height:20),
        ],
        SectionTitle('Vie scolaire'),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (ctx, snap) {
            if (snap.hasError) {
              return const Text('Impossible de charger la vie scolaire.', style: TextStyle(color:AppColors.textMuted));
            }
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs.toList()
              ..sort((a,b){
                final ta=(a.data() as Map)['createdAt']; final tb=(b.data() as Map)['createdAt'];
                if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
                return 0;
              });
            if (docs.isEmpty) {
              return const Text('Aucun article pour le moment.', style: TextStyle(color:AppColors.textMuted));
            }
            return Column(children: docs.map((d){
              final data = d.data() as Map<String,dynamic>;
              final images = (data['images'] is List) ? List<String>.from(data['images']) : <String>[];
              return Container(
                margin: const EdgeInsets.only(bottom:16),
                decoration: BoxDecoration(color: Colors.white,
                    borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                  if (images.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: SizedBox(height: 210, child: PageView(children: images.map((url)=>
                        GestureDetector(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> PhotoViewer(url: url))),
                          child: Image.network(url, fit: BoxFit.cover, width: double.infinity,
                              loadingBuilder: (c,w,p)=> p==null ? w : const Center(child: CircularProgressIndicator()),
                              errorBuilder: (c,e,s)=> const Center(child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted))),
                        )).toList())),
                    ),
                  Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                    Row(children:[
                      Expanded(child: Text(data['titre'] ?? '', style: const TextStyle(fontSize:16, fontWeight: FontWeight.w800))),
                      if (_peutSupprimer)
                        GestureDetector(
                          onTap: () async {
                            final ok = await showDialog<bool>(context: context, builder: (dctx)=> AlertDialog(
                              title: const Text('Supprimer cet article ?'),
                              content: const Text('L article et ses photos ne seront plus visibles.'),
                              actions: [
                                TextButton(onPressed: ()=>Navigator.pop(dctx,false), child: const Text('Annuler')),
                                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                                    onPressed: ()=>Navigator.pop(dctx,true), child: const Text('Supprimer')),
                              ]));
                            if (ok==true) { await FirebaseService.supprimerArticleVieScolaire(d.id);
                              if (context.mounted) showSnack(context, 'Article supprime.'); }
                          },
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size:20)),
                    ]),
                    if ((data['texte'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height:6),
                      Text(data['texte'], style: const TextStyle(fontSize:13, height:1.5, color: AppColors.textMain)),
                    ],
                    const SizedBox(height:8),
                    Text('${data['auteur'] ?? ''} · ${data['date'] ?? ''}'
                        '${images.isNotEmpty ? ' · ${images.length} photo(s) — touchez pour agrandir' : ''}',
                        style: const TextStyle(fontSize:11, color: AppColors.textMuted)),
                  ])),
                ]),
              );
            }).toList());
          }),
      ]),
    );
  }
}

// Visionneuse plein écran avec téléchargement dans la galerie
class PhotoViewer extends StatefulWidget {
  final String url;
  const PhotoViewer({super.key, required this.url});
  @override State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  bool _tel = false;
  Future<void> _telecharger() async {
    setState(()=> _tel = true);
    try {
      final bytes = await FirebaseStorage.instance.refFromURL(widget.url).getData(20 * 1024 * 1024);
      if (bytes == null) throw 'vide';
      final ok = await Gal.hasAccess() || await Gal.requestAccess();
      if (!ok) {
        if (mounted) showSnack(context, 'Autorisation refusee.', error:true);
        setState(()=>_tel=false); return;
      }
      await Gal.putImageBytes(bytes);
      if (mounted) showSnack(context, 'Photo enregistree dans la galerie 📸');
    } catch (_) {
      if (mounted) showSnack(context, 'Telechargement impossible.', error:true);
    }
    if (mounted) setState(()=> _tel = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, elevation: 0),
      body: Center(child: InteractiveViewer(child: Image.network(widget.url,
          errorBuilder: (c,e,s)=> const Icon(Icons.broken_image_rounded, color: Colors.white54, size:64)))),
      floatingActionButton: kIsWeb ? null : FloatingActionButton.extended(
        onPressed: _tel ? null : _telecharger,
        backgroundColor: AppColors.green,
        icon: _tel
            ? const SizedBox(height:18,width:18,child: CircularProgressIndicator(strokeWidth:2, color:Colors.white))
            : const Icon(Icons.download_rounded),
        label: const Text('Telecharger')),
    );
  }
}

// ══════════════════════════════════════════
//  FIN DU FICHIER
// ══════════════════════════════════════════


// ══════════════════════════════════════════
//  CLASSEMENT DE CLASSE (PROF) — temps reel + rapport PDF detaille
// ══════════════════════════════════════════
class ClassementClassePage extends StatefulWidget {
  final AppUser user;
  const ClassementClassePage({super.key, required this.user});
  @override State<ClassementClassePage> createState() => _ClassementClassePageState();
}

class _ClassementClassePageState extends State<ClassementClassePage> {
  String? _classe;
  Map<String, String> _nomsEleves = {};
  final Map<String, String> _nomsClasses = {};
  bool _chargement = true;

  String get _nomClasse => _nomsClasses[_classe] ?? _classe ?? '-';

  @override
  void initState() {
    super.initState();
    _classe = widget.user.classes.isNotEmpty
        ? widget.user.classes.first
        : widget.user.classeId;
    _chargerNomsClasses();
    _chargerEleves();
  }

  // Vrais noms des classes (ex. « 6eme A ») a partir de leurs identifiants.
  Future<void> _chargerNomsClasses() async {
    final ids = widget.user.classes.isNotEmpty
        ? widget.user.classes
        : [if (widget.user.classeId != null) widget.user.classeId!];
    for (final id in ids) {
      try {
        final d = await FirebaseFirestore.instance
            .collection('classes').doc(id).get();
        final data = d.data() ?? {};
        _nomsClasses[id] = (data['nom'] ?? data['name'] ?? data['libelle'] ?? id).toString();
      } catch (_) {
        _nomsClasses[id] = id;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _chargerEleves() async {
    setState(() => _chargement = true);
    try {
      final q = await FirebaseFirestore.instance.collection('utilisateurs')
          .where('classeId', isEqualTo: _classe).get();
      final m = <String, String>{};
      for (final d in q.docs) {
        final data = d.data();
        if ((data['role'] ?? '') == 'eleve') {
          m[d.id] = (data['nom'] ?? 'Eleve').toString();
        }
      }
      _nomsEleves = m;
    } catch (_) {}
    if (mounted) setState(() => _chargement = false);
  }

  // Moyenne ponderee /20 par eleve, rang (ex-aequo partages)
  // + detail des notes de chaque eleve pour le rapport PDF.
  List<Map<String, dynamic>> _calculer(QuerySnapshot s) {
    final somme = <String, double>{};
    final poids = <String, double>{};
    final details = <String, List<Map<String, dynamic>>>{};
    for (final d in s.docs) {
      final n = d.data() as Map<String, dynamic>;
      final id = (n['eleveId'] ?? '').toString();
      if (!_nomsEleves.containsKey(id)) continue;
      final note = (n['note'] as num?)?.toDouble();
      if (note == null) continue;
      var sur = (n['sur'] as num?)?.toDouble() ?? 20;
      if (sur <= 0) sur = 20;
      final coef = (n['coefficient'] as num?)?.toDouble() ?? 1;
      somme[id] = (somme[id] ?? 0) + (note / sur) * 20 * coef;
      poids[id] = (poids[id] ?? 0) + coef;
      (details[id] ??= []).add({
        'type': (n['type'] ?? 'Evaluation').toString(),
        'note': note,
        'sur': sur,
        'coef': coef,
        'appreciation': (n['appreciation'] ?? '').toString(),
        'ts': (n['createdAt'] is Timestamp)
            ? (n['createdAt'] as Timestamp).millisecondsSinceEpoch : 0,
      });
    }
    final lignes = <Map<String, dynamic>>[];
    _nomsEleves.forEach((id, nom) {
      final p = poids[id] ?? 0;
      final det = details[id] ?? [];
      det.sort((a, b) => (a['ts'] as int).compareTo(b['ts'] as int));
      lignes.add({
        'nom': nom,
        'moyenne': p == 0 ? null : (somme[id]! / p),
        'nb': det.length,
        'notes': det,
      });
    });
    lignes.sort((a, b) {
      final ma = a['moyenne'] as double?;
      final mb = b['moyenne'] as double?;
      if (ma == null && mb == null) {
        return (a['nom'] as String).compareTo(b['nom'] as String);
      }
      if (ma == null) return 1;
      if (mb == null) return -1;
      return mb.compareTo(ma);
    });
    int rang = 0;
    double? prec;
    int vus = 0;
    for (final l in lignes) {
      final m = l['moyenne'] as double?;
      if (m == null) { l['rang'] = null; continue; }
      vus++;
      if (prec == null || (prec - m).abs() > 0.0001) { rang = vus; prec = m; }
      l['rang'] = rang;
    }
    return lignes;
  }

  Future<void> _exporterPdf(List<Map<String, dynamic>> lignes) async {
    final doc = pw.Document();
    final date = DateTime.now();
    final enTete = pw.TextStyle(fontWeight: pw.FontWeight.bold);
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      footer: (c) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Text('Genere par Sentinel CI - Veiller, pas surveiller',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey))),
      build: (c) => [
        pw.Text('Sentinel CI - Classement de classe',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Classe : $_nomClasse    Matiere : ${widget.user.matiere ?? '-'}'),
        pw.Text('Professeur : ${widget.user.name}    Date : ${date.day}/${date.month}/${date.year}'),
        pw.SizedBox(height: 12),
        pw.Text('Classement general', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: ['Rang', 'Eleve', 'Moyenne /20', 'Nb notes'],
          headerStyle: enTete,
          cellAlignments: {0: pw.Alignment.center, 2: pw.Alignment.center, 3: pw.Alignment.center},
          data: lignes.map((l) => [
            l['rang']?.toString() ?? '-',
            l['nom'].toString(),
            l['moyenne'] == null ? '-' : (l['moyenne'] as double).toStringAsFixed(2),
            l['nb'].toString(),
          ]).toList(),
        ),
        pw.SizedBox(height: 16),
        pw.Text('Detail par eleve', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        for (final l in lignes) ...[
          pw.SizedBox(height: 10),
          pw.Text(
              '${l['rang'] == null ? '-' : '${l['rang']}e'} - ${l['nom']} - Moyenne : ${l['moyenne'] == null ? 'aucune note' : '${(l['moyenne'] as double).toStringAsFixed(2)}/20'}',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          if ((l['notes'] as List).isEmpty)
            pw.Text('Aucune note enregistree.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))
          else
            pw.TableHelper.fromTextArray(
              headers: ['Evaluation', 'Note', 'Coef', 'Appreciation'],
              headerStyle: enTete.copyWith(fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignments: {1: pw.Alignment.center, 2: pw.Alignment.center},
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(0.8),
                3: const pw.FlexColumnWidth(3.8),
              },
              data: (l['notes'] as List).map((n) => [
                n['type'].toString(),
                '${(n['note'] as double) % 1 == 0 ? (n['note'] as double).toInt() : n['note']}/${(n['sur'] as double) % 1 == 0 ? (n['sur'] as double).toInt() : n['sur']}',
                (n['coef'] as double) % 1 == 0
                    ? (n['coef'] as double).toInt().toString()
                    : n['coef'].toString(),
                (n['appreciation'] as String).isEmpty ? '-' : n['appreciation'],
              ]).toList(),
            ),
        ],
      ],
    ));
    final bytes = await doc.save();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Widget build(BuildContext context) {
    final classes = widget.user.classes.isNotEmpty
        ? widget.user.classes
        : [if (widget.user.classeId != null) widget.user.classeId!];
    return Scaffold(
      appBar: AppBar(
          title: Text('Classement - ${widget.user.matiere ?? 'Ma matiere'}')),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              if (classes.length > 1)
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: DropdownButtonFormField<String>(
                      value: _classe,
                      decoration: const InputDecoration(
                          labelText: 'Classe', border: OutlineInputBorder()),
                      items: classes
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(_nomsClasses[c] ?? c)))
                          .toList(),
                      onChanged: (v) { _classe = v; _chargerEleves(); },
                    )),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('notes')
                      .where('ecoleId', isEqualTo: widget.user.school)
                      .where('matiere', isEqualTo: widget.user.matiere ?? '')
                      .snapshots(),
                  builder: (c, s) {
                    if (!s.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final lignes = _calculer(s.data!);
                    final avecMoy = lignes.where((l) => l['moyenne'] != null).toList();
                    final moyClasse = avecMoy.isEmpty ? null
                        : avecMoy.map((l) => l['moyenne'] as double)
                            .reduce((a, b) => a + b) / avecMoy.length;
                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(children: [
                          Expanded(child: Text(
                              'Classe $_nomClasse - Moyenne : ${moyClasse == null ? '-' : moyClasse.toStringAsFixed(2)}/20',
                              style: const TextStyle(fontWeight: FontWeight.w800))),
                          Text('${_nomsEleves.length} eleve(s)',
                              style: const TextStyle(color: Colors.grey)),
                        ]),
                      ),
                      Expanded(
                        child: lignes.isEmpty
                            ? const Center(child: Text('Aucun eleve dans cette classe.'))
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                                itemCount: lignes.length,
                                itemBuilder: (c, i) {
                                  final l = lignes[i];
                                  final rang = l['rang'] as int?;
                                  final couleur = rang == 1
                                      ? const Color(0xFFFFB800)
                                      : rang == 2
                                          ? const Color(0xFF9E9E9E)
                                          : rang == 3
                                              ? const Color(0xFFB87333)
                                              : AppColors.green;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border)),
                                    child: Row(children: [
                                      Container(
                                        width: 34, height: 34,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: couleur.withOpacity(.15),
                                            shape: BoxShape.circle),
                                        child: Text(rang?.toString() ?? '-',
                                            style: TextStyle(
                                                color: couleur,
                                                fontWeight: FontWeight.w800)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(l['nom'].toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600))),
                                      Text(
                                          l['moyenne'] == null
                                              ? 'Aucune note'
                                              : '${(l['moyenne'] as double).toStringAsFixed(2)}/20',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: l['moyenne'] == null
                                                  ? Colors.grey
                                                  : AppColors.green)),
                                    ]),
                                  );
                                }),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: lignes.isEmpty
                                  ? null
                                  : () => _exporterPdf(lignes),
                              icon: const Icon(Icons.picture_as_pdf_rounded),
                              label: const Text('Exporter le rapport PDF'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14)),
                            ),
                          ),
                        ),
                      ),
                    ]);
                  },
                ),
              ),
            ]),
    );
  }
}

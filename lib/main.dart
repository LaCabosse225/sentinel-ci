// ============================================================
//  SENTINEL CI — Version Firebase
//  Connexion réelle + Firestore + Notifications Push
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Erreur Firebase: $e');
    }
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(const SentinelCIApp());
  }
// ══════════════════════════════════════════
class AppColors {
  static const green     = Color(0xFF0A7C43);
  static const green2    = Color(0xFF12A05A);
  static const greenBg   = Color(0xFFE6F5EE);
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
enum UserRole { admin, prof, eleve, parent }

class AppUser {
  final String name, initials, email, school, uid;
  final UserRole role;
  const AppUser({required this.name, required this.initials,
    required this.email, required this.school,
    required this.role, required this.uid});
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
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print('ERREUR AUTH: $e');
      return null;
    }
  }

  // Déconnexion
  static Future<void> signOut() async => await _auth.signOut();

  // Récupérer profil utilisateur
  static Future<Map<String,dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('utilisateurs').doc(uid).get();
      return doc.data();
    } catch (e) { return null; }
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
    await _db.collection('alertes').add({
      'titre': 'Nouvelle note — ${note['matiere']}',
      'corps': '${note['note']}/20 en ${note['type']}',
      'type': note['note'] >= 10 ? 'success' : 'danger',
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

  // Stream paiements
  static Stream<QuerySnapshot> streamPaiements() =>
      _db.collection('paiements')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots();

  // Stream agenda
  static Stream<QuerySnapshot> streamAgenda(String ecoleId) =>
      _db.collection('agenda')
          .where('ecoleId', isEqualTo: ecoleId)
          .orderBy('date')
          .snapshots();

  // Ajouter événement agenda
  static Future<void> ajouterEvenement(Map<String,dynamic> evt) async {
    await _db.collection('agenda').add({
      ...evt,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream emploi du temps
  static Stream<QuerySnapshot> streamEmploiDuTemps(String ecoleId, String classe) =>
      _db.collection('emploiDuTemps')
          .where('ecoleId', isEqualTo: ecoleId)
          .where('classe', isEqualTo: classe)
          .snapshots();

  // Stream utilisateurs (admin)
  static Stream<QuerySnapshot> streamUtilisateurs() =>
      _db.collection('utilisateurs').orderBy('nom').snapshots();
}

// ══════════════════════════════════════════
//  APP
// ══════════════════════════════════════════
class SentinelCIApp extends StatelessWidget {
  const SentinelCIApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sentinel CI',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: const LoginScreen(),
  );
}

// ══════════════════════════════════════════
//  LOGIN SCREEN — FIREBASE AUTH
// ══════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _role = UserRole.admin;
  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();
  bool _loading    = false;
  String? _error;

  final _roles = [
    (UserRole.admin,  '⚙️', 'Admin'),
    (UserRole.prof,   '📚', 'Prof'),
    (UserRole.eleve,  '🎒', 'Eleve'),
    (UserRole.parent, '👨‍👩‍👧', 'Parent'),
  ];

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final cred = await FirebaseService.signIn(
        _emailCtrl.text.trim(), _pwCtrl.text.trim());
    if (!mounted) return;
    if (cred == null) {
      setState(() { _loading = false; _error = 'Connexion échouée. Vérifiez vos identifiants.'; });
      return;
    }
    // Récupérer le profil
    final profile = await FirebaseService.getUserProfile(cred.user!.uid);
    if (!mounted) return;
    final user = AppUser(
      name: profile?['nom'] ?? 'Utilisateur',
      initials: (profile?['nom'] ?? 'U').substring(0,1).toUpperCase() + 'A',
      email: cred.user!.email ?? '',
      school: profile?['ecoleId'] ?? 'sentinel_ci',
      role: _role,
      uid: cred.user!.uid,
    );
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
                    Container(width:50, height:50,
                        decoration: BoxDecoration(
                            color: AppColors.green, borderRadius: BorderRadius.circular(14)),
                        child: const Center(child: Text('🛡️', style: TextStyle(fontSize:26)))),
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
                  Text('Choisissez votre profil', style: TextStyle(fontSize:13, color:Colors.grey[500])),
                  const SizedBox(height:20),

                  // Rôles
                  Row(children: _roles.map((r) {
                    final sel = _role == r.$1;
                    return Expanded(child: GestureDetector(
                      onTap: () => setState(() => _role = r.$1),
                      child: Container(
                        margin: const EdgeInsets.only(right:6),
                        padding: const EdgeInsets.symmetric(vertical:10),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.greenBg : Colors.white,
                          border: Border.all(
                              color: sel ? AppColors.green : AppColors.border,
                              width: sel ? 2 : 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(children:[
                          Text(r.$2, style:const TextStyle(fontSize:18)),
                          const SizedBox(height:3),
                          Text(r.$3, style: TextStyle(fontSize:10, fontWeight:FontWeight.w700,
                              color: sel ? AppColors.green : AppColors.textMuted)),
                        ]),
                      ),
                    ));
                  }).toList()),
                  const SizedBox(height:16),

                  // Champs
                  TextField(controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height:12),
                  TextField(controller: _pwCtrl, obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mot de passe')),

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
    Container(width:40, height:40,
        decoration: BoxDecoration(color:iconBg, borderRadius:BorderRadius.circular(10)),
        child: Icon(icon, color:color, size:20)),
    const SizedBox(height:10),
    Text(value, style: const TextStyle(fontSize:26, fontWeight:FontWeight.w800)),
    Text(label, style: const TextStyle(fontSize:12, color:AppColors.textMuted)),
    const SizedBox(height:6),
    Text(sub, style: TextStyle(fontSize:12, fontWeight:FontWeight.w600, color:color)),
  ]));
}

class NotePill extends StatelessWidget {
  final double note;
  const NotePill({super.key, required this.note});
  Color get _bg => note>=16 ? AppColors.greenBg : note>=13 ? AppColors.blueBg : note>=10 ? AppColors.goldBg : AppColors.redBg;
  Color get _fg => note>=16 ? AppColors.green   : note>=13 ? AppColors.blue   : note>=10 ? AppColors.gold   : AppColors.red;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal:10, vertical:4),
      decoration: BoxDecoration(color:_bg, borderRadius:BorderRadius.circular(20)),
      child: Text('$note/20', style: TextStyle(fontSize:12, fontWeight:FontWeight.w800, color:_fg)));
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

  List<_NavItem> get _navItems {
    switch(widget.user.role){
      case UserRole.admin: return [
        _NavItem(Icons.dashboard_rounded,      'Accueil'),
        _NavItem(Icons.school_rounded,         'Ecoles'),
        _NavItem(Icons.people_rounded,         'Utilisateurs'),
        _NavItem(Icons.credit_card_rounded,    'Revenus'),
        _NavItem(Icons.notifications_rounded,  'Alertes'),
        _NavItem(Icons.calendar_month_rounded, 'Agenda'),
      ];
      case UserRole.prof: return [
        _NavItem(Icons.dashboard_rounded,      'Accueil'),
        _NavItem(Icons.edit_rounded,           'Notes'),
        _NavItem(Icons.assignment_rounded,     'Devoirs'),
        _NavItem(Icons.menu_book_rounded,      'Lecons'),
        _NavItem(Icons.message_rounded,        'Messages'),
        _NavItem(Icons.calendar_month_rounded, 'Agenda'),
      ];
      case UserRole.eleve:
      case UserRole.parent: return [
        _NavItem(Icons.dashboard_rounded,      'Accueil'),
        _NavItem(Icons.bar_chart_rounded,      'Notes'),
        _NavItem(Icons.assignment_rounded,     'Devoirs'),
        _NavItem(Icons.menu_book_rounded,      'Programme'),
        _NavItem(Icons.notifications_rounded,  'Alertes'),
        _NavItem(Icons.calendar_month_rounded, 'Agenda'),
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
      ];
      case UserRole.prof: return [
        DashboardPage(user: widget.user),
        NotesPage(user: widget.user),
        DevoirsPage(user: widget.user),
        LeconsPage(user: widget.user),
        MessageriePage(user: widget.user),
        AgendaPage(user: widget.user),
      ];
      case UserRole.eleve:
      case UserRole.parent: return [
        DashboardPage(user: widget.user),
        NotesPage(user: widget.user),
        DevoirsPage(user: widget.user),
        LeconsPage(user: widget.user),
        AlertesPage(user: widget.user),
        AgendaPage(user: widget.user),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      UserRole.admin:  AppColors.purple,
      UserRole.prof:   AppColors.orange,
      UserRole.eleve:  AppColors.green,
      UserRole.parent: AppColors.blue,
    };
    final roleLabels = {
      UserRole.admin:  'Admin',
      UserRole.prof:   'Professeur',
      UserRole.eleve:  'Eleve',
      UserRole.parent: 'Parent',
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(children:[
          RichText(text: const TextSpan(children:[
            TextSpan(text:'Sentinel', style:TextStyle(color:AppColors.green, fontWeight:FontWeight.w800, fontSize:18)),
            TextSpan(text:'CI', style:TextStyle(color:AppColors.orange, fontWeight:FontWeight.w800, fontSize:18)),
          ])),
          const SizedBox(width:8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal:8, vertical:3),
            decoration: BoxDecoration(
                color: roleColors[widget.user.role]!.withOpacity(.12),
                borderRadius: BorderRadius.circular(20)),
            child: Text(roleLabels[widget.user.role]!,
                style: TextStyle(fontSize:10, fontWeight:FontWeight.w800,
                    color:roleColors[widget.user.role], letterSpacing:.5)),
          ),
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
      body: _pages[_idx.clamp(0, _pages.length-1)],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i.clamp(0, _pages.length-1)),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.greenBg,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _navItems.map((n) => NavigationDestination(
            icon: Icon(n.icon, size:22), label: n.label)).toList(),
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
  const DashboardPage({super.key, required this.user});

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

        Text('Bonjour, ${user.name.split(' ').first} 👋',
            style: const TextStyle(fontSize:20, fontWeight:FontWeight.w800)),
        Text(user.school, style: const TextStyle(fontSize:13, color:AppColors.textMuted)),
        const SizedBox(height:20),

        if(user.role == UserRole.admin) ...[
          GridView.count(crossAxisCount:2, shrinkWrap:true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio:0.95,
              children:[
                StatCard(value:'--', label:'Ecoles partenaires', sub:'Chargement...', icon:Icons.school_rounded, color:AppColors.green, iconBg:AppColors.greenBg),
                StatCard(value:'--', label:'Parents abonnes', sub:'Chargement...', icon:Icons.people_rounded, color:AppColors.blue, iconBg:AppColors.blueBg),
                StatCard(value:'--', label:'Revenus FCFA/mois', sub:'Chargement...', icon:Icons.payments_rounded, color:AppColors.orange, iconBg:AppColors.orangeBg),
                StatCard(value:'--', label:'Eleves inscrits', sub:'Chargement...', icon:Icons.school_rounded, color:AppColors.purple, iconBg:AppColors.purpleBg),
              ]),
        ] else ...[
          GridView.count(crossAxisCount:2, shrinkWrap:true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio:0.95,
              children:[
                StatCard(value:'--', label:'Moyenne generale', sub:'Chargement...', icon:Icons.bar_chart_rounded, color:AppColors.green, iconBg:AppColors.greenBg),
                StatCard(value:'--', label:'Rang classe', sub:'Chargement...', icon:Icons.emoji_events_rounded, color:AppColors.gold, iconBg:AppColors.goldBg),
                StatCard(value:'--', label:'Devoirs urgents', sub:'Chargement...', icon:Icons.assignment_late_rounded, color:AppColors.orange, iconBg:AppColors.orangeBg),
                StatCard(value:'--', label:'Alertes', sub:'Non lues', icon:Icons.notifications_rounded, color:AppColors.red, iconBg:AppColors.redBg),
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
  String _selMat   = 'Mathematiques';
  String _selEleve = 'konan_amani';
  String _selType  = 'Devoir surveille';

  final _matieres = ['Mathematiques','Physique-Chimie','SVT','Francais','Anglais','Histoire-Geo','EPS'];

  Future<void> _saisir() async {
    final n = double.tryParse(_noteCtrl.text);
    if (n == null || n < 0 || n > 20) {
      showSnack(context, 'Note invalide (0-20)', error:true); return;
    }
    await FirebaseService.ajouterNote({
      'eleveId':      _selEleve,
      'matiere':      _selMat,
      'type':         _selType,
      'note':         n,
      'appreciation': _appreCtrl.text,
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
            DropdownButtonFormField<String>(
                value: _selEleve,
                decoration: const InputDecoration(labelText: 'Eleve'),
                items: ['konan_amani','bamba_fatoumata','koffi_jb','coulibaly_m']
                    .map((e) => DropdownMenuItem(value:e, child:Text(e))).toList(),
                onChanged: (v) => setState(() => _selEleve = v!)),
            const SizedBox(height:10),
            DropdownButtonFormField<String>(
                value: _selMat,
                decoration: const InputDecoration(labelText: 'Matiere'),
                items: _matieres.map((m) => DropdownMenuItem(value:m, child:Text(m))).toList(),
                onChanged: (v) => setState(() => _selMat = v!)),
            const SizedBox(height:10),
            DropdownButtonFormField<String>(
                value: _selType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ['Devoir surveille','Interrogation','Examen','TP','Participation']
                    .map((t) => DropdownMenuItem(value:t, child:Text(t))).toList(),
                onChanged: (v) => setState(() => _selType = v!)),
            const SizedBox(height:10),
            TextField(controller:_noteCtrl, keyboardType:TextInputType.number,
                decoration:const InputDecoration(labelText:'Note (/20)')),
            const SizedBox(height:10),
            TextField(controller:_appreCtrl,
                decoration:const InputDecoration(labelText:'Appreciation')),
            const SizedBox(height:14),
            SizedBox(width:double.infinity, child:ElevatedButton(
                onPressed:_saisir,
                child:const Text('Enregistrer — Notifier parents 📲'))),
          ])),
          const SizedBox(height:20),
        ],

        SectionTitle('Notes en temps reel'),
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamNotes(
                isProf ? _selEleve : widget.user.uid),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.docs.isEmpty)
                return SCCard(child:const Text('Aucune note enregistree.',
                    style:TextStyle(color:AppColors.textMuted)));
              return SCCard(padding:EdgeInsets.zero, child:Column(
                  children: snap.data!.docs.asMap().entries.map((e) {
                    final data = e.value.data() as Map<String,dynamic>;
                    final note = (data['note'] as num?)?.toDouble() ?? 0;
                    final last = e.key == snap.data!.docs.length - 1;
                    return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            border: last ? null : const Border(
                                bottom: BorderSide(color:AppColors.bg))),
                        child: Row(children:[
                          Expanded(child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                            Text(data['matiere'] ?? '',
                                style:const TextStyle(fontSize:13, fontWeight:FontWeight.w600)),
                            Text('${data['type'] ?? ''} · ${data['date'] ?? ''}',
                                style:const TextStyle(fontSize:11, color:AppColors.textMuted)),
                            if ((data['appreciation'] ?? '').isNotEmpty)
                              Text(data['appreciation'],
                                  style:const TextStyle(fontSize:11, color:AppColors.textMuted)),
                          ])),
                          NotePill(note:note),
                        ]));
                  }).toList()));
            }),
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

  Future<void> _publier() async {
    if (_titreCtrl.text.isEmpty) {
      showSnack(context, 'Renseignez le titre', error:true); return;
    }
    await FirebaseService.publierDevoir({
      'titre':        _titreCtrl.text,
      'matiere':      _selMat,
      'date':         _dateCtrl.text.isEmpty ? 'A definir' : _dateCtrl.text,
      'ecoleId':      widget.user.school,
      'classe':       'Terminale C',
      'professeurId': widget.user.uid,
    });
    _titreCtrl.clear(); _dateCtrl.clear();
    if (mounted) showSnack(context, 'Devoir publie — Eleves et parents notifies 📲');
  }

  @override
  Widget build(BuildContext context) {
    final isProf = widget.user.role==UserRole.prof || widget.user.role==UserRole.admin;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        if (isProf) ...[
          SectionTitle('Publier un devoir'),
          SCCard(child: Column(children:[
            DropdownButtonFormField<String>(
                value: _selMat,
                decoration: const InputDecoration(labelText: 'Matiere'),
                items: ['Mathematiques','Physique-Chimie','SVT','Francais','Anglais','Histoire-Geo']
                    .map((m) => DropdownMenuItem(value:m, child:Text(m))).toList(),
                onChanged: (v) => setState(() => _selMat = v!)),
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
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamDevoirs(widget.user.school, 'Terminale C'),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.docs.isEmpty)
                return SCCard(child: const Text('Aucun devoir publie.',
                    style:TextStyle(color:AppColors.textMuted)));
              return SCCard(child: Column(
                  children: snap.data!.docs.map((d) {
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
                            Text(data['matiere'] ?? '',
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

  @override
  Widget build(BuildContext context) {
    final isProf = widget.user.role==UserRole.prof || widget.user.role==UserRole.admin;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        SectionTitle('Avancement du programme'),
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamLecons(widget.user.school, 'Terminale C'),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.docs.isEmpty)
                return SCCard(child:const Text('Aucune lecon enregistree.',
                    style:TextStyle(color:AppColors.textMuted)));
              return SCCard(child:Column(
                  children: snap.data!.docs.map((d) {
                    final data = d.data() as Map<String,dynamic>;
                    final pct  = (data['avancement'] as num?)?.toDouble() ?? 0;
                    return Padding(
                        padding: const EdgeInsets.only(bottom:14),
                        child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
                            Text(data['matiere'] ?? '',
                                style:const TextStyle(fontSize:13, fontWeight:FontWeight.w700)),
                            Text('${pct.toInt()}%',
                                style:const TextStyle(fontSize:12, fontWeight:FontWeight.w800, color:AppColors.green)),
                          ]),
                          const SizedBox(height:2),
                          Text(data['chapitre'] ?? '',
                              style:const TextStyle(fontSize:11, color:AppColors.textMuted)),
                          const SizedBox(height:5),
                          ProgressBar(value:pct/100, color:AppColors.green),
                        ]));
                  }).toList()));
            }),

        if (isProf) ...[
          const SizedBox(height:20),
          SectionTitle('Mettre a jour'),
          SCCard(child:Column(children:[
            DropdownButtonFormField<String>(
                value: _selMat,
                decoration: const InputDecoration(labelText:'Matiere'),
                items:['Mathematiques','Physique-Chimie','SVT','Francais','Anglais','Histoire-Geo']
                    .map((m)=>DropdownMenuItem(value:m,child:Text(m))).toList(),
                onChanged:(v)=>setState(()=>_selMat=v!)),
            const SizedBox(height:10),
            TextField(controller:_chapCtrl,
                decoration:const InputDecoration(labelText:'Chapitre en cours')),
            const SizedBox(height:10),
            TextField(controller:_pctCtrl, keyboardType:TextInputType.number,
                decoration:const InputDecoration(labelText:'Avancement (%)')),
            const SizedBox(height:14),
            SizedBox(width:double.infinity, child:ElevatedButton(
                onPressed:() async {
                  showSnack(context, 'Lecon mise a jour — parents notifies 📲');
                  _chapCtrl.clear(); _pctCtrl.clear();
                },
                child:const Text('Mettre a jour 📲'))),
          ])),
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
class MessageriePage extends StatefulWidget {
  final AppUser user;
  const MessageriePage({super.key, required this.user});
  @override State<MessageriePage> createState() => _MessageriePageState();
}

class _MessageriePageState extends State<MessageriePage> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  String _dest  = 'konan_parent';

  Future<void> _send() async {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    await FirebaseService.envoyerMessage({
      'de':           widget.user.uid,
      'vers':         _dest,
      'texte':        v,
      'roleEmetteur': widget.user.role.name,
      'ecoleId':      widget.user.school,
    });
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) => Column(children:[
    Padding(padding:const EdgeInsets.all(12),
        child:DropdownButtonFormField<String>(
            value: _dest,
            decoration: const InputDecoration(labelText:'Conversation avec'),
            items: ['konan_parent','diabate_prof','konan_amani','administration']
                .map((t)=>DropdownMenuItem(value:t,child:Text(t))).toList(),
            onChanged:(v)=>setState(()=>_dest=v!))),
    Expanded(child:StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.streamMessages(widget.user.uid),
        builder:(ctx, snap) {
          if (!snap.hasData) return const Center(child:CircularProgressIndicator());
          final docs = snap.data!.docs;
          return ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal:12),
              itemCount: docs.length,
              itemBuilder:(_,i){
                final data = docs[i].data() as Map<String,dynamic>;
                final moi = data['de'] == widget.user.uid;
                return Padding(
                    padding: const EdgeInsets.only(bottom:12),
                    child:Row(
                        mainAxisAlignment: moi ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children:[
                          if (!moi) ...[
                            CircleAvatar(radius:14, backgroundColor:AppColors.green,
                                child:Text((data['de']??'?')[0].toUpperCase(),
                                    style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w800))),
                            const SizedBox(width:6),
                          ],
                          Container(
                              constraints:BoxConstraints(maxWidth:MediaQuery.of(context).size.width*.65),
                              padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),
                              decoration:BoxDecoration(
                                  color:moi?AppColors.green:Colors.white,
                                  border:moi?null:Border.all(color:AppColors.border),
                                  borderRadius:BorderRadius.only(
                                      topLeft:const Radius.circular(14),topRight:const Radius.circular(14),
                                      bottomLeft:Radius.circular(moi?14:4),
                                      bottomRight:Radius.circular(moi?4:14))),
                              child:Text(data['texte']??'',
                                  style:TextStyle(fontSize:13,color:moi?Colors.white:AppColors.textMain))),
                        ]));
              });
        })),
    Container(
        padding:const EdgeInsets.all(12),
        decoration:const BoxDecoration(color:Colors.white,
            border:Border(top:BorderSide(color:AppColors.border))),
        child:Row(children:[
          Expanded(child:TextField(controller:_ctrl,
              decoration:const InputDecoration(hintText:'Votre message...', border:InputBorder.none),
              onSubmitted:(_)=>_send())),
          IconButton(icon:const Icon(Icons.send_rounded),
              color:AppColors.green, onPressed:_send),
        ])),
  ]);
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
  String _plan    = 'Premium';

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
                const SizedBox(width:10),
                Expanded(child:DropdownButtonFormField<String>(value:_plan,
                    decoration:const InputDecoration(labelText:'Plan'),
                    items:['Basique','Premium','Essai']
                        .map((p)=>DropdownMenuItem(value:p,child:Text(p))).toList(),
                    onChanged:(v)=>ss(()=>_plan=v!))),
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
                      'plan':    _plan,
                      'eleves':  int.tryParse(_nbCtrl.text)??0,
                      'statut':  'actif',
                      'revenus': 0,
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
                  const SizedBox(height:12),
                  Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                    Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
                        decoration:BoxDecoration(color:AppColors.greenBg,borderRadius:BorderRadius.circular(8)),
                        child:Text(data['plan']??'',
                            style:const TextStyle(fontSize:11,fontWeight:FontWeight.w700,color:AppColors.green))),
                    Text('${data['revenus']??0} FCFA/mois',
                        style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),
                  ]),
                ]));
              });
        })),
  ]);
}

// ══════════════════════════════════════════
//  UTILISATEURS PAGE (ADMIN)
// ══════════════════════════════════════════
class UtilisateursPage extends StatelessWidget {
  final AppUser user;
  const UtilisateursPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final roleColors = {
      'eleve':   (AppColors.green,  AppColors.greenBg),
      'parent':  (AppColors.blue,   AppColors.blueBg),
      'prof':    (AppColors.orange, AppColors.orangeBg),
      'admin':   (AppColors.purple, AppColors.purpleBg),
    };
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.streamUtilisateurs(),
        builder:(ctx, snap){
          if (snap.connectionState==ConnectionState.waiting)
            return const Center(child:CircularProgressIndicator());
          if (!snap.hasData||snap.data!.docs.isEmpty)
            return const Center(child:Text('Aucun utilisateur.'));
          return ListView.separated(
              padding:const EdgeInsets.all(16),
              itemCount:snap.data!.docs.length,
              separatorBuilder:(_,__)=>const SizedBox(height:10),
              itemBuilder:(_,i){
                final data = snap.data!.docs[i].data() as Map<String,dynamic>;
                final role = data['role']??'eleve';
                final rc = roleColors[role]??(AppColors.green,AppColors.greenBg);
                return SCCard(child:Row(children:[
                  CircleAvatar(radius:20, backgroundColor:rc.$1,
                      child:Text((data['nom']??'?')[0].toUpperCase(),
                          style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800))),
                  const SizedBox(width:12),
                  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Text(data['nom']??'',
                        style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700)),
                    Text(data['ecoleId']??'',
                        style:const TextStyle(fontSize:11,color:AppColors.textMuted)),
                  ])),
                  Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:3),
                      decoration:BoxDecoration(color:rc.$2,borderRadius:BorderRadius.circular(8)),
                      child:Text(role,
                          style:TextStyle(fontSize:10,fontWeight:FontWeight.w800,color:rc.$1))),
                ]));
              });
        });
  }
}

// ══════════════════════════════════════════
//  REVENUS PAGE (ADMIN)
// ══════════════════════════════════════════
class RevenusPage extends StatelessWidget {
  final AppUser user;
  const RevenusPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        GridView.count(crossAxisCount:2, shrinkWrap:true,
            physics:const NeverScrollableScrollPhysics(),
            crossAxisSpacing:12, mainAxisSpacing:12, childAspectRatio:0.95,
            children:[
              StatCard(value:'--',label:'Revenus mois (FCFA)',sub:'Chargement...',icon:Icons.payments_rounded,color:AppColors.green,iconBg:AppColors.greenBg),
              StatCard(value:'--',label:'Abonnes actifs',sub:'Chargement...',icon:Icons.people_rounded,color:AppColors.blue,iconBg:AppColors.blueBg),
              StatCard(value:'--',label:'Impayes ce mois',sub:'Relances actives',icon:Icons.warning_rounded,color:AppColors.orange,iconBg:AppColors.orangeBg),
              StatCard(value:'96%',label:'Taux recouvrement',sub:'Objectif 98%',icon:Icons.check_circle_rounded,color:AppColors.green,iconBg:AppColors.greenBg),
            ]),
        const SizedBox(height:20),
        SectionTitle('Plans tarifaires'),
        Row(children:[
          Expanded(child:Container(
              padding:const EdgeInsets.all(16),
              decoration:BoxDecoration(color:Colors.white,
                  border:Border.all(color:AppColors.green,width:2),
                  borderRadius:BorderRadius.circular(14)),
              child:Column(children:[
                const Text('Basique',style:TextStyle(fontWeight:FontWeight.w800,fontSize:14)),
                const SizedBox(height:6),
                const Text('2 500',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900,color:AppColors.green)),
                const Text('FCFA / parent / mois',style:TextStyle(fontSize:10,color:AppColors.textMuted)),
                const SizedBox(height:8),
                const Text('Notes + Devoirs + Alertes',
                    style:TextStyle(fontSize:11,color:AppColors.textMuted)),
              ]))),
          const SizedBox(width:12),
          Expanded(child:Container(
              padding:const EdgeInsets.all(16),
              decoration:BoxDecoration(color:AppColors.greenBg,
                  border:Border.all(color:AppColors.green),
                  borderRadius:BorderRadius.circular(14)),
              child:Column(children:[
                const Text('Premium',style:TextStyle(fontWeight:FontWeight.w800,fontSize:14)),
                const SizedBox(height:6),
                const Text('5 000',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900,color:AppColors.green)),
                const Text('FCFA / parent / mois',style:TextStyle(fontSize:10,color:AppColors.textMuted)),
                const SizedBox(height:8),
                const Text('Tout + Messagerie + Lecons',
                    style:TextStyle(fontSize:11,color:AppColors.textMuted)),
              ]))),
        ]),
        const SizedBox(height:20),
        SectionTitle('Mobile Money & Paiement'),
        SCCard(child:Column(children:[
          _payRow('Wave CI',       '🟣', AppColors.purple),
          _payRow('Orange Money',  '🟠', AppColors.orange),
          _payRow('MTN MoMo',      '🟡', AppColors.gold),
          _payRow('Moov Money',    '🔵', AppColors.blue),
          _payRow('Visa/Mastercard','💳', AppColors.textMuted),
        ])),
        const SizedBox(height:20),
        SectionTitle('Paiements recents'),
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamPaiements(),
            builder:(ctx,snap){
              if (!snap.hasData) return const Center(child:CircularProgressIndicator());
              if (snap.data!.docs.isEmpty)
                return SCCard(child:const Text('Aucun paiement.',
                    style:TextStyle(color:AppColors.textMuted)));
              return SCCard(padding:EdgeInsets.zero, child:Column(
                  children:snap.data!.docs.map((d){
                    final data = d.data() as Map<String,dynamic>;
                    final paye = data['statut']=='paye';
                    return Padding(
                        padding:const EdgeInsets.all(14),
                        child:Row(children:[
                          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                            Text(data['parentId']??'',
                                style:const TextStyle(fontSize:13,fontWeight:FontWeight.w700)),
                            Text('${data['operateur']??''} · ${data['plan']??''}',
                                style:const TextStyle(fontSize:11,color:AppColors.textMuted)),
                          ])),
                          Text('${data['montant']??0} F',
                              style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800)),
                          const SizedBox(width:8),
                          Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:3),
                              decoration:BoxDecoration(
                                  color:paye?AppColors.greenBg:AppColors.redBg,
                                  borderRadius:BorderRadius.circular(8)),
                              child:Text(paye?'Paye':'Impaye',
                                  style:TextStyle(fontSize:10,fontWeight:FontWeight.w800,
                                      color:paye?AppColors.green:AppColors.red))),
                        ]));
                  }).toList()));
            }),
      ]));

  Widget _payRow(String name, String emoji, Color color) => Padding(
      padding:const EdgeInsets.symmetric(vertical:10),
      child:Row(children:[
        Text(emoji,style:const TextStyle(fontSize:22)),
        const SizedBox(width:12),
        Expanded(child:Text(name,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w600))),
        Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
            decoration:BoxDecoration(color:AppColors.greenBg,borderRadius:BorderRadius.circular(20)),
            child:const Text('Actif',
                style:TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:AppColors.green))),
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
  final _jours = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi'];
  final _titreCtrl = TextEditingController();
  final _dateCtrl  = TextEditingController();
  String _selType  = 'evenement';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length:2, vsync:this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  bool get _canEdit => widget.user.role==UserRole.prof||widget.user.role==UserRole.admin;

  Future<void> _ajouterEvt() async {
    if (_titreCtrl.text.isEmpty||_dateCtrl.text.isEmpty) {
      showSnack(context,'Remplissez titre et date',error:true); return;
    }
    await FirebaseService.ajouterEvenement({
      'titre':   _titreCtrl.text,
      'date':    _dateCtrl.text,
      'type':    _selType,
      'ecoleId': widget.user.school,
      'classe':  'Terminale C',
      'notifie': false,
    });
    _titreCtrl.clear(); _dateCtrl.clear();
    if (mounted) showSnack(context, 'Evenement ajoute — Tous notifies 📲');
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

        // EMPLOI DU TEMPS
        SingleChildScrollView(
            padding:const EdgeInsets.all(16),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
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
                  stream:FirebaseService.streamEmploiDuTemps(widget.user.school,'Terminale C'),
                  builder:(ctx,snap){
                    if (!snap.hasData) return const Center(child:CircularProgressIndicator());
                    final docs = snap.data!.docs
                        .where((d)=>(d.data() as Map)['jour']==_selectedDay).toList();
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
                            Padding(padding:const EdgeInsets.all(14),child:Column(
                                crossAxisAlignment:CrossAxisAlignment.start,children:[
                              Text(data['heure']??'',
                                  style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:AppColors.green)),
                              const SizedBox(height:3),
                              Text(data['matiere']??'',
                                  style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800)),
                              const SizedBox(height:3),
                              Text('Salle ${data['salle']??''} · ${data['professeurId']??''}',
                                  style:const TextStyle(fontSize:12,color:AppColors.textMuted)),
                            ])),
                          ]));
                    }).toList());
                  }),
            ])),

        // CALENDRIER SCOLAIRE
        SingleChildScrollView(
            padding:const EdgeInsets.all(16),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              if (_canEdit)...[
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
                  const SizedBox(height:14),
                  SizedBox(width:double.infinity,child:ElevatedButton(
                      onPressed:_ajouterEvt,
                      child:const Text('Publier — Notifier tout le monde 📲'))),
                ])),
                const SizedBox(height:20),
              ],
              SectionTitle('Evenements & Calendrier'),
              StreamBuilder<QuerySnapshot>(
                  stream:FirebaseService.streamAgenda(widget.user.school),
                  builder:(ctx,snap){
                    if (!snap.hasData) return const Center(child:CircularProgressIndicator());
                    if (snap.data!.docs.isEmpty)
                      return const Text('Aucun evenement.',
                          style:TextStyle(color:AppColors.textMuted));
                    return Column(children:snap.data!.docs.map((d){
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
                            ])),
                          ]));
                    }).toList());
                  }),
            ])),
      ])),
    ]);
  }
}

// ══════════════════════════════════════════
//  FIN DU FICHIER
// ══════════════════════════════════════════

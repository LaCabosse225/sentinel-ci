// Implémentation WEB : ouvre les URLs dans un nouvel onglet
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> ouvrirUrlPlateforme(String url) async {
  html.window.open(url, '_blank');
}

// Implémentation MOBILE : ouvre les URLs via des méthodes natives
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

Future<void> ouvrirUrlPlateforme(String url) async {
  if (kIsWeb) return; // ne devrait pas arriver
  try {
    await SystemChannels.platform.invokeMethod('url_launcher/launch', {
      'url': url,
      'useSafariVC': false,
      'useWebView': false,
      'enableJavaScript': false,
      'enableDomStorage': false,
      'universalLinksOnly': false,
      'headers': <String, String>{},
    });
  } catch (_) {}
}

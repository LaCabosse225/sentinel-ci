// Service worker des notifications push web (PWA) — Sentinel CI.
// Il reçoit les notifications même quand l'onglet est fermé.
// Les bundles Firebase sont hébergés localement (site autonome) : le script
// web_autonome.py réécrit les chemins /firebasejs/ au moment du build.
importScripts('/firebasejs/firebase-app-compat.js');
importScripts('/firebasejs/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyC76Vz7DjxjRKpdQ6thnusgaBZMS9u-_hg',
  authDomain: 'sentinel-ci-c7592.firebaseapp.com',
  projectId: 'sentinel-ci-c7592',
  storageBucket: 'sentinel-ci-c7592.firebasestorage.app',
  messagingSenderId: '777104094412',
  appId: '1:777104094412:web:e27ecf7b65e0505081be69',
});

const messaging = firebase.messaging();

// Notification reçue quand l'app web est fermée ou en arrière-plan.
messaging.onBackgroundMessage(function (payload) {
  const titre = (payload.notification && payload.notification.title) || 'Sentinel CI';
  const options = {
    body: (payload.notification && payload.notification.body) || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'sentinel-notif',
  };
  self.registration.showNotification(titre, options);
});

// Au clic sur la notification : ouvrir (ou focaliser) l'application.
self.addEventListener('notificationclick', function (event) {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (liste) {
      for (const client of liste) {
        if (client.url.includes('/app') && 'focus' in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow('/app');
    })
  );
});

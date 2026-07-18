// ============================================================
//  SENTINEL CI — Robots de notifications automatiques
//  Ces fonctions tournent sur les serveurs Firebase 24h/24.
//  Elles surveillent les collections et envoient les notifications
//  push (son + bannière) sans aucune intervention humaine.
//
//  Ciblage :
//   - Devoir / Cours            -> canal de la classe concernée
//   - Agenda portée "ecole"     -> canal de toute l'école
//   - Agenda portée "classe"    -> canal de la classe
//   - Message privé             -> appareils du destinataire
//   - Note                      -> appareils de l'élève ET de ses parents
// ============================================================
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();
setGlobalOptions({ region: "us-central1", maxInstances: 10 });

// Même règle de nettoyage que dans l'application mobile.
const propre = (s) => String(s || "").replace(/[^A-Za-z0-9_.~%-]/g, "_");

// Coupe un texte trop long pour la bannière.
const court = (s, n = 90) => {
  const t = String(s || "").trim();
  return t.length <= n ? t : t.slice(0, n - 1) + "…";
};

// Options Android : canal haute priorité créé par l'application
// (son + vibration + bannière, même app fermée).
const optionsAndroid = {
  priority: "high",
  notification: {
    channelId: "sentinel_important",
    defaultSound: true,
    defaultVibrateTimings: true,
  },
};

// Envoi vers un canal (topic)
async function envoyerAuCanal(canal, titre, corps) {
  await admin.messaging().send({
    topic: canal,
    notification: { title: titre, body: corps },
    android: optionsAndroid,
  });
  console.log(`Notification envoyée au canal ${canal} : ${titre}`);
}

// Envoi vers les appareils d'une liste d'utilisateurs, avec nettoyage
// automatique des appareils qui n'existent plus.
async function envoyerAuxUtilisateurs(uids, titre, corps) {
  const db = admin.firestore();
  for (const uid of uids) {
    if (!uid) continue;
    const doc = await db.collection("utilisateurs").doc(uid).get();
    const jetons = (doc.data() || {}).fcmTokens || [];
    if (!jetons.length) continue;
    const reponse = await admin.messaging().sendEachForMulticast({
      tokens: jetons,
      notification: { title: titre, body: corps },
      android: optionsAndroid,
    });
    // Retirer les jetons morts (application désinstallée, etc.)
    const morts = [];
    reponse.responses.forEach((r, i) => {
      const code = r.error && r.error.code;
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token" ||
        code === "messaging/invalid-argument"
      ) {
        morts.push(jetons[i]);
      }
    });
    if (morts.length) {
      await db.collection("utilisateurs").doc(uid).update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...morts),
      });
    }
    console.log(
      `Notification -> ${uid} : ${reponse.successCount} ok, ${reponse.failureCount} échec(s)`
    );
  }
}

// ---------- 📚 NOUVEAU DEVOIR -> classe ----------
exports.notifDevoir = onDocumentCreated("devoirs/{id}", async (evt) => {
  const d = evt.data ? evt.data.data() : null;
  if (!d || !d.classeId) return;
  await envoyerAuCanal(
    `classe_${propre(d.classeId)}`,
    `📚 Nouveau devoir — ${d.matiere || ""}`.trim(),
    court(`${d.titre || "Devoir"} • à rendre le ${d.date || "?"}`)
  );
});

// ---------- 📖 NOUVEAU COURS -> classe ----------
exports.notifCours = onDocumentCreated("lecons/{id}", async (evt) => {
  const d = evt.data ? evt.data.data() : null;
  if (!d || !d.classeId) return;
  await envoyerAuCanal(
    `classe_${propre(d.classeId)}`,
    `📖 Nouveau cours — ${d.matiere || ""}`.trim(),
    court(d.titre || "Un nouveau contenu de cours est disponible")
  );
});

// ---------- 🗓️ AGENDA -> école entière ou classe ----------
exports.notifAgenda = onDocumentCreated("agenda/{id}", async (evt) => {
  const d = evt.data ? evt.data.data() : null;
  if (!d) return;
  const canal =
    d.portee === "classe" && d.classeId
      ? `classe_${propre(d.classeId)}`
      : `ecole_${propre(d.ecoleId)}`;
  if (!d.ecoleId && !(d.portee === "classe" && d.classeId)) return;
  await envoyerAuCanal(
    canal,
    `🗓️ Agenda — ${d.type || "Événement"}`,
    court(`${d.titre || ""} • ${d.date || ""}`)
  );
});

// ---------- ✉️ MESSAGE PRIVÉ -> destinataire ----------
exports.notifMessage = onDocumentCreated("messages/{id}", async (evt) => {
  const d = evt.data ? evt.data.data() : null;
  if (!d || !d.vers || d.vers === d.de) return;
  let nom = "Nouveau message";
  try {
    const exp = await admin
      .firestore()
      .collection("utilisateurs")
      .doc(d.de)
      .get();
    nom = (exp.data() || {}).nom || nom;
  } catch (e) {
    console.log("Expéditeur introuvable :", e.message);
  }
  await envoyerAuxUtilisateurs([d.vers], `✉️ ${nom}`, court(d.texte, 110));
});

// ---------- 📝 NOUVELLE NOTE -> élève + ses parents ----------
exports.notifNote = onDocumentCreated("notes/{id}", async (evt) => {
  const d = evt.data ? evt.data.data() : null;
  if (!d || !d.eleveId) return;
  const db = admin.firestore();
  const cibles = [d.eleveId];
  try {
    const parents = await db
      .collection("utilisateurs")
      .where("enfants", "array-contains", d.eleveId)
      .get();
    parents.forEach((p) => cibles.push(p.id));
  } catch (e) {
    console.log("Recherche parents impossible :", e.message);
  }
  await envoyerAuxUtilisateurs(
    cibles,
    `📝 Nouvelle note — ${d.matiere || ""}`.trim(),
    court(`${d.note}/${d.sur || 20} (${d.type || "évaluation"})`)
  );
});

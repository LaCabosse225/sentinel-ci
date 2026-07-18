// ============================================================
//  SENTINEL CI — Autoriser l'affichage des photos sur le site web
//  Applique le réglage CORS au coffre Firebase Storage : sans lui,
//  les navigateurs refusent d'afficher les images (icône brisée),
//  alors que l'application Android n'a pas cette contrainte.
//  Exécuté par Codemagic avec la clé de service. Idempotent.
// ============================================================
const { GoogleAuth } = require("google-auth-library");

const COFFRE = "sentinel-ci-c7592.firebasestorage.app";

(async () => {
  const auth = new GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/devstorage.full_control"],
  });
  const client = await auth.getClient();
  const res = await client.request({
    url: `https://storage.googleapis.com/storage/v1/b/${COFFRE}`,
    method: "PATCH",
    data: {
      cors: [
        {
          origin: ["*"],
          method: ["GET", "HEAD"],
          responseHeader: ["Content-Type", "Range"],
          maxAgeSeconds: 3600,
        },
      ],
    },
  });
  console.log("CORS applique au coffre :", JSON.stringify(res.data.cors));
  console.log("TERMINE : les photos s'afficheront sur le site web. ✔");
})().catch((e) => {
  console.error("ECHEC CORS :", e.message);
  process.exit(1);
});

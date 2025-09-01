const admin = require('firebase-admin');
const sa = require('./serviceAccountKey.json');

admin.initializeApp({ credential: admin.credential.cert(sa) });

// Pasa el UID por línea de comandos: node set_claims.js <UID>
const uid = process.argv[2];
if (!uid) {
  console.error('Falta UID. Uso: node set_claims.js <UID>');
  process.exit(1);
}

const claims = { brandId: 'omoda' };

admin.auth().setCustomUserClaims(uid, claims)
  .then(async () => {
    const user = await admin.auth().getUser(uid);
    console.log('Claims asignados OK. customClaims:', user.customClaims);
    process.exit(0);
  })
  .catch(err => {
    console.error('Error asignando claims:', err);
    process.exit(1);
  });

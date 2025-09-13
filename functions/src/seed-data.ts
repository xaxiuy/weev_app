import * as admin from 'firebase-admin';
import * as path from 'path';
import * as fs from 'fs';

// Busca credencial por variable o por archivo local
const credPath = process.env.GOOGLE_APPLICATION_CREDENTIALS
  ?? path.join(__dirname, '../serviceAccountKey.json');

if (!fs.existsSync(credPath)) {
  console.error('❌ No encuentro la credencial:', credPath);
  console.error('Crea serviceAccountKey.json o exporta GOOGLE_APPLICATION_CREDENTIALS');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require(credPath)),
});

const db = admin.firestore();

async function run() {
  // Brand settings (acme)
  await db.collection('brands').doc('acme').set({
    settings: {
      pointsPerActivationDefault: 50,
      tiers: [
        { level: 'bronze', minPoints: 0 },
        { level: 'silver', minPoints: 200 },
        { level: 'gold',  minPoints: 600 },
      ],
      tierValidityDays: 365,
    },
  }, { merge: true });

  // Products
  const products = [
    { id: 'sku1', title: 'Zapatillas Flux', image: 'https://picsum.photos/600/800?1', brandId: 'acme', tags: ['sneakers','running','lifestyle'] },
    { id: 'sku2', title: 'Remera Air',     image: 'https://picsum.photos/600/800?2', brandId: 'acme', tags: ['tops','training'] },
    { id: 'sku3', title: 'Campera Storm',  image: 'https://picsum.photos/600/800?3', brandId: 'acme', tags: ['jackets','outdoor'] },
  ];
  for (const p of products) {
    await db.collection('products').doc(p.id).set(p, { merge: true });
  }

  // Activation code de prueba
  await db.collection('activation_codes').doc('abc123').set({
    brandId: 'acme',
    code: 'abc123',
    productId: 'sku1',
    isUsed: false,
    validFrom: '2025-01-01',
    validTo: '2026-01-01',
    tags: ['promo','retail'],
  }, { merge: true });

  console.log('✅ Seeds completados');
  process.exit(0);
}

run().catch((e) => {
  console.error('❌ Error al sembrar:', e);
  process.exit(1);
});

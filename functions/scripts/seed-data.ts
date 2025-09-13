import * as admin from 'firebase-admin';
import * as path from 'path';

const serviceAccount = require(path.join(__dirname, '../serviceAccountKey.json'));
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function run() {
  await db.collection('brands').doc('acme').set({
    settings: {
      pointsPerActivationDefault: 50,
      tiers: [
        { level: 'bronze', minPoints: 0 },
        { level: 'silver', minPoints: 200 },
        { level: 'gold', minPoints: 600 }
      ],
      tierValidityDays: 365
    }
  });

  const products = [
    { id: 'sku1', title: 'Zapatillas Flux', image: 'https://picsum.photos/600/800?1', brandId: 'acme', tags: ['sneakers','running','lifestyle'] },
    { id: 'sku2', title: 'Remera Air', image: 'https://picsum.photos/600/800?2', brandId: 'acme', tags: ['tops','training'] },
    { id: 'sku3', title: 'Campera Storm', image: 'https://picsum.photos/600/800?3', brandId: 'acme', tags: ['jackets','outdoor'] }
  ];
  for (const p of products) {
    await db.collection('products').doc(p.id).set(p);
  }

  await db.collection('activation_codes').doc('abc123').set({
    brandId: 'acme',
    code: 'abc123',
    productId: 'sku1',
    isUsed: false,
    validFrom: '2025-01-01',
    validTo: '2026-01-01',
    tags: ['promo','retail']
  });

  console.log('✅ Seeds completados');
  process.exit(0);
}
run();

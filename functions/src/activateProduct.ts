import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const activateProduct = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new Error("AUTH_REQUIRED");
  }

  const code = String(request.data?.code ?? "").trim().toLowerCase();
  if (!code) {
    // v2: para retornar error al cliente, lanzamos y el SDK del cliente lo mapeará
    const err: any = new Error("INVALID_CODE");
    err.code = "INVALID_CODE";
    throw err;
  }

  const codeRef = db.collection("activation_codes").doc(code);
  const codeSnap = await codeRef.get();
  if (!codeSnap.exists) {
    const err: any = new Error("INVALID_CODE");
    err.code = "INVALID_CODE";
    throw err;
  }
  const codeData = codeSnap.data()!;
  if (codeData.isUsed) {
    const err: any = new Error("ALREADY_USED");
    err.code = "ALREADY_USED";
    throw err;
  }

  const brandId: string = codeData.brandId;
  const productId: string | null = codeData.productId ?? null;

  const brandSnap = await db.collection("brands").doc(brandId).get();
  if (!brandSnap.exists) {
    const err: any = new Error("INVALID_BRAND");
    err.code = "INVALID_BRAND";
    throw err;
  }
  const settings = (brandSnap.data()?.settings || {});
  const pointsDefault: number = settings.pointsPerActivationDefault ?? 50;
  const tiers: Array<{level:string;minPoints:number}> = settings.tiers ?? [
    { level: "bronze", minPoints: 0 },
    { level: "silver", minPoints: 200 },
    { level: "gold",   minPoints: 600 },
  ];
  const tierValidityDays: number = settings.tierValidityDays ?? 365;

  const points = pointsDefault; // MVP: sin overrides

  const activationRef = db.collection("activations").doc();
  const walletRef = db.collection("users").doc(uid).collection("wallet").doc(brandId);

  await db.runTransaction(async (tx) => {
    const fresh = await tx.get(codeRef);
    if (!fresh.exists) {
      const err: any = new Error("INVALID_CODE");
      err.code = "INVALID_CODE";
      throw err;
    }
    if (fresh.data()!.isUsed) {
      const err: any = new Error("ALREADY_USED");
      err.code = "ALREADY_USED";
      throw err;
    }

    // 1) marcar código usado
    tx.update(codeRef, {
      isUsed: true,
      usedBy: uid,
      usedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 2) crear activation
    tx.set(activationRef, {
      userId: uid,
      brandId,
      productId,
      code,
      points,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3) actualizar wallet
    const w = await tx.get(walletRef);
    const prev = w.exists ? w.data()! : { points: 0, tier: "bronze", tierExpiryAt: null };
    const newPoints = (prev.points ?? 0) + points;

    let newTier = prev.tier ?? "bronze";
    for (const t of tiers.sort((a,b)=>a.minPoints-b.minPoints)) {
      if (newPoints >= t.minPoints) newTier = t.level;
    }

    const now = admin.firestore.Timestamp.now();
    const expiryMs = tierValidityDays * 24 * 60 * 60 * 1000;
    const tierExpiryAt = new admin.firestore.Timestamp(Math.floor((now.toMillis()+expiryMs)/1000), 0);

    tx.set(walletRef, {
      points: newPoints,
      tier: newTier,
      tierExpiryAt,
      lastActivation: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  });

  return { points, brandId, tierValidityDays };
});

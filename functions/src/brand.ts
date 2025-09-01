import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2/options";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { z } from "zod";
import {
  BrandProfile, Product, Story, Card, ActivationRule,
  BrandMetricsSummary, BrandMetricsDaily,
} from "./types";
import { requireBrand, requireAdmin } from "./security";

setGlobalOptions({ region: "us-central1", memory: "256MiB", timeoutSeconds: 30 });
const db = getFirestore();

const todayKey = () => {
  const d = new Date();
  const yyyy = d.getUTCFullYear();
  const mm = String(d.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(d.getUTCDate()).padStart(2, "0");
  return `${yyyy}${mm}${dd}`;
};

// ===== BRAND PROFILE en brands/{brandId} =====
export const brandUpdateProfile = onCall(async (req) => {
  const brandId = requireBrand(req);

  const schema = z.object({
    name: z.string().min(2),
    logoUrl: z.string().url().optional(),
    description: z.string().max(2000).optional(),
    links: z.array(z.string().url()).optional(),
    categories: z.array(z.string()).max(20).optional(),
  });
  const data = schema.parse(req.data);
  const now = FieldValue.serverTimestamp() as any;

  const profile: Partial<BrandProfile> = {
    ...data,
    updatedAt: now,
  };

  await db.doc(`brands/${brandId}`).set({ createdAt: now, ...profile }, { merge: true });
  return { ok: true };
});

// ===== PRODUCTS =====
export const brandCreateProduct = onCall(async (req) => {
  const brandId = requireBrand(req);
  const schema = z.object({
    title: z.string().min(2),
    sku: z.string().optional(),
    price: z.number().nonnegative().optional(),
    imageUrl: z.string().url().optional(),
    inSwipe: z.boolean().optional(),
  });
  const input = schema.parse(req.data);
  const now = FieldValue.serverTimestamp() as any;

  const doc: Product = {
    ...input,
    inSwipe: input.inSwipe ?? false,
    createdAt: now,
    updatedAt: now,
  };

  const ref = await db.collection(`brands/${brandId}/products`).add(doc);
  return { ok: true, id: ref.id };
});

export const brandUpdateProduct = onCall(async (req) => {
  const brandId = requireBrand(req);
  const schema = z.object({
    productId: z.string(),
    title: z.string().min(2).optional(),
    sku: z.string().optional(),
    price: z.number().nonnegative().optional(),
    imageUrl: z.string().url().optional(),
    inSwipe: z.boolean().optional(),
  });
  const input = schema.parse(req.data);
  const now = FieldValue.serverTimestamp() as any;

  const { productId, ...rest } = input;
  await db.doc(`brands/${brandId}/products/${productId}`).set({ ...rest, updatedAt: now }, { merge: true });
  return { ok: true };
});

// ===== STORIES =====
export const brandCreateStory = onCall(async (req) => {
  const brandId = requireBrand(req);
  const schema = z.object({
    imageUrl: z.string().url(),
    linkUrl: z.string().url().optional(),
    expiresAt: z.string().datetime().optional(), // ISO8601
  });
  const input = schema.parse(req.data);
  const now = FieldValue.serverTimestamp() as any;

  const expiresAtDate = input.expiresAt ? new Date(input.expiresAt) : undefined;
  const doc: Story = {
    imageUrl: input.imageUrl,
    linkUrl: input.linkUrl,
    expiresAt: expiresAtDate as any,
    createdAt: now,
    updatedAt: now,
  };

  const ref = await db.collection(`brands/${brandId}/stories`).add(doc);
  return { ok: true, id: ref.id };
});

// ===== CARDS (wallet) =====
export const brandCreateCard = onCall(async (req) => {
  const brandId = requireBrand(req);
  const schema = z.object({
    title: z.string().min(2),
    colorHex: z.string().regex(/^#([0-9a-fA-F]{6})$/),
    logoUrl: z.string().url().optional(),
    benefitText: z.string().optional(),
  });
  const input = schema.parse(req.data);
  const now = FieldValue.serverTimestamp() as any;

  const doc: Card = { ...input, createdAt: now, updatedAt: now };
  const ref = await db.collection(`brands/${brandId}/cards`).add(doc);
  return { ok: true, id: ref.id };
});

// ===== ACTIVATION RULES =====
export const brandCreateActivationRule = onCall(async (req) => {
  const brandId = requireBrand(req);
  const schema = z.object({
    cardId: z.string(),
    type: z.enum(["COUNT_ITEMS", "AMOUNT", "SPECIFIC_SKU"]),
    threshold: z.number().int().positive().optional(),
    amountCents: z.number().int().positive().optional(),
    sku: z.string().optional(),
    active: z.boolean().default(true),
  });
  const input = schema.parse(req.data);
  const now = FieldValue.serverTimestamp() as any;

  if (input.type === "COUNT_ITEMS" && !input.threshold) {
    throw new HttpsError("invalid-argument", "COUNT_ITEMS requiere threshold.");
  }
  if (input.type === "AMOUNT" && !input.amountCents) {
    throw new HttpsError("invalid-argument", "AMOUNT requiere amountCents.");
  }
  if (input.type === "SPECIFIC_SKU" && !input.sku) {
    throw new HttpsError("invalid-argument", "SPECIFIC_SKU requiere sku.");
  }

  const cardSnap = await db.doc(`brands/${brandId}/cards/${input.cardId}`).get();
  if (!cardSnap.exists) {
    throw new HttpsError("not-found", "La tarjeta no existe.");
  }

  const rule: ActivationRule = {
    type: input.type,
    threshold: input.threshold,
    amountCents: input.amountCents,
    sku: input.sku,
    cardId: input.cardId,
    active: input.active,
    createdAt: now,
    updatedAt: now,
  };

  const ref = await db.collection(`brands/${brandId}/activationRules`).add(rule);
  return { ok: true, id: ref.id };
});

// ===== DASHBOARD =====
export const brandDashboard = onCall(async (req) => {
  const brandId = requireBrand(req);

  const summaryRef = db.doc(`brands/${brandId}/metrics/summary`);
  const dailyRef = db.collection(`brands/${brandId}/metrics/daily`).orderBy("date", "desc").limit(14);

  const [summarySnap, dailySnap] = await Promise.all([summaryRef.get(), dailyRef.get()]);

  const summary = (summarySnap.data() as BrandMetricsSummary | undefined) ?? {
    profileVisits: 0,
    swipeImpressions: 0,
    swipeLikes: 0,
    swipePasses: 0,
    activations: 0,
    unlockedCards: 0,
    updatedAt: new Date() as any,
  };

  const daily = dailySnap.docs.map((d) => d.data() as BrandMetricsDaily);

  // Top products por likes (30 d?as)
  const since = new Date();
  since.setUTCDate(since.getUTCDate() - 30);

  const eventsTop = await db.collection("events")
    .where("brandId", "==", brandId)
    .where("type", "==", "SWIPE_LIKE")
    .where("ts", ">=", since)
    .get();

  const likeByProduct = new Map<string, number>();
  for (const e of eventsTop.docs) {
    const pid = e.get("productId") as string | undefined;
    if (!pid) continue;
    likeByProduct.set(pid, (likeByProduct.get(pid) ?? 0) + 1);
  }

  const topProducts = [...likeByProduct.entries()]
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)
    .map(([productId, likes]) => ({ productId, likes }));

  return { ok: true, summary, daily, topProducts };
});

// ===== ADMIN: set custom claim brandId =====
export const adminSetBrandClaim = onCall(async (req) => {
  requireAdmin(req);
  const schema = z.object({ uid: z.string(), brandId: z.string() });
  const { uid, brandId } = schema.parse(req.data);

  const admin = (await import("firebase-admin")).default;
  await admin.auth().setCustomUserClaims(uid, { brandId });

  return { ok: true };
});

"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.adminSetBrandClaim = exports.brandDashboard = exports.brandCreateActivationRule = exports.brandCreateCard = exports.brandCreateStory = exports.brandUpdateProduct = exports.brandCreateProduct = exports.brandUpdateProfile = void 0;
const https_1 = require("firebase-functions/v2/https");
const options_1 = require("firebase-functions/v2/options");
const firestore_1 = require("firebase-admin/firestore");
const zod_1 = require("zod");
const security_1 = require("./security");
(0, options_1.setGlobalOptions)({ region: "us-central1", memory: "256MiB", timeoutSeconds: 30 });
const db = (0, firestore_1.getFirestore)();
const todayKey = () => {
    const d = new Date();
    const yyyy = d.getUTCFullYear();
    const mm = String(d.getUTCMonth() + 1).padStart(2, "0");
    const dd = String(d.getUTCDate()).padStart(2, "0");
    return `${yyyy}${mm}${dd}`;
};
// ===== BRAND PROFILE en brands/{brandId} =====
exports.brandUpdateProfile = (0, https_1.onCall)(async (req) => {
    const brandId = (0, security_1.requireBrand)(req);
    const schema = zod_1.z.object({
        name: zod_1.z.string().min(2),
        logoUrl: zod_1.z.string().url().optional(),
        description: zod_1.z.string().max(2000).optional(),
        links: zod_1.z.array(zod_1.z.string().url()).optional(),
        categories: zod_1.z.array(zod_1.z.string()).max(20).optional(),
    });
    const data = schema.parse(req.data);
    const now = firestore_1.FieldValue.serverTimestamp();
    const profile = {
        ...data,
        updatedAt: now,
    };
    await db.doc(`brands/${brandId}`).set({ createdAt: now, ...profile }, { merge: true });
    return { ok: true };
});
// ===== PRODUCTS =====
exports.brandCreateProduct = (0, https_1.onCall)(async (req) => {
    const brandId = (0, security_1.requireBrand)(req);
    const schema = zod_1.z.object({
        title: zod_1.z.string().min(2),
        sku: zod_1.z.string().optional(),
        price: zod_1.z.number().nonnegative().optional(),
        imageUrl: zod_1.z.string().url().optional(),
        inSwipe: zod_1.z.boolean().optional(),
    });
    const input = schema.parse(req.data);
    const now = firestore_1.FieldValue.serverTimestamp();
    const doc = {
        ...input,
        inSwipe: input.inSwipe ?? false,
        createdAt: now,
        updatedAt: now,
    };
    const ref = await db.collection(`brands/${brandId}/products`).add(doc);
    return { ok: true, id: ref.id };
});
exports.brandUpdateProduct = (0, https_1.onCall)(async (req) => {
    const brandId = (0, security_1.requireBrand)(req);
    const schema = zod_1.z.object({
        productId: zod_1.z.string(),
        title: zod_1.z.string().min(2).optional(),
        sku: zod_1.z.string().optional(),
        price: zod_1.z.number().nonnegative().optional(),
        imageUrl: zod_1.z.string().url().optional(),
        inSwipe: zod_1.z.boolean().optional(),
    });
    const input = schema.parse(req.data);
    const now = firestore_1.FieldValue.serverTimestamp();
    const { productId, ...rest } = input;
    await db.doc(`brands/${brandId}/products/${productId}`).set({ ...rest, updatedAt: now }, { merge: true });
    return { ok: true };
});
// ===== STORIES =====
exports.brandCreateStory = (0, https_1.onCall)(async (req) => {
    const brandId = (0, security_1.requireBrand)(req);
    const schema = zod_1.z.object({
        imageUrl: zod_1.z.string().url(),
        linkUrl: zod_1.z.string().url().optional(),
        expiresAt: zod_1.z.string().datetime().optional(), // ISO8601
    });
    const input = schema.parse(req.data);
    const now = firestore_1.FieldValue.serverTimestamp();
    const expiresAtDate = input.expiresAt ? new Date(input.expiresAt) : undefined;
    const doc = {
        imageUrl: input.imageUrl,
        linkUrl: input.linkUrl,
        expiresAt: expiresAtDate,
        createdAt: now,
        updatedAt: now,
    };
    const ref = await db.collection(`brands/${brandId}/stories`).add(doc);
    return { ok: true, id: ref.id };
});
// ===== CARDS (wallet) =====
exports.brandCreateCard = (0, https_1.onCall)(async (req) => {
    const brandId = (0, security_1.requireBrand)(req);
    const schema = zod_1.z.object({
        title: zod_1.z.string().min(2),
        colorHex: zod_1.z.string().regex(/^#([0-9a-fA-F]{6})$/),
        logoUrl: zod_1.z.string().url().optional(),
        benefitText: zod_1.z.string().optional(),
    });
    const input = schema.parse(req.data);
    const now = firestore_1.FieldValue.serverTimestamp();
    const doc = { ...input, createdAt: now, updatedAt: now };
    const ref = await db.collection(`brands/${brandId}/cards`).add(doc);
    return { ok: true, id: ref.id };
});
// ===== ACTIVATION RULES =====
exports.brandCreateActivationRule = (0, https_1.onCall)(async (req) => {
    const brandId = (0, security_1.requireBrand)(req);
    const schema = zod_1.z.object({
        cardId: zod_1.z.string(),
        type: zod_1.z.enum(["COUNT_ITEMS", "AMOUNT", "SPECIFIC_SKU"]),
        threshold: zod_1.z.number().int().positive().optional(),
        amountCents: zod_1.z.number().int().positive().optional(),
        sku: zod_1.z.string().optional(),
        active: zod_1.z.boolean().default(true),
    });
    const input = schema.parse(req.data);
    const now = firestore_1.FieldValue.serverTimestamp();
    if (input.type === "COUNT_ITEMS" && !input.threshold) {
        throw new https_1.HttpsError("invalid-argument", "COUNT_ITEMS requiere threshold.");
    }
    if (input.type === "AMOUNT" && !input.amountCents) {
        throw new https_1.HttpsError("invalid-argument", "AMOUNT requiere amountCents.");
    }
    if (input.type === "SPECIFIC_SKU" && !input.sku) {
        throw new https_1.HttpsError("invalid-argument", "SPECIFIC_SKU requiere sku.");
    }
    const cardSnap = await db.doc(`brands/${brandId}/cards/${input.cardId}`).get();
    if (!cardSnap.exists) {
        throw new https_1.HttpsError("not-found", "La tarjeta no existe.");
    }
    const rule = {
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
exports.brandDashboard = (0, https_1.onCall)(async (req) => {
    const brandId = (0, security_1.requireBrand)(req);
    const summaryRef = db.doc(`brands/${brandId}/metrics/summary`);
    const dailyRef = db.collection(`brands/${brandId}/metrics/daily`).orderBy("date", "desc").limit(14);
    const [summarySnap, dailySnap] = await Promise.all([summaryRef.get(), dailyRef.get()]);
    const summary = summarySnap.data() ?? {
        profileVisits: 0,
        swipeImpressions: 0,
        swipeLikes: 0,
        swipePasses: 0,
        activations: 0,
        unlockedCards: 0,
        updatedAt: new Date(),
    };
    const daily = dailySnap.docs.map((d) => d.data());
    // Top products por likes (30 d?as)
    const since = new Date();
    since.setUTCDate(since.getUTCDate() - 30);
    const eventsTop = await db.collection("events")
        .where("brandId", "==", brandId)
        .where("type", "==", "SWIPE_LIKE")
        .where("ts", ">=", since)
        .get();
    const likeByProduct = new Map();
    for (const e of eventsTop.docs) {
        const pid = e.get("productId");
        if (!pid)
            continue;
        likeByProduct.set(pid, (likeByProduct.get(pid) ?? 0) + 1);
    }
    const topProducts = [...likeByProduct.entries()]
        .sort((a, b) => b[1] - a[1])
        .slice(0, 10)
        .map(([productId, likes]) => ({ productId, likes }));
    return { ok: true, summary, daily, topProducts };
});
// ===== ADMIN: set custom claim brandId =====
exports.adminSetBrandClaim = (0, https_1.onCall)(async (req) => {
    (0, security_1.requireAdmin)(req);
    const schema = zod_1.z.object({ uid: zod_1.z.string(), brandId: zod_1.z.string() });
    const { uid, brandId } = schema.parse(req.data);
    const admin = (await Promise.resolve().then(() => __importStar(require("firebase-admin")))).default;
    await admin.auth().setCustomUserClaims(uid, { brandId });
    return { ok: true };
});

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onEventCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const options_1 = require("firebase-functions/v2/options");
(0, options_1.setGlobalOptions)({ region: "us-central1", memory: "128MiB", timeoutSeconds: 30 });
const db = (0, firestore_2.getFirestore)();
function todayKey() {
    const d = new Date();
    const yyyy = d.getUTCFullYear();
    const mm = String(d.getUTCMonth() + 1).padStart(2, "0");
    const dd = String(d.getUTCDate()).padStart(2, "0");
    return `${yyyy}${mm}${dd}`;
}
const FIELD_BY_TYPE = {
    "PROFILE_VISIT": "profileVisits",
    "SWIPE_IMPRESSION": "swipeImpressions",
    "SWIPE_LIKE": "swipeLikes",
    "SWIPE_PASS": "swipePasses",
    "ACTIVATION": "activations",
};
exports.onEventCreated = (0, firestore_1.onDocumentCreated)("events/{eventId}", async (event) => {
    const snap = event.data;
    if (!snap)
        return;
    const data = snap.data();
    const brandId = data.brandId;
    const type = data.type;
    if (!brandId || !type)
        return;
    const field = FIELD_BY_TYPE[type];
    if (!field)
        return;
    const day = todayKey();
    const inc = firestore_2.FieldValue.increment(1);
    const now = firestore_2.FieldValue.serverTimestamp();
    // Summary
    await db.doc(`brands/${brandId}/metrics/summary`).set({ [field]: inc, updatedAt: now }, { merge: true });
    // Diario
    await db.doc(`brands/${brandId}/metrics/daily/${day}`).set({ date: day, [field]: inc, updatedAt: now }, { merge: true });
});

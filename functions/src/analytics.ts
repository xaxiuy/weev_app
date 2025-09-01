import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { setGlobalOptions } from "firebase-functions/v2/options";

setGlobalOptions({ region: "us-central1", memory: "128MiB", timeoutSeconds: 30 });
const db = getFirestore();

function todayKey(): string {
  const d = new Date();
  const yyyy = d.getUTCFullYear();
  const mm = String(d.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(d.getUTCDate()).padStart(2, "0");
  return `${yyyy}${mm}${dd}`;
}

const FIELD_BY_TYPE: Record<string, string> = {
  "PROFILE_VISIT": "profileVisits",
  "SWIPE_IMPRESSION": "swipeImpressions",
  "SWIPE_LIKE": "swipeLikes",
  "SWIPE_PASS": "swipePasses",
  "ACTIVATION": "activations",
};

export const onEventCreated = onDocumentCreated("events/{eventId}", async (event) => {
  const snap = event.data;
  if (!snap) return;

  const data = snap.data() as any;
  const brandId: string | undefined = data.brandId;
  const type: string | undefined = data.type;

  if (!brandId || !type) return;

  const field = FIELD_BY_TYPE[type];
  if (!field) return;

  const day = todayKey();
  const inc = FieldValue.increment(1) as any;
  const now = FieldValue.serverTimestamp() as any;

  // Summary
  await db.doc(`brands/${brandId}/metrics/summary`).set(
    { [field]: inc, updatedAt: now },
    { merge: true }
  );

  // Diario
  await db.doc(`brands/${brandId}/metrics/daily/${day}`).set(
    { date: day, [field]: inc, updatedAt: now },
    { merge: true }
  );
});

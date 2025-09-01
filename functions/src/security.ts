import { HttpsError } from "firebase-functions/v2/https";

export function requireAuth(req: any): string {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Debe estar autenticado.");
  return uid;
}

export function requireBrand(req: any): string {
  requireAuth(req);
  const brandId = req.auth?.token?.brandId as string | undefined;
  if (!brandId) {
    throw new HttpsError("permission-denied", "Este usuario no tiene brandId en custom claims.");
  }
  return brandId;
}

export function requireAdmin(req: any): true {
  requireAuth(req);
  const isAdmin = !!req.auth?.token?.admin;
  if (!isAdmin) throw new HttpsError("permission-denied", "Solo admin.");
  return true;
}

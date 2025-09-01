"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = requireAuth;
exports.requireBrand = requireBrand;
exports.requireAdmin = requireAdmin;
const https_1 = require("firebase-functions/v2/https");
function requireAuth(req) {
    const uid = req.auth?.uid;
    if (!uid)
        throw new https_1.HttpsError("unauthenticated", "Debe estar autenticado.");
    return uid;
}
function requireBrand(req) {
    requireAuth(req);
    const brandId = req.auth?.token?.brandId;
    if (!brandId) {
        throw new https_1.HttpsError("permission-denied", "Este usuario no tiene brandId en custom claims.");
    }
    return brandId;
}
function requireAdmin(req) {
    requireAuth(req);
    const isAdmin = !!req.auth?.token?.admin;
    if (!isAdmin)
        throw new https_1.HttpsError("permission-denied", "Solo admin.");
    return true;
}

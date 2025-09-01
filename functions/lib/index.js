"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onEventCreated = exports.adminSetBrandClaim = exports.brandDashboard = exports.brandCreateActivationRule = exports.brandCreateCard = exports.brandCreateStory = exports.brandUpdateProduct = exports.brandCreateProduct = exports.brandUpdateProfile = void 0;
const app_1 = require("firebase-admin/app");
(0, app_1.initializeApp)();
// Re-export de funciones
var brand_1 = require("./brand");
Object.defineProperty(exports, "brandUpdateProfile", { enumerable: true, get: function () { return brand_1.brandUpdateProfile; } });
Object.defineProperty(exports, "brandCreateProduct", { enumerable: true, get: function () { return brand_1.brandCreateProduct; } });
Object.defineProperty(exports, "brandUpdateProduct", { enumerable: true, get: function () { return brand_1.brandUpdateProduct; } });
Object.defineProperty(exports, "brandCreateStory", { enumerable: true, get: function () { return brand_1.brandCreateStory; } });
Object.defineProperty(exports, "brandCreateCard", { enumerable: true, get: function () { return brand_1.brandCreateCard; } });
Object.defineProperty(exports, "brandCreateActivationRule", { enumerable: true, get: function () { return brand_1.brandCreateActivationRule; } });
Object.defineProperty(exports, "brandDashboard", { enumerable: true, get: function () { return brand_1.brandDashboard; } });
Object.defineProperty(exports, "adminSetBrandClaim", { enumerable: true, get: function () { return brand_1.adminSetBrandClaim; } });
var analytics_1 = require("./analytics");
Object.defineProperty(exports, "onEventCreated", { enumerable: true, get: function () { return analytics_1.onEventCreated; } });

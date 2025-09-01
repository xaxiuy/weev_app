import { initializeApp } from "firebase-admin/app";
initializeApp();

// Re-export de funciones
export {
  brandUpdateProfile,
  brandCreateProduct,
  brandUpdateProduct,
  brandCreateStory,
  brandCreateCard,
  brandCreateActivationRule,
  brandDashboard,
  adminSetBrandClaim,
} from "./brand";

export { onEventCreated } from "./analytics";

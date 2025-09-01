export interface BrandProfile {
  name: string;
  logoUrl?: string;
  description?: string;
  links?: string[];
  categories?: string[];
  createdAt?: FirebaseDate;
  updatedAt?: FirebaseDate;
}

export interface Product {
  title: string;
  sku?: string;
  price?: number;
  imageUrl?: string;
  inSwipe: boolean;
  createdAt: FirebaseDate;
  updatedAt: FirebaseDate;
}

export interface Story {
  imageUrl: string;
  linkUrl?: string;
  expiresAt?: FirebaseDate;
  createdAt: FirebaseDate;
  updatedAt: FirebaseDate;
}

export interface Card {
  title: string;
  colorHex: string; // "#RRGGBB"
  logoUrl?: string;
  benefitText?: string;
  createdAt: FirebaseDate;
  updatedAt: FirebaseDate;
}

export type ActivationRuleType = "COUNT_ITEMS" | "AMOUNT" | "SPECIFIC_SKU";

export interface ActivationRule {
  type: ActivationRuleType;
  threshold?: number;  // COUNT_ITEMS
  amountCents?: number; // AMOUNT
  sku?: string;         // SPECIFIC_SKU
  cardId: string;
  active: boolean;
  createdAt: FirebaseDate;
  updatedAt: FirebaseDate;
}

export interface BrandMetricsSummary {
  profileVisits: number;
  swipeImpressions: number;
  swipeLikes: number;
  swipePasses: number;
  activations: number;
  unlockedCards: number;
  updatedAt: FirebaseDate;
}

export interface BrandMetricsDaily {
  date: string; // yyyymmdd
  profileVisits: number;
  swipeImpressions: number;
  swipeLikes: number;
  swipePasses: number;
  activations: number;
  updatedAt?: FirebaseDate;
}

export type FirebaseDate = any; // Timestamp o FieldValue.serverTimestamp

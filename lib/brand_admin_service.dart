import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BrandAdminService {
  BrandAdminService._();
  static final _db = FirebaseFirestore.instance;

  /// Obtiene brandId desde custom claims del usuario actual.
  static Future<String> _brandId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No hay sesión.');
    final token = await user.getIdTokenResult(true); // refresh claims
    final claims = token.claims ?? {};
    final brandId = claims['brandId'];
    if (brandId is! String || brandId.isEmpty) {
      throw Exception('Este usuario no tiene brandId en Custom Claims.');
    }
    return brandId;
  }

  // ===== PERFIL =====
  static Future<void> updateProfile({
    required String name,
    String? logoUrl,
    String? description,
    List<String>? links,
    List<String>? categories,
  }) async {
    final brandId = await _brandId();
    final now = FieldValue.serverTimestamp();
    await _db.doc('brands/$brandId').set({
      'name': name,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (description != null) 'description': description,
      if (links != null) 'links': links,
      if (categories != null) 'categories': categories,
      'updatedAt': now,
      'createdAt': now, // merge evita pisar si ya existía
    }, SetOptions(merge: true));
  }

  // ===== PRODUCTOS =====
  static Future<String> createProduct({
    required String title,
    String? sku,
    double? price,
    String? imageUrl,
    bool inSwipe = false,
  }) async {
    final brandId = await _brandId();
    final now = FieldValue.serverTimestamp();
    final ref = await _db.collection('brands/$brandId/products').add({
      'title': title,
      if (sku != null) 'sku': sku,
      if (price != null) 'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'inSwipe': inSwipe,
      'createdAt': now,
      'updatedAt': now,
    });
    return ref.id;
  }

  static Future<void> updateProduct({
    required String productId,
    String? title,
    String? sku,
    double? price,
    String? imageUrl,
    bool? inSwipe,
  }) async {
    final brandId = await _brandId();
    final now = FieldValue.serverTimestamp();
    await _db.doc('brands/$brandId/products/$productId').set({
      if (title != null) 'title': title,
      if (sku != null) 'sku': sku,
      if (price != null) 'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (inSwipe != null) 'inSwipe': inSwipe,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> productsStream() async* {
    final brandId = await _brandId();
    yield* _db.collection('brands/$brandId/products').orderBy('createdAt', descending: true).snapshots();
  }

  // ===== STORIES =====
  static Future<String> createStory({
    required String imageUrl,
    String? linkUrl,
    DateTime? expiresAt, // null = no expira
  }) async {
    final brandId = await _brandId();
    final now = FieldValue.serverTimestamp();
    final ref = await _db.collection('brands/$brandId/stories').add({
      'imageUrl': imageUrl,
      if (linkUrl != null) 'linkUrl': linkUrl,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': now,
      'updatedAt': now,
    });
    return ref.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> storiesStream() async* {
    final brandId = await _brandId();
    yield* _db.collection('brands/$brandId/stories').orderBy('createdAt', descending: true).snapshots();
  }

  // ===== TARJETAS (wallet) =====
  static Future<String> createCard({
    required String title,
    required String colorHex, // "#RRGGBB"
    String? logoUrl,
    String? benefitText,
  }) async {
    final brandId = await _brandId();
    final now = FieldValue.serverTimestamp();
    final ref = await _db.collection('brands/$brandId/cards').add({
      'title': title,
      'colorHex': colorHex,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (benefitText != null) 'benefitText': benefitText,
      'createdAt': now,
      'updatedAt': now,
    });
    return ref.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> cardsStream() async* {
    final brandId = await _brandId();
    yield* _db.collection('brands/$brandId/cards').orderBy('createdAt', descending: true).snapshots();
  }

  // ===== REGLAS DE ACTIVACIÓN =====
  /// type: "COUNT_ITEMS" | "AMOUNT" | "SPECIFIC_SKU"
  static Future<String> createActivationRule({
    required String cardId,
    required String type,
    int? threshold,
    int? amountCents,
    String? sku,
    bool active = true,
  }) async {
    final brandId = await _brandId();

    if (type == 'COUNT_ITEMS' && (threshold == null || threshold <= 0)) {
      throw Exception('COUNT_ITEMS requiere threshold > 0');
    }
    if (type == 'AMOUNT' && (amountCents == null || amountCents <= 0)) {
      throw Exception('AMOUNT requiere amountCents > 0');
    }
    if (type == 'SPECIFIC_SKU' && (sku == null || sku.isEmpty)) {
      throw Exception('SPECIFIC_SKU requiere sku');
    }

    // Verificar tarjeta
    final cardSnap = await _db.doc('brands/$brandId/cards/$cardId').get();
    if (!cardSnap.exists) throw Exception('La tarjeta no existe.');

    final now = FieldValue.serverTimestamp();
    final ref = await _db.collection('brands/$brandId/activationRules').add({
      'cardId': cardId,
      'type': type,
      if (threshold != null) 'threshold': threshold,
      if (amountCents != null) 'amountCents': amountCents,
      if (sku != null) 'sku': sku,
      'active': active,
      'createdAt': now,
      'updatedAt': now,
    });
    return ref.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> rulesStream() async* {
    final brandId = await _brandId();
    yield* _db.collection('brands/$brandId/activationRules').orderBy('createdAt', descending: true).snapshots();
  }

  // ===== DASHBOARD (lectura simple sin Functions) =====
  /// Resumen contando eventos (últimos 30 días)
  static Future<Map<String, int>> summaryLast30d() async {
    final brandId = await _brandId();
    final since = DateTime.now().toUtc().subtract(const Duration(days: 30));
    final q = await _db
        .collection('events')
        .where('brandId', isEqualTo: brandId)
        .where('ts', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .get();

    int pv = 0, imp = 0, like = 0, pass = 0, act = 0;
    for (final d in q.docs) {
      switch ((d.data()['type'] ?? '') as String) {
        case 'PROFILE_VISIT': pv++; break;
        case 'SWIPE_IMPRESSION': imp++; break;
        case 'SWIPE_LIKE': like++; break;
        case 'SWIPE_PASS': pass++; break;
        case 'ACTIVATION': act++; break;
      }
    }
    return {
      'profileVisits': pv,
      'swipeImpressions': imp,
      'swipeLikes': like,
      'swipePasses': pass,
      'activations': act,
    };
  }

  /// Serie diaria simple (N días) – hace N consultas, mantener N pequeño (p.ej. 14)
  static Future<List<Map<String, dynamic>>> dailySeries({int days = 14}) async {
    final brandId = await _brandId();
    final now = DateTime.now().toUtc();

    final out = <Map<String, dynamic>>[];
    for (int i = 0; i < days; i++) {
      final dayEnd = DateTime.utc(now.year, now.month, now.day).subtract(Duration(days: i));
      final dayStart = dayEnd.subtract(const Duration(days: 1));

      final q = await _db
          .collection('events')
          .where('brandId', isEqualTo: brandId)
          .where('ts', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
          .where('ts', isLessThan: Timestamp.fromDate(dayEnd))
          .get();

      int pv = 0, imp = 0, like = 0, pass = 0, act = 0;
      for (final d in q.docs) {
        switch ((d.data()['type'] ?? '') as String) {
          case 'PROFILE_VISIT': pv++; break;
          case 'SWIPE_IMPRESSION': imp++; break;
          case 'SWIPE_LIKE': like++; break;
          case 'SWIPE_PASS': pass++; break;
          case 'ACTIVATION': act++; break;
        }
      }
      out.add({
        'date': '${dayStart.year}${dayStart.month.toString().padLeft(2, '0')}${dayStart.day.toString().padLeft(2, '0')}',
        'profileVisits': pv,
        'swipeImpressions': imp,
        'swipeLikes': like,
        'swipePasses': pass,
        'activations': act,
      });
    }
    return out.reversed.toList();
  }

  /// Top productos por likes (30 días)
  static Future<List<Map<String, dynamic>>> topProductsLast30d({int limit = 10}) async {
    final brandId = await _brandId();
    final since = DateTime.now().toUtc().subtract(const Duration(days: 30));
    final q = await _db
        .collection('events')
        .where('brandId', isEqualTo: brandId)
        .where('type', isEqualTo: 'SWIPE_LIKE')
        .where('ts', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .get();

    final map = <String, int>{};
    for (final d in q.docs) {
      final pid = d.data()['productId'] as String?;
      if (pid == null) continue;
      map.update(pid, (v) => v + 1, ifAbsent: () => 1);
    }

    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).map((e) => {'productId': e.key, 'likes': e.value}).toList();
  }
}

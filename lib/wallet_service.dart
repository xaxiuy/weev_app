import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  WalletService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Doc: users/{uid}/wallet/state
  static DocumentReference<Map<String, dynamic>> _stateDoc(String uid) {
    return _db.collection('users').doc(uid).collection('wallet').doc('state');
  }

  /// Subcolección de usos: users/{uid}/wallet/state/uses/{autoId}
  static CollectionReference<Map<String, dynamic>> _usesCol(String uid) {
    return _stateDoc(uid).collection('uses');
  }

  /// Stream del ID de la tarjeta activa (o null si no hay).
  static Stream<String?> activeCardIdStream(String uid) {
    return _stateDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      return data == null ? null : (data['activeCardId'] as String?);
    });
  }

  /// Setea la tarjeta activa. Si [cardId] es null, desactiva.
  static Future<void> setActiveCardId(String uid, String? cardId) {
    return _stateDoc(uid).set(
      {
        'activeCardId': cardId,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Registra un uso (cuando el usuario muestra el código).
  static Future<void> logUse(String uid, String cardId, {String? merchant}) {
    return _usesCol(uid).add({
      'cardId': cardId,
      'merchant': merchant, // opcional
      'at': FieldValue.serverTimestamp(),
    });
  }

  /// Últimos N usos (para mostrar historial).
  static Stream<List<Map<String, dynamic>>> lastUsesStream(String uid, {int limit = 20}) {
    return _usesCol(uid)
        .orderBy('at', descending: true)
        .limit(limit)
        .snapshots()
        .map((q) => q.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}

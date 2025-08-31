import 'package:cloud_firestore/cloud_firestore.dart';

class WalletState {
  final String? activeCardId;
  final Set<String> unlocked;

  const WalletState({
    required this.activeCardId,
    required this.unlocked,
  });

  factory WalletState.fromMap(Map<String, dynamic>? data) {
    final unlockedList = (data?['unlocked'] as List?)?.cast<String>() ?? <String>[];
    return WalletState(
      activeCardId: data?['activeCardId'] as String?,
      unlocked: unlockedList.toSet(),
    );
  }

  Map<String, dynamic> toMap() => {
        'activeCardId': activeCardId,
        'unlocked': unlocked.toList(),
      };
}

class WalletService {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _stateDoc(String uid) =>
      _db.collection('users').doc(uid).collection('wallet').doc('state');

  /// Stream en vivo del estado de la wallet del usuario
  static Stream<WalletState> walletStateStream(String uid) {
    return _stateDoc(uid).snapshots().map(
      (snap) => WalletState.fromMap(snap.data()),
    );
  }

  /// Establece la tarjeta activa o la desactiva (null)
  static Future<void> setActiveCardId(String uid, String? cardId) async {
    await _stateDoc(uid).set({'activeCardId': cardId}, SetOptions(merge: true));
  }

  /// Registra un uso (opcional, para historial/analytics)
  static Future<void> registerUse(String uid, String cardId) async {
    final usesCol = _db
        .collection('users')
        .doc(uid)
        .collection('wallet')
        .doc('uses')
        .collection('items');
    await usesCol.add({
      'cardId': cardId,
      'ts': FieldValue.serverTimestamp(),
    });
  }

  /// Canjea un código y desbloquea tarjetas (transacción)
  static Future<WalletRedeemResult> redeemActivationCode(String uid, String code) async {
    final clean = code.trim();
    if (clean.isEmpty) {
      return WalletRedeemResult(false, message: 'Código vacío');
    }

    final codeRef = _db.collection('activation_codes').doc(clean);
    final snap = await codeRef.get();
    if (!snap.exists) {
      return WalletRedeemResult(false, message: 'Código inválido');
    }

    return await _db.runTransaction<WalletRedeemResult>((tx) async {
      final fresh = await tx.get(codeRef);
      if (!fresh.exists) {
        return WalletRedeemResult(false, message: 'Código inválido');
      }
      final data = fresh.data() as Map<String, dynamic>;
      final usedBy = data['usedBy'];
      final List<String> cardIds = (data['cardIds'] as List?)?.cast<String>() ?? <String>[];

      if (usedBy != null && usedBy != uid) {
        return WalletRedeemResult(false, message: 'Este código ya fue usado');
      }
      if (cardIds.isEmpty) {
        return WalletRedeemResult(false, message: 'El código no tiene tarjetas asociadas');
      }

      // Marcar código como usado por este usuario
      tx.set(codeRef, {
        'usedBy': uid,
        'usedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Agregar tarjetas a "unlocked"
      final stateRef = _stateDoc(uid);
      final stateSnap = await tx.get(stateRef);
      final current = (stateSnap.data()?['unlocked'] as List?)?.cast<String>() ?? <String>[];
      final updated = {...current, ...cardIds}.toList();

      tx.set(stateRef, {'unlocked': updated}, SetOptions(merge: true));

      return WalletRedeemResult(true,
          message: 'Código canjeado', unlockedCardIds: cardIds);
    });
  }
}

class WalletRedeemResult {
  final bool ok;
  final String message;
  final List<String> unlockedCardIds;

  WalletRedeemResult(this.ok, {required this.message, this.unlockedCardIds = const []});
}

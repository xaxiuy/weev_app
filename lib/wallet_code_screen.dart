import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // para Timestamp en historial
import 'package:qr_flutter/qr_flutter.dart';
import 'wallet_service.dart';

class WalletCodeScreen extends StatelessWidget {
  const WalletCodeScreen({
    super.key,
    required this.cardId,
    required this.brand,
    required this.color,
    required this.logoUrl,
  });

  final String cardId;
  final String brand;
  final Color color;
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Código')),
        body: const Center(child: Text('Iniciá sesión para ver el código')),
      );
    }

    final uid = user.uid;
    final payload = 'weev://wallet?uid=$uid&card=$cardId&ts=${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      appBar: AppBar(title: const Text('Código de la tarjeta')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _CardPreview(brand: brand, color: color, logoUrl: logoUrl),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  Text('Mostrá este código en caja',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      border: Border.all(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: QrImageView(
                        data: payload,
                        version: QrVersions.auto,
                        size: 220,
                        gapless: true,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    payload,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Marcar uso'),
                    onPressed: () async {
                      await WalletService.logUse(uid, cardId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Uso registrado')));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LastUsesCard(uid: uid),
        ],
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({required this.brand, required this.color, required this.logoUrl});
  final String brand;
  final Color color;
  final String logoUrl;

  Color _darken(Color c, [double amount = 0.18]) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final bg = color;
    final bg2 = _darken(bg);
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [bg, bg2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: NetworkImage(logoUrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  brand,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Activa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastUsesCard extends StatelessWidget {
  const _LastUsesCard({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: WalletService.lastUsesStream(uid),
      builder: (context, snap) {
        final data = snap.data ?? const [];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historial de usos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                if (data.isEmpty)
                  Text('Sin registros aún', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.outline))
                else
                  ...data.map((e) {
                    final cardId = (e['cardId'] ?? '') as String;
                    final at = (e['at'] as Timestamp?);
                    final when = at?.toDate().toLocal().toString().substring(0, 16) ?? '—';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Tarjeta: $cardId'),
                      subtitle: Text('Fecha: $when'),
                      leading: const Icon(Icons.history),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

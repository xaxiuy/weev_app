import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = FirebaseAuth.instance.currentUser!;
    final payload = 'weev:${user.uid}:$cardId:${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      appBar: AppBar(title: Text('Código · $brand')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  brand,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: QrImageView(
              data: payload,
              version: QrVersions.auto,
              size: 240,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () async {
              await WalletService.registerUse(user.uid, cardId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uso registrado')));
              }
            },
            child: const Text('Registrar uso'),
          ),
        ],
      ),
    );
  }
}

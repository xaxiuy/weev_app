import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('wallet').doc('acme')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: doc,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Sin datos aún'));
          }
          final d = snap.data!.data()!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puntos: ${d['points'] ?? 0}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Tier: ${d['tier'] ?? 'bronze'}'),
                const SizedBox(height: 8),
                Text('Vence: ${d['tierExpiryAt'] != null ? (d['tierExpiryAt'].toDate()).toString() : '-'}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

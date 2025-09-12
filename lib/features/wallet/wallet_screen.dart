import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar:  AppBar(title: Text('Wallet')),
      body: Center(child: Text('Puntos, tier, tierExpiryAt')),
    );
  }
}

import 'package:flutter/material.dart';

class ActivateScreen extends StatelessWidget {
  const ActivateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar:  AppBar(title: Text('Activate')),
      body: Center(child: Text('Input/QR → callable activateProduct')),
    );
  }
}

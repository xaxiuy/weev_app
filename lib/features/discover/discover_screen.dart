import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar:  AppBar(title: Text('Discover')),
      body: Center(child: Text('Swipe 4:5 - Próximo paso')),
    );
  }
}

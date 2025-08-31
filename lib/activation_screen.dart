import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wallet_service.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _redeem() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresá un código')),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debés iniciar sesión')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await WalletService.redeemActivationCode(user.uid, code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
      if (res.ok) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al canjear: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activar artículo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Ingresá el código único del producto para desbloquear beneficios.'),
          const SizedBox(height: 12),
          TextField(
            controller: _codeCtrl,
            decoration: const InputDecoration(
              labelText: 'Código de activación',
              hintText: 'EJ: OMODA-123-ABC',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _redeem,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Canjear código'),
          ),
        ],
      ),
    );
  }
}

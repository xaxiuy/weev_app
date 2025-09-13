import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class ActivateScreen extends StatefulWidget {
  const ActivateScreen({super.key});
  @override
  State<ActivateScreen> createState() => _ActivateScreenState();
}

class _ActivateScreenState extends State<ActivateScreen> {
  final controller = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> _activate() async {
    setState(() { loading = true; error = null; });
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('activateProduct');
      final res = await callable.call({'code': controller.text.trim()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Activado! +${res.data['points']} pts')),
      );
      controller.clear();
    } on FirebaseFunctionsException catch (e) {
      setState(() => error = e.message ?? e.code);
    } catch (e) {
      setState(() => error = 'Error inesperado: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Código'),
            ),
            const SizedBox(height: 12),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: loading ? null : _activate,
              child: Text(loading ? '...' : 'Activar'),
            ),
          ],
        ),
      ),
    );
  }
}

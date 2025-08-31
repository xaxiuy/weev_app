import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Podés dejar este import; ya no lo usamos en web, pero servirá después en Android/iOS
import 'package:google_sign_in/google_sign_in.dart';

class WeevLoginScreen extends StatefulWidget {
  const WeevLoginScreen({super.key});

  @override
  State<WeevLoginScreen> createState() => _WeevLoginScreenState();
}

class _WeevLoginScreenState extends State<WeevLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _showPwd = false;
  bool _remember = true;
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    setState(() { _loading = true; _message = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? 'Error al iniciar sesión');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registerWithEmail() async {
    setState(() { _loading = true; _message = null; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
      );
      setState(() => _message = 'Cuenta creada. Sesión iniciada ✔');
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? 'No se pudo crear la cuenta');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // 👉 Versión solo Web para que compile en Chrome
  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _message = null; });
    try {
      final provider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(provider);
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? 'Error con Google Sign-In');
    } catch (_) {
      setState(() => _message = 'Error inesperado con Google');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const weevBlue = Color(0xFF1877F2);
    const bg = Color(0xFFF5F7F9);
    final border = Theme.of(context).colorScheme.outlineVariant;

    return Scaffold(
      backgroundColor: bg,
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 920;
          return Row(
            children: [
              // LEFT: Form
              Expanded(
                flex: 5,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 36, width: 36,
                                  decoration: BoxDecoration(
                                    color: weevBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('W',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('Weev',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Iniciá sesión',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Activá productos, sumá recompensas y gestioná tu wallet de marcas.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email
                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Password
                            TextField(
                              controller: _pwdCtrl,
                              obscureText: !_showPwd,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _showPwd = !_showPwd),
                                  icon: Icon(_showPwd ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Recordarme + Olvidé
                            Row(
                              children: [
                                Checkbox(
                                  value: _remember,
                                  onChanged: (v) => setState(() => _remember = v ?? true),
                                ),
                                const Text('Recordarme'),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('¿Olvidaste tu contraseña?'),
                                )
                              ],
                            ),

                            if (_message != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: border),
                                ),
                                child: Text(_message!, style: const TextStyle(fontSize: 13)),
                              ),
                            ],

                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _loading ? null : _signInWithEmail,
                                style: FilledButton.styleFrom(
                                  backgroundColor: weevBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 18, width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Iniciar sesión'),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // separador
                            Row(
                              children: [
                                Expanded(child: Divider(color: border)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('o', style: TextStyle(color: Colors.black54)),
                                ),
                                Expanded(child: Divider(color: border)),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Socials
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _loading ? null : _signInWithGoogle,
                                    icon: const Icon(Icons.g_mobiledata_outlined),
                                    label: const Text('Continuar con Google'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('¿No tenés cuenta?'),
                                TextButton(
                                  onPressed: _loading ? null : _registerWithEmail,
                                  child: const Text('Crear cuenta'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Al continuar aceptás los Términos y la Política de Privacidad.',
                              style: TextStyle(fontSize: 11, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // RIGHT: Panel marca (solo en anchos grandes)
              if (wide)
                Expanded(
                  flex: 5,
                  child: Container(
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1877F2), Color(0xFF0F5BD7)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: DefaultTextStyle(
                        style: const TextStyle(color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SizedBox(height: 20),
                            Text(
                              'Weev',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              'Activá productos.\nGaná recompensas.\nConectate con tus marcas favoritas.',
                              style: TextStyle(fontSize: 34, height: 1.15, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'El nuevo estándar para experiencias post-compra: wallet de beneficios, feed de activaciones y stories de novedades.',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            SizedBox(height: 20),
                            Text('* Vista previa UI: no envía datos reales.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

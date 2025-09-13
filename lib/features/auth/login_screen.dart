import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../theme/weev_colors.dart';
import '../../shared/theme/weev_typography.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> _signInEmail() async {
    setState(() { loading = true; error = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _signUpEmail() async {
    setState(() { loading = true; error = null; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (emailCtrl.text.isEmpty) {
      setState(() => error = "Ingresa tu email primero");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailCtrl.text.trim(),
      );
      setState(() => error = "Correo de recuperación enviado");
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    }
  }

  Future<void> _signInGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo editable
          Image.asset('assets/images/login_bg.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo editable
                  Image.asset('assets/images/logo.png', height: 80),
                  const SizedBox(height: 16),
                  Text("Weev", style: WeevTypography.h1.copyWith(color: Colors.white)),

                  const SizedBox(height: 32),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Contraseña",
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),

                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: loading ? null : _signInEmail,
                    child: Text(loading ? "..." : "Ingresar"),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: loading ? null : _signUpEmail,
                    child: const Text("Crear cuenta"),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _forgotPassword,
                    child: const Text("¿Olvidaste tu contraseña?"),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: loading ? null : _signInGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text("Ingresar con Google"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

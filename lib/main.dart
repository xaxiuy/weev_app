import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'weev_login_screen.dart';
import 'home_screen.dart';
import 'brand_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WeevApp());
}

class WeevApp extends StatelessWidget {
  const WeevApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1877F2),
      scaffoldBackgroundColor: const Color(0xFFF5F7F9),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        isDense: true,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weev',
      theme: theme,
      // Soporta rutas web como:
      //  - #/admin/brand/omoda
      //  - #/brand-admin?brandId=omoda
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        final uri = Uri.parse(name);

        // Ruta directa al Brand Admin via path: #/admin/brand/:brandId
        if (uri.pathSegments.length >= 3 &&
            uri.pathSegments[0] == 'admin' &&
            uri.pathSegments[1] == 'brand') {
          final brandId = uri.pathSegments[2];
          return MaterialPageRoute(
            builder: (_) => BrandAdminGate(brandId: brandId),
            settings: settings,
          );
        }

        // Ruta alternativa con query param: #/brand-admin?brandId=omoda
        if (uri.path == '/brand-admin') {
          final brandId = uri.queryParameters['brandId'];
          if (brandId != null && brandId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => BrandAdminGate(brandId: brandId),
              settings: settings,
            );
          }
          return MaterialPageRoute(
            builder: (_) => const _RouteError(
              title: 'Falta brandId',
              message: 'Usá #/brand-admin?brandId=omoda',
            ),
            settings: settings,
          );
        }

        // Raíz normal de la app (home con tabs) detrás de login
        if (uri.path == '/' || uri.path.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const _AuthGate(child: HomeScreen()),
            settings: settings,
          );
        }

        // 404 simple
        return MaterialPageRoute(
          builder: (_) => _RouteError(
            title: 'Ruta no encontrada',
            message: 'No existe la ruta: ${uri.toString()}',
          ),
          settings: settings,
        );
      },
    );
  }
}

/// Puerta general: si no hay sesión, muestra login; si hay, muestra [child]
class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snap.hasData ? child : const WeevLoginScreen();
      },
    );
  }
}

/// Puerta específica para Brand Admin:
/// - Requiere sesión
/// - Verifica doc brand_admins/{uid} y que brandId coincida
class BrandAdminGate extends StatelessWidget {
  const BrandAdminGate({super.key, required this.brandId});
  final String brandId;

  @override
  Widget build(BuildContext context) {
    return _AuthGate(
      child: _AdminCheck(brandId: brandId),
    );
  }
}

class _AdminCheck extends StatelessWidget {
  const _AdminCheck({required this.brandId});
  final String brandId;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = FirebaseFirestore.instance.collection('brand_admins').doc(user.uid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: doc.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const _RouteError(
            title: 'Sin permisos',
            message: 'Tu usuario no está configurado como admin de ninguna marca.',
          );
        }
        final data = snap.data!.data() ?? {};
        final allowedBrand = (data['brandId'] as String?)?.toLowerCase();
        if (allowedBrand != brandId.toLowerCase()) {
          return _RouteError(
            title: 'No autorizado',
            message: 'Tu usuario no es admin de "$brandId". Marca asignada: "${allowedBrand ?? '-'}".',
          );
        }
        return BrandAdminScreen(brandId: brandId);
      },
    );
  }
}

/// Pantalla de error de rutas/permisos
class _RouteError extends StatelessWidget {
  const _RouteError({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const _AuthGate(child: HomeScreen())),
                    (route) => false,
                  );
                },
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

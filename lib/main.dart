import 'package:flutter/material.dart';

void main() => runApp(const WeevApp());

class WeevApp extends StatelessWidget {
  const WeevApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1877F2), // WEEV.green (azul del mock)
      scaffoldBackgroundColor: const Color(0xFFF5F7F9), // WEEV.bg
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        isDense: true,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(color: Color(0xFF0b0f10)),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weev',
      theme: theme,
      home: const WeevLoginScreen(),
    );
  }
}

/// Tokens básicos de marca
class WeevTokens {
  static const Color green = Color(0xFF1877F2); // “verde” del mock = azul FB
  static const Color bg = Color(0xFFF5F7F9);
  static const Color text = Color(0xFF0b0f10);
  static const Color muted = Color(0xFF6b7280);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
}

class WeevLoginScreen extends StatefulWidget {
  const WeevLoginScreen({super.key});

  @override
  State<WeevLoginScreen> createState() => _WeevLoginScreenState();
}

class _WeevLoginScreenState extends State<WeevLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _showPwd = false;
  bool _remember = true;
  bool _loading = false;
  String _message = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    final email = _emailCtrl.text.trim();
    final pwd = _pwdCtrl.text;
    if (!email.contains('@')) return 'Ingresá un email válido';
    if (pwd.isEmpty) return 'Ingresá tu contraseña';
    return null;
  }

  Future<void> _handleSubmit() async {
    final err = _validate();
    if (err != null) {
      setState(() => _message = err);
      return;
    }
    setState(() {
      _message = '';
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 900)); // simula backend
    if (!mounted) return;
    setState(() {
      _loading = false;
      _message = 'Demo: sesión iniciada ✔';
    });
    // TODO: navegar a Home real
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inicio de sesión simulado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final wide = c.maxWidth >= 960; // 2 columnas en desktop
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                // LEFT: formulario
                Expanded(
                  flex: wide ? 1 : 0,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 64 : 24,
                        vertical: wide ? 48 : 24,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo + marca
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: WeevTokens.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'W',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Weev',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),

                            const SizedBox(height: 24),
                            Text('Iniciá sesión',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium),
                            const SizedBox(height: 6),
                            const Text(
                              'Activá productos, sumá recompensas y gestioná tu wallet de marcas.',
                              style: TextStyle(
                                color: WeevTokens.muted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Card principal del form
                            Container(
                              decoration: BoxDecoration(
                                color: WeevTokens.card.withOpacity(.95),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: WeevTokens.border),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x11000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          // Email
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text('Email',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall),
                                          ),
                                          const SizedBox(height: 6),
                                          _IconField(
                                            controller: _emailCtrl,
                                            hint: 'tu@email.com',
                                            icon: Icons.mail_outline,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                          const SizedBox(height: 14),

                                          // Password
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text('Contraseña',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall),
                                          ),
                                          const SizedBox(height: 6),
                                          _IconField(
                                            controller: _pwdCtrl,
                                            hint: '••••••••',
                                            icon: Icons.lock_outline,
                                            obscureText: !_showPwd,
                                            trailing: IconButton(
                                              onPressed: () => setState(() {
                                                _showPwd = !_showPwd;
                                              }),
                                              icon: Icon(_showPwd
                                                  ? Icons.visibility_off
                                                  : Icons.visibility),
                                            ),
                                          ),

                                          const SizedBox(height: 12),
                                          // Remember + Forgot
                                          Row(
                                            children: [
                                              Checkbox(
                                                value: _remember,
                                                onChanged: (v) => setState(
                                                    () => _remember = v ?? true),
                                              ),
                                              const Text(
                                                'Recordarme',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                              const Spacer(),
                                              TextButton(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              'Recupero simulado')));
                                                },
                                                child: Text(
                                                  '¿Olvidaste tu contraseña?',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: WeevTokens.green,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),

                                          if (_message.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: WeevTokens.border),
                                                color:
                                                    const Color(0xFFEFF6FF),
                                              ),
                                              child: Text(
                                                _message,
                                                style: const TextStyle(
                                                    fontSize: 13),
                                              ),
                                            ),
                                          ],

                                          const SizedBox(height: 12),
                                          // Submit
                                          SizedBox(
                                            width: double.infinity,
                                            child: FilledButton(
                                              onPressed:
                                                  _loading ? null : _handleSubmit,
                                              style: FilledButton.styleFrom(
                                                backgroundColor:
                                                    WeevTokens.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: _loading
                                                  ? const SizedBox(
                                                      height: 18,
                                                      width: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Text('Iniciar sesión'),
                                            ),
                                          ),

                                          const SizedBox(height: 16),
                                          // Divider “o”
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Divider(
                                                color: WeevTokens.border,
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                color: WeevTokens.card,
                                                child: const Text(
                                                  'o',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                              )
                                            ],
                                          ),

                                          const SizedBox(height: 12),
                                          // Social buttons
                                          LayoutBuilder(
                                            builder: (_, cs) {
                                              final twoCols =
                                                  cs.maxWidth >= 440;
                                              return Wrap(
                                                spacing: 12,
                                                runSpacing: 12,
                                                children: [
                                                  _SocialButton(
                                                    label:
                                                        'Continuar con Google',
                                                    svg: _googleSvg,
                                                    onTap: () {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Google Sign-In simulado')));
                                                    },
                                                  ),
                                                  _SocialButton(
                                                    label:
                                                        'Continuar con Facebook',
                                                    svg: _facebookSvg,
                                                    onTap: () {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Facebook Sign-In simulado')));
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Footer card
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 14),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                              color: WeevTokens.border),
                                        ),
                                        borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text('¿No tenés cuenta? ',
                                              style: TextStyle(fontSize: 13)),
                                          TextButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Crear cuenta (simulado)')));
                                            },
                                            child: Text(
                                              'Crear cuenta',
                                              style: TextStyle(
                                                color: WeevTokens.green,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            const Text(
                              'Al continuar aceptás los Términos y la Política de Privacidad.',
                              style: TextStyle(
                                  color: Color(0xFF6b7280), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // RIGHT: panel de marca (solo desktop)
                if (wide)
                  Expanded(
                    flex: 1,
                    child: _BrandPanel(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Campo con ícono a la izquierda y trailing opcional
class _IconField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? trailing;

  const _IconField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 44),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: WeevTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: WeevTokens.green,
                width: 2,
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 0,
          bottom: 0,
          child: Icon(icon, size: 18, color: Colors.grey.shade500),
        ),
        if (trailing != null)
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: trailing!,
          ),
      ],
    );
  }
}

/// Panel derecho con gradiente + “pitch”
class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Degradé
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1877F2),
                Color(0xFF0F5BD7),
              ],
            ),
          ),
        ),
        // Imagen overlay (Unsplash) — estilo “grain”
        Positioned.fill(
          child: Opacity(
            opacity: 0.10,
            child: Image.network(
              'https://images.unsplash.com/photo-1512295767273-ac109ac3acfa?q=80&w=2000&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Contenido
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text('W',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    const Text('Weev',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 36),
                  const Text(
                    'Activá productos.\nGaná recompensas.\nConectate con tus marcas favoritas.',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'El nuevo estándar para experiencias post-compra: wallet de beneficios, feed de activaciones y stories de novedades.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  _PitchItem(
                    icon: Icons.verified_user_outlined,
                    title: 'Activaciones verificadas',
                    subtitle:
                        'Escaneá, registrá y asegurá tus productos con garantía y soporte.',
                  ),
                  _PitchItem(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Recompensas y puntos',
                    subtitle:
                        'Canjeá beneficios por acciones dentro del ecosistema Weev.',
                  ),
                  _PitchItem(
                    icon: Icons.smartphone_outlined,
                    title: 'Stories y novedades',
                    subtitle:
                        'Descubrí lanzamientos y noticias de tus marcas preferidas.',
                  ),
                  const Spacer(),
                  const Text(
                    '* Vista previa UI: no envía datos reales.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PitchItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _PitchItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón social con ícono SVG in-code simplificado (sin paquetes)
class _SocialButton extends StatelessWidget {
  final String label;
  final String svg;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.svg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: WeevTokens.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ícono SVG simple (pintado con paths)
            SizedBox(
              height: 18,
              width: 18,
              child: CustomPaint(
                painter: _SvgPainter(svg),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinta un par de SVGs simples (Google / Facebook) sin dependencias
class _SvgPainter extends CustomPainter {
  final String data;
  _SvgPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    // Para mantenerlo liviano: 2 íconos predefinidos con paths aproximados.
    final p = Paint()..style = PaintingStyle.fill;

    if (data == _googleSvg) {
      // cuatro colores circulares básicos (no exacto al logo oficial)
      final r = Rect.fromLTWH(0, 0, size.width, size.height);
      // Amarillo
      p.color = const Color(0xFFFFC107);
      canvas.drawArc(r, -0.2, 1.0, true, p);
      // Rojo
      p.color = const Color(0xFFFF3D00);
      canvas.drawArc(r, 1.0, 1.0, true, p);
      // Verde
      p.color = const Color(0xFF4CAF50);
      canvas.drawArc(r, 2.0, 1.0, true, p);
      // Azul
      p.color = const Color(0xFF1976D2);
      canvas.drawArc(r, 3.0, 1.0, true, p);
    } else if (data == _facebookSvg) {
      p.color = const Color(0xFF1877F2);
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(3));
      canvas.drawRRect(r, p);
      // “f”
      final tp = TextPainter(
        text: const TextSpan(
          text: 'f',
          style: TextStyle(
              fontSize: 14, color: Colors.white, fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width * .33, size.height * .02));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const String _googleSvg = 'G';
const String _facebookSvg = 'F';

import 'package:flutter/material.dart';
import 'profile_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  final Profile profile;
  const PersonalInfoScreen({super.key, required this.profile});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _ig;
  late final TextEditingController _pin;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.profile.contactEmail);
    _phone = TextEditingController(text: widget.profile.phone);
    _ig = TextEditingController(text: widget.profile.instagram);
    _pin = TextEditingController(text: widget.profile.pinterest);
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _ig.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    widget.profile
      ..contactEmail = _email.text.trim()
      ..phone = _phone.text.trim()
      ..instagram = _ig.text.trim()
      ..pinterest = _pin.text.trim();
    await widget.profile.save();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información personal'),
        actions: [TextButton(onPressed: _save, child: const Text('Guardar'))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Box(border: border, child: TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          )),
          const SizedBox(height: 12),
          _Box(border: border, child: TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Teléfono'),
          )),
          const SizedBox(height: 12),
          _Box(border: border, child: TextField(
            controller: _ig,
            decoration: const InputDecoration(labelText: 'Instagram (usuario o link)'),
          )),
          const SizedBox(height: 12),
          _Box(border: border, child: TextField(
            controller: _pin,
            decoration: const InputDecoration(labelText: 'Pinterest (usuario o link)'),
          )),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final Color border;
  final Widget child;
  const _Box({required this.border, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
}

import 'package:flutter/material.dart';
import 'profile_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _linkInputCtrl = TextEditingController();
  final _interestInputCtrl = TextEditingController();

  Profile _profile = Profile();
  bool _loading = true;

  final _interestSuggestions = <String>[
    'Nike','Adidas','Apple','Samsung','Coca-Cola','Pepsi',
    'Netflix','Spotify','Nvidia','Sony','Weev',
  ];

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() {
    _nameCtrl.dispose(); _usernameCtrl.dispose(); _bioCtrl.dispose();
    _linkInputCtrl.dispose(); _interestInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await ProfileService.load();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _nameCtrl.text = p.name;
      _usernameCtrl.text = p.username;
      _bioCtrl.text = p.bio;
      _loading = false;
    });
  }

  void _addToList(TextEditingController ctrl, List<String> list) {
    final value = ctrl.text.trim();
    if (value.isEmpty) return;
    setState(() => list.add(value));
    ctrl.clear();
  }

  Future<void> _save() async {
    _profile
      ..name = _nameCtrl.text.trim()
      ..username = _usernameCtrl.text.trim()
      ..bio = _bioCtrl.text.trim();
    await _profile.save();
    if (mounted) Navigator.pop(context, _profile);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final border = Theme.of(context).colorScheme.outlineVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [TextButton(onPressed: _save, child: const Text('Guardar'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 32)),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Próximamente: cambiar foto/avatar')),
                ),
                child: const Text('Editar foto o avatar'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _Section(
            title: 'Nombre',
            child: TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Tu nombre')),
          ),

          _Section(
            title: 'Nombre de usuario',
            child: TextField(controller: _usernameCtrl, decoration: const InputDecoration(prefixText: '@ ')),
          ),

          _Section(
            title: 'Presentación',
            child: TextField(controller: _bioCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Contá algo sobre vos')),
          ),

          _Section(
            title: 'Enlaces',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: TextField(controller: _linkInputCtrl, decoration: const InputDecoration(hintText: 'https://tuenlace'))),
                  const SizedBox(width: 8),
                  FilledButton.tonal(onPressed: () => _addToList(_linkInputCtrl, _profile.links), child: const Text('Agregar')),
                ]),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _profile.links.map((e) => Chip(
                    label: Text(e),
                    onDeleted: () => setState(() => _profile.links.remove(e)),
                  )).toList(),
                ),
              ],
            ),
          ),

          _Section(
            title: 'Intereses / marcas',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _interestSuggestions.map((s) {
                    final selected = _profile.interests.contains(s);
                    return FilterChip(
                      label: Text(s), selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v && !selected) { _profile.interests.add(s); }
                          else { _profile.interests.remove(s); }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: _interestInputCtrl, decoration: const InputDecoration(hintText: 'Agregar interés/marca'))),
                  const SizedBox(width: 8),
                  FilledButton.tonal(onPressed: () => _addToList(_interestInputCtrl, _profile.interests), child: const Text('Agregar')),
                ]),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _profile.interests.map((e) => Chip(
                    label: Text(e),
                    onDeleted: () => setState(() => _profile.interests.remove(e)),
                  )).toList(),
                ),
              ],
            ),
          ),

          // Usa initialValue para evitar deprecación
          _Section(
            title: 'Sexo',
            child: DropdownButtonFormField<Gender>(
              initialValue: _profile.gender,
              items: Gender.values.map((g) => DropdownMenuItem(
                value: g,
                child: Text({
                  Gender.none: 'Prefiero no decir',
                  Gender.male: 'Hombre',
                  Gender.female: 'Mujer',
                  Gender.other: 'Otro',
                }[g]!),
              )).toList(),
              onChanged: (g) => setState(() => _profile.gender = g ?? Gender.none),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: const Text('Configuración de información personal'),
              subtitle: const Text('Email, teléfono, Instagram, Pinterest'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoEditScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title; final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(12)),
          child: child,
        ),
      ]),
    );
  }
}

/// ===== Pantalla para email, teléfono, IG, Pinterest =====
class PersonalInfoEditScreen extends StatefulWidget {
  const PersonalInfoEditScreen({super.key});
  @override
  State<PersonalInfoEditScreen> createState() => _PersonalInfoEditScreenState();
}

class _PersonalInfoEditScreenState extends State<PersonalInfoEditScreen> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _pinterestCtrl = TextEditingController();

  Profile _profile = Profile();
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() {
    _emailCtrl.dispose(); _phoneCtrl.dispose(); _instagramCtrl.dispose(); _pinterestCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await ProfileService.load();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _emailCtrl.text = p.contactEmail;
      _phoneCtrl.text = p.phone;
      _instagramCtrl.text = p.instagram;
      _pinterestCtrl.text = p.pinterest;
      _loading = false;
    });
  }

  Future<void> _save() async {
    _profile
      ..contactEmail = _emailCtrl.text.trim()
      ..phone = _phoneCtrl.text.trim()
      ..instagram = _instagramCtrl.text.trim()
      ..pinterest = _pinterestCtrl.text.trim();
    await _profile.save();
    if (mounted) Navigator.pop(context, _profile);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información personal'),
        actions: [TextButton(onPressed: _save, child: const Text('Guardar'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoField(label: 'Correo electrónico', controller: _emailCtrl, hint: 'tu@correo.com'),
          _InfoField(label: 'Teléfono', controller: _phoneCtrl, hint: '+59812345678'),
          _InfoField(label: 'Instagram', controller: _instagramCtrl, hint: 'instagram.com/tuusuario'),
          _InfoField(label: 'Pinterest', controller: _pinterestCtrl, hint: 'pinterest.com/tuusuario'),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label; final TextEditingController controller; final String hint;
  const _InfoField({required this.label, required this.controller, required this.hint});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
    ),
  );
}


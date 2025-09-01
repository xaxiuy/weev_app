import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// ===============================================
///  Brand Admin (Flutter + Firestore, client-only)
/// ===============================================
/// Ruta esperada (si usás navegación por código):
///   Navigator.push(context,
///     MaterialPageRoute(builder: (_) => BrandAdminScreen(brandId: 'omoda')));
///
/// La pantalla verifica permisos buscando:
///   brands/{brandId}/admins/{currentUser.uid}
///
/// Estructura usada:
///  brands/{brandId} doc:
///    displayName, description, website, instagram, pinterest,
///    primaryColor (hex), logoUrl
///  brands/{brandId}/products/{doc}
///    title, price, sku, imageUrl, active, createdAt
///  brands/{brandId}/stories/{doc}
///    imageUrl, caption, active, createdAt
///  brands/{brandId}/cards/{doc}
///    name, colorHex, logoUrl, active, createdAt
///  brands/{brandId}/activationRules/{doc}
///    ruleType ('countItems' | 'minAmount' | 'specificProduct')
///    params (map<String, dynamic>), unlockCardId, active, createdAt

class BrandAdminScreen extends StatefulWidget {
  const BrandAdminScreen({super.key, required this.brandId});
  final String brandId;

  @override
  State<BrandAdminScreen> createState() => _BrandAdminScreenState();
}

class _BrandAdminScreenState extends State<BrandAdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 6, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Iniciá sesión para continuar')),
      );
    }

    final adminDoc = FirebaseFirestore.instance
        .collection('brands')
        .doc(widget.brandId)
        .collection('admins')
        .doc(user.uid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: adminDoc.snapshots(),
      builder: (context, snap) {
        final isAdmin = snap.hasData && snap.data!.exists;
        if (!isAdmin) {
          return Scaffold(
            appBar: AppBar(title: Text('Admin ${widget.brandId.toUpperCase()}')),
            body: const Center(
              child: Text(
                'Sin permisos – Tu usuario no está configurado como admin de esta marca.',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Admin ${widget.brandId.toUpperCase()}'),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Resumen'),
                Tab(text: 'Productos'),
                Tab(text: 'Historias'),
                Tab(text: 'Tarjetas'),
                Tab(text: 'Reglas'),
                Tab(text: 'Perfil'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _OverviewTab(brandId: widget.brandId),
              _ProductsTab(brandId: widget.brandId),
              _StoriesTab(brandId: widget.brandId),
              _CardsTab(brandId: widget.brandId),
              _RulesTab(brandId: widget.brandId),
              _BrandProfileTab(brandId: widget.brandId),
            ],
          ),
        );
      },
    );
  }
}

/// -------------------------------
/// Helpers
/// -------------------------------
Color colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFF111827);
  final cleaned = hex.replaceAll('#', '');
  final buffer = StringBuffer();
  if (cleaned.length == 6) buffer.write('FF');
  buffer.write(cleaned);
  return Color(int.parse(buffer.toString(), radix: 16));
}

String colorToHex(Color c) {
  final v = c.value.toRadixString(16).padLeft(8, '0').toUpperCase();
  return '#${v.substring(2)}'; // sin alpha
}

Widget _counterCard({
  required String label,
  required IconData icon,
  required int count,
}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Icon(icon, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('$count', style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ]),
    ),
  );
}

CollectionReference<Map<String, dynamic>> _col(
        String brandId, String sub) =>
    FirebaseFirestore.instance
        .collection('brands')
        .doc(brandId)
        .collection(sub);

/// -------------------------------
/// Resumen (conteos rápidos)
/// -------------------------------
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.brandId});
  final String brandId;

  @override
  Widget build(BuildContext context) {
    final products$ = _col(brandId, 'products').snapshots();
    final stories$ = _col(brandId, 'stories').snapshots();
    final cards$ = _col(brandId, 'cards').snapshots();
    final rules$ = _col(brandId, 'activationRules').snapshots();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        StreamBuilder(
          stream: products$,
          builder: (context, snap) =>
              _counterCard(label: 'Productos', icon: Icons.inventory_2,
                  count: snap.hasData ? snap.data!.docs.length : 0),
        ),
        const SizedBox(height: 8),
        StreamBuilder(
          stream: stories$,
          builder: (context, snap) =>
              _counterCard(label: 'Historias', icon: Icons.history_edu,
                  count: snap.hasData ? snap.data!.docs.length : 0),
        ),
        const SizedBox(height: 8),
        StreamBuilder(
          stream: cards$,
          builder: (context, snap) =>
              _counterCard(label: 'Tarjetas', icon: Icons.credit_card,
                  count: snap.hasData ? snap.data!.docs.length : 0),
        ),
        const SizedBox(height: 8),
        StreamBuilder(
          stream: rules$,
          builder: (context, snap) =>
              _counterCard(label: 'Reglas de activación', icon: Icons.rule,
                  count: snap.hasData ? snap.data!.docs.length : 0),
        ),
        const SizedBox(height: 16),
        const Text(
          'Esto es en vivo (escucha Firestore). Más adelante podemos sumar métricas históricas.',
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

/// -------------------------------
/// Productos (CRUD)
/// -------------------------------
class _ProductsTab extends StatelessWidget {
  const _ProductsTab({required this.brandId});
  final String brandId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          _col(brandId, 'products').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snap) {
        final docs = snap.hasData ? snap.data!.docs : const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _editProduct(context, brandId),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo producto'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data();
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (data['imageUrl'] ?? '').toString().isNotEmpty
                        ? NetworkImage(data['imageUrl'])
                        : null,
                    child: (data['imageUrl'] ?? '').toString().isEmpty
                        ? const Icon(Icons.inventory_2)
                        : null,
                  ),
                  title: Text(data['title'] ?? 'Sin título',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('SKU: ${data['sku'] ?? '-'}  ·  \$${(data['price'] ?? 0).toString()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: (data['active'] ?? true) == true,
                        onChanged: (val) => d.reference.update({'active': val}),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editProduct(context, brandId, doc: d),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => d.reference.delete(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editProduct(BuildContext context, String brandId,
      {QueryDocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final isEdit = doc != null;
    final data = doc?.data() ?? {};
    final title = TextEditingController(text: data['title'] ?? '');
    final price = TextEditingController(text: (data['price'] ?? '').toString());
    final sku = TextEditingController(text: data['sku'] ?? '');
    final imageUrl = TextEditingController(text: data['imageUrl'] ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEdit ? 'Editar producto' : 'Nuevo producto',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 8),
              TextField(controller: price, decoration: const InputDecoration(labelText: 'Precio (número)'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: sku, decoration: const InputDecoration(labelText: 'SKU')),
              const SizedBox(height: 8),
              TextField(controller: imageUrl, decoration: const InputDecoration(labelText: 'Imagen (URL)')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final p = double.tryParse(price.text.trim()) ?? 0.0;
                  final payload = {
                    'title': title.text.trim(),
                    'price': p,
                    'sku': sku.text.trim(),
                    'imageUrl': imageUrl.text.trim(),
                    'active': data['active'] ?? true,
                    'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
                  };
                  if (isEdit) {
                    await doc!.reference.update(payload);
                  } else {
                    await _col(brandId, 'products').add(payload);
                  }
                  if (context.mounted) Navigator.pop(ctx);
                },
                child: Text(isEdit ? 'Guardar cambios' : 'Crear'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// -------------------------------
/// Historias (CRUD) – tipo Instagram
/// -------------------------------
class _StoriesTab extends StatelessWidget {
  const _StoriesTab({required this.brandId});
  final String brandId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          _col(brandId, 'stories').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snap) {
        final docs = snap.hasData ? snap.data!.docs : const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _editStory(context, brandId),
            icon: const Icon(Icons.add),
            label: const Text('Nueva historia'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data();
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if ((data['imageUrl'] ?? '').toString().isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16/9,
                        child: Image.network(data['imageUrl'], fit: BoxFit.cover),
                      ),
                    ListTile(
                      title: Text(data['caption'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: (data['active'] ?? true) == true,
                            onChanged: (val) => d.reference.update({'active': val}),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editStory(context, brandId, doc: d),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => d.reference.delete(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editStory(BuildContext context, String brandId,
      {QueryDocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final isEdit = doc != null;
    final data = doc?.data() ?? {};
    final imageUrl = TextEditingController(text: data['imageUrl'] ?? '');
    final caption = TextEditingController(text: data['caption'] ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEdit ? 'Editar historia' : 'Nueva historia',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(controller: imageUrl, decoration: const InputDecoration(labelText: 'Imagen (URL)')),
              const SizedBox(height: 8),
              TextField(controller: caption, decoration: const InputDecoration(labelText: 'Texto')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final payload = {
                    'imageUrl': imageUrl.text.trim(),
                    'caption': caption.text.trim(),
                    'active': data['active'] ?? true,
                    'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
                  };
                  if (isEdit) {
                    await doc!.reference.update(payload);
                  } else {
                    await _col(brandId, 'stories').add(payload);
                  }
                  if (context.mounted) Navigator.pop(ctx);
                },
                child: Text(isEdit ? 'Guardar cambios' : 'Crear'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// -------------------------------
/// Tarjetas Wallet (CRUD)
/// -------------------------------
class _CardsTab extends StatelessWidget {
  const _CardsTab({required this.brandId});
  final String brandId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          _col(brandId, 'cards').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snap) {
        final docs = snap.hasData ? snap.data!.docs : const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _editCard(context, brandId),
            icon: const Icon(Icons.add_card),
            label: const Text('Nueva tarjeta'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data();
              final color = colorFromHex((data['colorHex'] ?? '#111827'));
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: const Icon(Icons.credit_card, color: Colors.white),
                  ),
                  title: Text(data['name'] ?? 'Tarjeta',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('Color: ${data['colorHex'] ?? '#111827'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: (data['active'] ?? true) == true,
                        onChanged: (val) => d.reference.update({'active': val}),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editCard(context, brandId, doc: d),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => d.reference.delete(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editCard(BuildContext context, String brandId,
      {QueryDocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final isEdit = doc != null;
    final data = doc?.data() ?? {};
    final name = TextEditingController(text: data['name'] ?? '');
    final colorHex = TextEditingController(text: data['colorHex'] ?? '#111827');
    final logoUrl = TextEditingController(text: data['logoUrl'] ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isEdit ? 'Editar tarjeta' : 'Nueva tarjeta',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
              const SizedBox(height: 8),
              TextField(controller: colorHex, decoration: const InputDecoration(labelText: 'Color (HEX, ej: #10B981)')),
              const SizedBox(height: 8),
              TextField(controller: logoUrl, decoration: const InputDecoration(labelText: 'Logo (URL)')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  final payload = {
                    'name': name.text.trim(),
                    'colorHex': colorHex.text.trim().isEmpty ? '#111827' : colorHex.text.trim(),
                    'logoUrl': logoUrl.text.trim(),
                    'active': data['active'] ?? true,
                    'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
                  };
                  if (isEdit) {
                    await doc!.reference.update(payload);
                  } else {
                    await _col(brandId, 'cards').add(payload);
                  }
                  if (context.mounted) Navigator.pop(ctx);
                },
                child: Text(isEdit ? 'Guardar cambios' : 'Crear'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// -------------------------------
/// Reglas de activación (CRUD)
/// -------------------------------
class _RulesTab extends StatelessWidget {
  const _RulesTab({required this.brandId});
  final String brandId;

  static const ruleTypes = <String, String>{
    'countItems': 'Cantidad de prendas',
    'minAmount': 'Monto mínimo',
    'specificProduct': 'Producto específico',
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _col(brandId, 'activationRules')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.hasData ? snap.data!.docs : const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _editRule(context, brandId),
            icon: const Icon(Icons.rule),
            label: const Text('Nueva regla'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data();
              final type = data['ruleType'] ?? 'countItems';
              final params = Map<String, dynamic>.from(data['params'] ?? {});
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(ruleTypes[type] ?? type,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('params: $params · unlockCardId: ${data['unlockCardId'] ?? '-'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: (data['active'] ?? true) == true,
                        onChanged: (val) => d.reference.update({'active': val}),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editRule(context, brandId, doc: d),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => d.reference.delete(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editRule(BuildContext context, String brandId,
      {QueryDocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final isEdit = doc != null;
    final data = doc?.data() ?? {};
    String ruleType = (data['ruleType'] ?? 'countItems').toString();
    final unlockCardId = TextEditingController(text: data['unlockCardId'] ?? '');

    // params
    final pCount = TextEditingController(text: (data['params']?['count'] ?? '').toString());
    final pAmount = TextEditingController(text: (data['params']?['amount'] ?? '').toString());
    final pSku = TextEditingController(text: data['params']?['sku'] ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isEdit ? 'Editar regla' : 'Nueva regla',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ruleType,
                  items: ruleTypes.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) => setState(() => ruleType = v ?? 'countItems'),
                  decoration: const InputDecoration(labelText: 'Tipo de regla'),
                ),
                const SizedBox(height: 8),

                if (ruleType == 'countItems') ...[
                  TextField(
                    controller: pCount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad mínima de prendas'),
                  ),
                ] else if (ruleType == 'minAmount') ...[
                  TextField(
                    controller: pAmount,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Monto mínimo (ej: 100.0)'),
                  ),
                ] else if (ruleType == 'specificProduct') ...[
                  TextField(
                    controller: pSku,
                    decoration: const InputDecoration(labelText: 'SKU requerido'),
                  ),
                ],

                const SizedBox(height: 8),
                TextField(
                  controller: unlockCardId,
                  decoration: const InputDecoration(
                    labelText: 'ID de tarjeta a desbloquear (cards/{id})',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    final Map<String, dynamic> params = {};
                    if (ruleType == 'countItems') {
                      params['count'] = int.tryParse(pCount.text.trim()) ?? 0;
                    } else if (ruleType == 'minAmount') {
                      params['amount'] = double.tryParse(pAmount.text.trim()) ?? 0.0;
                    } else if (ruleType == 'specificProduct') {
                      params['sku'] = pSku.text.trim();
                    }
                    final payload = {
                      'ruleType': ruleType,
                      'params': params,
                      'unlockCardId': unlockCardId.text.trim(),
                      'active': data['active'] ?? true,
                      'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
                    };
                    if (isEdit) {
                      await doc!.reference.update(payload);
                    } else {
                      await _col(brandId, 'activationRules').add(payload);
                    }
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: Text(isEdit ? 'Guardar cambios' : 'Crear'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// -------------------------------
/// Perfil de marca (editar doc brands/{brandId})
/// -------------------------------
class _BrandProfileTab extends StatefulWidget {
  const _BrandProfileTab({required this.brandId});
  final String brandId;

  @override
  State<_BrandProfileTab> createState() => _BrandProfileTabState();
}

class _BrandProfileTabState extends State<_BrandProfileTab> {
  final _displayName = TextEditingController();
  final _description = TextEditingController();
  final _website = TextEditingController();
  final _instagram = TextEditingController();
  final _pinterest = TextEditingController();
  final _logoUrl = TextEditingController();
  final _primaryColorHex = TextEditingController(text: '#111827');

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snap = await FirebaseFirestore.instance
        .collection('brands')
        .doc(widget.brandId)
        .get();
    final data = snap.data() ?? {};
    _displayName.text = data['displayName'] ?? widget.brandId.toUpperCase();
    _description.text = data['description'] ?? '';
    _website.text = data['website'] ?? '';
    _instagram.text = data['instagram'] ?? '';
    _pinterest.text = data['pinterest'] ?? '';
    _logoUrl.text = data['logoUrl'] ?? '';
    _primaryColorHex.text = data['primaryColor'] ?? '#111827';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final payload = {
      'displayName': _displayName.text.trim(),
      'description': _description.text.trim(),
      'website': _website.text.trim(),
      'instagram': _instagram.text.trim(),
      'pinterest': _pinterest.text.trim(),
      'logoUrl': _logoUrl.text.trim(),
      'primaryColor': _primaryColorHex.text.trim().isEmpty
          ? '#111827'
          : _primaryColorHex.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance
        .collection('brands')
        .doc(widget.brandId)
        .set(payload, SetOptions(merge: true));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil de marca guardado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextField(controller: _displayName, decoration: const InputDecoration(labelText: 'Nombre público')),
              const SizedBox(height: 8),
              TextField(controller: _description, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
              const SizedBox(height: 8),
              TextField(controller: _website, decoration: const InputDecoration(labelText: 'Website')),
              const SizedBox(height: 8),
              TextField(controller: _instagram, decoration: const InputDecoration(labelText: 'Instagram')),
              const SizedBox(height: 8),
              TextField(controller: _pinterest, decoration: const InputDecoration(labelText: 'Pinterest')),
              const SizedBox(height: 8),
              TextField(controller: _logoUrl, decoration: const InputDecoration(labelText: 'Logo (URL)')),
              const SizedBox(height: 8),
              TextField(controller: _primaryColorHex, decoration: const InputDecoration(labelText: 'Color primario (HEX)')),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

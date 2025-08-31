import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_edit_screen.dart';
import 'wallet_service.dart';
import 'wallet_code_screen.dart';

/// Pantalla principal con 5 tabs:
/// Inicio · Descubrir · Wallet · Perfil · Swipe
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  late final List<Widget> _pages = [
    const _HomeTab(),
    const _StubPage(title: 'Descubrir (próximamente)'),
    const _WalletTab(), // Wallet con persistencia Firestore
    const _ProfileTab(),
    const _SwipeTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text('Weev', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Descubrir'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), selectedIcon: Icon(Icons.swap_horiz), label: 'Swipe'),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// HOME (historias + feed demo)
////////////////////////////////////////////////////////////////
class _HomeTab extends StatefulWidget {
  const _HomeTab();
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final List<_StoryData> stories = [
    _StoryData(name: 'Tu historia', imageUrl: 'https://i.pravatar.cc/150?img=68', isYou: true),
    _StoryData(name: 'OMODA', imageUrl: 'https://i.pravatar.cc/150?img=12'),
    _StoryData(name: 'JAECOO', imageUrl: 'https://i.pravatar.cc/150?img=25'),
    _StoryData(name: 'ZEEKR', imageUrl: 'https://i.pravatar.cc/150?img=31'),
    _StoryData(name: 'XPENG', imageUrl: 'https://i.pravatar.cc/150?img=5'),
    _StoryData(name: 'Lavazza', imageUrl: 'https://i.pravatar.cc/150?img=44'),
    _StoryData(name: 'Top Pádel', imageUrl: 'https://i.pravatar.cc/150?img=9'),
  ];

  final List<_PostData> posts = [
    _PostData(brand: 'OMODA', subtitle: 'Nueva activación en WTC', imageUrl: 'https://picsum.photos/seed/omoda/900/600', cta: 'Ver activación'),
    _PostData(brand: 'JAECOO', subtitle: 'Beneficio 2x1 weekend', imageUrl: 'https://picsum.photos/seed/jaecoo/900/600', cta: 'Ver beneficio'),
    _PostData(brand: 'ZEEKR', subtitle: 'Test drive VIP', imageUrl: 'https://picsum.photos/seed/zeekr/900/600', cta: 'Reservar cupo'),
  ];

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feed actualizado')));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 112,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _StoryRing(data: stories[i]),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _PostCard(data: posts[i]),
              childCount: posts.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  const _StoryRing({required this.data});
  final _StoryData data;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      data.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
    );

    final ring = Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(colors: [Color(0xFFFD1D1D), Color(0xFFFCAF45), Color(0xFF833AB4), Color(0xFFFD1D1D)]),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Color(0xFFE5E7EB), width: 1)),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipOval(child: Image.network(data.imageUrl, fit: BoxFit.cover)),
          ),
        ),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(children: [
          ring,
          if (data.isYou)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.add, size: 14, color: Colors.white),
              ),
            ),
        ]),
        const SizedBox(height: 6),
        SizedBox(width: 74, child: label),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.data});
  final _PostData data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            leading: CircleAvatar(backgroundImage: NetworkImage('https://api.dicebear.com/7.x/initials/svg?seed=${data.brand}')),
            title: Text(data.brand, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(data.subtitle),
            trailing: IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
          ),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(data.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                const SizedBox(width: 4),
                IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline)),
                const SizedBox(width: 4),
                IconButton(onPressed: () {}, icon: const Icon(Icons.send_outlined)),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chevron_right),
              label: Text(data.cta),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// WALLET (apiladas + activar) con persistencia Firestore
////////////////////////////////////////////////////////////////
class _WalletTab extends StatefulWidget {
  const _WalletTab();
  @override
  State<_WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<_WalletTab> {
  // Datos de ejemplo: marca, color, logo
  final List<_WalletCardData> _allCards = [
    _WalletCardData(
      id: 'omoda',
      brand: 'OMODA',
      color: const Color(0xFF111827),
      logoUrl: 'https://api.dicebear.com/7.x/initials/svg?seed=OMODA',
    ),
    _WalletCardData(
      id: 'jaecoo',
      brand: 'JAECOO',
      color: const Color(0xFF0EA5E9),
      logoUrl: 'https://api.dicebear.com/7.x/initials/svg?seed=JAECOO',
    ),
    _WalletCardData(
      id: 'zeekr',
      brand: 'ZEEKR',
      color: const Color(0xFF9333EA),
      logoUrl: 'https://api.dicebear.com/7.x/initials/svg?seed=ZEEKR',
    ),
    _WalletCardData(
      id: 'xpeng',
      brand: 'XPENG',
      color: const Color(0xFF10B981),
      logoUrl: 'https://api.dicebear.com/7.x/initials/svg?seed=XPENG',
    ),
  ];

  String _filter = 'Todas';
  late final PageController _pageController = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_WalletCardData> get _filtered {
    if (_filter == 'Todas') return _allCards;
    return _allCards.where((c) => c.brand == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Iniciá sesión para usar tu Wallet',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final uid = user.uid;

    return StreamBuilder<String?>(
      stream: WalletService.activeCardIdStream(uid),
      builder: (context, snap) {
        final activeId = snap.data;

        return Column(
          children: [
            // Filtros por marca
            SizedBox(
              height: 56,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                scrollDirection: Axis.horizontal,
                children: [
                  _brandChip('Todas'),
                  const SizedBox(width: 8),
                  for (final b in _allCards.map((e) => e.brand).toSet()) ...[
                    _brandChip(b),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),

            // Pila vertical estilo Wallet (PageView vertical)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final card = _filtered[index];
                  final isActive = activeId == card.id;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: _WalletCard(
                      data: card,
                      isActive: isActive,
                      onActivate: () => WalletService.setActiveCardId(uid, card.id),
                      onDeactivate: () => WalletService.setActiveCardId(uid, null),
                    ),
                  );
                },
              ),
            ),

            // Info “apiladas”
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Deslizá verticalmente para ver tus tarjetas',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.outline),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _brandChip(String name) {
    final selected = _filter == name;
    return ChoiceChip(
      label: Text(name),
      selected: selected,
      onSelected: (_) => setState(() => _filter = name),
    );
  }
}

class _WalletCardData {
  final String id;
  final String brand;
  final Color color;
  final String logoUrl;
  const _WalletCardData({
    required this.id,
    required this.brand,
    required this.color,
    required this.logoUrl,
  });
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.data,
    required this.isActive,
    required this.onActivate,
    required this.onDeactivate,
  });

  final _WalletCardData data;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  Color _darken(Color c, [double amount = 0.12]) {
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final bg = data.color;
    final bg2 = _darken(bg, 0.18);
    return Card(
      elevation: isActive ? 8 : 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bg, bg2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Marca en watermark
            Positioned(
              right: -20,
              bottom: -10,
              child: Opacity(
                opacity: 0.12,
                child: Text(
                  data.brand,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: logo + marca + estado
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: NetworkImage(data.logoUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data.brand,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (isActive) const _ActivePill(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // “Tarjeta” visual
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tarjeta de beneficios', style: TextStyle(color: Colors.white70)),
                              SizedBox(height: 8),
                              Text(
                                'Activá para usar en el comercio',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.credit_card, color: Colors.white),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Acciones
                  Row(
                    children: [
                      if (!isActive)
                        Expanded(
                          child: FilledButton(
                            onPressed: onActivate,
                            child: const Text('Activar'),
                          ),
                        )
                      else ...[
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: onDeactivate,
                            child: const Text('Desactivar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => WalletCodeScreen(
                                  cardId: data.id,
                                  brand: data.brand,
                                  color: data.color,
                                  logoUrl: data.logoUrl,
                                ),
                              ));
                            },
                            child: const Text('Mostrar código'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.white),
          SizedBox(width: 6),
          Text('Activa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// PERFIL
////////////////////////////////////////////////////////////////
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  String _initials(String? nameOrEmail) {
    final s = (nameOrEmail ?? '').trim();
    if (s.isEmpty) return 'U';
    final parts = s.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0].isNotEmpty ? parts[0][0] : 'U').toUpperCase() + (parts[1].isNotEmpty ? parts[1][0] : '');
    }
    return s[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('No hay sesión activa'));

    final name = user.displayName ?? '';
    final email = user.email ?? '';
    final photo = user.photoURL;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: photo != null ? NetworkImage(photo) : null,
                  child: photo == null ? Text(_initials(name.isNotEmpty ? name : email)) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Usuario Weev',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              ListTile(leading: const Icon(Icons.fingerprint), title: const Text('UID'), subtitle: Text(user.uid)),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: const Text('Email verificado'),
                subtitle: Text(user.emailVerified ? 'Sí' : 'No'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////
/// SWIPE (demo tipo Tinder)
////////////////////////////////////////////////////////////////
class _SwipeTab extends StatefulWidget {
  const _SwipeTab();
  @override
  State<_SwipeTab> createState() => _SwipeTabState();
}

class _SwipeTabState extends State<_SwipeTab> {
  final List<_SwipeItem> _queue = [
    _SwipeItem(id: '1', brand: 'Weev x OMODA', title: 'Campera Tech 3L', imageUrl: 'https://picsum.photos/seed/campera/1000/1200', tags: ['impermeable', 'windproof', 'UR']),
    _SwipeItem(id: '2', brand: 'Weev x JAECOO', title: 'Sneakers Urbanos', imageUrl: 'https://picsum.photos/seed/sneakers/1000/1200', tags: ['vegan', 'city', 'comfort']),
    _SwipeItem(id: '3', brand: 'Weev x ZEEKR', title: 'Buzo Oversize', imageUrl: 'https://picsum.photos/seed/buzo/1000/1200', tags: ['soft', 'casual']),
    _SwipeItem(id: '4', brand: 'Weev x XPENG', title: 'Tech Tee', imageUrl: 'https://picsum.photos/seed/tee/1000/1200', tags: ['dryfit', 'training']),
  ];
  final List<_SwipeItem> _liked = [];
  final List<_SwipeItem> _passed = [];

  void _onLike() {
    if (_queue.isEmpty) return;
    setState(() => _liked.add(_queue.removeAt(0)));
  }

  void _onNope() {
    if (_queue.isEmpty) return;
    setState(() => _passed.add(_queue.removeAt(0)));
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_outline, size: 64),
          const SizedBox(height: 8),
          const Text('No hay más por hoy'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              setState(() {
                _queue.addAll(_liked);
                _queue.addAll(_passed);
                _liked.clear();
                _passed.clear();
              });
            },
            child: const Text('Reiniciar demo'),
          ),
        ]),
      );
    }

    final visible = _queue.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                for (int i = visible.length - 1; i >= 0; i--)
                  _buildStackedCard(item: visible[i], isTop: i == 0, indexFromTop: i),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _roundAction(context, icon: Icons.close, semantic: 'Nope', onTap: _onNope),
              _roundAction(context, icon: Icons.favorite, semantic: 'Like', onTap: _onLike),
            ],
          ),
          const SizedBox(height: 6),
          Text('Likes: ${_liked.length}  ·  Pasados: ${_passed.length}', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildStackedCard({required _SwipeItem item, required bool isTop, required int indexFromTop}) {
    final double scale = 1 - (indexFromTop * 0.04);
    final double topOffset = indexFromTop * 12.0;
    final card = _SwipeCard(item: item);

    if (!isTop) {
      return Positioned.fill(top: topOffset, child: Transform.scale(scale: scale, child: card));
    }

    return Positioned.fill(
      top: topOffset,
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.horizontal,
        onDismissed: (dir) {
          if (dir == DismissDirection.startToEnd) {
            _onLike();
          } else {
            _onNope();
          }
        },
        background: _swipeBackground(
          align: Alignment.centerLeft,
          icon: Icons.favorite,
          color: Colors.green.withValues(alpha: 0.15),
          iconColor: Colors.green,
          label: 'LIKE',
        ),
        secondaryBackground: _swipeBackground(
          align: Alignment.centerRight,
          icon: Icons.close,
          color: Colors.red.withValues(alpha: 0.15),
          iconColor: Colors.red,
          label: 'NOPE',
        ),
        child: Transform.scale(scale: scale, child: card),
      ),
    );
  }

  Widget _swipeBackground({
    required Alignment align,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      alignment: align,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: iconColor, letterSpacing: 1.2)),
      ]),
    );
  }

  Widget _roundAction(BuildContext context, {required IconData icon, required String semantic, required VoidCallback onTap}) {
    return Semantics(
      button: true,
      label: semantic,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [BoxShadow(blurRadius: 10, spreadRadius: 0, offset: Offset(0, 4), color: Color(0x1A000000))],
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(icon, size: 32),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// MODELOS auxiliares
////////////////////////////////////////////////////////////////
class _SwipeCard extends StatelessWidget {
  const _SwipeCard({required this.item});
  final _SwipeItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              Image.network(item.imageUrl, fit: BoxFit.cover),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment(0, -0.2), end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black54]),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                item.brand,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: -6,
                children: item.tags
                    .map((t) => Chip(
                          label: Text(t),
                          visualDensity: VisualDensity.compact,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ))
                    .toList(),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SwipeItem {
  final String id;
  final String brand;
  final String title;
  final String imageUrl;
  final List<String> tags;
  _SwipeItem({required this.id, required this.brand, required this.title, required this.imageUrl, required this.tags});
}

class _StoryData {
  final String name;
  final String imageUrl;
  final bool isYou;
  _StoryData({required this.name, required this.imageUrl, this.isYou = false});
}

class _PostData {
  final String brand;
  final String subtitle;
  final String imageUrl;
  final String cta;
  _PostData({required this.brand, required this.subtitle, required this.imageUrl, required this.cta});
}

class _StubPage extends StatelessWidget {
  const _StubPage({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
}

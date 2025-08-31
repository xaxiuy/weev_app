import 'package:flutter/material.dart';

/// Pantalla principal después del login.
/// Top bar "Weev", bottom bar con 5 ítems:
/// Inicio · Descubrir · Wallet · Perfil · Swipe
/// Home completo: historias estilo IG + feed de activaciones.
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
    const _StubPage(title: 'Wallet (próximamente)'),
    const _StubPage(title: 'Perfil (próximamente)'),
    const _StubPage(title: 'Swipe (próximamente)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Weev',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          // Casa = Home
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          // Lupa = Descubrir actividades de marcas/usuarios
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Descubrir',
          ),
          // Wallet = tarjetas/descuentos
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          // Perfil
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          // Swipe (tipo Tinder)
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Swipe',
          ),
        ],
      ),
    );
  }
}

/// ===================== HOME TAB =====================
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  // Historias demo
  final List<_StoryData> stories = [
    _StoryData(name: 'Tu historia', imageUrl: 'https://i.pravatar.cc/150?img=68', isYou: true),
    _StoryData(name: 'OMODA', imageUrl: 'https://i.pravatar.cc/150?img=12'),
    _StoryData(name: 'JAECOO', imageUrl: 'https://i.pravatar.cc/150?img=25'),
    _StoryData(name: 'ZEEKR', imageUrl: 'https://i.pravatar.cc/150?img=31'),
    _StoryData(name: 'XPENG', imageUrl: 'https://i.pravatar.cc/150?img=5'),
    _StoryData(name: 'Lavazza', imageUrl: 'https://i.pravatar.cc/150?img=44'),
    _StoryData(name: 'Top Pádel', imageUrl: 'https://i.pravatar.cc/150?img=9'),
  ];

  // Feed demo
  final List<_PostData> posts = [
    _PostData(
      brand: 'OMODA',
      subtitle: 'Nueva activación en WTC',
      imageUrl: 'https://picsum.photos/seed/omoda/900/600',
      cta: 'Ver activación',
    ),
    _PostData(
      brand: 'JAECOO',
      subtitle: 'Beneficio 2x1 weekend',
      imageUrl: 'https://picsum.photos/seed/jaecoo/900/600',
      cta: 'Ver beneficio',
    ),
    _PostData(
      brand: 'ZEEKR',
      subtitle: 'Test drive VIP',
      imageUrl: 'https://picsum.photos/seed/zeekr/900/600',
      cta: 'Reservar cupo',
    ),
  ];

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feed actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          // Historias
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
          // Feed
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

/// Story ring con borde degradado (estilo IG)
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
        gradient: SweepGradient(
          colors: [
            Color(0xFFFD1D1D), // rojo
            Color(0xFFFCAF45), // naranja
            Color(0xFF833AB4), // violeta
            Color(0xFFFD1D1D),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFFE5E7EB), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: Image.network(data.imageUrl, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
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
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(width: 74, child: label),
      ],
    );
  }
}

/// Card de publicación / activación
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
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://api.dicebear.com/7.x/initials/svg?seed=${data.brand}'),
            ),
            title: Text(data.brand, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(data.subtitle),
            trailing: IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
          ),
          // Imagen
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(data.imageUrl, fit: BoxFit.cover),
            ),
          ),
          // Acciones
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
          // CTA
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

/// ===================== MODELOS (demo) =====================
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

/// ===================== STUBS =====================
class _StubPage extends StatelessWidget {
  const _StubPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

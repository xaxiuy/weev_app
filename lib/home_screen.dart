import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_service.dart';
import 'profile_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await ProfileService.load();
    setState(() => _profile = p);
  }

  Future<void> _openProfile() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
    await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final display = (_profile?.name.isNotEmpty ?? false)
        ? _profile!.name
        : (user?.displayName ?? user?.email ?? 'usuario');

    final pages = <Widget>[
      _WalletTab(user: user, profile: _profile),
      const _ActivacionesTab(),
      const _StoriesTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weev'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Editar perfil',
            onPressed: _openProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(display),
                subtitle: Text(user?.email ?? 'Sin email'),
                onTap: _openProfile,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar perfil'),
                onTap: _openProfile,
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Información personal'),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoEditScreen()));
                  await _loadProfile();
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () async => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: 'Activaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Stories',
          ),
        ],
      ),
    );
  }
}

class _WalletTab extends StatelessWidget {
  final User? user;
  final Profile? profile;
  const _WalletTab({required this.user, required this.profile});
  @override
  Widget build(BuildContext context) {
    final display = (profile?.name.isNotEmpty ?? false)
        ? profile!.name
        : (user?.displayName ?? user?.email ?? 'usuario');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Text('Hola,  👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Intereses',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (profile?.interests ?? []).isEmpty
                  ? [const Text('Aún no agregaste intereses.')]
                  : profile!.interests.map((e) => Chip(label: Text(e))).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: 'Saldo de recompensas',
            child: Row(
              children: [
                const Icon(Icons.stars, size: 28),
                const SizedBox(width: 12),
                const Text('7.450 pts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const Spacer(),
                FilledButton.tonal(onPressed: () {}, child: const Text('Canjear')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivacionesTab extends StatelessWidget {
  const _ActivacionesTab();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _Card(
        title: 'Activación #',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Participá y ganá puntos con la campaña .', style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.info_outline), label: const Text('Ver más')),
                const SizedBox(width: 8),
                FilledButton(onPressed: () {}, child: const Text('Participar')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _StoriesTab extends StatelessWidget {
  const _StoriesTab();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 4 / 5,
      ),
      itemCount: 6,
      itemBuilder: (_, i) => _Card(
        title: 'Story ',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(child: Placeholder()),
            SizedBox(height: 8),
            Text('Novedades y lanzamientos', style: TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

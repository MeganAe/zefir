import 'package:flutter/material.dart';
import '../widgets/zefir_logo.dart';
import 'compression/compression_screen.dart';
import 'search/search_screen.dart';
import 'favorites/favorites_screen.dart';
import 'settings/settings_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _index = 0;

  static const _screens = [
    CompressionScreen(),
    SearchScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Recherche',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}

/// Barre M3 expressive réutilisable : logo à gauche, menu + more_vert.
class ZefirTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenu;
  final List<Widget>? extraActions;
  const ZefirTopBar({super.key, required this.title, this.onMenu, this.extraActions});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: onMenu ?? () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu : utilisez la barre de navigation en bas.')),
        ),
      ),
      title: Row(children: [const ZefirLogo(size: 32), const SizedBox(width: 10), Text(title)]),
      actions: [
        ...(extraActions ?? const []),
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Plus d’options',
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => const _MoreSheet(),
          ),
        ),
      ],
    );
  }
}

class _MoreSheet extends StatelessWidget {
  const _MoreSheet();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('À propos de Zefir'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Zefir',
                applicationVersion: '1.1.0',
                applicationLegalese: 'Compression vidéo 100% locale • par Metoushael',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Aide'),
            subtitle: const Text('Sélectionnez une vidéo puis lancez la compression.'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}


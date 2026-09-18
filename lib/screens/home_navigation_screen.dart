import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../widgets/stats_sheet.dart';
import '../widgets/zefir_logo.dart';
import 'compression/compression_screen.dart';
import 'history/history_screen.dart';
import 'search/search_screen.dart';
import 'favorites/favorites_screen.dart';
import 'settings/settings_screen.dart';

/// Expose la navigation par onglets aux widgets descendants (barre supérieure,
/// feuilles modales, écrans). Évite de propager des callbacks partout.
class ZefirNavigation extends InheritedWidget {
  final int index;
  final ValueChanged<int> goTo;

  const ZefirNavigation({
    super.key,
    required this.index,
    required this.goTo,
    required super.child,
  });

  static ZefirNavigation? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ZefirNavigation>();

  /// Index des onglets de la barre de navigation.
  static const int homeTab = 0;
  static const int searchTab = 1;
  static const int favoritesTab = 2;
  static const int settingsTab = 3;

  @override
  bool updateShouldNotify(ZefirNavigation oldWidget) =>
      oldWidget.index != index;
}

class HomeNavigationScreen extends StatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _index = ZefirNavigation.homeTab;

  static const _screens = [
    CompressionScreen(),
    SearchScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  void _goTo(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return ZefirNavigation(
      index: _index,
      goTo: _goTo,
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Recherche',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Favoris',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre supérieure M3 Expressive : 64dp, logo, menu, more_vert.
///
/// Le bouton menu ouvre une feuille listant les destinations principales
/// (dont l'historique, qui n'est pas un onglet de la barre de navigation).
class ZefirTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenu;
  final List<Widget>? extraActions;
  final bool showLogo;
  final bool scrollUnder;

  const ZefirTopBar({
    super.key,
    required this.title,
    this.onMenu,
    this.extraActions,
    this.showLogo = true,
    this.scrollUnder = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      titleSpacing: 8,
      backgroundColor:
          scrollUnder ? scheme.surfaceContainer : scheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        tooltip: 'Navigation',
        onPressed: onMenu ?? () => _showNavigationSheet(context),
      ),
      title: Row(
        children: [
          if (showLogo) ...[
            const ZefirLogo(size: 30),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      actions: [
        ...(extraActions ?? const []),
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Plus d’options',
          onPressed: () => showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (_) => const ZefirMoreSheet(),
          ),
        ),
      ],
    );
  }

  void _showNavigationSheet(BuildContext context) {
    final nav = ZefirNavigation.maybeOf(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Historique des compressions'),
              subtitle: const Text('Consulter, comparer et supprimer'),
              onTap: () {
                Navigator.pop(sheetContext);
                openHistory(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded),
              title: const Text('Recherche'),
              onTap: () {
                Navigator.pop(sheetContext);
                nav?.goTo(ZefirNavigation.searchTab);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_rounded),
              title: const Text('Favoris'),
              onTap: () {
                Navigator.pop(sheetContext);
                nav?.goTo(ZefirNavigation.favoritesTab);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(sheetContext);
                nav?.goTo(ZefirNavigation.settingsTab);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Feuille « plus d'options » partagée par les barres supérieures.
class ZefirMoreSheet extends StatelessWidget {
  const ZefirMoreSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: _iconBadge(context, Icons.history_rounded),
            title: const Text('Historique'),
            subtitle: const Text('Toutes les compressions enregistrées'),
            onTap: () {
              Navigator.pop(context);
              openHistory(context);
            },
          ),
          ListTile(
            leading: _iconBadge(context, Icons.insights_rounded),
            title: const Text('Statistiques'),
            subtitle: const Text('Espace total économisé'),
            onTap: () {
              Navigator.pop(context);
              showStatsSheet(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: _iconBadge(context, Icons.info_outline),
            title: const Text('À propos de Zefir'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion:
                    '${AppConstants.appVersion} (build ${AppConstants.buildNumber})',
                applicationIcon: const ZefirLogo(size: 44),
                applicationLegalese:
                    'Compression vidéo 100% locale • par ${AppConstants.creatorName}',
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Traitement entièrement hors-ligne propulsé par '
                    '${AppConstants.engineName}. Aucune vidéo ne quitte votre '
                    'appareil.',
                    style: TextStyle(
                        fontSize: 13, color: scheme.onSurfaceVariant),
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: _iconBadge(context, Icons.help_outline),
            title: const Text('Aide rapide'),
            subtitle: const Text('Choisir, ajuster, compresser'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (_) => const _HelpSheet(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(BuildContext context, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
    );
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    final steps = <(IconData, String, String)>[
      (
        Icons.video_file_outlined,
        '1. Choisir la source',
        'Touchez la carte d\'import ou le bouton flottant pour sélectionner une vidéo.'
      ),
      (
        Icons.tune_rounded,
        '2. Régler le profil',
        'Choisissez un profil d\'encodage, puis ajustez résolution, audio et '
            'format dans les Paramètres.'
      ),
      (
        Icons.bolt_rounded,
        '3. Lancer la compression',
        'Suivez la progression en direct. Vous pouvez interrompre à tout moment.'
      ),
      (
        Icons.play_circle_outline,
        '4. Vérifier le résultat',
        'Comparez la taille, lisez l\'aperçu, partagez ou marquez en favori.'
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comment ça marche',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...steps.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(s.$1),
                  title: Text(s.$2),
                  subtitle: Text(s.$3),
                )),
          ],
        ),
      ),
    );
  }
}

/// Ouvre l'historique complet (écran poussé par-dessus la navigation).
Future<void> openHistory(BuildContext context) async {
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const HistoryScreen()),
  );
}

/// Affiche la feuille de statistiques agrégées.
void showStatsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const StatsSheet(),
  );
}


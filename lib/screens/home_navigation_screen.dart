import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../services/favorites_service.dart';
import '../services/history_service.dart';
import '../services/thumbnail_service.dart';
import '../widgets/stats_sheet.dart';
import '../widgets/zefir_logo.dart';
import 'compression/compression_screen.dart';
import 'favorites/favorites_screen.dart';
import 'history/history_screen.dart';
import 'search/search_screen.dart';
import 'settings/settings_screen.dart';

/// Expose la navigation par onglets et le contrôle du drawer aux widgets descendants.
class ZefirNavigation extends InheritedWidget {
  final int index;
  final ValueChanged<int> goTo;
  final VoidCallback? openMenu;

  const ZefirNavigation({
    super.key,
    required this.index,
    required this.goTo,
    this.openMenu,
    required super.child,
  });

  static ZefirNavigation? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ZefirNavigation>();

  static const int homeTab = 0;
  static const int historyTab = 1;
  static const int searchTab = 2;
  static const int favoritesTab = 3;
  static const int settingsTab = 4;

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _screens = [
    CompressionScreen(),
    HistoryScreen(),
    SearchScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  void _goTo(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  void _openMenu() => _scaffoldKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    return ZefirNavigation(
      index: _index,
      goTo: _goTo,
      openMenu: _openMenu,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _SideNavigation(selectedIndex: _index, onSelect: _goTo),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final content = IndexedStack(index: _index, children: _screens);

            // Responsive : Mobile / Écran étroit (< 900px)
            if (constraints.maxWidth < 900) {
              return Column(
                children: [
                  Expanded(child: content),
                  _BottomPrimaryNavigation(
                    selectedIndex: _index,
                    onSelect: _goTo,
                  ),
                ],
              );
            }

            // Responsive : Desktop / Écran large (>= 900px)
            return Row(
              children: [
                _DesktopSidebar(selectedIndex: _index, onSelect: _goTo),
                const VerticalDivider(width: 1, thickness: 1, color: Color(0xFF243354)),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Barre de navigation inférieure M3 Expressive pour smartphone et tablette.
/// Reste toujours disponible en bas de l'écran, y compris sur la page Historique.
class _BottomPrimaryNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _BottomPrimaryNavigation({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      elevation: 3,
      backgroundColor: scheme.surface,
      indicatorColor: const Color(0xFFD6F25A),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.play_circle_outline),
          selectedIcon: Icon(Icons.play_circle_filled_rounded, color: Color(0xFF14213D)),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history_rounded, color: Color(0xFF14213D)),
          label: 'Historique',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search_rounded, color: Color(0xFF14213D)),
          label: 'Recherche',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border),
          selectedIcon: Icon(Icons.bookmark_rounded, color: Color(0xFF14213D)),
          label: 'Favoris',
        ),
        NavigationDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune_rounded, color: Color(0xFF14213D)),
          label: 'Paramètres',
        ),
      ],
    );
  }
}

/// Barre latérale fixe dédiée à la version Desktop / PC.
class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _DesktopSidebar({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final history = HistoryService();
    final favorites = FavoritesService();

    return Container(
      width: 270,
      color: const Color(0xFF14213D),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Branding Zefir
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  const ZefirLogo(size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Compression Vidéo Locale',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6F25A).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFD6F25A).withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'v1.2',
                      style: TextStyle(
                        color: Color(0xFFD6F25A),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Badge d'économies réalisées
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListenableBuilder(
                listenable: history,
                builder: (context, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2D4E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2C3E68)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6F25A).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.savings_rounded, color: Color(0xFFD6F25A), size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Formatters.formatBytes(history.totalSavedBytes),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${history.totalVideosCompressed} vidéo(s) optimisée(s)',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            const _SidebarSection(label: 'NAVIGATION PRINCIPALE'),

            // Entrées de navigation
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _DrawerEntry(
                    icon: Icons.play_circle_outline,
                    label: 'Accueil',
                    selected: selectedIndex == ZefirNavigation.homeTab,
                    onTap: () => onSelect(ZefirNavigation.homeTab),
                  ),
                  ListenableBuilder(
                    listenable: history,
                    builder: (context, _) => _DrawerEntry(
                      icon: Icons.history_rounded,
                      label: 'Historique',
                      badgeText: history.items.isNotEmpty ? '${history.items.length}' : null,
                      selected: selectedIndex == ZefirNavigation.historyTab,
                      onTap: () => onSelect(ZefirNavigation.historyTab),
                    ),
                  ),
                  _DrawerEntry(
                    icon: Icons.search_rounded,
                    label: 'Recherche',
                    selected: selectedIndex == ZefirNavigation.searchTab,
                    onTap: () => onSelect(ZefirNavigation.searchTab),
                  ),
                  ListenableBuilder(
                    listenable: favorites,
                    builder: (context, _) => _DrawerEntry(
                      icon: Icons.bookmark_border_rounded,
                      label: 'Favoris',
                      badgeText: favorites.ids.isNotEmpty ? '${favorites.ids.length}' : null,
                      selected: selectedIndex == ZefirNavigation.favoritesTab,
                      onTap: () => onSelect(ZefirNavigation.favoritesTab),
                    ),
                  ),
                  _DrawerEntry(
                    icon: Icons.tune_rounded,
                    label: 'Paramètres',
                    selected: selectedIndex == ZefirNavigation.settingsTab,
                    onTap: () => onSelect(ZefirNavigation.settingsTab),
                  ),

                  const SizedBox(height: 16),
                  const _SidebarSection(label: 'OUTILS & GESTION'),
                  _DrawerEntry(
                    icon: Icons.insights_rounded,
                    label: 'Statistiques complètes',
                    onTap: () => showStatsSheet(context),
                  ),
                  _DrawerEntry(
                    icon: Icons.cleaning_services_outlined,
                    label: 'Nettoyage du stockage',
                    onTap: () => _showStorageCleanerDialog(context),
                  ),
                  _DrawerEntry(
                    icon: Icons.lightbulb_outline_rounded,
                    label: 'Guide & Conseils',
                    onTap: () => _showHelpModal(context),
                  ),
                  _DrawerEntry(
                    icon: Icons.shield_outlined,
                    label: 'Moteur & Confidentialité',
                    onTap: () => _showPrivacyDialog(context),
                  ),
                ],
              ),
            ),

            // Pied de barre latérale
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF243354))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD6F25A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '100% Hors-ligne • Privé',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.white.withValues(alpha: 0.7), size: 18),
                    tooltip: 'À propos de Zefir',
                    onPressed: () => _showAboutZefir(context),
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

/// Menu latéral (Drawer) pour smartphone et tablette.
/// Contient l'intégralité des fonctionnalités qui ne sont pas dans la barre du bas :
/// statistiques détaillées, nettoyage du cache/stockage, guide d'encodage, sécurité et À propos.
class _SideNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _SideNavigation({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final history = HistoryService();
    final favorites = FavoritesService();

    return Drawer(
      backgroundColor: const Color(0xFF14213D),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête drawer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  const ZefirLogo(size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Compression locale & confidentielle',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Résumé d'économie
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListenableBuilder(
                listenable: history,
                builder: (context, _) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2D4E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.savings_outlined, color: Color(0xFFD6F25A), size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Économisé : ${Formatters.formatBytes(history.totalSavedBytes)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Divider(color: Color(0xFF243354)),
            const _SidebarSection(label: 'ACCÈS DIRECT'),

            _DrawerEntry(
              icon: Icons.play_circle_outline,
              label: 'Accueil',
              selected: selectedIndex == ZefirNavigation.homeTab,
              onTap: () {
                Navigator.pop(context);
                onSelect(ZefirNavigation.homeTab);
              },
            ),
            ListenableBuilder(
              listenable: history,
              builder: (context, _) => _DrawerEntry(
                icon: Icons.history_rounded,
                label: 'Historique des compressions',
                badgeText: history.items.isNotEmpty ? '${history.items.length}' : null,
                selected: selectedIndex == ZefirNavigation.historyTab,
                onTap: () {
                  Navigator.pop(context);
                  onSelect(ZefirNavigation.historyTab);
                },
              ),
            ),
            _DrawerEntry(
              icon: Icons.search_rounded,
              label: 'Recherche',
              selected: selectedIndex == ZefirNavigation.searchTab,
              onTap: () {
                Navigator.pop(context);
                onSelect(ZefirNavigation.searchTab);
              },
            ),
            ListenableBuilder(
              listenable: favorites,
              builder: (context, _) => _DrawerEntry(
                icon: Icons.bookmark_border_rounded,
                label: 'Favoris',
                badgeText: favorites.ids.isNotEmpty ? '${favorites.ids.length}' : null,
                selected: selectedIndex == ZefirNavigation.favoritesTab,
                onTap: () {
                  Navigator.pop(context);
                  onSelect(ZefirNavigation.favoritesTab);
                },
              ),
            ),
            _DrawerEntry(
              icon: Icons.tune_rounded,
              label: 'Paramètres',
              selected: selectedIndex == ZefirNavigation.settingsTab,
              onTap: () {
                Navigator.pop(context);
                onSelect(ZefirNavigation.settingsTab);
              },
            ),

            const SizedBox(height: 8),
            const Divider(color: Color(0xFF243354)),
            const _SidebarSection(label: 'OUTILS SUPPLÉMENTAIRES'),

            // TOUS LES ÉLÉMENTS QUI N'ÉTAIENT PAS DANS LA BARRE DU BAS
            _DrawerEntry(
              icon: Icons.insights_rounded,
              label: 'Statistiques d\'espace',
              onTap: () {
                Navigator.pop(context);
                showStatsSheet(context);
              },
            ),
            _DrawerEntry(
              icon: Icons.cleaning_services_outlined,
              label: 'Nettoyer le cache & stockage',
              onTap: () {
                Navigator.pop(context);
                _showStorageCleanerDialog(context);
              },
            ),
            _DrawerEntry(
              icon: Icons.lightbulb_outline_rounded,
              label: 'Guide & Astuces de compression',
              onTap: () {
                Navigator.pop(context);
                _showHelpModal(context);
              },
            ),
            _DrawerEntry(
              icon: Icons.shield_outlined,
              label: 'Moteur FFmpeg & Sécurité',
              onTap: () {
                Navigator.pop(context);
                _showPrivacyDialog(context);
              },
            ),
            _DrawerEntry(
              icon: Icons.info_outline,
              label: 'À propos de Zefir',
              onTap: () {
                Navigator.pop(context);
                _showAboutZefir(context);
              },
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Zefir v${AppConstants.appVersion} • Par ${AppConstants.creatorName}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String label;
  const _SidebarSection({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8FA1BD),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      );
}

class _DrawerEntry extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badgeText;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerEntry({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeText,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Material(
          color: selected ? const Color(0xFFD6F25A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected ? const Color(0xFF14213D) : Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected ? const Color(0xFF14213D) : Colors.white,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF14213D).withValues(alpha: 0.15)
                            : const Color(0xFFD6F25A).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText!,
                        style: TextStyle(
                          color: selected ? const Color(0xFF14213D) : const Color(0xFFD6F25A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

/// Barre supérieure unifiée Zefir : titre, logo, bouton menu hamburger
/// qui déclenche fidèlement le drawer latéral sur toutes les vues (y compris l'historique).
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
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return AppBar(
      titleSpacing: isDesktop ? 20 : 8,
      backgroundColor: scrollUnder ? scheme.surfaceContainer : scheme.surface,
      leading: isDesktop
          ? null
          : IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Menu latéral',
              onPressed: onMenu ??
                  () {
                    final nav = ZefirNavigation.maybeOf(context);
                    if (nav?.openMenu != null) {
                      nav!.openMenu!();
                    } else {
                      Scaffold.maybeOf(context)?.openDrawer();
                    }
                  },
            ),
      automaticallyImplyLeading: !isDesktop,
      title: Row(
        children: [
          if (showLogo) ...[
            const ZefirLogo(size: 30),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      actions: [
        ...(extraActions ?? const []),
        IconButton(
          icon: const Icon(Icons.insights_rounded),
          tooltip: 'Statistiques rapides',
          onPressed: () => showStatsSheet(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ------------------------------------------------------------- Modales & Dialogs

void _showAboutZefir(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  showAboutDialog(
    context: context,
    applicationName: AppConstants.appName,
    applicationVersion: '${AppConstants.appVersion} (build ${AppConstants.buildNumber})',
    applicationIcon: const ZefirLogo(size: 44),
    applicationLegalese: 'Compression vidéo 100% locale • Développé par ${AppConstants.creatorName}',
    children: [
      const SizedBox(height: 12),
      Text(
        'Zefir transforme vos vidéos lourdes en formats ultra-légers sans aucune '
        'perte visible de netteté. Aucun serveur, aucun cloud, tout s\'exécute '
        'directement sur votre appareil grâce à ${AppConstants.engineName}.',
        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
      ),
    ],
  );
}

Future<void> _showStorageCleanerDialog(BuildContext context) async {
  final cacheSize = await ThumbnailService.cacheSize();
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nettoyage du stockage'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Espace utilisé par les miniatures : ${Formatters.formatBytes(cacheSize)}'),
          const SizedBox(height: 12),
          const Text(
            'Vider le cache libère l\'espace temporaire sans affecter vos fichiers vidéo compressés.',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Fermer'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await ThumbnailService.clearCache();
            if (ctx.mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache des miniatures nettoyé avec succès.')),
              );
            }
          },
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Nettoyer le cache'),
        ),
      ],
    ),
  );
}

void _showHelpModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => const _HelpSheet(),
  );
}

void _showPrivacyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.shield_rounded, color: Color(0xFF14213D)),
          SizedBox(width: 8),
          Text('Sécurité & Moteur FFmpeg'),
        ],
      ),
      content: const Text(
        'Toutes les compressions vidéo sont réalisées localement sur votre processeur '
        'grâce à FFmpeg Kit. Aucune donnée, vidéo ou métadonnée ne transite par internet.\n\n'
        'Vos vidéos restent strictement privées et sécurisées sur votre machine.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Compris'),
        ),
      ],
    ),
  );
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    final steps = <(IconData, String, String)>[
      (
        Icons.video_file_outlined,
        '1. Sélection de la vidéo',
        'Choisissez votre vidéo source ou glissez-la depuis vos fichiers.'
      ),
      (
        Icons.tune_rounded,
        '2. Choix du profil d\'optimisation',
        'Sélectionnez Ultra (maxi gain), Équilibré (idéal au quotidien) ou Haute Qualité.'
      ),
      (
        Icons.bolt_rounded,
        '3. Compression locale ultra-rapide',
        'Suivez la progression, le FPS et l\'estimation en temps réel.'
      ),
      (
        Icons.share_outlined,
        '4. Partage & Visionnage immédiat',
        'Comparez la taille originale et compressée, puis partagez en 1 clic.'
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guide d\'utilisation Zefir', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...steps.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(s.$1, color: const Color(0xFF14213D)),
                  title: Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(s.$3),
                )),
          ],
        ),
      ),
    );
  }
}

/// Permet d'ouvrir l'écran d'historique en basculant simplement l'onglet si disponible,
/// garantissant la présence permanente de la barre inférieure et du menu latéral.
Future<void> openHistory(BuildContext context) async {
  final nav = ZefirNavigation.maybeOf(context);
  if (nav != null) {
    nav.goTo(ZefirNavigation.historyTab);
  } else {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }
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

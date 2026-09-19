import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/compression_result.dart';
import '../../services/favorites_service.dart';
import '../../services/history_service.dart';
import '../../services/preferences_service.dart';
import '../home_navigation_screen.dart';
import '../preview/video_player_screen.dart';
import 'history_detail_screen.dart';
import 'widgets/history_item_tile.dart';

/// Historique complet des compressions : recherche, tri, filtres, statistiques.
///
/// Écran poussé par-dessus la barre de navigation depuis l'accueil ou la
/// feuille du menu, d'où l'usage d'une [AppBar] standard retour.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  final FavoritesService _favoritesService = FavoritesService();
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _sort = AppConstants.defaultSort;
  bool _showThumbnails = true;

  /// `null` = aucun filtre de profil ; sinon libellé exact du profil.
  String? _presetFilter;

  /// N'afficher que les résultats marqués comme favoris.
  bool _onlyFavorites = false;

  @override
  void initState() {
    super.initState();
    if (!_historyService.isLoaded) {
      _historyService.loadHistory();
    }
    if (!_favoritesService.isLoaded) {
      _favoritesService.load();
    }
    _loadPreferredSort();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferredSort() async {
    final sort = await PreferencesService.getDefaultSort();
    final thumbs = await PreferencesService.getShowThumbnails();
    if (mounted) {
      setState(() {
        if (AppConstants.sortLabels.containsKey(sort)) _sort = sort;
        _showThumbnails = thumbs;
      });
    }
  }

  Future<void> _updateSort(String value) async {
    setState(() => _sort = value);
    await PreferencesService.setDefaultSort(value);
  }

  /// Profils réellement présents dans l'historique (alimente les filtres).
  List<String> get _availablePresets {
    final labels = <String>{};
    for (final item in _historyService.items) {
      labels.add(item.presetLabel);
    }
    final list = labels.toList()..sort();
    return list;
  }

  /// Liste affichée : recherche, filtre favoris, filtre profil, puis tri.
  List<CompressionResult> get _visibleItems {
    var items = _historyService.search(_query);
    if (_onlyFavorites) {
      items = items.where((e) => _favoritesService.isFavorite(e.id)).toList();
    }
    if (_presetFilter != null) {
      items = items.where((e) => e.presetLabel == _presetFilter).toList();
    }
    return HistoryService.sort(items, _sort);
  }

  bool get _hasActiveFilter => _onlyFavorites || _presetFilter != null;

  void _resetFilters() {
    setState(() {
      _query = '';
      _onlyFavorites = false;
      _presetFilter = null;
      _searchController.clear();
    });
  }

  /// Feuille de tri M3 : liste radio des critères disponibles.
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: RadioGroup<String>(
          groupValue: _sort,
          onChanged: (value) {
            Navigator.pop(context);
            if (value != null) _updateSort(value);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Trier par',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              ...AppConstants.sortLabels.entries.map(
                (entry) => RadioListTile<String>(
                  value: entry.key,
                  title: Text(entry.value),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- actions

  Future<void> _openDetail(CompressionResult item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryDetailScreen(result: item)),
    );
  }

  /// Lecture du fichier compressé dans le lecteur intégré.
  Future<void> _playFile(CompressionResult item) async {
    final file = File(item.compressedPath);
    if (!await file.exists()) {
      _showSnackbar('Fichier compressé introuvable sur le disque local.');
      return;
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          path: item.compressedPath,
          title: item.fileName,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(CompressionResult item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce résultat ?'),
        content: Text(
          '« ${item.fileName} » sera retiré de l\'historique et son fichier '
          'compressé effacé du stockage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.deleteRecord(item.id);
      await _favoritesService.removeAll([item.id]);
      if (!mounted) return;
      _showSnackbar('« ${item.fileName} » supprimé.');
    }
  }

  Future<void> _confirmClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Tout effacer ?'),
        content: const Text(
          'Tout l\'historique sera vidé et les fichiers compressés seront '
          'supprimés. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ids = _historyService.items.map((e) => e.id).toList();
      await _historyService.clearAll();
      await _favoritesService.removeAll(ids);
      if (!mounted) return;
      _resetFilters();
      _showSnackbar('Historique purgé.');
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZefirTopBar(
        title: 'Historique',
        showLogo: false,
        extraActions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            tooltip: 'Statistiques',
            onPressed: () => showStatsSheet(context),
          ),
          ListenableBuilder(
            listenable: _historyService,
            builder: (context, _) {
              if (_historyService.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
                tooltip: 'Tout effacer',
                onPressed: _confirmClearAll,
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          _historyService,
          _favoritesService,
        ]),
        builder: (context, _) {
          if (_historyService.items.isEmpty) {
            return _EmptyHistory(onPick: () => Navigator.maybePop(context));
          }
          return Column(
            children: [
              _buildOverview(context),
              _buildSearchField(context),
              _buildSortRow(context),
              Expanded(child: _buildList(context)),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------- composants

  /// Bandeau de synthèse : économies cumulées + accès aux statistiques.
  Widget _buildOverview(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Total Économisé',
                    value: Formatters.formatBytes(_historyService.totalSavedBytes),
                    subtitle: 'Gain d\'espace disque',
                    icon: Icons.savings_rounded,
                    accentColor: const Color(0xFFD6F25A),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Vidéos Traitées',
                    value: '${_historyService.totalVideosCompressed}',
                    subtitle: 'Fichiers convertis',
                    icon: Icons.video_library_rounded,
                    accentColor: const Color(0xFF14213D),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Réduction Moyenne',
                    value: '${_historyService.averageReduction.toStringAsFixed(1)}%',
                    subtitle: 'Taux de compression global',
                    icon: Icons.trending_down_rounded,
                    accentColor: const Color(0xFFF26B4B),
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.savings_rounded,
                    size: 20, color: scheme.onPrimaryContainer),
              ),
              title: Text(
                Formatters.formatBytes(_historyService.totalSavedBytes),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'économisés sur ${_historyService.totalVideosCompressed} vidéo(s)',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.insights_rounded),
                tooltip: 'Statistiques détaillées',
                onPressed: () => showStatsSheet(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor == const Color(0xFF14213D)
                    ? const Color(0xFF14213D).withValues(alpha: 0.1)
                    : accentColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: accentColor == const Color(0xFFD6F25A) ? const Color(0xFF14213D) : accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Champ de recherche M3 (pilule, surfaceContainerHigh).
  Widget _buildSearchField(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Rechercher un fichier, un profil…',
        constraints: const BoxConstraints(minHeight: 52),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
        ),
        trailing: [
          if (_query.isNotEmpty || _hasActiveFilter)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              tooltip: 'Effacer la recherche',
              onPressed: _resetFilters,
            ),
        ],
        onChanged: (value) => setState(() => _query = value),
      ),
    );
  }

  /// Rangée de chips de filtrage : tri, favoris, profils présents.
  Widget _buildSortRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ActionChip(
            avatar: Icon(Icons.sort_rounded,
                size: 18, color: scheme.onSurfaceVariant),
            label: Text(AppConstants.sortLabels[_sort] ?? 'Trier'),
            onPressed: _showSortSheet,
          ),
          const SizedBox(width: 8),
          FilterChip(
            avatar: Icon(
              _onlyFavorites ? Icons.favorite_rounded : Icons.favorite_outline,
              size: 18,
              color: _onlyFavorites ? scheme.error : scheme.onSurfaceVariant,
            ),
            label: const Text('Favoris'),
            selected: _onlyFavorites,
            onSelected: (value) => setState(() => _onlyFavorites = value),
          ),
          for (final preset in _availablePresets) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(preset),
              selected: _presetFilter == preset,
              onSelected: (value) =>
                  setState(() => _presetFilter = value ? preset : null),
            ),
          ],
        ],
      ),
    );
  }

  /// Liste des résultats filtrés + triés, tuiles M3 Expressive ou Grille sur PC.
  Widget _buildList(BuildContext context) {
    final items = _visibleItems;
    if (items.isEmpty) {
      return _NoResults(onReset: _resetFilters);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          final crossAxisCount = constraints.maxWidth >= 1300 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 12,
              mainAxisExtent: 130,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return HistoryItemTile(
                item: item,
                showThumbnail: _showThumbnails,
                isFavorite: _favoritesService.isFavorite(item.id),
                onOpen: () => _openDetail(item),
                onPlay: () => _playFile(item),
                onShare: () => _shareFile(item),
                onDelete: () => _confirmDelete(item),
                onToggleFavorite: () => _toggleFavorite(item),
              );
            },
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return HistoryItemTile(
              item: item,
              showThumbnail: _showThumbnails,
              isFavorite: _favoritesService.isFavorite(item.id),
              onOpen: () => _openDetail(item),
              onPlay: () => _playFile(item),
              onShare: () => _shareFile(item),
              onDelete: () => _confirmDelete(item),
              onToggleFavorite: () => _toggleFavorite(item),
            );
          },
        );
      },
    );
  }

  Future<void> _shareFile(CompressionResult item) async {
    final file = File(item.compressedPath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(item.compressedPath)],
        text: 'Vidéo : ${item.fileName}',
      );
    } else {
      _showSnackbar('Fichier introuvable pour le partage.');
    }
  }

  Future<void> _toggleFavorite(CompressionResult item) async {
    await _favoritesService.toggle(item.id);
    if (!mounted) return;
    _showSnackbar(
      _favoritesService.isFavorite(item.id)
          ? 'Ajouté aux favoris.'
          : 'Retiré des favoris.',
    );
  }
}

/// État vide : aucun enregistrement dans l'historique.
class _EmptyHistory extends StatelessWidget {
  final VoidCallback onPick;

  const _EmptyHistory({required this.onPick});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_rounded,
                  size: 40, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text('Historique vide',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Compressez votre première vidéo : elle apparaîtra ici avec '
              'ses statistiques d\'économie d\'espace.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.compress_rounded),
              label: const Text('Compresser une vidéo'),
            ),
          ],
        ),
      ),
    );
  }
}

/// État vide : la recherche / les filtres ne renvoient rien.
class _NoResults extends StatelessWidget {
  final VoidCallback onReset;

  const _NoResults({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Aucun résultat',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Aucune vidéo ne correspond à votre recherche ou aux filtres '
              'actifs.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              label: const Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/compression_result.dart';
import '../../services/favorites_service.dart';
import '../../services/history_service.dart';
import '../../services/preferences_service.dart';
import '../../widgets/stats_sheet.dart';
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
    if (mounted && AppConstants.sortLabels.containsKey(sort)) {
      setState(() => _sort = sort);
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
                icon: Icon(Icons.delete_sweep_outlined,
                    color: Theme.of(context).colorScheme.error),
                tooltip: 'Tout effacer',
                onPressed: _confirmClearAll,
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_historyService, _favoritesService]),
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

      ),
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
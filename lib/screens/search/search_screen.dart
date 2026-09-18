import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../models/compression_result.dart';
import '../../services/favorites_service.dart';
import '../../services/history_service.dart';
import '../../services/preferences_service.dart';
import '../history/history_actions.dart';
import '../history/widgets/history_item_tile.dart';
import '../home_navigation_screen.dart';

/// Écran Recherche : filtre l'historique par nom / profil, tri multiple,
/// filtre « favoris uniquement », miniatures et lecture intégrée.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final HistoryService _history = HistoryService();
  final FavoritesService _favorites = FavoritesService();

  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String _sort = AppConstants.defaultSort;
  bool _favoritesOnly = false;
  bool _showThumbnails = true;

  @override
  void initState() {
    super.initState();
    _history.loadHistory();
    _favorites.load();
    _loadPreferences();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final sort = await PreferencesService.getDefaultSort();
    final thumbs = await PreferencesService.getShowThumbnails();
    if (!mounted) return;
    setState(() {
      if (AppConstants.sortLabels.containsKey(sort)) _sort = sort;
      _showThumbnails = thumbs;
    });
  }

  void _showSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<String>(
          groupValue: _sort,
          onChanged: (value) {
            if (value != null) setState(() => _sort = value);
            Navigator.of(sheetContext).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text('Trier par',
                    style: Theme.of(sheetContext).textTheme.titleMedium),
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

  List<CompressionResult> _filtered() {
    final q = _query.trim().toLowerCase();
    Iterable<CompressionResult> items = _history.items;
    if (q.isNotEmpty) {
      items = items.where((e) =>
          e.fileName.toLowerCase().contains(q) ||
          e.presetLabel.toLowerCase().contains(q));
    }
    if (_favoritesOnly) {
      items = items.where((e) => _favorites.isFavorite(e.id));
    }
    return HistoryService.sort(items.toList(), _sort);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const ZefirTopBar(title: 'Recherche'),
      body: ListenableBuilder(
        listenable: Listenable.merge([_history, _favorites]),
        builder: (context, _) {
          final items = _filtered();
          final bool hasQuery = _query.trim().isNotEmpty || _favoritesOnly;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBar(
                  controller: _controller,
                  hintText: 'Rechercher une vidéo, un profil…',
                  leading: Icon(Icons.search_rounded,
                      color: scheme.onSurfaceVariant),
                  trailing: _query.isEmpty
                      ? null
                      : [
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            tooltip: 'Effacer',
                            onPressed: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                          ),
                        ],
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),


              // Filtres : tri + favoris uniquement.
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ActionChip(
                      avatar: Icon(Icons.sort_rounded,
                          size: 18, color: scheme.primary),
                      label: Text(AppConstants.sortLabels[_sort] ?? 'Trier'),
                      onPressed: _showSortSheet,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: Icon(
                        _favoritesOnly
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline,
                        size: 18,
                        color: _favoritesOnly
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                      label: const Text('Favoris'),
                      selected: _favoritesOnly,
                      onSelected: (v) => setState(() => _favoritesOnly = v),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: items.isEmpty
                    ? _EmptySearch(
                        hasQuery: hasQuery,
                        onClear: () {
                          _controller.clear();
                          setState(() {
                            _query = '';
                            _favoritesOnly = false;
                          });
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return HistoryItemTile(
                            item: item,
                            isFavorite: _favorites.isFavorite(item.id),
                            showThumbnail: _showThumbnails,
                            onOpen: () => HistoryActions.open(context, item),
                            onPlay: () => HistoryActions.play(context, item),
                            onShare: () => HistoryActions.share(context, item),
                            onDelete: () =>
                                HistoryActions.confirmDelete(context, item),
                            onToggleFavorite: () =>
                                HistoryActions.toggleFavorite(context, item),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final bool hasQuery;
  final VoidCallback onClear;

  const _EmptySearch({required this.hasQuery, required this.onClear});

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
              child: Icon(Icons.search_off_rounded,
                  size: 40, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text(hasQuery ? 'Aucun résultat' : 'Historique vide',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Essayez un autre mot-clé ou retirez le filtre favoris.'
                  : 'Compressez une première vidéo pour pouvoir la rechercher ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (hasQuery) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Réinitialiser les filtres'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

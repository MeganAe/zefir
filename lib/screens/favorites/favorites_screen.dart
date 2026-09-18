import 'package:flutter/material.dart';

import '../../models/compression_result.dart';
import '../../services/favorites_service.dart';
import '../../services/history_service.dart';
import '../../services/preferences_service.dart';
import '../history/history_actions.dart';
import '../history/widgets/history_item_tile.dart';
import '../home_navigation_screen.dart';

/// Écran Favoris : résultats marqués d'un cœur, avec miniatures et lecture.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final HistoryService _history = HistoryService();
  final FavoritesService _favorites = FavoritesService();
  bool _showThumbnails = true;

  @override
  void initState() {
    super.initState();
    _history.loadHistory();
    _favorites.load();
    _loadThumbnailPreference();
  }

  Future<void> _loadThumbnailPreference() async {
    final thumbs = await PreferencesService.getShowThumbnails();
    if (mounted) setState(() => _showThumbnails = thumbs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ZefirTopBar(title: 'Favoris'),
      body: ListenableBuilder(
        listenable: Listenable.merge([_history, _favorites]),
        builder: (context, _) {
          final items = _history.items
              .where((e) => _favorites.isFavorite(e.id))
              .toList();
          if (items.isEmpty) {
            return const _EmptyFavorites();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final CompressionResult item = items[i];
              return HistoryItemTile(
                item: item,
                isFavorite: true,
                showThumbnail: _showThumbnails,
                onOpen: () => HistoryActions.open(context, item),
                onPlay: () => HistoryActions.play(context, item),
                onShare: () => HistoryActions.share(context, item),
                onDelete: () => HistoryActions.confirmDelete(context, item),
                onToggleFavorite: () =>
                    HistoryActions.toggleFavorite(context, item),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

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
              child: Icon(Icons.favorite_outline,
                  size: 40, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text('Aucun favori',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Touchez le cœur d\'un résultat de l\'historique pour le '
              'retrouver ici, miniature et lecture incluses.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

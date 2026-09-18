import 'package:flutter/material.dart';
import '../../models/compression_result.dart';
import '../../services/favorites_service.dart';
import '../../services/history_service.dart';
import '../history/history_detail_screen.dart';
import '../home_navigation_screen.dart';

/// Ecran Favoris : resultats marques d'une etoile.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _history = HistoryService();
  final _favorites = FavoritesService();

  @override
  void initState() {
    super.initState();
    _favorites.load();
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text('Aucun favori',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Touchez l’etoile pour retrouver un resultat ici.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final CompressionResult item = items[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.movie_outlined,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer),
                  ),
                  title: Text(item.fileName,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(item.presetLabel),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _favorites.toggle(item.id),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => HistoryDetailScreen(result: item)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

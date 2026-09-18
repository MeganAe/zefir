import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../models/compression_result.dart';
import '../../services/history_service.dart';
import '../history/history_detail_screen.dart';
import '../home_navigation_screen.dart';

/// Ecran Recherche : filtre l'historique en local.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _history = HistoryService();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ZefirTopBar(title: 'Recherche'),
      body: ListenableBuilder(
        listenable: _history,
        builder: (context, _) {
          final q = _query.trim().toLowerCase();
          final List<CompressionResult> items = q.isEmpty
              ? _history.items
              : _history.items
                  .where((e) =>
                      e.fileName.toLowerCase().contains(q) ||
                      e.presetLabel.toLowerCase().contains(q))
                  .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBar(
                  hintText: 'Rechercher une video, un profil',
                  leading: const Icon(Icons.search),
                  trailing: _query.isEmpty
                      ? null
                      : [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _query = ''),
                          )
                        ],
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          q.isEmpty
                              ? 'Aucune compression pour le moment.'
                              : 'Aucun resultat.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Icon(Icons.movie_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                              ),
                              title: Text(item.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                  '${Formatters.formatBytes(item.compressedSizeBytes)} • ${item.presetLabel}'),
                              trailing:
                                  const Icon(Icons.chevron_right_rounded),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        HistoryDetailScreen(result: item)),
                              ),
                            ),
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

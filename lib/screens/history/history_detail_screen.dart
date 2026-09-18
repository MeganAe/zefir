import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/formatters.dart';
import '../../models/compression_result.dart';
import '../../services/favorites_service.dart';
import '../../services/history_service.dart';

class HistoryDetailScreen extends StatelessWidget {
  final CompressionResult result;
  const HistoryDetailScreen({super.key, required this.result});

  Future<void> _open(BuildContext context) async {
    await OpenFilex.open(result.compressedPath);
  }

  Future<void> _share(BuildContext context) async {
    await Share.shareXFiles([XFile(result.compressedPath)],
        text: 'Video : ${result.fileName}');
  }

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Supprimer "${result.fileName}" et son fichier ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      await HistoryService().deleteRecord(result.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(result.fileName,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          ListenableBuilder(
            listenable: FavoritesService(),
            builder: (context, _) {
              final fav = FavoritesService().isFavorite(result.id);
              return IconButton(
                icon: Icon(fav ? Icons.favorite : Icons.favorite_outline,
                    color: fav ? scheme.error : null),
                onPressed: () => FavoritesService().toggle(result.id),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Apercu',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    result.fileName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bilan avant / apres',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _Metric(
                            label: 'Original',
                            value: Formatters.formatBytes(
                                result.originalSizeBytes))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _Metric(
                            label: 'Compresse',
                            value: Formatters.formatBytes(
                                result.compressedSizeBytes))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: _Metric(
                            label: 'Economise',
                            value: Formatters.formatSavedBytes(
                                result.originalSizeBytes,
                                result.compressedSizeBytes))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _Metric(
                            label: 'Reduction',
                            value: Formatters.formatReduction(
                                result.originalSizeBytes,
                                result.compressedSizeBytes))),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    'Profil : ${result.presetLabel} • ${result.executionTimeSeconds}s',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: FilledButton(
                onPressed: () => _open(context),
                child: const Text('Lire'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _share(context),
                child: const Text('Partager'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}


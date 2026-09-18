import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/compression_result.dart';

class HistoryItemTile extends StatelessWidget {
  final CompressionResult item;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const HistoryItemTile({
    super.key,
    required this.item,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(item.createdAt);
    final reductionPct = Formatters.formatReduction(item.originalSizeBytes, item.compressedSizeBytes);
    final savedBytes = Formatters.formatSavedBytes(item.originalSizeBytes, item.compressedSizeBytes);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.movie_outlined,
                color: Theme.of(context).colorScheme.primary),
            title: Text(item.fileName,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(formattedDate),
            trailing: Chip(label: Text(reductionPct)),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${Formatters.formatBytes(item.originalSizeBytes)} -> ${Formatters.formatBytes(item.compressedSizeBytes)}'),
                const SizedBox(height: 4),
                Text(
                    'Economie : $savedBytes • ${item.presetLabel} • ${item.executionTimeSeconds}s',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onOpen,
                        child: const Text('Lire'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onShare,
                        child: const Text('Partager'),
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

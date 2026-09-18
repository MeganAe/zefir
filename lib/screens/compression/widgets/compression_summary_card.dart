import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/compression_result.dart';

class CompressionSummaryCard extends StatelessWidget {
  final CompressionResult result;
  final VoidCallback onOpenVideo;
  final VoidCallback onShareVideo;
  final VoidCallback onReset;

  const CompressionSummaryCard({
    super.key,
    required this.result,
    required this.onOpenVideo,
    required this.onShareVideo,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final savingsStr = Formatters.formatSavedBytes(result.originalSizeBytes, result.compressedSizeBytes);
    final reductionPct = Formatters.formatReduction(result.originalSizeBytes, result.compressedSizeBytes);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.check_circle,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Compression terminee'),
            subtitle: Text('${result.executionTimeSeconds}s'),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                    '${Formatters.formatBytes(result.originalSizeBytes)} -> ${Formatters.formatBytes(result.compressedSizeBytes)}'),
                const SizedBox(height: 8),
                Text('$savingsStr economises ($reductionPct)'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onOpenVideo,
                        child: const Text('Lire'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: onShareVideo,
                        child: const Text('Partager'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onReset,
                    child: const Text('Compresser une autre video'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

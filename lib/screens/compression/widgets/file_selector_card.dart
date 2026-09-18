import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/video_item.dart';

class FileSelectorCard extends StatelessWidget {
  final VideoItem? video;
  final bool isAnalyzing;
  final VoidCallback onPickVideo;
  final VoidCallback onClear;

  const FileSelectorCard({
    super.key,
    required this.video,
    required this.isAnalyzing,
    required this.onPickVideo,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (isAnalyzing) {
      return const Card(
        child: SizedBox(
          height: 140,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (video == null) {
      return Card(
        child: InkWell(
          onTap: onPickVideo,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.video_library_outlined,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 18),
                const Text('Selectionner un fichier video'),
                const SizedBox(height: 6),
                Text('MP4, MOV, MKV, WebM, AVI',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      );
    }

    // Video details when loaded
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.insert_drive_file_outlined,
                color: Theme.of(context).colorScheme.primary),
            title: Text(video!.name,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              tooltip: 'Retirer',
            ),
          ),

          // Metadata Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildMetaCell(
                      context: context,
                      label: 'Taille',
                      value: Formatters.formatBytes(video!.sizeBytes),
                      icon: Icons.data_usage_outlined,
                    ),
                    const SizedBox(width: 12),
                    _buildMetaCell(
                      context: context,
                      label: 'Duree',
                      value: video!.duration != null
                          ? Formatters.formatDuration(video!.duration!)
                          : 'N/A',
                      icon: Icons.timer_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMetaCell(
                      context: context,
                      label: 'Resolution',
                      value: video!.resolutionText,
                      icon: Icons.aspect_ratio_outlined,
                    ),
                    const SizedBox(width: 12),
                    _buildMetaCell(
                      context: context,
                      label: 'Frequence',
                      value: video!.frameRate != null
                          ? '${video!.frameRate!.toStringAsFixed(1)} ips'
                          : 'N/A',
                      icon: Icons.speed_outlined,
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

  Widget _buildMetaCell({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
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

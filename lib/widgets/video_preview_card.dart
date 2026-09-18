import 'dart:io';

import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../models/video_item.dart';
import '../screens/preview/video_player_screen.dart';
import 'video_thumbnail.dart';

/// Aperçu source : miniature (FFmpeg + cache), métadonnées et lecture intégrée.
class VideoPreviewCard extends StatelessWidget {
  final VideoItem? video;
  final String? directPath;
  final String title;

  const VideoPreviewCard({
    super.key,
    this.video,
    this.directPath,
    this.title = 'Aperçu',
  });

  void _play(BuildContext context, String path, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(path: path, title: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final path = directPath ?? video?.path;

    if (path == null || path.isEmpty) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.movie_outlined, color: scheme.onSurfaceVariant),
          title: Text(title),
          subtitle: const Text('Aucune vidéo sélectionnée'),
        ),
      );
    }

    final name = video?.name ??
        path.split(Platform.pathSeparator).last;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            VideoThumbnail(
              path: path,
              width: 84,
              height: 64,
              borderRadius: 14,
              onPlay: () => _play(context, path, name),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          letterSpacing: 0.4,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (video?.sizeBytes != null)
                        _chip(
                          scheme,
                          Icons.data_usage_rounded,
                          Formatters.formatBytes(video!.sizeBytes),
                        ),
                      if (video?.duration != null)
                        _chip(
                          scheme,
                          Icons.schedule_rounded,
                          Formatters.formatDuration(video!.duration!),
                        ),
                      if (video?.resolutionText != null &&
                          video!.resolutionText != 'N/A')
                        _chip(
                          scheme,
                          Icons.aspect_ratio_rounded,
                          video!.resolutionText,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            IconButton.filledTonal(
              tooltip: 'Lire la vidéo',
              onPressed: () => _play(context, path, name),
              icon: const Icon(Icons.play_arrow_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(ColorScheme scheme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}


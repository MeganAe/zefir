import 'dart:io';
import 'package:flutter/material.dart';
import '../core/utils/formatters.dart';
import '../models/video_item.dart';

/// Apercu source simple (metadonnees) — sans lecteur embarque.
class VideoPreviewCard extends StatelessWidget {
  final VideoItem? video;
  final String? directPath;
  final String title;

  const VideoPreviewCard({
    super.key,
    this.video,
    this.directPath,
    this.title = 'Apercu',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final path = directPath ?? video?.path;
    final name = video?.name ??
        (path == null || path.isEmpty
            ? 'Aucune video'
            : path.split(Platform.pathSeparator).last);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.movie_outlined,
              color: scheme.onPrimaryContainer),
        ),
        title: Text(title),
        subtitle: Text(
          video == null
              ? name
              : '$name • ${Formatters.formatBytes(video!.sizeBytes)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}


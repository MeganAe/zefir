import 'dart:io';

import 'package:flutter/material.dart';

import '../services/thumbnail_service.dart';

/// Miniature vidéo avec génération paresseuse (FFmpeg) et cache disque.
///
/// Affiche un fond `surfaceContainerHigh` tant que l'image n'est pas prête,
/// puis l'image extraite accompagnée d'un bouton lecture superposé.
class VideoThumbnail extends StatefulWidget {
  final String path;
  final double width;
  final double height;
  final double borderRadius;
  final bool showPlayBadge;
  final VoidCallback? onPlay;

  const VideoThumbnail({
    super.key,
    required this.path,
    this.width = 76,
    this.height = 56,
    this.borderRadius = 12,
    this.showPlayBadge = true,
    this.onPlay,
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  File? _thumb;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant VideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _thumb = null;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    if (mounted) setState(() => _loading = true);
    final file = await ThumbnailService.generate(widget.path);
    if (!mounted) return;
    setState(() {
      _thumb = file;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget content;
    if (_thumb != null) {
      content = Image.file(
        _thumb!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _placeholder(scheme),
      );
    } else if (_loading) {
      content = Container(
        width: widget.width,
        height: widget.height,
        color: scheme.surfaceContainerHigh,
        alignment: Alignment.center,
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      content = _placeholder(scheme);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          content,
          if (widget.showPlayBadge)
            Material(
              color: scheme.inverseSurface.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onPlay,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 18,
                    color: scheme.onInverseSurface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: scheme.surfaceContainerHigh,
      alignment: Alignment.center,
      child: Icon(
        Icons.movie_outlined,
        size: widget.height * 0.45,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
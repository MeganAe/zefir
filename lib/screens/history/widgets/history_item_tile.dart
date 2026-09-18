import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formatters.dart';
import '../../../models/compression_result.dart';
import '../../../widgets/press_scale.dart';
import '../../../widgets/video_thumbnail.dart';

/// Tuile d'un résultat de compression, en design M3 Expressive.
///
/// Partagée par l'historique, les favoris et la recherche afin de garantir un
/// rendu strictement identique dans toute l'application : miniature, badge de
/// réduction, actions rapides et chevron d'ouverture.
class HistoryItemTile extends StatelessWidget {
  final CompressionResult item;
  final VoidCallback onOpen;
  final VoidCallback onPlay;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final bool showThumbnail;

  const HistoryItemTile({
    super.key,
    required this.item,
    required this.onOpen,
    required this.onPlay,
    required this.onShare,
    required this.onDelete,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.showThumbnail = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(item.createdAt);
    final reductionStr = Formatters.formatReduction(
        item.originalSizeBytes, item.compressedSizeBytes);
    final savedBytes = Formatters.formatSavedBytes(
        item.originalSizeBytes, item.compressedSizeBytes);
    final reductionRatio = item.originalSizeBytes > 0
        ? (item.savedBytes / item.originalSizeBytes).clamp(0.0, 1.0)
        : 0.0;

    return PressScale(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Ligne principale : miniature, titres, badge de réduction ----
              Row(
                children: [
                  showThumbnail
                      ? VideoThumbnail(
                          path: item.compressedPath,
                          width: 64,
                          height: 64,
                          borderRadius: 16,
                          onPlay: onPlay,
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.movie_outlined,
                              size: 20, color: scheme.onPrimaryContainer),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$formattedDate • $savedBytes gagnés',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reductionStr,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onTertiaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ---- Jauge de réduction (progression relative) ----
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: reductionRatio,
                    minHeight: 5,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // ---- Bandeau technique + actions rapides ----
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${Formatters.formatBytes(item.originalSizeBytes)} → '
                        '${Formatters.formatBytes(item.compressedSizeBytes)}'
                        ' • ${item.presetLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Lire',
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Partager',
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined, size: 20),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_outline,
                      size: 20,
                      color: isFavorite ? scheme.error : scheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Supprimer',
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline,
                        size: 20, color: scheme.error),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

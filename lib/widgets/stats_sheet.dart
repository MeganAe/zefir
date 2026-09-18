import 'package:flutter/material.dart';

import '../core/utils/formatters.dart';
import '../services/history_service.dart';

/// Feuille de statistiques agrégées : volumes, économies, répartition.
class StatsSheet extends StatelessWidget {
  const StatsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: HistoryService(),
      builder: (context, _) {
        final history = HistoryService();
        if (history.items.isEmpty) return const _EmptyStats();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Statistiques',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'Cumul de toutes vos compressions locales.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                _KpiCard(
                  icon: Icons.savings_rounded,
                  label: 'Espace économisé',
                  value: Formatters.formatBytes(history.totalSavedBytes),
                  highlight: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _KpiTile(
                      icon: Icons.movie_rounded,
                      label: 'Vidéos',
                      value: '${history.totalVideosCompressed}',
                    ),
                    const SizedBox(width: 12),
                    _KpiTile(
                      icon: Icons.compress_rounded,
                      label: 'Réduction moyenne',
                      value:
                          '${history.averageReduction.toStringAsFixed(1)} %',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _KpiTile(
                      icon: Icons.input_rounded,
                      label: 'Total source',
                      value:
                          Formatters.formatBytes(history.totalOriginalBytes),
                    ),
                    const SizedBox(width: 12),
                    _KpiTile(
                      icon: Icons.output_rounded,
                      label: 'Total compressé',
                      value:
                          Formatters.formatBytes(history.totalCompressedBytes),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SavingsBar(history: history),
                const SizedBox(height: 24),
                _BiggestSaving(history: history),
              ],
            ),
          ),
        );
      },
    );
  }
}
/// Grand indicateur (pleine largeur) : chiffre mis en avant.
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlight ? scheme.primaryContainer : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: highlight ? scheme.primary : scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: highlight ? scheme.onPrimary : scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: highlight
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: highlight ? scheme.onPrimaryContainer : null,
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

/// Indicateur compact (demi-largeur) dans une rangée.
class _KpiTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _KpiTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre comparative source → compressé avec légende et pourcentage.
class _SavingsBar extends StatelessWidget {
  final HistoryService history;

  const _SavingsBar({required this.history});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final original = history.totalOriginalBytes;
    final compressed = history.totalCompressedBytes;
    final total = original + compressed;

    // Part compressée : portion utile, comparée au volume source.
    final compressedRatio = total > 0 ? compressed / total : 0.0;
    final savedRatio = total > 0 ? history.totalSavedBytes / original : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Répartition des volumes',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: ((1 - compressedRatio) * 1000).round().clamp(1, 1000),
                  child: Container(height: 16, color: scheme.primary),
                ),
                Expanded(
                  flex: (compressedRatio * 1000).round().clamp(1, 1000),
                  child: Container(
                      height: 16, color: scheme.surfaceContainerHighest),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _legendDot(scheme.primary, 'Source', original),
              const SizedBox(width: 16),
              _legendDot(
                  scheme.surfaceContainerHighest, 'Compressé', compressed),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Réduction globale de ${(savedRatio * 100).clamp(0, 100).toStringAsFixed(1)} % '
            'sur ${history.totalVideosCompressed} fichier(s).',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label, int bytes) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label · ${Formatters.formatBytes(bytes)}',
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Met en avant la compression la plus rentable de l'historique.
class _BiggestSaving extends StatelessWidget {
  final HistoryService history;

  const _BiggestSaving({required this.history});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = history.items;
    if (items.isEmpty) return const SizedBox.shrink();

    var best = items.first;
    for (final item in items) {
      if (item.savedBytes > best.savedBytes) best = item;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded,
              size: 28, color: scheme.onTertiaryContainer),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meilleur gain',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onTertiaryContainer,
                        )),
                const SizedBox(height: 2),
                Text(
                  Formatters.formatSavedBytes(
                    best.originalSizeBytes,
                    best.compressedSizeBytes,
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.onTertiaryContainer,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  best.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onTertiaryContainer.withValues(alpha: 0.8),
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

/// État vide : aucune compression enregistrée.
class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.insights_rounded,
                  size: 30, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text('Aucune statistique',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Compressez une première vidéo : volumes, économies et '
              'réduction moyenne s\'afficheront ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

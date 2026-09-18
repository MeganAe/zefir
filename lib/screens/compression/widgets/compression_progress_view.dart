import 'package:flutter/material.dart';
import '../../../services/ffmpeg_service.dart';

class CompressionProgressView extends StatelessWidget {
  final CompressionProgress progress;
  final VoidCallback onCancel;

  const CompressionProgressView({
    super.key,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (progress.percentage * 100).clamp(0, 100).toDouble();
    final percentInt = percent.toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bolt_rounded,
                      size: 22, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Compression en cours',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        progress.stage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('$percentInt%',
                    style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),

            const SizedBox(height: 18),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.percentage > 0 ? percent / 100 : null,
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 18),

            // Technical telemetry
            Row(
              children: [
                _buildTelemetryItem(
                  context: context,
                  label: 'Cadence',
                  value: progress.fps > 0
                      ? '${progress.fps.toStringAsFixed(0)} ips'
                      : '--',
                ),
                const SizedBox(width: 8),
                _buildTelemetryItem(
                  context: context,
                  label: 'Débit',
                  value: progress.bitrate > 0
                      ? '${(progress.bitrate / 1000).toStringAsFixed(0)} kbps'
                      : '--',
                ),
                const SizedBox(width: 8),
                _buildTelemetryItem(
                  context: context,
                  label: 'Temps',
                  value: '${(progress.timeMs / 1000).toStringAsFixed(1)}s',
                ),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.stop_circle_outlined, size: 20),
                label: const Text('Interrompre'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryItem(
      {required BuildContext context,
      required String label,
      required String value}) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

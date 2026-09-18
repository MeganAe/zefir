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
    final percentInt = (progress.percentage * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(progress.stage)),
                Text('$percentInt%'),
              ],
            ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress.percentage > 0 ? progress.percentage : null,
            minHeight: 6,
          ),
          const SizedBox(height: 16),
          // Technical Telemetry
          Row(
            children: [
              _buildTelemetryItem(
                context: context,
                label: 'Cadence',
                value: progress.fps > 0 ? '${progress.fps.toStringAsFixed(0)} fps' : '--',
              ),
              const SizedBox(width: 8),
              _buildTelemetryItem(
                context: context,
                label: 'Debit',
                value: progress.bitrate > 0 ? '${(progress.bitrate / 1000).toStringAsFixed(0)} kbps' : '--',
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
            child: OutlinedButton(
              onPressed: onCancel,
              child: const Text('Interrompre'),
            ),
          ),
        ],
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

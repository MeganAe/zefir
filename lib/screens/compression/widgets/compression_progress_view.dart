import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    progress.stage.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                '$percentInt%',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Crisp Linear Bar
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            child: LinearProgressIndicator(
              value: progress.percentage > 0 ? progress.percentage : null,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          // Technical Telemetry
          Row(
            children: [
              _buildTelemetryItem(
                label: 'CADENCE',
                value: progress.fps > 0 ? '${progress.fps.toStringAsFixed(0)} fps' : '--',
              ),
              const SizedBox(width: 8),
              _buildTelemetryItem(
                label: 'DÉBIT FLUX',
                value: progress.bitrate > 0 ? '${(progress.bitrate / 1000).toStringAsFixed(0)} kbps' : '--',
              ),
              const SizedBox(width: 8),
              _buildTelemetryItem(
                label: 'PROGRESSION',
                value: '${(progress.timeMs / 1000).toStringAsFixed(1)}s',
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.stop_outlined, size: 16, color: AppColors.danger),
              label: const Text(
                'INTERROMPRE L\'ENCODAGE',
                style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryItem({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

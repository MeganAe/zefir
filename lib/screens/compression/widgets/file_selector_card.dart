import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
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
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              SizedBox(height: 14),
              Text(
                'EXTRACTION DES MÉTADONNÉES SOURCE...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (video == null) {
      return InkWell(
        onTap: onPickVideo,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  border: Border.all(color: AppColors.borderFocused, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: const Icon(
                  Icons.video_library_outlined,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'SÉLECTIONNER UN FICHIER VIDÉO',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Formats compatibles : MP4, MOV, MKV, WebM, AVI',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Video details when loaded
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.accent,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    video!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                  tooltip: 'Retirer',
                ),
              ],
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
                      label: 'TAILLE BRUTE',
                      value: Formatters.formatBytes(video!.sizeBytes),
                      icon: Icons.data_usage_outlined,
                      highlight: true,
                    ),
                    const SizedBox(width: 12),
                    _buildMetaCell(
                      label: 'DURÉE',
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
                      label: 'RÉSOLUTION',
                      value: video!.resolutionText,
                      icon: Icons.aspect_ratio_outlined,
                    ),
                    const SizedBox(width: 12),
                    _buildMetaCell(
                      label: 'FRÉQUENCE',
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
    required String label,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: highlight ? AppColors.accent : AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: highlight ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                    ),
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

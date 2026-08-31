import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/statistics.dart';
import '../models/compression_preset.dart';
import '../models/video_item.dart';

class CompressionProgress {
  final double percentage; // 0.0 to 1.0
  final double fps;
  final double bitrate;
  final int timeMs;
  final int totalDurationMs;
  final String stage;

  const CompressionProgress({
    required this.percentage,
    required this.fps,
    required this.bitrate,
    required this.timeMs,
    required this.totalDurationMs,
    required this.stage,
  });
}

class FFmpegService {
  static int? _activeSessionId;

  /// Analyse les métadonnées approfondies d'une vidéo
  static Future<VideoItem> probeVideo(String filePath) async {
    final file = File(filePath);
    final size = await file.length();
    final name = filePath.split(Platform.pathSeparator).last;

    try {
      final session = await FFprobeKit.getMediaInformation(filePath);
      final info = session.getMediaInformation();

      if (info != null) {
        final durationStr = info.getDuration();
        final durationSec = double.tryParse(durationStr ?? '0') ?? 0.0;
        final duration = Duration(milliseconds: (durationSec * 1000).toInt());

        int? width;
        int? height;
        double? frameRate;
        final streams = info.getStreams();

        for (var stream in streams) {
          if (stream.getType() == 'video') {
            width = stream.getWidth();
            height = stream.getHeight();
            final rFrameRate = stream.getRealFrameRate();
            if (rFrameRate != null && rFrameRate.contains('/')) {
              final parts = rFrameRate.split('/');
              final num = double.tryParse(parts[0]);
              final den = double.tryParse(parts[1]);
              if (num != null && den != null && den > 0) {
                frameRate = num / den;
              }
            }
            break;
          }
        }

        final format = info.getFormat();
        final bitrate = int.tryParse(info.getBitrate() ?? '0');

        return VideoItem(
          path: filePath,
          name: name,
          sizeBytes: size,
          duration: duration,
          width: width,
          height: height,
          format: format,
          frameRate: frameRate,
          bitrate: bitrate,
        );
      }
    } catch (_) {}

    return VideoItem(
      path: filePath,
      name: name,
      sizeBytes: size,
    );
  }

  /// Exécute la compression vidéo avec flux d'état temps réel
  static Future<bool> compressVideo({
    required String inputPath,
    required String outputPath,
    required CompressionPreset preset,
    required int totalDurationMs,
    required void Function(CompressionProgress progress) onProgress,
  }) async {
    final completer = Completer<bool>();
    final args = preset.buildArgs(inputPath, outputPath);

    final session = await FFmpegKit.executeWithArgumentsAsync(
      args,
      (FFmpegSession session) async {
        final returnCode = await session.getReturnCode();
        _activeSessionId = null;

        if (ReturnCode.isSuccess(returnCode)) {
          onProgress(CompressionProgress(
            percentage: 1.0,
            fps: 0,
            bitrate: 0,
            timeMs: totalDurationMs,
            totalDurationMs: totalDurationMs,
            stage: 'Terminé',
          ));
          completer.complete(true);
        } else if (ReturnCode.isCancel(returnCode)) {
          completer.complete(false);
        } else {
          completer.complete(false);
        }
      },
      (log) {
        // Logs de bas niveau FFmpeg si nécessaire
      },
      (Statistics statistics) {
        final timeMs = statistics.getTime();
        double progress = 0.0;

        if (totalDurationMs > 0 && timeMs > 0) {
          progress = (timeMs / totalDurationMs).clamp(0.0, 0.99);
        }

        onProgress(CompressionProgress(
          percentage: progress,
          fps: statistics.getVideoFps(),
          bitrate: statistics.getBitrate(),
          timeMs: timeMs,
          totalDurationMs: totalDurationMs,
          stage: 'Encodage en cours...',
        ));
      },
    );

    _activeSessionId = session.getSessionId();
    return completer.future;
  }

  /// Annule la session de compression en cours
  static Future<void> cancelCompression() async {
    if (_activeSessionId != null) {
      await FFmpegKit.cancel(_activeSessionId!);
      _activeSessionId = null;
    } else {
      await FFmpegKit.cancel();
    }
  }
}

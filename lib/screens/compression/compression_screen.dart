import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_helper.dart';
import '../../models/compression_preset.dart';
import '../../models/compression_result.dart';
import '../../models/video_item.dart';
import '../../services/ffmpeg_service.dart';
import '../../services/history_service.dart';
import '../../services/preferences_service.dart';
import 'widgets/compression_progress_view.dart';
import 'widgets/compression_summary_card.dart';
import 'widgets/file_selector_card.dart';
import 'widgets/preset_selector.dart';

enum CompressionStatus { idle, analyzing, compressing, completed, error }

class CompressionScreen extends StatefulWidget {
  const CompressionScreen({super.key});

  @override
  State<CompressionScreen> createState() => _CompressionScreenState();
}

class _CompressionScreenState extends State<CompressionScreen> {
  final ImagePicker _picker = ImagePicker();
  VideoItem? _selectedVideo;
  CompressionPreset _selectedPreset = CompressionPreset.defaultPreset;
  CompressionStatus _status = CompressionStatus.idle;
  CompressionProgress? _progress;
  CompressionResult? _lastResult;
  String? _errorMessage;
  DateTime? _compressionStartTime;

  @override
  void initState() {
    super.initState();
    _loadDefaultPreset();
  }

  Future<void> _loadDefaultPreset() async {
    final presetId = await PreferencesService.getDefaultPreset();
    if (mounted) {
      setState(() {
        _selectedPreset = CompressionPreset.getById(presetId);
      });
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(hours: 4),
      );

      if (file == null) return;

      setState(() {
        _status = CompressionStatus.analyzing;
        _errorMessage = null;
        _lastResult = null;
      });

      final videoItem = await FFmpegService.probeVideo(file.path);

      if (mounted) {
        setState(() {
          _selectedVideo = videoItem;
          _status = CompressionStatus.idle;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = CompressionStatus.error;
          _errorMessage = 'Échec de lecture du fichier vidéo : $e';
        });
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedVideo = null;
      _status = CompressionStatus.idle;
      _progress = null;
      _lastResult = null;
      _errorMessage = null;
    });
  }

  Future<void> _startCompression() async {
    if (_selectedVideo == null) return;

    final inputPath = _selectedVideo!.path;
    final totalDurationMs = _selectedVideo!.duration?.inMilliseconds ?? 0;

    setState(() {
      _status = CompressionStatus.compressing;
      _errorMessage = null;
      _progress = CompressionProgress(
        percentage: 0.0,
        fps: 0,
        bitrate: 0,
        timeMs: 0,
        totalDurationMs: totalDurationMs,
        stage: 'Initialisation du pipeline...',
      );
      _compressionStartTime = DateTime.now();
    });

    final outputPath = await FileHelper.generateOutputPath();

    final success = await FFmpegService.compressVideo(
      inputPath: inputPath,
      outputPath: outputPath,
      preset: _selectedPreset,
      totalDurationMs: totalDurationMs,
      onProgress: (prog) {
        if (mounted && _status == CompressionStatus.compressing) {
          setState(() {
            _progress = prog;
          });
        }
      },
    );

    if (!mounted) return;

    final executionTime = _compressionStartTime != null
        ? DateTime.now().difference(_compressionStartTime!).inSeconds
        : 0;

    if (success) {
      final compressedSize = await FileHelper.getFileSize(outputPath);

      final result = CompressionResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: _selectedVideo!.name,
        originalPath: inputPath,
        compressedPath: outputPath,
        originalSizeBytes: _selectedVideo!.sizeBytes,
        compressedSizeBytes: compressedSize,
        durationMs: totalDurationMs,
        presetId: _selectedPreset.id,
        presetLabel: _selectedPreset.label,
        createdAt: DateTime.now(),
        executionTimeSeconds: executionTime > 0 ? executionTime : 1,
      );

      // Save to persistent history
      await HistoryService().addRecord(result);

      // Check user preference if original should be deleted
      final deleteOriginal = await PreferencesService.getDeleteOriginal();
      if (deleteOriginal) {
        await FileHelper.deleteFile(inputPath);
      }

      setState(() {
        _status = CompressionStatus.completed;
        _lastResult = result;
      });
    } else {
      // Cleanup failed or aborted output file
      await FileHelper.deleteFile(outputPath);

      setState(() {
        _status = CompressionStatus.idle;
        _errorMessage = 'Traitement interrompu ou échec de l\'encodage.';
      });
    }
  }

  Future<void> _cancelCompression() async {
    await FFmpegService.cancelCompression();
    setState(() {
      _status = CompressionStatus.idle;
      _progress = null;
    });
  }

  Future<void> _openCompressedVideo() async {
    if (_lastResult == null) return;
    final file = File(_lastResult!.compressedPath);
    if (await file.exists()) {
      await OpenFilex.open(_lastResult!.compressedPath);
    } else {
      _showSnackbar('Fichier introuvable sur le stockage local.');
    }
  }

  Future<void> _shareCompressedVideo() async {
    if (_lastResult == null) return;
    final file = File(_lastResult!.compressedPath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(_lastResult!.compressedPath)],
        text: 'Vidéo compressée avec Zefir (${_lastResult!.fileName})',
      );
    } else {
      _showSnackbar('Fichier introuvable pour le partage.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZEFIR'),
        actions: [
          if (_selectedVideo != null && _status == CompressionStatus.idle)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Réinitialiser',
              onPressed: _clearSelection,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Source Card
            FileSelectorCard(
              video: _selectedVideo,
              isAnalyzing: _status == CompressionStatus.analyzing,
              onPickVideo: _pickVideo,
              onClear: _clearSelection,
            ),

            const SizedBox(height: 16),

            // Error notice if any
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.12),
                  border: Border.all(color: AppColors.danger, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Active compression progress
            if (_status == CompressionStatus.compressing && _progress != null) ...[
              CompressionProgressView(
                progress: _progress!,
                onCancel: _cancelCompression,
              ),
              const SizedBox(height: 16),
            ],

            // Completion Summary Report
            if (_status == CompressionStatus.completed && _lastResult != null) ...[
              CompressionSummaryCard(
                result: _lastResult!,
                onOpenVideo: _openCompressedVideo,
                onShareVideo: _shareCompressedVideo,
                onReset: _clearSelection,
              ),
              const SizedBox(height: 16),
            ],

            // Preset Selector (visible when idle or analyzing)
            if (_status != CompressionStatus.completed && _status != CompressionStatus.compressing) ...[
              PresetSelector(
                selectedPreset: _selectedPreset,
                onSelectPreset: (preset) {
                  setState(() {
                    _selectedPreset = preset;
                  });
                },
                isEnabled: _status == CompressionStatus.idle,
              ),
              const SizedBox(height: 20),

              // Compression Trigger Action Button
              ElevatedButton.icon(
                onPressed: (_selectedVideo != null && _status == CompressionStatus.idle)
                    ? _startCompression
                    : null,
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('LANCER LA COMPRESSION'),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

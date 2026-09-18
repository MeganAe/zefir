import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/file_helper.dart';
import '../../models/compression_preset.dart';
import '../../models/compression_result.dart';
import '../../models/video_item.dart';
import '../../services/favorites_service.dart';
import '../../services/ffmpeg_service.dart';
import '../../services/history_service.dart';
import '../../services/preferences_service.dart';
import '../../widgets/connected_button_group.dart';
import '../../widgets/video_preview_card.dart';
import '../history/history_detail_screen.dart';
import '../home_navigation_screen.dart';
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

    final outputPath = await FileHelper.generateOutputPath(
      extension: await PreferencesService.getOutputFormat());

    final targetHeight = await PreferencesService.getTargetHeight();
    final argsPreset = _selectedPreset.withTargetHeight(targetHeight);

    final success = await FFmpegService.compressVideo(
      inputPath: inputPath,
      outputPath: outputPath,
      preset: argsPreset,
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
      await FavoritesService().load();

      // Check user preference if original should be deleted
      final deleteOriginal = await PreferencesService.getDeleteOriginal();
      if (deleteOriginal) {
        await FileHelper.deleteFile(inputPath);
      }

      final keepOn = await PreferencesService.getKeepScreenOn();
      if (keepOn) {
        try {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        } catch (_) {}
      }

      final autoShare = await PreferencesService.getAutoShare();
      if (autoShare && await File(outputPath).exists()) {
        await Share.shareXFiles([XFile(outputPath)],
            text: 'Video compressee avec Zefir (${result.fileName})');
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

  Future<void> _openDetail(CompressionResult r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryDetailScreen(result: r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: ZefirTopBar(
        title: 'Accueil',
        extraActions: [
          if (_selectedVideo != null && _status == CompressionStatus.idle)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reinitialiser',
              onPressed: _clearSelection,
            ),
        ],
      ),
      floatingActionButton: _selectedVideo == null
          ? FloatingActionButton(
              onPressed: _pickVideo,
              tooltip: 'Choisir une video',
              child: const Icon(Icons.edit),
            )
          : null,
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
              Card(
                color: scheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 18, color: scheme.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: scheme.onErrorContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
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
              FilledButton(
                onPressed: (_selectedVideo != null && _status == CompressionStatus.idle)
                    ? _startCompression
                    : null,
                child: const Text('Lancer la compression'),
              ),
              const SizedBox(height: 12),
              if (_selectedVideo != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConnectedButtonGroup(
                    firstLabel: 'Favori',
                    firstIcon: Icons.favorite_outline,
                    onFirst: _lastResult == null
                        ? null
                        : () => FavoritesService()
                            .toggle(_lastResult!.id),
                    secondLabel: 'Partager',
                    secondIcon: Icons.share_outlined,
                    onSecond: _lastResult == null
                        ? null
                        : _shareCompressedVideo,
                  ),
                ),
                const SizedBox(height: 12),
                VideoPreviewCard(
                    video: _selectedVideo, title: 'Apercu source'),
                const SizedBox(height: 12),
                _RecentList(onOpen: _openDetail),
              ],
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  final void Function(CompressionResult r) onOpen;
  const _RecentList({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HistoryService(),
      builder: (context, _) {
        final items = HistoryService().items.take(3).toList();
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recents', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Icon(
                          i == 0
                              ? Icons.inbox_outlined
                              : i == 1
                                  ? Icons.star_outline
                                  : Icons.archive_outlined,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                      title: Text(items[i].fileName,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(items[i].presetLabel),
                      trailing:
                          const Icon(Icons.chevron_right_rounded),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: i == 0
                              ? const Radius.circular(28)
                              : const Radius.circular(8),
                          bottom: i == items.length - 1
                              ? const Radius.circular(28)
                              : const Radius.circular(8),
                        ),
                      ),
                      onTap: () => onOpen(items[i]),
                    ),
                    if (i != items.length - 1)
                      const SizedBox(height: 3),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

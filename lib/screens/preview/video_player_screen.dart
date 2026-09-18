import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/utils/formatters.dart';

/// Lecteur vidéo M3 Expressive : lecture locale, seek, volume, partage.
///
/// Fond `inverseSurface` : seul écran volontairement sombre, comme le veut la
/// convention M3 pour la consommation de média plein écran.
class VideoPlayerScreen extends StatefulWidget {
  final String path;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.path,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  Timer? _hideTimer;
  bool _controlsVisible = true;
  bool _initializing = true;
  String? _error;
  bool _seeking = false;
  double _seekValue = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _open();
  }

  Future<void> _open() async {
    final file = File(widget.path);
    if (!await file.exists()) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Fichier introuvable sur le stockage local.';
        });
      }
      return;
    }

    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      controller.addListener(_onTick);
      setState(() {
        _controller = controller;
        _initializing = false;
      });
      _scheduleHide();
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Lecture impossible : format non supporté par le lecteur '
              'intégré. Utilisez « Ouvrir avec… ».';
        });
      }
    }
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller?.value.isPlaying == true) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleHide();
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
      _hideTimer?.cancel();
      if (mounted) setState(() => _controlsVisible = true);
    } else {
      await controller.play();
      _scheduleHide();
    }
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.setVolume(controller.value.volume == 0 ? 1 : 0);
    if (mounted) setState(() {});
  }

  Future<void> _share() async {
    final file = File(widget.path);
    if (!await file.exists()) return;
    await Share.shareXFiles([XFile(widget.path)], text: widget.title);
  }

  Future<void> _openExternal() async {
    await OpenFilex.open(widget.path);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = _controller;
    final value = controller?.value;

    return Scaffold(
      backgroundColor: scheme.inverseSurface,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: _initializing
                  ? CircularProgressIndicator(color: scheme.inversePrimary)
                  : _error != null
                      ? _ErrorPane(
                          message: _error!,
                          onOpenExternal: _openExternal,
                        )
                      : value != null && value.isInitialized
                          ? AspectRatio(
                              aspectRatio: value.aspectRatio,
                              child: VideoPlayer(controller!),
                            )
                          : const SizedBox.shrink(),
            ),
            AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        scheme.inverseSurface.withValues(alpha: 0.85),
                        scheme.inverseSurface.withValues(alpha: 0.15),
                        scheme.inverseSurface.withValues(alpha: 0.90),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _buildTopBar(scheme),
                        const Spacer(),
                        _buildCenterControls(scheme),
                        const Spacer(),
                        if (value != null && value.isInitialized)
                          _buildBottomBar(scheme, value),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: scheme.onInverseSurface,
            tooltip: 'Retour',
            onPressed: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onInverseSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: scheme.onInverseSurface,
            tooltip: 'Partager',
            onPressed: _share,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: scheme.onInverseSurface,
            tooltip: 'Plus d\'options',
            onPressed: _showMoreSheet,
          ),
        ],
      ),
    );
  }

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Ouvrir avec une autre application'),
              onTap: () {
                Navigator.pop(context);
                _openExternal();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Partager la vidéo'),
              onTap: () {
                Navigator.pop(context);
                _share();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls(ColorScheme scheme) {
    final controller = _controller;
    if (controller == null || _error != null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _skipButton(scheme, Icons.replay_10, -10),
        const SizedBox(width: 24),
        FloatingActionButton(
          onPressed: _togglePlay,
          backgroundColor: scheme.inversePrimary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            controller.value.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            size: 28,
          ),
        ),
        const SizedBox(width: 24),
        _skipButton(scheme, Icons.forward_10, 10),
      ],
    );
  }

  Widget _skipButton(ColorScheme scheme, IconData icon, int seconds) {
    return IconButton(
      icon: Icon(icon, size: 30),
      color: scheme.onInverseSurface,
      tooltip: seconds < 0 ? 'Reculer de 10s' : 'Avancer de 10s',
      onPressed: () async {
        final controller = _controller;
        if (controller == null) return;
        final duration = controller.value.duration;
        final target = controller.value.position + Duration(seconds: seconds);
        final clamped = target < Duration.zero
            ? Duration.zero
            : (target > duration ? duration : target);
        await controller.seekTo(clamped);
        if (mounted) setState(() {});
        _scheduleHide();
      },
    );
  }

  Widget _buildBottomBar(ColorScheme scheme, VideoPlayerValue value) {
    final duration = value.duration;
    final position =
        _seeking ? Duration(milliseconds: _seekValue.round()) : value.position;
    final maxMs =
        duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
    final current = position.inMilliseconds.toDouble().clamp(0.0, maxMs);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: scheme.inversePrimary,
              inactiveTrackColor:
                  scheme.onInverseSurface.withValues(alpha: 0.30),
              thumbColor: scheme.inversePrimary,
              overlayColor: scheme.inversePrimary.withValues(alpha: 0.15),
            ),
            child: Slider(
              value: current,
              max: maxMs,
              onChangeStart: (_) => setState(() => _seeking = true),
              onChanged: (v) => setState(() => _seekValue = v),
              onChangeEnd: (v) async {
                final controller = _controller;
                setState(() => _seeking = false);
                if (controller != null) {
                  await controller
                      .seekTo(Duration(milliseconds: v.round()));
                }
                if (mounted) setState(() {});
                _scheduleHide();
              },
            ),
          ),
          Row(
            children: [
              Text(
                Formatters.formatDuration(position),
                style: TextStyle(
                  color: scheme.onInverseSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' / ${Formatters.formatDuration(duration)}',
                style: TextStyle(
                  color: scheme.onInverseSurface.withValues(alpha: 0.70),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  value.volume == 0
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  size: 20,
                ),
                color: scheme.onInverseSurface,
                tooltip:
                    value.volume == 0 ? 'Activer le son' : 'Couper le son',
                onPressed: _toggleMute,
              ),
              if (value.isBuffering)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.inversePrimary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  final String message;
  final VoidCallback onOpenExternal;

  const _ErrorPane({required this.message, required this.onOpenExternal});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.videocam_off_outlined,
              size: 48, color: scheme.onInverseSurface),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onInverseSurface, fontSize: 14),
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: onOpenExternal,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Ouvrir avec…'),
          ),
        ],
      ),
    );
  }
}
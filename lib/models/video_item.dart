class VideoItem {
  final String path;
  final String name;
  final int sizeBytes;
  final Duration? duration;
  final int? width;
  final int? height;
  final String? format;
  final double? frameRate;
  final int? bitrate;

  const VideoItem({
    required this.path,
    required this.name,
    required this.sizeBytes,
    this.duration,
    this.width,
    this.height,
    this.format,
    this.frameRate,
    this.bitrate,
  });

  String get resolutionText {
    if (width != null && height != null) {
      return '${width}x$height';
    }
    return 'Résolution N/A';
  }

  VideoItem copyWith({
    String? path,
    String? name,
    int? sizeBytes,
    Duration? duration,
    int? width,
    int? height,
    String? format,
    double? frameRate,
    int? bitrate,
  }) {
    return VideoItem(
      path: path ?? this.path,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      format: format ?? this.format,
      frameRate: frameRate ?? this.frameRate,
      bitrate: bitrate ?? this.bitrate,
    );
  }
}

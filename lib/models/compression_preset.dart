enum PresetType { ultraLight, balanced, highQuality, archival }

class CompressionPreset {
  final String id;
  final String label;
  final String technicalSummary;
  final String description;
  final int crf;
  final String? scaleFilter;
  final String presetSpeed;
  final String audioBitrate;
  final PresetType type;

  const CompressionPreset({
    required this.id,
    required this.label,
    required this.technicalSummary,
    required this.description,
    required this.crf,
    this.scaleFilter,
    required this.presetSpeed,
    required this.audioBitrate,
    required this.type,
  });

  CompressionPreset withTargetHeight(int targetHeight) {
    if (type == PresetType.highQuality) return this;
    final filter = 'scale=-2:min($targetHeight\\,ih)';
    return CompressionPreset(
      id: id,
      label: label,
      technicalSummary: technicalSummary,
      description: description,
      crf: crf,
      scaleFilter: filter,
      presetSpeed: presetSpeed,
      audioBitrate: audioBitrate,
      type: type,
    );
  }

  /// Remplace le débit audio (kbps) — utilisé par le réglage applicatif.
  CompressionPreset withAudioBitrate(int kbps) {
    if (kbps <= 0) return this;
    return CompressionPreset(
      id: id,
      label: label,
      technicalSummary: technicalSummary,
      description: description,
      crf: crf,
      scaleFilter: scaleFilter,
      presetSpeed: presetSpeed,
      audioBitrate: '${kbps}k',
      type: type,
    );
  }

  /// Construit la commande d'arguments FFmpeg pour ce profil
  ///
  /// [hwaccelDecode] ajoute `-hwaccel auto` avant l'entrée : le décodage
  /// matériel est utilisé quand il est disponible, avec repli logiciel
  /// automatique de FFmpeg dans le cas contraire.
  List<String> buildArgs(
    String inputPath,
    String outputPath, {
    bool hwaccelDecode = false,
  }) {
    final args = <String>['-y'];
    if (hwaccelDecode) {
      args.addAll(['-hwaccel', 'auto']);
    }
    args.addAll([
      '-i', inputPath,
      '-c:v', 'libx264',
      '-crf', crf.toString(),
      '-preset', presetSpeed,
      '-pix_fmt', 'yuv420p',
    ]);

    if (scaleFilter != null && scaleFilter!.isNotEmpty) {
      args.addAll(['-vf', scaleFilter!]);
    }

    args.addAll([
      '-c:a', 'aac',
      '-b:a', audioBitrate,
      '-movflags', '+faststart',
      outputPath,
    ]);

    return args;
  }

  static const List<CompressionPreset> allPresets = [
    CompressionPreset(
      id: 'balanced',
      label: 'Équilibré Standard',
      technicalSummary: 'CRF 26 • Scale 720p • AAC 128k',
      description: 'Compromis optimal entre préservation des détails et gain de stockage.',
      crf: 26,
      scaleFilter: 'scale=-2:min(720\\,ih)',
      presetSpeed: 'medium',
      audioBitrate: '128k',
      type: PresetType.balanced,
    ),
    CompressionPreset(
      id: 'ultra_light',
      label: 'Distribution Rapide',
      technicalSummary: 'CRF 30 • Scale 540p • AAC 96k',
      description: 'Réduction maximale de poids pour partage immédiat et messageries.',
      crf: 30,
      scaleFilter: 'scale=-2:min(540\\,ih)',
      presetSpeed: 'fast',
      audioBitrate: '96k',
      type: PresetType.ultraLight,
    ),
    CompressionPreset(
      id: 'high_quality',
      label: 'Haute Fidélité',
      technicalSummary: 'CRF 22 • Source Res • AAC 192k',
      description: 'Conservation rigoureuse de la netteté et de la dynamique colorimétrique.',
      crf: 22,
      scaleFilter: null,
      presetSpeed: 'slow',
      audioBitrate: '192k',
      type: PresetType.highQuality,
    ),
    CompressionPreset(
      id: 'archival',
      label: 'Archive Compacte',
      technicalSummary: 'CRF 33 • Scale 480p • AAC 64k',
      description: 'Format condensé dédié à la sauvegarde et à la libération d\'espace critique.',
      crf: 33,
      scaleFilter: 'scale=-2:min(480\\,ih)',
      presetSpeed: 'veryfast',
      audioBitrate: '64k',
      type: PresetType.archival,
    ),
  ];

  static CompressionPreset get defaultPreset => allPresets[0];

  static CompressionPreset getById(String id) {
    return allPresets.firstWhere(
      (p) => p.id == id,
      orElse: () => defaultPreset,
    );
  }
}

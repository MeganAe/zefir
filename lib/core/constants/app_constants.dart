class AppConstants {
  static const String appName = 'Zefir';
  static const String appTagline =
      'Compression vidéo locale, design Material 3 Expressive';
  static const String appVersion = '1.2.0';
  static const String buildNumber = '3';
  static const String creatorName = 'Metoushael';
  static const String packageId = 'com.metoushael.zefir';
  static const String engineName = 'FFmpeg Core GPL v6.0';

  // Storage keys
  static const String historyStorageKey = 'zefir_compression_history_v1';
  static const String favoritesStorageKey = 'zefir_favorites_v1';
  static const String defaultPresetKey = 'zefir_default_preset';
  static const String deleteOriginalKey = 'zefir_delete_original_after_compression';
  static const String keepScreenOnKey = 'zefir_keep_screen_on';
  static const String autoShareKey = 'zefir_auto_share_after_compression';
  static const String targetHeightKey = 'zefir_target_height';
  static const String outputFormatKey = 'zefir_output_format';
  static const String customAudioBitrateKey = 'zefir_custom_audio_bitrate';
  static const String hardwareAccelKey = 'zefir_hardware_accel_enabled';
  static const String encodingSpeedKey = 'zefir_encoding_speed';
  static const String usePresetSpeedKey = 'zefir_use_preset_speed';
  static const String showThumbnailsKey = 'zefir_show_thumbnails';
  static const String autoPlayResultKey = 'zefir_auto_play_result';
  static const String defaultSortKey = 'zefir_default_sort';

  static const int defaultTargetHeight = 720;
  static const List<int> targetHeights = [480, 540, 720, 1080];
  static const List<String> outputFormats = ['mp4', 'mkv'];

  /// Débits audio disponibles (kbps) — pilote l'argument `-b:a`.
  static const int defaultAudioBitrate = 128;
  static const List<int> audioBitrates = [64, 96, 128, 192];

  /// Critères de tri partagés par Historique, Favoris et Recherche.
  static const String sortByDateDesc = 'date_desc';
  static const String sortByDateAsc = 'date_asc';
  static const String sortByName = 'name';
  static const String sortBySize = 'size';
  static const String sortBySavings = 'savings';

  static const String defaultSort = sortByDateDesc;

  static const Map<String, String> sortLabels = {
    sortByDateDesc: 'Plus récentes',
    sortByDateAsc: 'Plus anciennes',
    sortByName: 'Nom (A → Z)',
    sortBySize: 'Taille compressée',
    sortBySavings: 'Gain d\'espace',
  };
}


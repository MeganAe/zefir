class AppConstants {
  static const String appName = 'Zefir';
  static const String appTagline = 'Compression vidéo locale, design Material 3 Expressive';
  static const String appVersion = '1.1.0';
  static const String buildNumber = '2';
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
  static const String hardwareAccelKey = 'zefir_hardware_accel';

  static const int defaultTargetHeight = 720;
  static const List<int> targetHeights = [480, 540, 720, 1080];
  static const List<String> outputFormats = ['mp4', 'mkv'];
}

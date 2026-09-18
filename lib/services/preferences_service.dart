import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<String> getDefaultPreset() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.defaultPresetKey) ?? 'balanced';
  }

  static Future<void> setDefaultPreset(String presetId) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.defaultPresetKey, presetId);
  }

  static Future<bool> getDeleteOriginal() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.deleteOriginalKey) ?? false;
  }

  static Future<void> setDeleteOriginal(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.deleteOriginalKey, value);
  }

  static Future<bool> getKeepScreenOn() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.keepScreenOnKey) ?? true;
  }

  static Future<void> setKeepScreenOn(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.keepScreenOnKey, value);
  }

  static Future<bool> getAutoShare() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.autoShareKey) ?? false;
  }

  static Future<void> setAutoShare(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.autoShareKey, value);
  }

  static Future<int> getTargetHeight() async {
    final prefs = await _instance;
    return prefs.getInt(AppConstants.targetHeightKey) ??
        AppConstants.defaultTargetHeight;
  }

  static Future<void> setTargetHeight(int value) async {
    final prefs = await _instance;
    await prefs.setInt(AppConstants.targetHeightKey, value);
  }

  static Future<String> getOutputFormat() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.outputFormatKey) ?? 'mp4';
  }

  static Future<void> setOutputFormat(String value) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.outputFormatKey, value);
  }

  static Future<int> getCustomAudioBitrate() async {
    final prefs = await _instance;
    return prefs.getInt(AppConstants.customAudioBitrateKey) ??
        AppConstants.defaultAudioBitrate;
  }

  static Future<void> setCustomAudioBitrate(int kbps) async {
    final prefs = await _instance;
    await prefs.setInt(AppConstants.customAudioBitrateKey, kbps);
  }

  static Future<bool> getHardwareAccel() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.hardwareAccelKey) ?? false;
  }

  static Future<void> setHardwareAccel(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.hardwareAccelKey, value);
  }

  static Future<bool> getShowThumbnails() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.showThumbnailsKey) ?? true;
  }

  static Future<void> setShowThumbnails(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.showThumbnailsKey, value);
  }

  static Future<bool> getAutoPlayResult() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.autoPlayResultKey) ?? false;
  }

  static Future<void> setAutoPlayResult(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.autoPlayResultKey, value);
  }

  static Future<String> getDefaultSort() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.defaultSortKey) ??
        AppConstants.defaultSort;
  }

  static Future<void> setDefaultSort(String value) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.defaultSortKey, value);
  }
}


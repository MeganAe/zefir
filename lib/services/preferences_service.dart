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
}

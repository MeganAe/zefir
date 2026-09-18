import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Favoris persistés (ids de CompressionResult).
class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  Set<String> _ids = {};
  bool _loaded = false;
  bool get isLoaded => _loaded;

  bool isFavorite(String id) => _ids.contains(id);
  List<String> get ids => _ids.toList();

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ids = (prefs.getStringList(AppConstants.favoritesStorageKey) ?? []).toSet();
    } catch (_) {
      _ids = {};
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.favoritesStorageKey, _ids.toList());
    } catch (_) {}
  }
}

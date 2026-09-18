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
    await _persist();
  }

  /// Retire des identifiants (après suppression d'un enregistrement).
  Future<void> removeAll(Iterable<String> ids) async {
    var changed = false;
    for (final id in ids) {
      if (_ids.remove(id)) changed = true;
    }
    if (changed) {
      notifyListeners();
      await _persist();
    }
  }

  /// Vide la liste des favoris.
  Future<void> clearAll() async {
    if (_ids.isEmpty) return;
    _ids.clear();
    notifyListeners();
    await _persist();
  }

  int get count => _ids.length;

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          AppConstants.favoritesStorageKey, _ids.toList());
    } catch (_) {}
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/file_helper.dart';
import '../models/compression_result.dart';

class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  List<CompressionResult> _items = [];
  bool _isLoaded = false;

  List<CompressionResult> get items => List.unmodifiable(_items);
  bool get isLoaded => _isLoaded;

  int get totalSavedBytes {
    return _items.fold(0, (sum, item) => sum + item.savedBytes);
  }

  int get totalVideosCompressed => _items.length;

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(AppConstants.historyStorageKey);
      if (rawList != null) {
        _items = rawList
            .map((itemStr) {
              try {
                return CompressionResult.fromJson(itemStr);
              } catch (_) {
                return null;
              }
            })
            .whereType<CompressionResult>()
            .toList();

        // Trie par date décroissante (plus récent en premier)
        _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _items = [];
      }
    } catch (_) {
      _items = [];
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> addRecord(CompressionResult result) async {
    _items.insert(0, result);
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> deleteRecord(String id, {bool deleteFileFromDisk = true}) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _items[index];
      if (deleteFileFromDisk) {
        await FileHelper.deleteFile(item.compressedPath);
      }
      _items.removeAt(index);
      notifyListeners();
      await _saveToDisk();
    }
  }

  Future<void> clearAll({bool deleteFiles = true}) async {
    if (deleteFiles) {
      for (var item in _items) {
        await FileHelper.deleteFile(item.compressedPath);
      }
    }
    _items.clear();
    notifyListeners();
    await _saveToDisk();
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = _items.map((item) => item.toJson()).toList();
      await prefs.setStringList(AppConstants.historyStorageKey, stringList);
    } catch (_) {}
  }
}

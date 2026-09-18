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
  bool get isEmpty => _items.isEmpty;

  int get totalSavedBytes {
    return _items.fold(0, (sum, item) => sum + item.savedBytes);
  }

  int get totalOriginalBytes {
    return _items.fold(0, (sum, item) => sum + item.originalSizeBytes);
  }

  int get totalCompressedBytes {
    return _items.fold(0, (sum, item) => sum + item.compressedSizeBytes);
  }

  int get totalVideosCompressed => _items.length;

  /// Réduction moyenne pondérée sur l'ensemble de l'historique.
  double get averageReduction {
    if (totalOriginalBytes <= 0) return 0.0;
    final saved = totalSavedBytes;
    if (saved <= 0) return 0.0;
    return (saved / totalOriginalBytes) * 100.0;
  }

  /// Retrouve un enregistrement par identifiant.
  CompressionResult? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Filtre par nom de fichier et/ou libellé de profil.
  List<CompressionResult> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return _items
        .where((e) =>
            e.fileName.toLowerCase().contains(q) ||
            e.presetLabel.toLowerCase().contains(q) ||
            e.compressedPath.toLowerCase().contains(q))
        .toList();
  }

  /// Applique un critère de tri de [AppConstants.sortLabels].
  static List<CompressionResult> sort(
    List<CompressionResult> source,
    String criterion,
  ) {
    final list = List<CompressionResult>.from(source);
    switch (criterion) {
      case AppConstants.sortByDateAsc:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case AppConstants.sortByName:
        list.sort((a, b) =>
            a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
        break;
      case AppConstants.sortBySize:
        list.sort((a, b) => b.compressedSizeBytes.compareTo(a.compressedSizeBytes));
        break;
      case AppConstants.sortBySavings:
        list.sort((a, b) => b.savedBytes.compareTo(a.savedBytes));
        break;
      case AppConstants.sortByDateDesc:
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

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

  /// Supprime plusieurs enregistrements en une passe (sélection multiple).
  Future<int> deleteRecords(
    Iterable<String> ids, {
    bool deleteFilesFromDisk = true,
  }) async {
    final idSet = ids.toSet();
    if (idSet.isEmpty) return 0;

    final removed = <CompressionResult>[];
    _items.removeWhere((item) {
      if (idSet.contains(item.id)) {
        removed.add(item);
        return true;
      }
      return false;
    });

    if (removed.isEmpty) return 0;

    if (deleteFilesFromDisk) {
      for (final item in removed) {
        await FileHelper.deleteFile(item.compressedPath);
      }
    }

    notifyListeners();
    await _saveToDisk();
    return removed.length;
  }

  /// Nombre d'enregistrements dont le fichier compressé n'existe plus.
  Future<int> countMissingFiles() async {
    int missing = 0;
    for (final item in _items) {
      if (!await FileHelper.fileExists(item.compressedPath)) missing++;
    }
    return missing;
  }

  /// Retire de l'historique les entrées dont le fichier a disparu.
  Future<int> pruneMissingFiles() async {
    final missingIds = <String>[];
    for (final item in _items) {
      if (!await FileHelper.fileExists(item.compressedPath)) {
        missingIds.add(item.id);
      }
    }
    return deleteRecords(missingIds, deleteFilesFromDisk: false);
  }

  Future<void> clearAll({bool deleteFiles = true}) async {
    if (deleteFiles) {
      for (final item in _items) {
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

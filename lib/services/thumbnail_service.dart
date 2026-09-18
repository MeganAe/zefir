import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';

/// Génère et met en cache des miniatures vidéo (1 image extraite par FFmpeg).
///
/// Le cache vit dans `<appSupport>/ZefirThumbnails` et survit aux redémarrages,
/// ce qui évite de relancer un décodage FFmpeg à chaque affichage de liste.
class ThumbnailService {
  static const String _folderName = 'ZefirThumbnails';

  /// Mémoire courte durée : évite les rebuilds multiples dans une même session.
  static final Map<String, File> _memo = {};

  /// Cache négatif : ne pas relancer une extraction qui a déjà échoué.
  static final Set<String> _failed = {};

  static Future<Directory> _cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/$_folderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Hash FNV-1a 64 bits : déterministe entre les sessions (contrairement à
  /// `String.hashCode` qui n'est pas garanti stable).
  static String _hash(String input) {
    // Variante 32 bits : compatible avec la représentation des entiers Web.
    const int offset = 0x811c9dc5;
    const int prime = 0x01000193;
    int hash = offset;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return hash.toUnsigned(32).toRadixString(16).padLeft(8, '0');
  }

  static Future<File?> _cachedFile(String videoPath) async {
    final dir = await _cacheDir();
    return File('${dir.path}/thumb_${_hash(videoPath)}.jpg');
  }

  /// Retourne la miniature en cache, ou `null` si indisponible.
  static Future<File?> getCached(String videoPath) async {
    if (videoPath.isEmpty) return null;

    final memoized = _memo[videoPath];
    if (memoized != null && await memoized.exists()) return memoized;

    if (_failed.contains(videoPath)) return null;

    try {
      final cached = await _cachedFile(videoPath);
      if (cached != null &&
          await cached.exists() &&
          await cached.length() > 0) {
        _memo[videoPath] = cached;
        return cached;
      }
    } catch (_) {}
    return null;
  }

  /// Extrait une image de la vidéo et la renvoie. Renvoie `null` en cas d'échec
  /// (fichier absent, codec non supporté…).
  static Future<File?> generate(
    String videoPath, {
    Duration seek = const Duration(seconds: 1),
    int width = 360,
  }) async {
    if (videoPath.isEmpty) return null;

    final cached = await getCached(videoPath);
    if (cached != null) return cached;

    if (_failed.contains(videoPath)) return null;

    final source = File(videoPath);
    try {
      if (!await source.exists()) {
        _failed.add(videoPath);
        return null;
      }
    } catch (_) {
      _failed.add(videoPath);
      return null;
    }

    try {
      final target = await _cachedFile(videoPath);
      if (target == null) return null;

      // -ss avant -i : seek rapide sur l'index.
      final session = await FFmpegKit.executeWithArguments([
        '-y',
        '-ss',
        '${seek.inMilliseconds / 1000}',
        '-i',
        videoPath,
        '-frames:v',
        '1',
        '-vf',
        'scale=$width:-2',
        '-q:v',
        '4',
        target.path,
      ]);

      final code = await session.getReturnCode();
      if (ReturnCode.isSuccess(code) &&
          await target.exists() &&
          await target.length() > 0) {
        _memo[videoPath] = target;
        return target;
      }
    } catch (_) {}

    _failed.add(videoPath);
    return null;
  }

  /// Purge complète du cache disque + mémoire.
  static Future<int> clearCache() async {
    _memo.clear();
    _failed.clear();
    try {
      final dir = await _cacheDir();
      int count = 0;
      await for (final entity in dir.list()) {
        if (entity is File) {
          await entity.delete();
          count++;
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  /// Taille occupée par le cache, en octets.
  static Future<int> cacheSize() async {
    try {
      final dir = await _cacheDir();
      int total = 0;
      await for (final entity in dir.list()) {
        if (entity is File) {
          total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Invalide l'entrée d'une vidéo (après suppression par exemple).
  static void invalidate(String videoPath) {
    _memo.remove(videoPath);
    _failed.remove(videoPath);
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  /// Génère un chemin de destination unique pour la vidéo compressée
  static Future<String> generateOutputPath({String extension = 'mp4'}) async {
    final dir = await getApplicationDocumentsDirectory();
    final zefirDir = Directory('${dir.path}/ZefirOutputs');
    if (!await zefirDir.exists()) {
      await zefirDir.create(recursive: true);
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${zefirDir.path}/zefir_compressed_$timestamp.$extension';
  }

  /// Récupère la taille d'un fichier en octets
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (_) {}
    return 0;
  }

  /// Supprime un fichier local s'il existe
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Vérifie l'existence d'un fichier local.
  static Future<bool> fileExists(String filePath) async {
    if (filePath.isEmpty) return false;
    try {
      return await File(filePath).exists();
    } catch (_) {
      return false;
    }
  }

  /// Extrait le nom de fichier propre depuis un chemin absolu
  static String getFileName(String path) {
    if (path.isEmpty) return 'inconnu.mp4';
    return path.split(Platform.pathSeparator).last;
  }

  /// Nombre de fichiers présents dans le dossier de sortie.
  static Future<int> outputsFileCount() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final zefirDir = Directory('${dir.path}/ZefirOutputs');
      if (!await zefirDir.exists()) return 0;
      int count = 0;
      await for (final entity in zefirDir.list()) {
        if (entity is File) count++;
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  /// Espace total occupé par les fichiers de sortie, en octets.
  static Future<int> outputsTotalSize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final zefirDir = Directory('${dir.path}/ZefirOutputs');
      if (!await zefirDir.exists()) return 0;
      int total = 0;
      await for (final entity in zefirDir.list()) {
        if (entity is File) total += await entity.length();
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Nettoie tous les fichiers de sortie temporaires
  static Future<int> clearOutputsCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final zefirDir = Directory('${dir.path}/ZefirOutputs');
      if (await zefirDir.exists()) {
        int count = 0;
        final entities = zefirDir.listSync();
        for (final entity in entities) {
          if (entity is File) {
            await entity.delete();
            count++;
          }
        }
        return count;
      }
    } catch (_) {}
    return 0;
  }
}

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

  /// Extrait le nom de fichier propre depuis un chemin absolu
  static String getFileName(String path) {
    if (path.isEmpty) return 'inconnu.mp4';
    return path.split(Platform.pathSeparator).last;
  }

  /// Nettoie tous les fichiers de sortie temporaires
  static Future<int> clearOutputsCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final zefirDir = Directory('${dir.path}/ZefirOutputs');
      if (await zefirDir.exists()) {
        int count = 0;
        final entities = zefirDir.listSync();
        for (var entity in entities) {
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

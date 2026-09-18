import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/compression_result.dart';
import '../../services/favorites_service.dart';
import '../../services/history_service.dart';
import '../preview/video_player_screen.dart';
import 'history_detail_screen.dart';

/// Actions partagées sur un enregistrement (ouverture, lecture, partage,
/// favori, suppression) réutilisées par Historique, Favoris et Recherche
/// afin de garantir un comportement identique dans toute l'application.
abstract final class HistoryActions {
  /// Ouvre l'écran de détail.
  static Future<void> open(BuildContext context, CompressionResult item) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryDetailScreen(result: item)),
    );
  }

  /// Lance la lecture du fichier compressé dans le lecteur intégré.
  static Future<void> play(
    BuildContext context,
    CompressionResult item,
  ) async {
    final file = File(item.compressedPath);
    if (!await file.exists()) {
      if (context.mounted) {
        _snack(context, 'Fichier compressé introuvable sur le disque local.');
      }
      return;
    }
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          path: item.compressedPath,
          title: item.fileName,
        ),
      ),
    );
  }

  /// Partage le fichier compressé via la feuille système.
  static Future<void> share(
    BuildContext context,
    CompressionResult item,
  ) async {
    final file = File(item.compressedPath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(item.compressedPath)],
        text: 'Vidéo : ${item.fileName}',
      );
    } else if (context.mounted) {
      _snack(context, 'Fichier introuvable pour le partage.');
    }
  }

  /// Ajoute / retire l'enregistrement des favoris avec retour visuel.
  static Future<void> toggleFavorite(
    BuildContext context,
    CompressionResult item,
  ) async {
    final favorites = FavoritesService();
    await favorites.toggle(item.id);
    if (!context.mounted) return;
    _snack(
      context,
      favorites.isFavorite(item.id)
          ? 'Ajouté aux favoris.'
          : 'Retiré des favoris.',
    );
  }

  /// Demande confirmation puis supprime l'enregistrement, son fichier
  /// compressé et son marque-page de favori.
  static Future<void> confirmDelete(
    BuildContext context,
    CompressionResult item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer ce résultat ?'),
        content: Text(
          '« ${item.fileName} » sera retiré de l\'historique et son fichier '
          'compressé effacé du stockage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await HistoryService().deleteRecord(item.id);
    await FavoritesService().removeAll([item.id]);
    if (!context.mounted) return;
    _snack(context, '« ${item.fileName} » supprimé.');
  }

  static void _snack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

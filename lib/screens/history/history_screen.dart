import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/compression_result.dart';
import '../../services/history_service.dart';
import 'widgets/history_item_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();

  @override
  void initState() {
    super.initState();
    if (!_historyService.isLoaded) {
      _historyService.loadHistory();
    }
  }

  Future<void> _openFile(CompressionResult item) async {
    final file = File(item.compressedPath);
    if (await file.exists()) {
      await OpenFilex.open(item.compressedPath);
    } else {
      _showSnackbar('Fichier compressé introuvable sur le disque local.');
    }
  }

  Future<void> _shareFile(CompressionResult item) async {
    final file = File(item.compressedPath);
    if (await file.exists()) {
      await Share.shareXFiles(
        [XFile(item.compressedPath)],
        text: 'Vidéo : ${item.fileName}',
      );
    } else {
      _showSnackbar('Fichier source introuvable pour le partage.');
    }
  }

  Future<void> _confirmDelete(CompressionResult item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        title: const Text(
          'SUPPRESSION',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        content: Text(
          'Supprimer "${item.fileName}" de l\'historique et effacer le fichier compressé ?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULER', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('SUPPRIMER', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.deleteRecord(item.id);
      _showSnackbar('Élément supprimé de l\'historique.');
    }
  }

  Future<void> _confirmClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        title: const Text(
          'EFFACER TOUT L\'HISTORIQUE',
          style: TextStyle(
            color: AppColors.danger,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        content: const Text(
          'Cette action va effacer tous les enregistrements et purger les fichiers compressés associés.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULER', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('TOUT EFFACER', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.clearAll();
      _showSnackbar('Historique entièrement purgé.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORIQUE'),
        actions: [
          ListenableBuilder(
            listenable: _historyService,
            builder: (context, _) {
              if (_historyService.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, size: 22, color: AppColors.danger),
                tooltip: 'Purger tout l\'historique',
                onPressed: _confirmClearAll,
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _historyService,
        builder: (context, _) {
          final items = _historyService.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 1),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    child: const Icon(
                      Icons.history_outlined,
                      size: 28,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AUCUN ENREGISTREMENT',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Les vidéos compressées apparaîtront dans ce journal.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          final totalSavedStr = Formatters.formatBytes(_historyService.totalSavedBytes);

          return CustomScrollView(
            slivers: [
              // Summary Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border, width: 1),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ÉCONOMIE TOTALE CUMULÉE',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              totalSavedStr,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'FICHIERS TRAITÉS',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${items.length}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Items List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HistoryItemTile(
                          item: item,
                          onOpen: () => _openFile(item),
                          onShare: () => _shareFile(item),
                          onDelete: () => _confirmDelete(item),
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }
}

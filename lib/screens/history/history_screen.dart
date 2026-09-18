import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/formatters.dart';
import '../../models/compression_result.dart';
import '../../services/history_service.dart';
import 'history_detail_screen.dart';
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

  Future<void> _openDetail(CompressionResult item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HistoryDetailScreen(result: item)),
    );
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
        title: const Text('Suppression'),
        content: Text('Supprimer "${item.fileName}" et son fichier ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.deleteRecord(item.id);
      _showSnackbar('Element supprime.');
    }
  }

  Future<void> _confirmClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tout effacer ?'),
        content: const Text('Effacer tout l\'historique et les fichiers ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _historyService.clearAll();
      _showSnackbar('Historique purge.');
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
        title: const Text('Historique'),
        actions: [
          ListenableBuilder(
            listenable: _historyService,
            builder: (context, _) {
              if (_historyService.items.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(Icons.delete_sweep_outlined,
                    color: Theme.of(context).colorScheme.error),
                tooltip: 'Tout effacer',
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
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_outlined, size: 40),
                  SizedBox(height: 16),
                  Text('Aucun enregistrement'),
                  SizedBox(height: 6),
                  Text('Les videos compressees apparaitront ici.'),
                ],
              ),
            );
          }

          final totalSavedStr = Formatters.formatBytes(_historyService.totalSavedBytes);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Economie totale'),
                              Text(totalSavedStr),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Fichiers'),
                              Text('${items.length}'),
                            ],
                          ),
                        ],
                      ),
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
                          onOpen: () => _openDetail(item),
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

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/file_helper.dart';
import '../../core/utils/formatters.dart';
import '../../models/compression_preset.dart';
import '../../services/favorites_service.dart';
import '../../services/history_service.dart';
import '../../services/preferences_service.dart';
import '../../services/thumbnail_service.dart';
import '../home_navigation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedPresetId = 'balanced';
  bool _deleteOriginal = false;
  bool _keepScreenOn = true;
  bool _autoShare = false;
  int _targetHeight = AppConstants.defaultTargetHeight;
  String _outputFormat = 'mp4';
  int _audioBitrate = AppConstants.defaultAudioBitrate;
  bool _hwAccel = false;
  bool _showThumbnails = true;
  bool _autoPlay = false;
  String _defaultSort = AppConstants.defaultSort;
  int _thumbnailCacheSize = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final presetId = await PreferencesService.getDefaultPreset();
    final deleteOrig = await PreferencesService.getDeleteOriginal();
    final keepOn = await PreferencesService.getKeepScreenOn();
    final autoShare = await PreferencesService.getAutoShare();
    final targetHeight = await PreferencesService.getTargetHeight();
    final outputFormat = await PreferencesService.getOutputFormat();
    final audioBitrate = await PreferencesService.getCustomAudioBitrate();
    final hwAccel = await PreferencesService.getHardwareAccel();
    final showThumbnails = await PreferencesService.getShowThumbnails();
    final autoPlay = await PreferencesService.getAutoPlayResult();
    final defaultSort = await PreferencesService.getDefaultSort();
    final thumbSize = await ThumbnailService.cacheSize();

    if (mounted) {
      setState(() {
        _selectedPresetId = presetId;
        _deleteOriginal = deleteOrig;
        _keepScreenOn = keepOn;
        _autoShare = autoShare;
        _targetHeight = targetHeight;
        _outputFormat = outputFormat;
        _audioBitrate = audioBitrate;
        _hwAccel = hwAccel;
        _showThumbnails = showThumbnails;
        _autoPlay = autoPlay;
        _defaultSort = defaultSort;
        _thumbnailCacheSize = thumbSize;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDefaultPreset(String presetId) async {
    setState(() {
      _selectedPresetId = presetId;
    });
    await PreferencesService.setDefaultPreset(presetId);
  }

  Future<void> _updateDeleteOriginal(bool value) async {
    setState(() {
      _deleteOriginal = value;
    });
    await PreferencesService.setDeleteOriginal(value);
  }

  Future<void> _updateKeepScreenOn(bool value) async {
    setState(() {
      _keepScreenOn = value;
    });
    await PreferencesService.setKeepScreenOn(value);
  }

  Future<void> _updateAutoShare(bool value) async {
    setState(() {
      _autoShare = value;
    });
    await PreferencesService.setAutoShare(value);
  }

  Future<void> _updateTargetHeight(int value) async {
    setState(() {
      _targetHeight = value;
    });
    await PreferencesService.setTargetHeight(value);
  }

  Future<void> _updateOutputFormat(String value) async {
    setState(() {
      _outputFormat = value;
    });
    await PreferencesService.setOutputFormat(value);
  }

  Future<void> _updateAudioBitrate(int value) async {
    setState(() {
      _audioBitrate = value;
    });
    await PreferencesService.setCustomAudioBitrate(value);
  }

  Future<void> _updateHwAccel(bool value) async {
    setState(() {
      _hwAccel = value;
    });
    await PreferencesService.setHardwareAccel(value);
  }

  Future<void> _updateShowThumbnails(bool value) async {
    setState(() {
      _showThumbnails = value;
    });
    await PreferencesService.setShowThumbnails(value);
  }

  Future<void> _updateAutoPlay(bool value) async {
    setState(() {
      _autoPlay = value;
    });
    await PreferencesService.setAutoPlayResult(value);
  }

  Future<void> _updateDefaultSort(String value) async {
    setState(() {
      _defaultSort = value;
    });
    await PreferencesService.setDefaultSort(value);
  }


  Future<void> _clearCache() async {
    final count = await FileHelper.clearOutputsCache();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count fichier(s) temporaire(s) purgé(s).'),
        ),
      );
    }
  }

  Future<void> _clearThumbnails() async {
    final count = await ThumbnailService.clearCache();
    final size = await ThumbnailService.cacheSize();
    if (mounted) {
      setState(() => _thumbnailCacheSize = size);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count miniature(s) supprimée(s).')),
      );
    }
  }

  Future<void> _confirmDanger({
    required String title,
    required String message,
    required String actionLabel,
    required Future<void> Function() onConfirm,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    if (confirmed == true) await onConfirm();
  }

  Future<void> _clearHistory() async {
    await _confirmDanger(
      title: 'Effacer l\'historique ?',
      message: 'Tous les enregistrements de compression seront supprimés. '
          'Les fichiers compressés restent sur le stockage.',
      actionLabel: 'Effacer',
      onConfirm: () async {
        final ids = HistoryService().items.map((e) => e.id).toList();
        await HistoryService().clearAll(deleteFiles: false);
        await FavoritesService().removeAll(ids);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historique effacé.')),
          );
        }
      },
    );
  }

  Future<void> _clearFavorites() async {
    await _confirmDanger(
      title: 'Vider les favoris ?',
      message: 'Les vidéos retirées resteront dans l\'historique.',
      actionLabel: 'Vider',
      onConfirm: () async {
        await FavoritesService().clearAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favoris vidés.')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      appBar: const ZefirTopBar(title: 'Paramètres'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('Profil par defaut'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profil par defaut',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      DropdownButton<String>(
                        value: _selectedPresetId,
                        underline: const SizedBox.shrink(),
                        items: CompressionPreset.allPresets.map((preset) {
                          return DropdownMenuItem<String>(
                            value: preset.id,
                            child: Text(preset.label),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) _updateDefaultPreset(val);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Supprimer la source'),
                  subtitle: const Text(
                      'Efface le fichier original apres compression'),
                  value: _deleteOriginal,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onChanged: _updateDeleteOriginal,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Partage automatique'),
                  subtitle:
                      const Text('Ouvre le partage apres chaque succes'),
                  value: _autoShare,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onChanged: _updateAutoShare,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Ecran actif'),
                  subtitle:
                      const Text('Garde le mode immersif pendant le rendu'),
                  value: _keepScreenOn,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onChanged: _updateKeepScreenOn,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Resolution cible'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<int>(
                segments: AppConstants.targetHeights
                    .map((h) => ButtonSegment<int>(
                        value: h, label: Text('${h}p')))
                    .toList(),
                selected: {_targetHeight},
                onSelectionChanged: (s) => _updateTargetHeight(s.first),
              ),
            ),
          ),

          const SizedBox(height: 16),
          _buildSectionHeader('Format de sortie'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: AppConstants.outputFormats
                    .map((f) => ButtonSegment<String>(
                        value: f, label: Text(f.toUpperCase())))
                    .toList(),
                selected: {_outputFormat},
                onSelectionChanged: (s) => _updateOutputFormat(s.first),
              ),
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Encodage avancé'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Débit audio',
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: SegmentedButton<int>(
                    segments: AppConstants.audioBitrates
                        .map((b) => ButtonSegment<int>(
                            value: b, label: Text('$b k')))
                        .toList(),
                    selected: {_audioBitrate},
                    onSelectionChanged: (s) => _updateAudioBitrate(s.first),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Accélération matérielle'),
                  subtitle: const Text(
                      'Utilise l\'encodeur matériel lorsqu\'il est disponible'),
                  value: _hwAccel,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onChanged: _updateHwAccel,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Affichage & lecture'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Miniatures'),
                  subtitle:
                      const Text('Affiche un aperçu des vidéos (cache local)'),
                  value: _showThumbnails,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onChanged: _updateShowThumbnails,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Lecture automatique'),
                  subtitle: const Text(
                      'Ouvre le lecteur après chaque compression réussie'),
                  value: _autoPlay,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onChanged: _updateAutoPlay,
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tri par défaut',
                          style: Theme.of(context).textTheme.titleSmall),
                      DropdownButton<String>(
                        value: AppConstants.sortLabels
                                .containsKey(_defaultSort)
                            ? _defaultSort
                            : AppConstants.defaultSort,
                        underline: const SizedBox.shrink(),
                        items: AppConstants.sortLabels.entries
                            .map((e) => DropdownMenuItem<String>(
                                value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) _updateDefaultSort(val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Maintenance du stockage'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('Purger les sorties'),
                  subtitle: const Text('Supprime les fichiers compressés '
                      'considérés comme temporaires'),
                  trailing: FilledButton(
                    onPressed: _clearCache,
                    child: const Text('Purger'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Miniatures en cache'),
                  subtitle:
                      Text('Occupe ${Formatters.formatBytes(_thumbnailCacheSize)}'),
                  trailing: FilledButton.tonal(
                    onPressed: _clearThumbnails,
                    child: const Text('Vider'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Zone de danger'),
          const SizedBox(height: 8),
          Card(
            color: scheme.errorContainer,
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(Icons.history_rounded,
                      color: scheme.onErrorContainer),
                  title: Text('Effacer l\'historique',
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      )),
                  subtitle: Text(
                      'Supprime tous les enregistrements (fichiers conservés)',
                      style: TextStyle(
                          color:
                              scheme.onErrorContainer.withValues(alpha: 0.8))),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_forever_rounded,
                        color: scheme.onErrorContainer),
                    tooltip: 'Effacer',
                    onPressed: _clearHistory,
                  ),
                ),
                Divider(
                    height: 1,
                    color: scheme.onErrorContainer.withValues(alpha: 0.2)),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(Icons.favorite_rounded,
                      color: scheme.onErrorContainer),
                  title: Text('Vider les favoris',
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      )),
                  subtitle: Text('Retire toutes les vidéos des favoris',
                      style: TextStyle(
                          color:
                              scheme.onErrorContainer.withValues(alpha: 0.8))),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_sweep_rounded,
                        color: scheme.onErrorContainer),
                    tooltip: 'Vider',
                    onPressed: _clearFavorites,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Specifications & credits'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSpecRow(context, 'Application', AppConstants.appName),
                  const Divider(height: 18),
                  _buildSpecRow(context, 'Version',
                      '${AppConstants.appVersion} (Build ${AppConstants.buildNumber})'),
                  const Divider(height: 18),
                  _buildSpecRow(context, 'Createur', AppConstants.creatorName,
                      isHighlighted: true),
                  const Divider(height: 18),
                  _buildSpecRow(
                      context, 'Package', AppConstants.packageId),
                  const Divider(height: 18),
                  _buildSpecRow(
                      context, 'Moteur', AppConstants.engineName),
                  const Divider(height: 18),
                  _buildSpecRow(context, 'Confidentialite',
                      'Traitement 100% local'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              '${AppConstants.appName} • Par ${AppConstants.creatorName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }

  Widget _buildSpecRow(BuildContext context, String label, String value,
      {bool isHighlighted = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isHighlighted ? scheme.primary : scheme.onSurface,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

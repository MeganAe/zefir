import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/file_helper.dart';
import '../../models/compression_preset.dart';
import '../../services/preferences_service.dart';
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

    if (mounted) {
      setState(() {
        _selectedPresetId = presetId;
        _deleteOriginal = deleteOrig;
        _keepScreenOn = keepOn;
        _autoShare = autoShare;
        _targetHeight = targetHeight;
        _outputFormat = outputFormat;
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

          _buildSectionHeader('Maintenance du stockage'),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(Icons.cleaning_services_outlined),
              title: const Text('Purger le cache'),
              subtitle: const Text('Supprime les fichiers temporaires'),
              trailing: FilledButton(
                onPressed: _clearCache,
                child: const Text('Purger'),
              ),
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

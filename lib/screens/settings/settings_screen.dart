import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_helper.dart';
import '../../models/compression_preset.dart';
import '../../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedPresetId = 'balanced';
  bool _deleteOriginal = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final presetId = await PreferencesService.getDefaultPreset();
    final deleteOrig = await PreferencesService.getDeleteOriginal();

    if (mounted) {
      setState(() {
        _selectedPresetId = presetId;
        _deleteOriginal = deleteOrig;
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PARAMÈTRES & SYSTÈME'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section Configuration
          _buildSectionHeader('CONFIGURATION D\'ENCODAGE'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROFIL PAR DÉFAUT',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Profil sélectionné à l\'ouverture',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      DropdownButton<String>(
                        value: _selectedPresetId,
                        dropdownColor: AppColors.surfaceElevated,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
                        items: CompressionPreset.allPresets.map((preset) {
                          return DropdownMenuItem<String>(
                            value: preset.id,
                            child: Text(
                              preset.label,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                            ),
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
                  title: const Text(
                    'SUPPRESSION DE LA SOURCE',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Efface le fichier original après succès de compression',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  value: _deleteOriginal,
                  activeColor: AppColors.accent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onChanged: _updateDeleteOriginal,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Maintenance
          _buildSectionHeader('MAINTENANCE DU STOCKAGE'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.warning, size: 22),
              title: const Text(
                'PURGER LE CACHE DE RENDU',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Supprime les flux temporaires résiduels du disque',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              trailing: OutlinedButton(
                onPressed: _clearCache,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('PURGER', style: TextStyle(fontSize: 11)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section Spécifications & Crédits
          _buildSectionHeader('SPÉCIFICATIONS TECHNIQUES & CRÉDITS'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSpecRow('APPLICATION', AppConstants.appName),
                const Divider(height: 18),
                _buildSpecRow('VERSION', '${AppConstants.appVersion} (Build ${AppConstants.buildNumber})'),
                const Divider(height: 18),
                _buildSpecRow('CRÉATEUR & LEAD DEV', AppConstants.creatorName, isHighlighted: true),
                const Divider(height: 18),
                _buildSpecRow('PACKAGE ID', AppConstants.packageId),
                const Divider(height: 18),
                _buildSpecRow('MOTEUR D\'ENCODAGE', AppConstants.engineName),
                const Divider(height: 18),
                _buildSpecRow('CONFIDENTIALITÉ', 'Traitement 100% Hors-Ligne (On-Device)'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Architectural Footer Quote
          Center(
            child: Text(
              '${AppConstants.appName} • Conçu par ${AppConstants.creatorName}',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
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
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? AppColors.accent : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

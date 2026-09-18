import 'package:flutter/material.dart';
import '../../../models/compression_preset.dart';

class PresetSelector extends StatelessWidget {
  final CompressionPreset selectedPreset;
  final ValueChanged<CompressionPreset> onSelectPreset;
  final bool isEnabled;

  const PresetSelector({
    super.key,
    required this.selectedPreset,
    required this.onSelectPreset,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text('Profil d\'encodage'),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: CompressionPreset.allPresets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final preset = CompressionPreset.allPresets[index];
            final isSelected = preset.id == selectedPreset.id;

            return InkWell(
              onTap: isEnabled ? () => onSelectPreset(preset) : null,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      size: 20,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                preset.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                              Text(
                                preset.technicalSummary,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preset.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

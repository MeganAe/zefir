import 'package:flutter/material.dart';

/// Groupe de 2 boutons connectés M3 Expressive : coins externes pill, coins internes 8dp.
class ConnectedButtonGroup extends StatelessWidget {
  final String firstLabel;
  final IconData firstIcon;
  final VoidCallback? onFirst;
  final String secondLabel;
  final IconData secondIcon;
  final VoidCallback? onSecond;

  const ConnectedButtonGroup({
    super.key,
    required this.firstLabel,
    required this.firstIcon,
    required this.onFirst,
    required this.secondLabel,
    required this.secondIcon,
    required this.onSecond,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: onFirst,
          icon: Icon(firstIcon, size: 18),
          label: Text(firstLabel),
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                bottomLeft: Radius.circular(28),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        const SizedBox(width: 3),
        FilledButton.icon(
          onPressed: onSecond,
          icon: Icon(secondIcon, size: 18),
          label: Text(secondLabel),
          style: FilledButton.styleFrom(
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                topRight: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
      ],
    );
  }
}

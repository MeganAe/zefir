import 'package:flutter/material.dart';

/// Logo Zefir — éclair « Z » Material Symbols Rounded sur fond primary.
class ZefirLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const ZefirLogo({super.key, this.size = 40, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(
            Icons.bolt_rounded,
            color: scheme.onPrimary,
            size: size * 0.58,
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 10),
          Text(
            'Zefir',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ],
    );
  }
}

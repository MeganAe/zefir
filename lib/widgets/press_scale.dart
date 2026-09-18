import 'package:flutter/material.dart';

/// Enveloppe tactile M3 Expressive : ripple + léger rétrécissement à l'appui.
///
/// Le facteur d'échelle reste volontairement discret (0,97) pour respecter
/// `MotionScheme.standard()` : état pressé marqué, aucune animation rebondissante.
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final BorderRadius? borderRadius;

  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.borderRadius,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null && widget.onLongPress == null) {
      return widget.child;
    }

    return AnimatedScale(
      scale: _pressed ? widget.scale : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        child: widget.child,
      ),
    );
  }
}

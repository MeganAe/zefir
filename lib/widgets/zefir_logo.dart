import 'package:flutter/material.dart';

/// Marque Zefir : deux bandes de compression convergent vers une image légère.
/// Le dessin est vectoriel et reste net à toutes les tailles.
class ZefirLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const ZefirLogo({super.key, this.size = 40, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(size: Size.square(size), painter: _ZefirMarkPainter()),
        if (showWordmark) ...[
          SizedBox(width: size * .24),
          Text(
            'zefir',
            style: TextStyle(
              fontFamily: 'serif',
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: size * .68,
              height: 1,
              letterSpacing: -.6,
            ),
          ),
        ],
      ],
    );
  }
}

class _ZefirMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width;
    final dark = Paint()..color = const Color(0xFF14213D);
    final lime = Paint()..color = const Color(0xFFD6F25A);
    final coral = Paint()..color = const Color(0xFFF26B4B);
    final radius = Radius.circular(unit * .22);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, radius), dark);

    final upper = Path()
      ..moveTo(unit * .18, unit * .27)
      ..lineTo(unit * .82, unit * .27)
      ..lineTo(unit * .67, unit * .43)
      ..lineTo(unit * .18, unit * .43)
      ..close();
    canvas.drawPath(upper, lime);

    final lower = Path()
      ..moveTo(unit * .18, unit * .57)
      ..lineTo(unit * .82, unit * .57)
      ..lineTo(unit * .67, unit * .73)
      ..lineTo(unit * .18, unit * .73)
      ..close();
    canvas.drawPath(lower, coral);

    canvas.drawCircle(Offset(unit * .72, unit * .5), unit * .075,
        Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

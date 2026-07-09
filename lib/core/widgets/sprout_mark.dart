import 'package:flutter/material.dart';

/// Placeholder for the real Orynta sprout mark described in
/// Orynta_Brand_Guide.md §2 (two-leaf silhouette). Swap for the actual
/// vector asset once designed — kept as a single solid-color shape so it
/// still reads correctly at small sizes per the guide's construction notes.
class SproutMark extends StatelessWidget {
  final double size;
  final Color color;

  const SproutMark({super.key, this.size = 64, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SproutPainter(color: color)),
    );
  }
}

class _SproutPainter extends CustomPainter {
  final Color color;
  _SproutPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Stem
    final stemPath = Path()
      ..moveTo(w * 0.5, h * 0.95)
      ..quadraticBezierTo(w * 0.5, h * 0.55, w * 0.5, h * 0.35)
      ..lineTo(w * 0.56, h * 0.35)
      ..quadraticBezierTo(w * 0.56, h * 0.6, w * 0.56, h * 0.95)
      ..close();
    canvas.drawPath(stemPath, paint);

    // Left leaf
    final leftLeaf = Path()
      ..moveTo(w * 0.53, h * 0.4)
      ..quadraticBezierTo(w * 0.08, h * 0.36, w * 0.12, h * 0.05)
      ..quadraticBezierTo(w * 0.5, h * 0.08, w * 0.53, h * 0.4)
      ..close();
    canvas.drawPath(leftLeaf, paint);

    // Right leaf
    final rightLeaf = Path()
      ..moveTo(w * 0.53, h * 0.32)
      ..quadraticBezierTo(w * 0.92, h * 0.22, w * 0.85, h * 0.0)
      ..quadraticBezierTo(w * 0.5, h * 0.02, w * 0.53, h * 0.32)
      ..close();
    canvas.drawPath(rightLeaf, paint);
  }

  @override
  bool shouldRepaint(covariant _SproutPainter oldDelegate) =>
      oldDelegate.color != color;
}

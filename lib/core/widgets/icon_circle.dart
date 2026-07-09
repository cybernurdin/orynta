import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The app's one consistent decorative motif per Orynta_Brand_Guide.md §5:
/// solid-fill rounded icon inside a solid-color circle. Repeat everywhere
/// rather than introducing new decorative devices.
class IconCircle extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  const IconCircle({
    super.key,
    required this.icon,
    this.background = AppColors.forest,
    this.foreground = AppColors.white,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: foreground, size: size * 0.52),
    );
  }
}

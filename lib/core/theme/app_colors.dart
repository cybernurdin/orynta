import 'package:flutter/material.dart';

/// Orynta brand palette — "Forest & Moss".
/// See Orynta_Brand_Guide.md §3.
class AppColors {
  AppColors._();

  static const Color forest = Color(0xFF2C5F2D);
  static const Color forestDark = Color(0xFF1B3D1C);
  static const Color moss = Color(0xFF97BC62);
  static const Color cream = Color(0xFFF7F6F1);
  static const Color amber = Color(0xFFC97A2B);
  static const Color ink = Color(0xFF222A1F);
  static const Color grey = Color(0xFF6B7568);
  static const Color white = Color(0xFFFFFFFF);

  // Confidence-band colors — functional, keep consistent everywhere.
  static const Color confidenceHigh = Color(0xFF4C8C3B);
  static const Color confidenceMedium = Color(0xFFC97A2B);
  static const Color confidenceLow = Color(0xFFB4462E);

  static Color confidenceColor(double score) {
    if (score >= 0.75) return confidenceHigh;
    if (score >= 0.5) return confidenceMedium;
    return confidenceLow;
  }
}

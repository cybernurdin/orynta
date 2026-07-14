import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App-wide theme, matching Orynta_Brand_Guide.md §4 & §6.
/// Mobile app defaults to light/Cream mode for outdoor daylight legibility;
/// Forest Dark is reserved for onboarding/splash only.
class AppTheme {
  AppTheme._();

  static const String _headlineFont = 'Cambria';

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.forest,
        secondary: AppColors.moss,
        surface: AppColors.cream,
        error: AppColors.confidenceLow,
        onPrimary: AppColors.white,
        onSecondary: AppColors.ink,
        onSurface: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _headlineFont,
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
          .copyWith(
            headlineMedium: const TextStyle(
              fontFamily: _headlineFont,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
            titleLarge: const TextStyle(
              fontFamily: _headlineFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
            bodyLarge: const TextStyle(fontSize: 16, color: AppColors.ink),
            bodyMedium: const TextStyle(fontSize: 14, color: AppColors.ink),
            bodySmall: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forest,
          side: const BorderSide(color: AppColors.forest, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.forest,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(color: Color(0x1A222A1F)),
    );
  }

  /// Onboarding/splash always use this regardless of the user's Dark Mode
  /// preference — per brand guide §7. Also selectable as the app-wide Dark
  /// Mode theme from Profile > Settings, so it's kept at full parity with
  /// `light()` rather than as a partial/decorative-only theme.
  static const Color _surfaceDark = Color(0xFF16311A);

  static ThemeData dark() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.forestDark,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.moss,
        secondary: AppColors.amber,
        surface: AppColors.forestDark,
        error: AppColors.confidenceLow,
        onPrimary: AppColors.forestDark,
        onSecondary: AppColors.forestDark,
        onSurface: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.forestDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _headlineFont,
          color: AppColors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.white, displayColor: AppColors.white)
          .copyWith(
            headlineMedium: const TextStyle(
              fontFamily: _headlineFont,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            titleLarge: const TextStyle(
              fontFamily: _headlineFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            bodyLarge: const TextStyle(fontSize: 16, color: AppColors.white),
            bodyMedium: const TextStyle(fontSize: 14, color: AppColors.white),
            bodySmall: TextStyle(fontSize: 12, color: AppColors.white.withValues(alpha: 0.7)),
          ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.moss,
          foregroundColor: AppColors.forestDark,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.moss,
          side: const BorderSide(color: AppColors.moss, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surfaceDark,
        selectedItemColor: AppColors.moss,
        unselectedItemColor: AppColors.white.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      dividerTheme: DividerThemeData(color: AppColors.white.withValues(alpha: 0.1)),
    );
  }
}

import 'package:flutter/material.dart';

/// Material 3 Expressive — Theme clair bleu Zefir.
/// Les ecrans utilisent les roles du ColorScheme, jamais de couleurs en dur.
class ZefirColors {
  static const Color primary = Color(0xFF0B57D0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD3E3FD);
  static const Color onPrimaryContainer = Color(0xFF041E49);
  static const Color secondary = Color(0xFF5A5C7C);
  static const Color secondaryContainer = Color(0xFFDCE2F9);
  static const Color onSecondaryContainer = Color(0xFF131C2B);
  static const Color tertiaryContainer = Color(0xFFFFD8EE);
  static const Color onTertiaryContainer = Color(0xFF2E1125);
  static const Color surface = Color(0xFFFAF9FD);
  static const Color surfaceLow = Color(0xFFF3F3FA);
  static const Color surfaceDefault = Color(0xFFEEEDF3);
  static const Color surfaceHigh = Color(0xFFE9E8EF);
  static const Color surfaceHighest = Color(0xFFE3E2E6);
  static const Color onSurface = Color(0xFF1B1B1F);
  static const Color onSurfaceVariant = Color(0xFF44474E);
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6D0);
  static const Color inverseSurface = Color(0xFF303034);
  static const Color inverseOnSurface = Color(0xFFF2F0F4);
  static const Color inversePrimary = Color(0xFFA8C7FA);
  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onErrorContainer = Color(0xFF410E0B);
}

/// Compat ascendante : ancien code AppColors.* redirige vers le scheme clair.
class AppColors {
  static const Color background = ZefirColors.surface;
  static const Color surface = ZefirColors.surfaceLow;
  static const Color surfaceElevated = ZefirColors.surfaceHigh;
  static const Color border = ZefirColors.outlineVariant;
  static const Color borderFocused = ZefirColors.outline;
  static const Color textPrimary = ZefirColors.onSurface;
  static const Color textSecondary = ZefirColors.onSurfaceVariant;
  static const Color textMuted = ZefirColors.outline;
  static const Color accent = ZefirColors.primary;
  static const Color accentSubtle = ZefirColors.primaryContainer;
  static const Color primaryAction = ZefirColors.primary;
  static const Color danger = ZefirColors.error;
  static const Color warning = Color(0xFF7A4A00);
  static const Color info = ZefirColors.primary;
}

class AppTheme {
  static ColorScheme get lightScheme => const ColorScheme.light(
        primary: ZefirColors.primary,
        onPrimary: ZefirColors.onPrimary,
        primaryContainer: ZefirColors.primaryContainer,
        onPrimaryContainer: ZefirColors.onPrimaryContainer,
        secondary: ZefirColors.secondary,
        secondaryContainer: ZefirColors.secondaryContainer,
        onSecondaryContainer: ZefirColors.onSecondaryContainer,
        tertiaryContainer: ZefirColors.tertiaryContainer,
        onTertiaryContainer: ZefirColors.onTertiaryContainer,
        surface: ZefirColors.surface,
        onSurface: ZefirColors.onSurface,
        surfaceContainerLowest: ZefirColors.surface,
        surfaceContainerLow: ZefirColors.surfaceLow,
        surfaceContainer: ZefirColors.surfaceDefault,
        surfaceContainerHigh: ZefirColors.surfaceHigh,
        surfaceContainerHighest: ZefirColors.surfaceHighest,
        onSurfaceVariant: ZefirColors.onSurfaceVariant,
        outline: ZefirColors.outline,
        outlineVariant: ZefirColors.outlineVariant,
        inverseSurface: ZefirColors.inverseSurface,
        onInverseSurface: ZefirColors.inverseOnSurface,
        inversePrimary: ZefirColors.inversePrimary,
        error: ZefirColors.error,
        onError: ZefirColors.onError,
        errorContainer: ZefirColors.errorContainer,
        onErrorContainer: ZefirColors.onErrorContainer,
      );

  static ThemeData get lightTheme {
    final scheme = lightScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        elevation: 0,
        height: 80,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: const StadiumBorder(),
        ),
      ),
      tonalButtonTheme: TonalButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outline, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.inverseOnSurface, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}

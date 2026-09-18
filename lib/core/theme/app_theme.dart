import 'package:flutter/material.dart';

/// La palette Zefir : encre profonde, papier chaud et accent citron.
class ZefirColors {
  static const ink = Color(0xFF14213D);
  static const paper = Color(0xFFF7F5F0);
  static const canvas = Color(0xFFECE8DF);
  static const lime = Color(0xFFD6F25A);
  static const coral = Color(0xFFF26B4B);
  static const mutedInk = Color(0xFF647083);
  static const line = Color(0xFFD5D0C6);
}

/// Alias conservés pour les composants existants.
class AppColors {
  static const background = ZefirColors.paper;
  static const surface = Colors.white;
  static const surfaceElevated = ZefirColors.canvas;
  static const border = ZefirColors.line;
  static const borderFocused = ZefirColors.ink;
  static const textPrimary = ZefirColors.ink;
  static const textSecondary = ZefirColors.mutedInk;
  static const textMuted = ZefirColors.mutedInk;
  static const accent = ZefirColors.lime;
  static const accentSubtle = Color(0xFFF0F8C9);
  static const primaryAction = ZefirColors.ink;
  static const danger = ZefirColors.coral;
  static const warning = Color(0xFF9A6700);
  static const info = ZefirColors.ink;
}

class AppTheme {
  static const _scheme = ColorScheme.light(
    primary: ZefirColors.ink,
    onPrimary: Colors.white,
    primaryContainer: ZefirColors.lime,
    onPrimaryContainer: ZefirColors.ink,
    secondary: ZefirColors.coral,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFD8CF),
    onSecondaryContainer: ZefirColors.ink,
    surface: ZefirColors.paper,
    onSurface: ZefirColors.ink,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFFFFEFB),
    surfaceContainer: ZefirColors.canvas,
    surfaceContainerHigh: Color(0xFFE4E0D7),
    surfaceContainerHighest: Color(0xFFDCD7CC),
    onSurfaceVariant: ZefirColors.mutedInk,
    outline: ZefirColors.line,
    outlineVariant: ZefirColors.line,
    error: ZefirColors.coral,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD2),
    onErrorContainer: Color(0xFF5C1B0B),
  );

  static ThemeData get lightTheme {
    final text = Typography.material2021()
        .black
        .copyWith(
          displayLarge:
              const TextStyle(fontFamily: 'serif', fontSize: 42, height: 1.05),
          headlineMedium:
              const TextStyle(fontFamily: 'serif', fontSize: 30, height: 1.1),
          titleLarge: const TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 21,
              fontWeight: FontWeight.w800),
          titleMedium: const TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 16,
              fontWeight: FontWeight.w700),
          bodyMedium: const TextStyle(
              fontFamily: 'sans-serif', fontSize: 14, height: 1.5),
          labelLarge: const TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 13,
              fontWeight: FontWeight.w800),
        )
        .apply(bodyColor: _scheme.onSurface, displayColor: _scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: _scheme,
      scaffoldBackgroundColor: ZefirColors.paper,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: ZefirColors.paper,
        foregroundColor: _scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: _scheme.surfaceContainerLowest,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ZefirColors.line),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(color: ZefirColors.line, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ZefirColors.ink,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: ZefirColors.ink),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ZefirColors.line),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: ZefirColors.ink,
        selectedIconTheme: const IconThemeData(color: ZefirColors.ink),
        unselectedIconTheme: const IconThemeData(color: Color(0xFFBEC6D4)),
        selectedLabelTextStyle: text.labelLarge?.copyWith(color: Colors.white),
        unselectedLabelTextStyle:
            text.labelLarge?.copyWith(color: const Color(0xFFBEC6D4)),
        indicatorColor: ZefirColors.lime,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: ZefirColors.ink,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ZefirColors.lime,
        foregroundColor: ZefirColors.ink,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ZefirColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}

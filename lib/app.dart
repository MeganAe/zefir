import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_navigation_screen.dart';

class ZefirApp extends StatelessWidget {
  const ZefirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zefir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const HomeNavigationScreen(),
    );
  }
}


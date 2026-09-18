import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/favorites_service.dart';
import 'services/history_service.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFEEEDF3),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await PreferencesService.init();
  await HistoryService().loadHistory();
  await FavoritesService().load();

  runApp(const ZefirApp());
}


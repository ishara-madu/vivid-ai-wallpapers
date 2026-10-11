import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  void _handleThemeChange(bool isDark) {
    setState(() {
      _isDark = isDark;
    });
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gazeo - Vivid AI Wallpapers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: MainNavigationScreen(
        isDark: _isDark,
        onThemeChanged: _handleThemeChange,
      ),
    );
  }
}

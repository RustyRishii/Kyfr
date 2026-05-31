import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const KyfrApp());
}

class KyfrApp extends StatefulWidget {
  const KyfrApp({super.key});

  @override
  State<KyfrApp> createState() => _KyfrAppState();
}

class _KyfrAppState extends State<KyfrApp> {
  String? _userName;

  void _handleAuthenticated(String userName) {
    setState(() {
      _userName = userName;
    });
  }

  void _handleLogout() {
    setState(() {
      _userName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'Kyfr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: _userName == null
          ? AuthScreen(onAuthenticated: _handleAuthenticated)
          : HomeShell(userName: _userName!, onLogout: _handleLogout),
    );
  }
}

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
      seedColor: const Color(0xFF14B8A6),
      primary: const Color(0xFF0F766E),
      secondary: const Color(0xFF14B8A6),
      surface: Colors.white,
      onSurface: const Color(0xFF10201D),
    );

    return MaterialApp(
      title: 'Kyfr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF2FBFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2FBFA),
          foregroundColor: Color(0xFF10201D),
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD3F4F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD3F4F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 1.4),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundColor: const Color(0xFF0F766E),
            side: const BorderSide(color: Color(0xFF99F6E4)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xFFCCFBF1),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF134E4A),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 360),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(0, 0.035),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: _userName == null
            ? AuthScreen(
                key: const ValueKey('auth-screen'),
                onAuthenticated: _handleAuthenticated,
              )
            : HomeShell(
                key: const ValueKey('home-shell'),
                userName: _userName!,
                onLogout: _handleLogout,
              ),
      ),
    );
  }
}

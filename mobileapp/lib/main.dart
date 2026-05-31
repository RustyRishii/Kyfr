import 'package:flutter/material.dart';

import 'models/auth_session.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'services/kyfr_api.dart';
import 'services/realtime_client.dart';

void main() {
  runApp(const KyfrApp());
}

class KyfrApp extends StatefulWidget {
  const KyfrApp({super.key, this.apiClient, this.realtimeClient});

  final KyfrApi? apiClient;
  final RealtimeClient? realtimeClient;

  @override
  State<KyfrApp> createState() => _KyfrAppState();
}

class _KyfrAppState extends State<KyfrApp> {
  late final KyfrApi _apiClient;
  late final RealtimeClient _realtimeClient;
  AuthSession? _session;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? HttpKyfrApi();
    _realtimeClient = widget.realtimeClient ?? KyfrRealtimeClient();
  }

  @override
  void dispose() {
    _apiClient.close();
    _realtimeClient.disconnect();
    super.dispose();
  }

  Future<String?> _handleAuthSubmit({
    required bool isLogin,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final session = isLogin
          ? await _apiClient.login(email: email, password: password)
          : await _apiClient.signup(
              name: name,
              email: email,
              password: password,
            );
      if (!mounted) {
        return null;
      }
      setState(() {
        _session = session;
      });
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Unable to connect to Kyfr. Please try again.';
    }
  }

  Future<void> _handleLogout() async {
    await _realtimeClient.disconnect();
    if (!mounted) {
      return;
    }
    setState(() {
      _session = null;
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
        duration: const Duration(milliseconds: 380),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: _session == null
            ? AuthScreen(
                key: const ValueKey('auth-screen'),
                onSubmit: _handleAuthSubmit,
              )
            : HomeShell(
                key: const ValueKey('home-shell'),
                session: _session!,
                apiClient: _apiClient,
                realtimeClient: _realtimeClient,
                onLogout: _handleLogout,
              ),
      ),
    );
  }
}

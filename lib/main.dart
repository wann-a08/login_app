import 'package:flutter/material.dart';

import 'core/app_navigator.dart';
import 'core/app_session.dart';
import 'pages/data_page.dart';
import 'pages/home_input.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/siswa_form_page.dart';

// Class utama aplikasi.
void main() {
  runApp(MyApp(session: AppSession()));
}

// Class untuk mengatur aplikasi, pemulihan sesi, dan route guard.
class MyApp extends StatelessWidget {
  final AppSession session;
  const MyApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Admin',
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/startup',
      onGenerateRoute: (settings) {
        final path = settings.name ?? '/';
        if (path == '/startup') {
          return MaterialPageRoute(builder: (_) => _StartupPage(session: session), settings: settings);
        }
        if (path == '/') {
          return MaterialPageRoute(
            builder: (_) => session.isAuthenticated
                ? HomePage(session: session)
                : LoginPage(session: session),
            settings: settings,
          );
        }
        if (!session.isAuthenticated) {
          return MaterialPageRoute(builder: (_) => LoginPage(session: session), settings: settings);
        }
        switch (path) {
          case '/home':
            return MaterialPageRoute(builder: (_) => HomePage(session: session), settings: settings);
          case '/data':
            return MaterialPageRoute(builder: (_) => const DataPage(), settings: settings);
          case '/inputdata':
            return MaterialPageRoute(builder: (_) => const HomeInputPage(), settings: settings);
          case '/siswa-form':
            return MaterialPageRoute(builder: (_) => const SiswaFormPage(), settings: settings);
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
                body: const Center(child: Text('Halaman yang diminta tidak tersedia.')),
              ),
              settings: settings,
            );
        }
      },
    );
  }
}

// Memeriksa token tersimpan sebelum menampilkan halaman utama.
class _StartupPage extends StatefulWidget {
  final AppSession session;
  const _StartupPage({required this.session});

  @override
  State<_StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<_StartupPage> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    await widget.session.restore();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      widget.session.isAuthenticated ? '/home' : '/',
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

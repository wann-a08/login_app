import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/data_page.dart';
import 'pages/home_input.dart';

// Class utama aplikasi.
void main() {
  runApp(const MyApp());
}

// Class untuk mengatur aplikasi dan routing.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/data': (context) => const DataPage(),
        '/inputdata': (context) => const HomeInputPage(),

      },
    );
  }
}
import 'package:flutter/material.dart';
// import 'package:myapp/pages/login.dart';
import 'package:school_hub/pages/start.dart';
import 'package:school_hub/pages/create_class.dart';
import 'package:school_hub/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const StartPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}


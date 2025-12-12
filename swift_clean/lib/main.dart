import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SwiftConquerApp());
}

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftConquer',
      theme: ThemeData.dark(),
      routes: {
        '/': (_) => const HomeScreen(),
        '/test': (_) => const TestScreen(),
      },
    );
  }
}

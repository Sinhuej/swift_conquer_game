import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const SwiftConquerApp());
}

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftConquer',
      home: const HomeScreen(),
    );
  }
}

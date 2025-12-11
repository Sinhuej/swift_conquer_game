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
      title: "Swift Conquer",
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

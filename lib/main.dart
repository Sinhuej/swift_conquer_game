import 'package:flutter/material.dart';
import 'screens/flame_screen.dart';

void main() {
  runApp(const SwiftConquerApp());
}

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlameScreen(),
    );
  }
}

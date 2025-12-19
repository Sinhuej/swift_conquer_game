import 'package:flutter/material.dart';
import 'screens/flame_screen.dart';

void main() {
  runApp(const SwiftConquerApp());
}

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SwiftConquer',
      theme: ThemeData.dark(),
      home: const FlameScreen(),
    );
  }
}

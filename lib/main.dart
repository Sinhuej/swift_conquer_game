import 'package:flutter/material.dart';
import 'screens/test_screen.dart';

void main() {
  runApp(const SwiftConquerApp());
}

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftConquer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const TestScreen(),
    );
  }
}

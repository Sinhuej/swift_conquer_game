import 'package:flutter/material.dart';

void main() {
  runApp(const SwiftCleanApp());
}

class SwiftCleanApp extends StatelessWidget {
  const SwiftCleanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swift Clean Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Swift Clean Build Test')),
        body: const Center(child: Text('Workflow OK!')),
      ),
    );
  }
}

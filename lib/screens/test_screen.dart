import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SwiftConquer')),
      body: const Center(
        child: Text(
          'SwiftConquer Phase 15 — Build Stable',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

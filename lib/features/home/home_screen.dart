import 'package:flutter/material.dart';
import '../testmap/test_map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Launch Test Map"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TestMapScreen()),
            );
          },
        ),
      ),
    );
  }
}

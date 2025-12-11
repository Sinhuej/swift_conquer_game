import 'package:flutter/material.dart';
import 'test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Swift Conquer")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Run Test Screen"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TestScreen()),
            );
          },
        ),
      ),
    );
  }
}

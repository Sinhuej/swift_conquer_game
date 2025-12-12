import 'package:flutter/material.dart';
import 'test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer Home")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Launch Test Screen"),
          onPressed: () => Navigator.pushNamed(context, '/test'),
        ),
      ),
    );
  }
}

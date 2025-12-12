import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/test'),
          child: const Text("Launch Engine Test"),
        ),
      ),
    );
  }
}

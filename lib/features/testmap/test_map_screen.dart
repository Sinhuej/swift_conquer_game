import 'package:flutter/material.dart';

class TestMapScreen extends StatelessWidget {
  const TestMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Map")),
      body: const Center(
        child: Text("Test Map Loaded — Engine placeholder OK"),
      ),
    );
  }
}

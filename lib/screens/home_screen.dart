import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Swift Conquer")),
      body: const Center(
        child: Text("Swift Conquer Base Build Ready"),
      ),
    );
  }
}

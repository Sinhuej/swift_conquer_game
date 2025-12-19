import 'package:flutter/material.dart';

class FlameScreen extends StatelessWidget {
  const FlameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwiftConquer'),
      ),
      body: const Center(
        child: Text(
          'SwiftConquer Core Engine Running',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

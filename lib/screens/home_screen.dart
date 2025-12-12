import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.pushNamed(context, '/test'),
          child: const Text('Launch Test Map'),
        ),
      ),
    );
  }
}

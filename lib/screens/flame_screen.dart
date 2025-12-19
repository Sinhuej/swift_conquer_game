import 'package:flutter/material.dart';

/// Temporary screen used to keep CI GREEN while we iterate.
/// We'll wire Flame in a later phase once APIs are aligned.
class FlameScreen extends StatelessWidget {
  const FlameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "SwiftConquer is GREEN ✅\n(Flame wiring comes next)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

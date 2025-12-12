import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import '../game/swift_conquer_game.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Map")),
      body: GameWidget(game: SwiftConquerGame()),
    );
  }
}

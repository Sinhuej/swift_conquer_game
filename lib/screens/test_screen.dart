import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/flame/swiftconquer_flame_game.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer • Playable Sandbox")),
      body: GameWidget(game: SwiftConquerFlameGame()),
    );
  }
}

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/core/game_loop.dart';
import '../game/flame/swiftconquer_flame_game.dart';

class FlameScreen extends StatelessWidget {
  const FlameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loop = GameLoop();
    final game = SwiftConquerFlameGame(loop: loop);

    return Scaffold(
      appBar: AppBar(title: const Text("SwiftConquer • Flame")),
      body: GameWidget(game: game),
    );
  }
}

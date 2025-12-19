import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/flame/swift_conquer_flame_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: SwiftConquerFlameGame(),
      ),
    );
  }
}

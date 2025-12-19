import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'game/flame/swiftconquer_flame_game.dart';

void main() {
  runApp(const SwiftConquerApp());
}

class SwiftConquerApp extends StatelessWidget {
  const SwiftConquerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget(game: SwiftConquerFlameGame()),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:flame/game.dart';
import 'swift_conquer_flame_game.dart';

class FlameEntry extends StatelessWidget {
  const FlameEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: SwiftConquerFlameGame());
  }
}

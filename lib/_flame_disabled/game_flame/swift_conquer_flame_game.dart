import 'package:flame/game.dart';
import '../core/game_loop.dart';

class SwiftConquerFlameGame extends FlameGame {
  final GameLoop loop = GameLoop();

  @override
  void update(double dt) {
    super.update(dt);
    loop.tick(dt);
  }
}

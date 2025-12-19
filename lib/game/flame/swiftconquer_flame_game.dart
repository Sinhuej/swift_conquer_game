import 'package:flame/game.dart';
import 'package:flame/input.dart';

import '../core/game_loop.dart';
import 'render/world_renderer.dart';

class SwiftConquerFlameGame extends FlameGame
    with TapCallbacks, LongPressCallbacks {
  final GameLoop loop = GameLoop();

  @override
  Future<void> onLoad() async {
    add(WorldRenderer(loop.world));
  }

  @override
  void update(double dt) {
    super.update(dt);
    loop.tick(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Phase 32: selection hook
  }

  @override
  void onLongPressStart(LongPressStartEvent event) {
    // Phase 32: box select / command hook
  }
}

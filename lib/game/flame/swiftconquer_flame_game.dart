import 'package:flame/game.dart';
import 'package:flame/input.dart';
import '../core/game_loop.dart';
import '../math/vec2.dart';
import 'adapters/input_adapter.dart';
import 'render/world_renderer.dart';

class SwiftConquerFlameGame extends FlameGame with TapDetector, LongPressDetector {
  final GameLoop loop = GameLoop();
  late final InputAdapter input = InputAdapter(loop);

  @override
  Future<void> onLoad() async {
    // Spawn 2 demo units
    loop.world.spawnUnit(const Vec2(140, 220), teamId: 1, hp: 30);
    loop.world.spawnUnit(const Vec2(360, 220), teamId: 2, hp: 30);

    add(WorldRenderer(loop));
  }

  @override
  void update(double dt) {
    super.update(dt);
    loop.tick(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    final p = info.eventPosition.game;
    input.onTap(Vec2(p.x, p.y));
  }

  @override
  void onLongPressStart(LongPressStartInfo info) {
    final p = info.eventPosition.game;
    input.onLongPress(Vec2(p.x, p.y));
  }
}

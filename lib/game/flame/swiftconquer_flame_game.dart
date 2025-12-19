import 'package:flame/game.dart';
import '../core/game_loop.dart';
import 'render/world_renderer.dart';

class SwiftConquerFlameGame extends FlameGame {
  final GameLoop loop;
  late final WorldRenderer renderer;

  SwiftConquerFlameGame({required this.loop});

  @override
  Future<void> onLoad() async {
    renderer = WorldRenderer(loop.world);
  }

  @override
  void update(double dt) {
    super.update(dt);
    loop.tick(dt);
  }

  @override
  void render(canvas) {
    super.render(canvas);
    renderer.render(canvas);
  }
}

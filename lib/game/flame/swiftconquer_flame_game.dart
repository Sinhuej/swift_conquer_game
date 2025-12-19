import 'package:flame/game.dart';
import 'package:flame/events.dart';
import '../core/game_loop.dart';
import '../core/entity_id.dart';
import '../math/vec2.dart';
import 'render/world_renderer.dart';

class SwiftConquerFlameGame extends FlameGame
    with TapCallbacks, LongPressCallbacks {
  final GameLoop loop;

  EntityId? unitA;

  SwiftConquerFlameGame({required this.loop});

  @override
  Future<void> onLoad() async {
    // Spawn 2 units so you instantly see motion/teams.
    unitA = loop.world.spawnUnit(const Vec2(120, 260), teamId: 1, hp: 25);
    loop.world.spawnUnit(const Vec2(320, 260), teamId: 2, hp: 25);

    // Renderer reads WorldState and draws it.
    add(WorldRenderer(loop: loop));
  }

  @override
  void update(double dt) {
    super.update(dt);
    loop.tick(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // Tap = move Unit A toward tap position
    final id = unitA;
    if (id == null) return;
    if (!loop.world.exists(id)) return;

    final p = event.canvasPosition;
    loop.world.moveOrders[id]?.target = Vec2(p.x, p.y);
  }

  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event);

    // Long press = spawn a new unit at press location
    final p = event.canvasPosition;
    final teamId = (loop.world.entityCount % 2) + 1;
    loop.world.spawnUnit(Vec2(p.x, p.y), teamId: teamId, hp: 20);
  }
}

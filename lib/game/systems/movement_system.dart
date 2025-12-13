import '../core/world_state.dart';

class MovementSystem {
  final WorldState world;
  MovementSystem(this.world);

  void update(double dt) {
    for (final u in world.aliveUnits()) {
      u.pos.x += u.vel.x * dt;
      u.pos.y += u.vel.y * dt;

      // clamp to world bounds
      if (u.pos.x < 0) u.pos.x = 0;
      if (u.pos.y < 0) u.pos.y = 0;
      if (u.pos.x > world.worldW) u.pos.x = world.worldW;
      if (u.pos.y > world.worldH) u.pos.y = world.worldH;
    }
  }
}

import 'game_system.dart';
import '../core/world_state.dart';

class CombatSystem extends GameSystem {
  @override
  void update(double dt, WorldState world) {
    world.healths.forEach((id, hp) {
      if (hp.current <= 0) {
        world.remove(id);
      }
    });
  }
}

import '../core/world_state.dart';
import 'game_system.dart';
import 'movement_system.dart';
import 'combat_system.dart';

class SystemManager {
  final List<GameSystem> _systems = [
    MovementSystem(),
    CombatSystem(),
  ];

  void update(WorldState world, double dt) {
    for (final s in _systems) {
      s.update(world, dt);
    }
    world.cleanupDead();
  }
}

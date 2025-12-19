import '../core/world_state.dart';
import 'combat_system.dart';
import 'game_system.dart';
import 'movement_system.dart';

class SystemManager {
  final List<GameSystem> systems = [
    MovementSystem(),
    CombatSystem(),
  ];

  void update(double dt, WorldState world) {
    for (final s in systems) {
      s.update(dt, world);
    }
  }
}

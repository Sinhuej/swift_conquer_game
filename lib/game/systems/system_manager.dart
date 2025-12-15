import 'game_system.dart';
import 'movement_system.dart';
import 'selection_system.dart';
import 'combat_system.dart';
import '../core/world_state.dart';

class SystemManager {
  final List<GameSystem> _systems = [
    MovementSystem(),
    SelectionSystem(),
    CombatSystem(),
  ];

  void update(double dt, WorldState world) {
    for (final s in _systems) {
      s.update(dt, world);
    }
  }
}

import 'game_system.dart';
import 'movement_system.dart';
import 'combat_system.dart';

class SystemManager {
  final List<GameSystem> _systems = [
    MovementSystem(),
    CombatSystem(),
  ];

  void update(double dt) {
    for (final system in _systems) {
      system.update(dt);
    }
  }
}

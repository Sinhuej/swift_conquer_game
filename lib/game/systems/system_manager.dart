import 'game_system.dart';
import 'movement_system.dart';
import 'selection_system.dart';

class SystemManager {
  final List<GameSystem> _systems = [];

  SystemManager() {
    _systems.addAll([
      SelectionSystem(),
      MovementSystem(),
    ]);
  }

  void update(double dt) {
    for (final system in _systems) {
      system.update(dt);
    }
  }
}

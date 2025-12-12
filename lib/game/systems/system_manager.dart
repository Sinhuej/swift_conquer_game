import 'game_system.dart';
import 'movement_system.dart';
import 'selection_system.dart';
import '../core/world_state.dart';

class SystemManager {
  final WorldState world = WorldState();

  final List<GameSystem> _systems = [
    MovementSystem(),
    SelectionSystem(),
  ];

  void update(double dt) {
    world.advance(dt);
    for (final system in _systems) {
      system.update(dt);
    }
  }
}

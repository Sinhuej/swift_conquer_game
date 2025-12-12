import '../core/world_state.dart';
import '../systems/system_manager.dart';
import '../systems/movement_system.dart';
import '../systems/selection_system.dart';
import '../systems/combat_system.dart';

class GameLoop {
  final WorldState world = WorldState();
  late final SystemManager systems;

  late final MovementSystem movement;
  late final SelectionSystem selection;
  late final CombatSystem combat;

  GameLoop() {
    movement = MovementSystem(world);
    selection = SelectionSystem();
    combat = CombatSystem(world);

    systems = SystemManager()
      ..add(movement)
      ..add(selection)
      ..add(combat);
  }

  void update(double dt) {
    systems.update(dt);
  }
}

import '../core/world_state.dart';
import 'movement_system.dart';
import 'combat_system.dart';

class SystemManager {
  final WorldState world;

  late final MovementSystem movement;
  late final CombatSystem combat;

  SystemManager(this.world) {
    movement = MovementSystem(world);
    combat = CombatSystem(world);
  }

  void update(double dt) {
    movement.update(dt);
    combat.update(dt);
  }
}

  void addCombat(WorldState world) {
    systems.add(CombatSystem(world));
  }

  void addCombat(WorldState world) {
    systems.add(CombatSystem(world));
  }

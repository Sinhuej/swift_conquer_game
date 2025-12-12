import 'world_state.dart';
import '../systems/combat_system.dart';

class GameLoop {
  final WorldState world = WorldState();
  final CombatSystem combat = CombatSystem();

  void update(double dt) {
    // Phase 17: systems tick here
  }
}


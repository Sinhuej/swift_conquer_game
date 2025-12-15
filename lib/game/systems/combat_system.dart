import '../core/world_state.dart';
import '../components/health.dart';
import 'game_system.dart';

/// Phase 23: CombatSystem (placeholder tick damage)
/// Later: range, fire rate, projectile simulation, armor types, etc.
class CombatSystem implements GameSystem {
  @override
  void update(WorldState world, double dt) {
    // For now: nothing automatic.
    // You will drive combat via commands/events in later phases.
    // This file exists to keep architecture stable + compiling.
    for (final id in world.entities) {
      final hp = world.health[id];
      if (hp == null) continue;
      if (hp.current <= 0) {
        world.destroyEntity(id);
      }
    }
  }
}

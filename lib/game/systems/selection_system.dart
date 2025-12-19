import '../core/entity_id.dart';
import '../core/world_state.dart';
import '../math/vec2.dart';
import 'game_system.dart';

class SelectionSystem implements GameSystem {
  EntityId? selected;

  /// Select the closest unit to [worldPoint] within [radius].
  EntityId? pickUnit(WorldState world, Vec2 worldPoint, {double radius = 28}) {
    EntityId? best;
    double bestDist = 1e18;

    for (final id in world.entities) {
      final p = world.positions[id]?.value;
      if (p == null) continue;
      final d = p.distanceTo(worldPoint);
      if (d <= radius && d < bestDist) {
        best = id;
        bestDist = d;
      }
    }

    selected = best;
    return best;
  }

  @override
  void update(double dt, WorldState world) {
    // no-op for now (selection is driven by input adapter)
  }
}

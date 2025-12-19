import '../core/world_state.dart';

class FogSystem {
  final Set<int> visibleEntities = {};

  void update(WorldState world, int teamId) {
    visibleEntities.clear();
    for (final id in world.entities) {
      visibleEntities.add(id.value);
    }
  }
}

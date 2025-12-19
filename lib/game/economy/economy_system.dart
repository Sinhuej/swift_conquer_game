import '../core/world_state.dart';

class EconomySystem {
  void update(WorldState world) {
    for (final id in world.entities) {
      final team = world.teams[id];
      if (team == null) continue;

      world.teamResources.update(
        team.id,
        (v) => v + 1,
        ifAbsent: () => 1,
      );
    }
  }
}

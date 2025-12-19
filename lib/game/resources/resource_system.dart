import '../core/world_state.dart';

class ResourceSystem {
  final Map<int, int> teamResources = {};

  void tick(WorldState world) {
    for (final team in world.teams.values) {
      teamResources[team.id] = (teamResources[team.id] ?? 0) + 1;
    }
  }
}

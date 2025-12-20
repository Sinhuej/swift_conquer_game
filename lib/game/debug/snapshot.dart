import '../core/world_state.dart';

class Snapshot {
  static Map<String, dynamic> dump(WorldState world) {
    return {
      'entities': world.entityCount,
      'positions': world.positions.length,
      'health': world.health.length,
      'teams': world.teams.length,
    };
  }
}

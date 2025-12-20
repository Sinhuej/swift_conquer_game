import 'world_state.dart';

class VictorySystem {
  static int? check(WorldState world) {
    final teams = <int>{};

    for (final t in world.teams.values) {
      teams.add(t.id);
    }

    return teams.length == 1 ? teams.first : null;
  }
}

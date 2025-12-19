import '../core/world_state.dart';

class VictoryCheck {
  static int? winner(WorldState world) {
    final teams = <int>{};
    for (final t in world.teams.values) {
      teams.add(t.id);
    }
    if (teams.length == 1) return teams.first;
    return null;
  }
}

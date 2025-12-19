import 'game_state.dart';
import '../core/game_loop.dart';
import '../core/world_state.dart';

class GameController {
  GameState state = GameState.playing;
  final GameLoop loop;

  GameController(this.loop);

  void tick(double dt) {
    if (state != GameState.playing) return;

    loop.tick(dt);

    final winner = _checkVictory(loop.world);
    if (winner != null) {
      state = GameState.victory;
    }
  }

  int? _checkVictory(WorldState world) {
    final teams = <int>{};
    for (final t in world.teams.values) {
      teams.add(t.id);
    }
    if (teams.length == 1) return teams.first;
    return null;
  }
}

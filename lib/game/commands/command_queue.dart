import '../core/world_state.dart';

abstract class GameCommand {
  void apply(WorldState world);
}

class CommandQueue {
  final List<GameCommand> _q = [];

  void enqueue(GameCommand cmd) => _q.add(cmd);

  void flush(WorldState world) {
    for (final c in _q) {
      c.apply(world);
    }
    _q.clear();
  }
}

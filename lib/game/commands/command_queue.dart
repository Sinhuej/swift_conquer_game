import '../core/entity_id.dart';
import '../math/vec2.dart';

abstract class GameCommand {}

class MoveCommand extends GameCommand {
  final EntityId id;
  final Vec2 target;
  MoveCommand(this.id, this.target);
}

class CommandQueue {
  final List<GameCommand> _queue = [];
  void push(GameCommand c) => _queue.add(c);
  List<GameCommand> drain() {
    final out = List<GameCommand>.from(_queue);
    _queue.clear();
    return out;
  }
}

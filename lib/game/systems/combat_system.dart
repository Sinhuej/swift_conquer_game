import '../core/world_state.dart';
import '../core/attack_event.dart';
import '../systems/game_system.dart';

class CombatSystem implements GameSystem {
  final List<AttackEvent> _queue = [];

  void queue(AttackEvent e) => _queue.add(e);

  @override
  void update(double dt, WorldState world) {
    if (_queue.isEmpty) return;

    for (final e in _queue) {
      if (!world.exists(e.target)) continue;
      final hp = world.health[e.target];
      if (hp == null) continue;

      hp.current -= e.damage;
    }

    _queue.clear();
  }
}

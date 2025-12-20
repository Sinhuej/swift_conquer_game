import 'world_state.dart';

class DeathCleanup {
  static void run(WorldState world) {
    final dead = world.health.entries
        .where((e) => e.value.current <= 0)
        .map((e) => e.key)
        .toList();

    for (final id in dead) {
      world.destroy(id);
    }
  }
}

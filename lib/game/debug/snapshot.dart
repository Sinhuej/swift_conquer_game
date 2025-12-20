import '../core/world_state.dart';

class Snapshot {
  final int tick;
  final int entityCount;

  Snapshot({required this.tick, required this.entityCount});

  static Snapshot from(WorldState world, int tick) {
    return Snapshot(tick: tick, entityCount: world.entityCount);
  }

  @override
  String toString() => 'Snapshot(tick=$tick, entities=$entityCount)';
}

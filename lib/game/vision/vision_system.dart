import '../core/world_state.dart';
import '../fog/fog_map.dart';
import 'vision.dart';

class VisionSystem {
  final FogMap fog;

  VisionSystem(this.fog);

  void update(WorldState world) {
    fog.visibleTilesByTeam.clear();

    for (final id in world.entities) {
      final team = world.teams[id];
      final pos = world.positions[id];
      final vision = world.visions[id];

      if (team == null || pos == null || vision == null) continue;

      final tileId = pos.value.x.toInt() << 16 | pos.value.y.toInt();
      fog.reveal(team.id, tileId);
    }
  }
}

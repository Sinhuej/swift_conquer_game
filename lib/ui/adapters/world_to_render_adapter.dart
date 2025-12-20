import '../../game/core/world_state.dart';
import '../render_models/render_world.dart';
import '../render_models/render_unit.dart';

class WorldToRenderAdapter {
  static RenderWorld fromWorld(WorldState world) {
    final units = <RenderUnit>[];

    for (final id in world.entities) {
      final pos = world.positions[id];
      final team = world.teams[id];
      final hp = world.health[id];
      if (pos == null || team == null || hp == null) continue;

      units.add(RenderUnit(
        id: id.value,
        x: pos.value.x,
        y: pos.value.y,
        teamId: team.id,
        alive: hp.current > 0,
      ));
    }

    return RenderWorld(units: units);
  }
}

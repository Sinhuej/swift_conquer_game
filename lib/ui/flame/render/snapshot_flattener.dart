import 'package:flame/extensions.dart';

import '../../render_models/render_world.dart';
import 'render_entity.dart';

class SnapshotFlattener {
  const SnapshotFlattener();

  List<RenderEntity> flatten(RenderWorld snapshot) {
    return snapshot.units
        .map(
          (unit) => RenderEntity(
            id: unit.id,
            pos: Vector2(unit.x, unit.y),
            rot: 0.0,
            type: unit.teamId,
            flags: unit.alive ? 1 : 0,
          ),
        )
        .toList(growable: false);
  }
}

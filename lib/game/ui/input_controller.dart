import 'dart:ui';

import '../buildings/building_footprint.dart';
import '../core/entity_id.dart';
import '../core/world_state.dart';
import '../math/vec2.dart';
import 'camera_view.dart';

class InputController {
  final Set<EntityId> selected = <EntityId>{};

  void onTapAt({
    required Offset localPos,
    required WorldState world,
    required CameraView cam,
  }) {
    final worldTap = cam.screenToWorld(Vec2(localPos.dx, localPos.dy));
    final hit = _hitTest(world: world, cam: cam, localPos: localPos, worldTap: worldTap);

    if (hit != null) {
      if (selected.contains(hit)) {
        selected.remove(hit);
        return;
      }

      selected
        ..clear()
        ..add(hit);
      return;
    }

    if (selected.isNotEmpty) {
      for (final id in selected) {
        final move = world.moveOrders[id];
        if (move != null) {
          move.target = worldTap;
        }
      }
    }
  }

  void selectBox({
    required Rect screenRect,
    required WorldState world,
    required CameraView cam,
    required int teamId,
  }) {
    selected.clear();

    for (final id in world.entities) {
      final team = world.teams[id];
      final pos = world.positions[id];
      if (team == null || pos == null) continue;
      if (team.id != teamId) continue;

      final screen = cam.worldToScreen(pos.value);
      if (screenRect.contains(Offset(screen.x, screen.y))) {
        selected.add(id);
      }
    }
  }

  EntityId? _hitTest({
    required WorldState world,
    required CameraView cam,
    required Offset localPos,
    required Vec2 worldTap,
  }) {
    EntityId? bestUnit;
    double bestDist2 = 999999999.0;

    for (final id in world.entities) {
      final pos = world.positions[id];
      if (pos == null) continue;
      final d = pos.value - worldTap;
      final dist2 = d.x * d.x + d.y * d.y;
      if (dist2 < bestDist2) {
        bestDist2 = dist2;
        bestUnit = id;
      }
    }

    if (bestUnit != null && bestDist2 <= (30 * 30)) {
      return bestUnit;
    }

    for (final id in world.buildingIds) {
      final type = world.buildingTypes[id];
      final center = world.buildingPositions[id];
      if (type == null || center == null) continue;

      final fp = footprintFor(type);
      final halfW = fp.cols * 40.0 / 2.0;
      final halfH = fp.rows * 40.0 / 2.0;

      final left = center.x - halfW;
      final top = center.y - halfH;
      final right = center.x + halfW;
      final bottom = center.y + halfH;

      if (worldTap.x >= left &&
          worldTap.x <= right &&
          worldTap.y >= top &&
          worldTap.y <= bottom) {
        return id;
      }
    }

    return null;
  }

  void clearSelection() => selected.clear();
}

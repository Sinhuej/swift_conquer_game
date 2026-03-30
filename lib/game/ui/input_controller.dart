import 'dart:math' as math;
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

    final hit = _hitTest(
      world: world,
      worldTap: worldTap,
    );

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

    if (selected.isEmpty) return;

    final movable = selected
        .where((id) => world.moveOrders[id] != null && world.positions[id] != null)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    if (movable.isEmpty) return;

    if (movable.length == 1) {
      world.moveOrders[movable.first]?.target = worldTap;
      return;
    }

    _issueFormationMove(
      world: world,
      units: movable,
      destination: worldTap,
    );
  }

  void _issueFormationMove({
    required WorldState world,
    required List<EntityId> units,
    required Vec2 destination,
  }) {
    final centroid = _centroid(world, units);

    Vec2 forward = destination - centroid;
    final len = math.sqrt((forward.x * forward.x) + (forward.y * forward.y));
    if (len < 0.001) {
      forward = const Vec2(1, 0);
    } else {
      forward = Vec2(forward.x / len, forward.y / len);
    }

    final right = Vec2(-forward.y, forward.x);
    final spacing = _formationSpacing(world, units);

    final cols = math.max(2, math.sqrt(units.length).ceil());

    for (int i = 0; i < units.length; i++) {
      final id = units[i];
      final row = i ~/ cols;
      final col = i % cols;

      final unitsRemaining = units.length - (row * cols);
      final rowWidth = math.min(cols, unitsRemaining);

      final lateral = (col - ((rowWidth - 1) / 2.0)) * spacing;
      final depth = row * spacing * 0.9;

      final target = Vec2(
        destination.x + (right.x * lateral) - (forward.x * depth),
        destination.y + (right.y * lateral) - (forward.y * depth),
      );

      world.moveOrders[id]?.target = target;
    }
  }

  Vec2 _centroid(WorldState world, List<EntityId> units) {
    double x = 0;
    double y = 0;

    for (final id in units) {
      final pos = world.positions[id]!.value;
      x += pos.x;
      y += pos.y;
    }

    return Vec2(x / units.length, y / units.length);
  }

  double _formationSpacing(WorldState world, List<EntityId> units) {
    bool hasVehicle = false;

    for (final id in units) {
      final kind = world.unitKinds[id] ?? 'tank';
      if (kind == 'tank' || kind == 'harvester' || kind == 'mobile_hq_center') {
        hasVehicle = true;
        break;
      }
    }

    return hasVehicle ? 56.0 : 34.0;
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

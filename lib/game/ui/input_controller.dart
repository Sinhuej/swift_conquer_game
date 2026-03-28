import 'package:flutter/material.dart';
import '../core/entity_id.dart';
import '../core/world_state.dart';
import '../math/vec2.dart';
import 'camera_view.dart';

class InputController {
  final Set<EntityId> selected = <EntityId>{};

  void onTapDown({
    required TapDownDetails details,
    required WorldState world,
    required CameraView cam,
  }) {
    final p = details.localPosition;
    final worldTap = cam.screenToWorld(Vec2(p.dx, p.dy));
    final hit = _nearestUnit(world, worldTap);

    if (hit != null) {
      if (selected.contains(hit)) {
        selected.remove(hit);
        return;
      }

      if (selected.isNotEmpty) {
        final selectedTeam = world.teams[selected.first]?.id;
        final hitTeam = world.teams[hit]?.id;
        if (selectedTeam != null && hitTeam == selectedTeam) {
          selected.add(hit);
          return;
        }
      }
    }

    if (selected.isNotEmpty) {
      for (final id in selected) {
        final mo = world.moveOrders[id];
        if (mo != null) {
          mo.target = worldTap;
        }
      }
      return;
    }

    if (hit != null) {
      selected.add(hit);
    }
  }

  EntityId? _nearestUnit(WorldState world, Vec2 point) {
    EntityId? best;
    double bestDist2 = 999999999.0;

    for (final id in world.entities) {
      final pos = world.positions[id];
      if (pos == null) continue;
      final d = pos.value - point;
      final dist2 = d.x * d.x + d.y * d.y;
      if (dist2 < bestDist2) {
        bestDist2 = dist2;
        best = id;
      }
    }

    if (best != null && bestDist2 <= (30 * 30)) {
      return best;
    }
    return null;
  }

  void clearSelection() => selected.clear();
}

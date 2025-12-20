import 'package:flutter/material.dart';
import '../core/world_state.dart';
import '../core/entity_id.dart';
import '../math/vec2.dart';
import 'camera_view.dart';

class InputController {
  final Set<EntityId> selected = <EntityId>{};

  /// Tap selects nearest unit (within radius). If already selected, tap sets move target.
  void onTapDown({
    required TapDownDetails details,
    required WorldState world,
    required CameraView cam,
  }) {
    final p = details.localPosition;
    final worldTap = cam.screenToWorld(Vec2(p.dx, p.dy));

    // If we have selection, treat tap as a move command.
    if (selected.isNotEmpty) {
      for (final id in selected) {
        final mo = world.moveOrders[id];
        if (mo != null) {
          mo.target = worldTap;
        }
      }
      return;
    }

    // Otherwise, pick nearest unit.
    EntityId? best;
    double bestDist2 = 999999999.0;

    for (final id in world.entities) {
      final pos = world.positions[id];
      if (pos == null) continue;
      final d = pos.value - worldTap;
      final dist2 = d.x * d.x + d.y * d.y;
      if (dist2 < bestDist2) {
        bestDist2 = dist2;
        best = id;
      }
    }

    // 30 world-units radius for selection
    if (best != null && bestDist2 <= (30 * 30)) {
      selected.add(best);
    }
  }

  void clearSelection() => selected.clear();
}

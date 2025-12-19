import '../camera/camera_state.dart';
import '../core/entity_id.dart';
import '../core/world_state.dart';
import '../math/vec2.dart';

class InputController {
  EntityId? selected;

  EntityId? pickUnitAt(WorldState world, Vec2 worldPoint, {double radius = 18}) {
    for (final id in world.entities) {
      final p = world.positions[id]?.value;
      if (p == null) continue;
      final dx = p.x - worldPoint.x;
      final dy = p.y - worldPoint.y;
      final d2 = dx * dx + dy * dy;
      if (d2 <= radius * radius) return id;
    }
    return null;
  }

  void onTap(WorldState world, CameraState cam, Vec2 screenPoint) {
    final wp = cam.screenToWorld(screenPoint);
    final hit = pickUnitAt(world, wp);

    if (hit != null) {
      selected = hit;
      return;
    }

    // If no unit tapped: move selected
    final sel = selected;
    if (sel != null && world.exists(sel)) {
      world.moveOrders[sel]?.target = wp;
    }
  }
}

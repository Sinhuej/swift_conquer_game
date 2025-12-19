import '../../core/entity_id.dart';
import '../../core/game_loop.dart';
import '../../math/vec2.dart';

class InputAdapter {
  final GameLoop loop;

  InputAdapter(this.loop);

  /// Called when user taps at world coordinates.
  void onTap(Vec2 worldPoint) {
    final world = loop.world;
    final sel = loop.systems.selection;

    // Try pick a unit (select)
    final picked = sel.pickUnit(world, worldPoint, radius: 32);
    if (picked != null) {
      return;
    }

    // If nothing picked: if we have a selected unit -> move it
    final EntityId? selected = sel.selected;
    if (selected != null && world.exists(selected)) {
      world.moveOrders[selected]?.target = worldPoint;
    }
  }

  /// Called when user long-presses a unit: set attack target if possible
  void onLongPress(Vec2 worldPoint) {
    final world = loop.world;
    final sel = loop.systems.selection;
    final attacker = sel.selected;
    if (attacker == null || !world.exists(attacker)) return;

    final target = sel.pickUnit(world, worldPoint, radius: 32);
    if (target != null && target != attacker) {
      world.targetOrders[attacker]?.targetId = target;
    }
  }
}

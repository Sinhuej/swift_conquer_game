import '../core/entity_id.dart';
import '../core/world_state.dart';

class SelectionSystem {
  EntityId? selected;

  void select(WorldState world, EntityId? id) {
    if (id == null) {
      selected = null;
      return;
    }
    if (!world.exists(id)) return;
    selected = id;
  }
}

import '../core/entity_id.dart';
import '../core/world_state.dart';

class SelectionGroups {
  final Map<int, Set<EntityId>> _groups = <int, Set<EntityId>>{};

  void assign(int slot, Iterable<EntityId> ids) {
    _groups[slot] = Set<EntityId>.from(ids);
  }

  Set<EntityId> recall(int slot, WorldState world) {
    final src = _groups[slot] ?? const <EntityId>{};
    return src.where(world.exists).toSet();
  }

  bool hasMembers(int slot, WorldState world) {
    return recall(slot, world).isNotEmpty;
  }

  int count(int slot, WorldState world) {
    return recall(slot, world).length;
  }
}

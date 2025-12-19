import '../core/entity_id.dart';
import '../math/vec2.dart';

class InputState {
  final Set<EntityId> selected = <EntityId>{};

  // For panning
  Vec2 lastDragScreen = const Vec2(0, 0);
  bool dragging = false;

  void clearSelection() => selected.clear();

  void selectSingle(EntityId id) {
    selected
      ..clear()
      ..add(id);
  }

  bool isSelected(EntityId id) => selected.contains(id);
}

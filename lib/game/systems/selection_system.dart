import 'game_system.dart';

class SelectionSystem extends GameSystem {
  int? selectedEntity;

  void select(int id) {
    selectedEntity = id;
  }

  @override
  void update(double dt) {
    // Phase 16: idle
  }
}

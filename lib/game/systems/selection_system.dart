import 'game_system.dart';

class SelectionSystem extends GameSystem {
  int? selectedUnitId;

  void select(int unitId) {
    selectedUnitId = unitId;
  }

  @override
  void update(double dt) {}
}

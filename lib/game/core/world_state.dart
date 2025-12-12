import '../entities/unit.dart';

class WorldState {
  final Map<int, Unit> units = {};

  void addUnit(Unit unit) {
    units[unit.id] = unit;
  }

  Unit? getUnit(int id) => units[id];
}

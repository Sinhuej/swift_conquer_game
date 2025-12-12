class WorldState {
  final Map<int, UnitState> units = {};

  int _nextId = 1;

  int spawnUnit(double x, double y, {int hp = 100}) {
    final id = _nextId++;
    units[id] = UnitState(
      id: id,
      x: x,
      y: y,
      hp: hp,
    );
    return id;
  }
}

class UnitState {
  final int id;
  double x;
  double y;
  int hp;

  UnitState({
    required this.id,
    required this.x,
    required this.y,
    required this.hp,
  });

  bool get isAlive => hp > 0;
}

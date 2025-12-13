import '../math/vec2.dart';

class UnitState {
  final int id;
  int team; // 0=player, 1=enemy (for now)
  Vec2 pos;
  Vec2 vel;

  double radius;
  double hp;
  double maxHp;

  double attackDamage;
  double attackRange;
  double attackCooldown; // seconds
  double attackTimer;    // time until can attack again

  int? targetUnitId;

  UnitState({
    required this.id,
    required this.team,
    required this.pos,
    Vec2? vel,
    this.radius = 14,
    this.hp = 100,
    this.maxHp = 100,
    this.attackDamage = 10,
    this.attackRange = 90,
    this.attackCooldown = 0.8,
    this.attackTimer = 0,
    this.targetUnitId,
  }) : vel = vel ?? Vec2(0, 0);

  bool get isAlive => hp > 0;
}

class WorldState {
  int _nextId = 1;

  final Map<int, UnitState> units = {};
  int? selectedUnitId;

  // Simple bounds for now (world coords)
  double worldW = 1200;
  double worldH = 800;

  int spawnUnit({
    required int team,
    required Vec2 pos,
    double hp = 100,
    double dmg = 10,
    double range = 90,
    double cd = 0.8,
  }) {
    final id = _nextId++;
    units[id] = UnitState(
      id: id,
      team: team,
      pos: pos,
      hp: hp,
      maxHp: hp,
      attackDamage: dmg,
      attackRange: range,
      attackCooldown: cd,
    );
    return id;
  }

  Iterable<UnitState> aliveUnits() => units.values.where((u) => u.isAlive);

  void cullDead() {
    units.removeWhere((_, u) => !u.isAlive);
    if (selectedUnitId != null && !units.containsKey(selectedUnitId)) {
      selectedUnitId = null;
    }
  }
}

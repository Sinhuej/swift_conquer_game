class WorldState {
  final List<Unit> units = [];
  final List<Battle> activeBattles = [];

  void removeUnit(Unit unit) {
    units.remove(unit);
  }
}

class Unit {
  int hp;
  int attack;
  int armor;
  double tierMultiplier;
  double coverModifier;

  Unit({
    required this.hp,
    required this.attack,
    required this.armor,
    this.tierMultiplier = 1.0,
    this.coverModifier = 1.0,
  });
}

class Battle {
  final Unit attacker;
  final Unit defender;

  Battle(this.attacker, this.defender);
}

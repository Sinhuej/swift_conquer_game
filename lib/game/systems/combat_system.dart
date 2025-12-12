import '../entities/unit.dart';

class CombatSystem {
  void attack(Unit attacker, Unit defender) {
    if (!attacker.isAlive || !defender.isAlive) return;
    defender.hp -= attacker.attack;
  }
}

import '../combat/unit_stats.dart';
import '../combat/damage_model.dart';

class CombatSystem {
  void resolve({
    required UnitStats attacker,
    required UnitStats defender,
  }) {
    final damage = DamageModel.calculate(
      attack: attacker.attack,
      defense: defender.defense,
    );

    // Hook point: apply damage to world state later
    // defender.hp -= damage;
  }
}

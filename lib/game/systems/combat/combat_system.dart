import '../game_system.dart';
import '../../core/world_state.dart';

class CombatSystem extends GameSystem {
  final WorldState world;

  CombatSystem(this.world);

  @override
  void update(double dt) {
    for (final battle in world.activeBattles) {
      _resolveBattle(battle);
    }
  }

  void _resolveBattle(Battle battle) {
    final attackPower =
        battle.attacker.attack * battle.attacker.tierMultiplier;

    final defensePower =
        battle.defender.armor * battle.defender.coverModifier;

    final damage = (attackPower - defensePower).clamp(1, 999);

    battle.defender.hp -= damage;

    if (battle.defender.hp <= 0) {
      world.removeUnit(battle.defender);
    }
  }
}

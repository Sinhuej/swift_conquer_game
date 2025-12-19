import '../core/entity_id.dart';

class AttackCommand {
  final EntityId attacker;
  final EntityId target;
  AttackCommand(this.attacker, this.target);
}

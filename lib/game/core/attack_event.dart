import 'entity_id.dart';

class AttackEvent {
  final EntityId attacker;
  final EntityId target;
  final int damage;

  AttackEvent({
    required this.attacker,
    required this.target,
    required this.damage,
  });
}

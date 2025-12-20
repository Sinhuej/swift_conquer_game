import '../core/entity_id.dart';
import '../math/vec2.dart';

sealed class UnitIntent {
  final EntityId actor;
  const UnitIntent(this.actor);
}

class MoveIntent extends UnitIntent {
  final Vec2 target;
  const MoveIntent(super.actor, this.target);
}

class AttackIntent extends UnitIntent {
  final EntityId target;
  const AttackIntent(super.actor, this.target);
}

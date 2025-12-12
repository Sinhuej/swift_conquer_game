import 'attack_event.dart';
import '../components/health_component.dart';

class Entity {
  final int id;
  HealthComponent? health;

  Entity(this.id);
}

class WorldState {
  final Map<int, Entity> entities = {};
  final List<AttackEvent> pendingAttacks = [];

  Entity createEntity(int id, {double? hp}) {
    final e = Entity(id);
    if (hp != null) {
      e.health = HealthComponent(hp);
    }
    entities[id] = e;
    return e;
  }

  void queueAttack(int targetId, double damage) {
    pendingAttacks.add(AttackEvent(targetId, damage));
  }
}

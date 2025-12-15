import '../components/position.dart';
import '../components/health.dart';
import '../components/team.dart';
import '../components/move_order.dart';
import '../components/target_order.dart';

class WorldState {
  int _nextId = 0;

  final Map<int, Position> positions = {};
  final Map<int, Health> health = {};
  final Map<int, Team> teams = {};
  final Map<int, MoveOrder> moveOrders = {};
  final Map<int, TargetOrder> targetOrders = {};

  int spawnUnit() {
    final id = _nextId++;
    positions[id] = Position(0, 0);
    health[id] = Health(100);
    teams[id] = Team(0);
    return id;
  }

  bool exists(int id) => positions.containsKey(id);

  int get entityCount => positions.length;
}

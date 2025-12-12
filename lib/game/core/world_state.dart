import '../entities/unit.dart';
import '../entities/tile.dart';

class WorldState {
  final Map<int, Unit> units = {};
  final Map<int, Tile> tiles = {};

  int _nextId = 0;

  int nextId() => _nextId++;

  void addUnit(Unit unit) {
    units[unit.id] = unit;
  }

  void addTile(Tile tile) {
    tiles[tile.id] = tile;
  }
}

import 'map_definition.dart';

class OccupancyMap {
  final Set<GridCell> _occupied = <GridCell>{};

  void clear() => _occupied.clear();

  void occupy(Iterable<GridCell> cells) {
    _occupied.addAll(cells);
  }

  void release(Iterable<GridCell> cells) {
    for (final cell in cells) {
      _occupied.remove(cell);
    }
  }

  bool isOccupied(GridCell cell) => _occupied.contains(cell);

  bool areAllFree(Iterable<GridCell> cells) {
    for (final cell in cells) {
      if (_occupied.contains(cell)) return false;
    }
    return true;
  }

  Set<GridCell> get cells => Set<GridCell>.from(_occupied);
}

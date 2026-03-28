import '../math/vec2.dart';
import 'map_definition.dart';

class MapGrid {
  final MapDefinition map;

  const MapGrid(this.map);

  int get cellSize => map.cellSize;

  int get cols => (map.worldWidth / cellSize).ceil();
  int get rows => (map.worldHeight / cellSize).ceil();

  GridCell worldToCell(Vec2 world) {
    return GridCell(
      (world.x / cellSize).floor(),
      (world.y / cellSize).floor(),
    );
  }

  Vec2 cellTopLeft(GridCell cell) {
    return Vec2(
      cell.col * cellSize.toDouble(),
      cell.row * cellSize.toDouble(),
    );
  }

  Vec2 cellCenter(GridCell cell) {
    return Vec2(
      (cell.col + 0.5) * cellSize,
      (cell.row + 0.5) * cellSize,
    );
  }

  bool isInsideCell(GridCell cell) {
    return cell.col >= 0 &&
        cell.row >= 0 &&
        cell.col < cols &&
        cell.row < rows;
  }

  List<GridCell> footprintCellsForCenter(Vec2 center, int footprintCols, int footprintRows) {
    final anchor = worldToCell(center);
    final left = anchor.col - ((footprintCols - 1) ~/ 2);
    final top = anchor.row - ((footprintRows - 1) ~/ 2);

    final out = <GridCell>[];
    for (int dy = 0; dy < footprintRows; dy++) {
      for (int dx = 0; dx < footprintCols; dx++) {
        out.add(GridCell(left + dx, top + dy));
      }
    }
    return out;
  }

  Vec2 snapCenterForFootprint(Vec2 center, int footprintCols, int footprintRows) {
    final cells = footprintCellsForCenter(center, footprintCols, footprintRows);
    if (cells.isEmpty) return center;

    int minCol = cells.first.col;
    int maxCol = cells.first.col;
    int minRow = cells.first.row;
    int maxRow = cells.first.row;

    for (final cell in cells) {
      if (cell.col < minCol) minCol = cell.col;
      if (cell.col > maxCol) maxCol = cell.col;
      if (cell.row < minRow) minRow = cell.row;
      if (cell.row > maxRow) maxRow = cell.row;
    }

    return Vec2(
      ((minCol + maxCol + 1) / 2.0) * cellSize,
      ((minRow + maxRow + 1) / 2.0) * cellSize,
    );
  }
}

import '../core/world_state.dart';
import '../map/map_definition.dart';
import '../map/map_grid.dart';
import 'building_footprint.dart';

class BuildRadius {
  static const int tiles = 3;

  static Set<GridCell> coverageForTeam({
    required WorldState world,
    required MapGrid grid,
    required int teamId,
  }) {
    final out = <GridCell>{};

    for (final id in world.buildingIds) {
      final team = world.buildingTeams[id];
      final type = world.buildingTypes[id];
      final center = world.buildingPositions[id];

      if (team == null || team.id != teamId) continue;
      if (type == null || !type.projectsBuildRadius) continue;
      if (center == null) continue;

      final fp = footprintFor(type);
      final cells = grid.footprintCellsForCenter(center, fp.cols, fp.rows);
      if (cells.isEmpty) continue;

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

      for (int row = minRow - tiles; row <= maxRow + tiles; row++) {
        for (int col = minCol - tiles; col <= maxCol + tiles; col++) {
          final cell = GridCell(col, row);
          if (grid.isInsideCell(cell)) {
            out.add(cell);
          }
        }
      }
    }

    return out;
  }
}

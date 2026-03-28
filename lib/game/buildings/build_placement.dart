import '../core/world_state.dart';
import '../map/map_definition.dart';
import '../map/map_grid.dart';
import '../map/occupancy_map.dart';
import '../math/vec2.dart';
import 'build_radius.dart';
import 'building_footprint.dart';
import 'building_type.dart';

class PlacementResult {
  final bool ok;
  final String reason;
  final List<GridCell> cells;
  final Vec2 snappedCenter;

  const PlacementResult({
    required this.ok,
    required this.reason,
    required this.cells,
    required this.snappedCenter,
  });
}

class BuildPlacement {
  static PlacementResult validate({
    required WorldState world,
    required MapGrid grid,
    required OccupancyMap occupancy,
    required int teamId,
    required BuildingType type,
    required Vec2 center,
    bool ignoreBuildRadius = false,
  }) {
    final fp = footprintFor(type);
    final cells = grid.footprintCellsForCenter(center, fp.cols, fp.rows);
    final snapped = grid.snapCenterForFootprint(center, fp.cols, fp.rows);

    if (cells.isEmpty) {
      return PlacementResult(
        ok: false,
        reason: 'No cells selected.',
        cells: const [],
        snappedCenter: snapped,
      );
    }

    for (final cell in cells) {
      if (!grid.isInsideCell(cell)) {
        return PlacementResult(
          ok: false,
          reason: 'Out of bounds.',
          cells: cells,
          snappedCenter: snapped,
        );
      }
      if (grid.map.blocked.contains(cell)) {
        return PlacementResult(
          ok: false,
          reason: 'Blocked terrain.',
          cells: cells,
          snappedCenter: snapped,
        );
      }
      if (occupancy.isOccupied(cell)) {
        return PlacementResult(
          ok: false,
          reason: 'Not enough room.',
          cells: cells,
          snappedCenter: snapped,
        );
      }
    }

    if (!ignoreBuildRadius) {
      final coverage = BuildRadius.coverageForTeam(
        world: world,
        grid: grid,
        teamId: teamId,
      );

      if (coverage.isEmpty) {
        return PlacementResult(
          ok: false,
          reason: 'No build radius.',
          cells: cells,
          snappedCenter: snapped,
        );
      }

      bool inside = false;
      for (final cell in cells) {
        if (coverage.contains(cell)) {
          inside = true;
          break;
        }
      }

      if (!inside) {
        return PlacementResult(
          ok: false,
          reason: 'Outside build radius.',
          cells: cells,
          snappedCenter: snapped,
        );
      }
    }

    return PlacementResult(
      ok: true,
      reason: 'OK',
      cells: cells,
      snappedCenter: snapped,
    );
  }
}

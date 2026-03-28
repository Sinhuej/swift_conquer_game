#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "== SwiftConquer Phase 171-180: map + mobile HQ deploy + base-building demo =="

mkdir -p assets/maps
mkdir -p lib/game/map
mkdir -p lib/game/buildings
mkdir -p lib/game/state

cat > assets/maps/dev_map_01.json <<'JSON'
{
  "id": "dev_map_01",
  "name": "Dev Map 01",
  "worldWidth": 2000,
  "worldHeight": 1200,
  "cellSize": 40,
  "spawns": [
    { "x": 200, "y": 600 },
    { "x": 1800, "y": 600 }
  ],
  "blocked": [
    { "col": 20, "row": 8 },
    { "col": 21, "row": 8 },
    { "col": 22, "row": 8 },
    { "col": 23, "row": 8 },
    { "col": 24, "row": 8 },

    { "col": 20, "row": 20 },
    { "col": 21, "row": 20 },
    { "col": 22, "row": 20 },
    { "col": 23, "row": 20 },
    { "col": 24, "row": 20 }
  ],
  "resources": [
    { "x": 700, "y": 420, "type": "ore", "amount": 5000 },
    { "x": 1300, "y": 780, "type": "ore", "amount": 5000 }
  ]
}
JSON

cat > lib/game/map/map_definition.dart <<'DART'
import 'dart:convert';

class GridCell {
  final int col;
  final int row;

  const GridCell(this.col, this.row);

  @override
  bool operator ==(Object other) {
    return other is GridCell && other.col == col && other.row == row;
  }

  @override
  int get hashCode => Object.hash(col, row);

  @override
  String toString() => '($col,$row)';
}

class MapSpawnPoint {
  final double x;
  final double y;

  const MapSpawnPoint(this.x, this.y);

  factory MapSpawnPoint.fromJson(Map<String, Object?> json) {
    return MapSpawnPoint(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }
}

class MapResourcePoint {
  final double x;
  final double y;
  final String type;
  final int amount;

  const MapResourcePoint({
    required this.x,
    required this.y,
    required this.type,
    required this.amount,
  });

  factory MapResourcePoint.fromJson(Map<String, Object?> json) {
    return MapResourcePoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      type: (json['type'] as String?) ?? 'ore',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }
}

class MapDefinition {
  final String id;
  final String name;
  final double worldWidth;
  final double worldHeight;
  final int cellSize;
  final List<MapSpawnPoint> spawns;
  final Set<GridCell> blocked;
  final List<MapResourcePoint> resources;

  const MapDefinition({
    required this.id,
    required this.name,
    required this.worldWidth,
    required this.worldHeight,
    required this.cellSize,
    required this.spawns,
    required this.blocked,
    required this.resources,
  });

  factory MapDefinition.fromJson(Map<String, Object?> json) {
    final blockedRaw = (json['blocked'] as List?) ?? const [];
    final spawnsRaw = (json['spawns'] as List?) ?? const [];
    final resourcesRaw = (json['resources'] as List?) ?? const [];

    return MapDefinition(
      id: (json['id'] as String?) ?? 'unknown_map',
      name: (json['name'] as String?) ?? 'Unknown Map',
      worldWidth: (json['worldWidth'] as num).toDouble(),
      worldHeight: (json['worldHeight'] as num).toDouble(),
      cellSize: (json['cellSize'] as num).toInt(),
      spawns: spawnsRaw
          .map((e) => MapSpawnPoint.fromJson((e as Map).cast<String, Object?>()))
          .toList(),
      blocked: blockedRaw
          .map((e) {
            final m = (e as Map).cast<String, Object?>();
            return GridCell(
              (m['col'] as num).toInt(),
              (m['row'] as num).toInt(),
            );
          })
          .toSet(),
      resources: resourcesRaw
          .map((e) => MapResourcePoint.fromJson((e as Map).cast<String, Object?>()))
          .toList(),
    );
  }
}

MapDefinition mapDefinitionFromJsonString(String raw) {
  return MapDefinition.fromJson(jsonDecode(raw) as Map<String, Object?>);
}
DART

cat > lib/game/map/map_loader.dart <<'DART'
import 'package:flutter/services.dart' show rootBundle;

import 'map_definition.dart';

class MapLoader {
  static Future<MapDefinition> loadAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return mapDefinitionFromJsonString(raw);
  }
}
DART

cat > lib/game/map/map_grid.dart <<'DART'
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
DART

cat > lib/game/map/occupancy_map.dart <<'DART'
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
DART

cat > lib/game/buildings/building_type.dart <<'DART'
enum BuildingType {
  mobileHqCenter,
  hq,
  powerPlant,
  barracks,
  refinery,
}

extension BuildingTypeX on BuildingType {
  String get label {
    switch (this) {
      case BuildingType.mobileHqCenter:
        return 'Mobile HQ Center';
      case BuildingType.hq:
        return 'HQ';
      case BuildingType.powerPlant:
        return 'Power Plant';
      case BuildingType.barracks:
        return 'Barracks';
      case BuildingType.refinery:
        return 'Refinery';
    }
  }

  bool get projectsBuildRadius => this != BuildingType.mobileHqCenter;

  bool get isBuildMenuType {
    return this == BuildingType.powerPlant ||
        this == BuildingType.barracks ||
        this == BuildingType.refinery;
  }
}
DART

cat > lib/game/buildings/building_footprint.dart <<'DART'
import 'building_type.dart';

class BuildingFootprint {
  final int cols;
  final int rows;

  const BuildingFootprint(this.cols, this.rows);
}

BuildingFootprint footprintFor(BuildingType type) {
  switch (type) {
    case BuildingType.mobileHqCenter:
      return const BuildingFootprint(1, 1);
    case BuildingType.hq:
      return const BuildingFootprint(3, 3);
    case BuildingType.powerPlant:
      return const BuildingFootprint(2, 2);
    case BuildingType.barracks:
      return const BuildingFootprint(2, 2);
    case BuildingType.refinery:
      return const BuildingFootprint(3, 2);
  }
}
DART

cat > lib/game/buildings/build_radius.dart <<'DART'
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
DART

cat > lib/game/buildings/build_placement.dart <<'DART'
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
DART

cat > lib/game/state/build_mode.dart <<'DART'
import '../buildings/building_type.dart';

class BuildMode {
  BuildingType? pendingType;

  bool get isActive => pendingType != null;

  void select(BuildingType type) {
    pendingType = type;
  }

  void clear() {
    pendingType = null;
  }
}
DART

cat > lib/game/core/world_state.dart <<'DART'
import '../buildings/building_type.dart';
import '../components/health.dart';
import '../components/move_order.dart';
import '../components/position.dart';
import '../components/target_order.dart';
import '../components/team.dart';
import '../math/vec2.dart';
import 'entity_id.dart';

class WorldState {
  int _nextId = 1;

  int get nextIdForSave => _nextId;
  void setNextIdForSave(int value) {
    if (value < 1) {
      throw ArgumentError('nextId must be >= 1');
    }
    _nextId = value;
  }

  final Set<EntityId> entities = <EntityId>{};

  final Map<EntityId, Position> positions = {};
  final Map<EntityId, Health> health = {};
  final Map<EntityId, Team> teams = {};
  final Map<EntityId, MoveOrder> moveOrders = {};
  final Map<EntityId, TargetOrder> targetOrders = {};
  final Map<EntityId, String> unitKinds = {};

  final Set<EntityId> buildingIds = <EntityId>{};
  final Map<EntityId, BuildingType> buildingTypes = {};
  final Map<EntityId, Vec2> buildingPositions = {};
  final Map<EntityId, Team> buildingTeams = {};

  int get entityCount => entities.length + buildingIds.length;

  bool exists(EntityId id) => entities.contains(id) || buildingIds.contains(id);

  EntityId spawnUnit(
    Vec2 start, {
    int teamId = 1,
    int hp = 20,
    String kind = 'tank',
  }) {
    final id = EntityId(_nextId++);
    entities.add(id);
    positions[id] = Position(start);
    health[id] = Health(current: hp, max: hp);
    teams[id] = Team(teamId);
    moveOrders[id] = MoveOrder();
    targetOrders[id] = TargetOrder();
    unitKinds[id] = kind;
    return id;
  }

  EntityId spawnMobileHqCenter(
    Vec2 start, {
    int teamId = 1,
    int hp = 35,
  }) {
    return spawnUnit(
      start,
      teamId: teamId,
      hp: hp,
      kind: 'mobile_hq_center',
    );
  }

  bool isMobileHqCenter(EntityId id) => unitKinds[id] == 'mobile_hq_center';

  EntityId spawnBuilding(
    BuildingType type,
    Vec2 center, {
    int teamId = 1,
  }) {
    final id = EntityId(_nextId++);
    buildingIds.add(id);
    buildingTypes[id] = type;
    buildingPositions[id] = center;
    buildingTeams[id] = Team(teamId);
    return id;
  }

  void destroy(EntityId id) {
    entities.remove(id);
    positions.remove(id);
    health.remove(id);
    teams.remove(id);
    moveOrders.remove(id);
    targetOrders.remove(id);
    unitKinds.remove(id);

    buildingIds.remove(id);
    buildingTypes.remove(id);
    buildingPositions.remove(id);
    buildingTeams.remove(id);
  }
}
DART

cat > lib/game/ui/input_controller.dart <<'DART'
import 'package:flutter/material.dart';
import '../core/entity_id.dart';
import '../core/world_state.dart';
import '../math/vec2.dart';
import 'camera_view.dart';

class InputController {
  final Set<EntityId> selected = <EntityId>{};

  void onTapDown({
    required TapDownDetails details,
    required WorldState world,
    required CameraView cam,
  }) {
    final p = details.localPosition;
    final worldTap = cam.screenToWorld(Vec2(p.dx, p.dy));
    final hit = _nearestUnit(world, worldTap);

    if (hit != null) {
      if (selected.contains(hit)) {
        selected.remove(hit);
        return;
      }

      if (selected.isNotEmpty) {
        final selectedTeam = world.teams[selected.first]?.id;
        final hitTeam = world.teams[hit]?.id;
        if (selectedTeam != null && hitTeam == selectedTeam) {
          selected.add(hit);
          return;
        }
      }
    }

    if (selected.isNotEmpty) {
      for (final id in selected) {
        final mo = world.moveOrders[id];
        if (mo != null) {
          mo.target = worldTap;
        }
      }
      return;
    }

    if (hit != null) {
      selected.add(hit);
    }
  }

  EntityId? _nearestUnit(WorldState world, Vec2 point) {
    EntityId? best;
    double bestDist2 = 999999999.0;

    for (final id in world.entities) {
      final pos = world.positions[id];
      if (pos == null) continue;
      final d = pos.value - point;
      final dist2 = d.x * d.x + d.y * d.y;
      if (dist2 < bestDist2) {
        bestDist2 = dist2;
        best = id;
      }
    }

    if (best != null && bestDist2 <= (30 * 30)) {
      return best;
    }
    return null;
  }

  void clearSelection() => selected.clear();
}
DART

cat > lib/game/ui/world_painter.dart <<'DART'
import 'dart:ui';

import 'package:flutter/material.dart';

import '../buildings/building_footprint.dart';
import '../buildings/building_type.dart';
import '../core/entity_id.dart';
import '../core/world_state.dart';
import '../map/map_definition.dart';
import '../map/map_grid.dart';
import '../math/vec2.dart';
import 'camera_view.dart';

class WorldPainter extends CustomPainter {
  final WorldState world;
  final CameraView cam;
  final Set<EntityId> selected;
  final MapDefinition? map;
  final MapGrid? grid;
  final Set<GridCell> buildRadiusCells;
  final BuildingType? pendingType;

  WorldPainter({
    required this.world,
    required this.cam,
    required this.selected,
    required this.map,
    required this.grid,
    required this.buildRadiusCells,
    required this.pendingType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0B1220);
    canvas.drawRect(Offset.zero & size, bg);

    _drawMapBounds(canvas);
    _drawBuildRadius(canvas);
    _drawBlockedCells(canvas);
    _drawBuildings(canvas);
    _drawUnits(canvas);
    _drawHudHint(canvas, size);
  }

  void _drawMapBounds(Canvas canvas) {
    if (map == null) return;

    final topLeft = cam.worldToScreen(const Vec2(0, 0));
    final bottomRight = cam.worldToScreen(Vec2(map!.worldWidth, map!.worldHeight));

    final rect = Rect.fromLTRB(
      topLeft.x,
      topLeft.y,
      bottomRight.x,
      bottomRight.y,
    );

    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFF101A28),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF223247),
    );
  }

  void _drawBuildRadius(Canvas canvas) {
    final g = grid;
    if (g == null) return;

    final fill = Paint()..color = const Color(0x2222C55E);

    for (final cell in buildRadiusCells) {
      final world = g.cellTopLeft(cell);
      final screen = cam.worldToScreen(world);
      final rect = Rect.fromLTWH(
        screen.x,
        screen.y,
        g.cellSize * cam.zoom,
        g.cellSize * cam.zoom,
      );
      canvas.drawRect(rect, fill);
    }
  }

  void _drawBlockedCells(Canvas canvas) {
    final g = grid;
    final m = map;
    if (g == null || m == null) return;

    final fill = Paint()..color = const Color(0xFF243244);

    for (final cell in m.blocked) {
      final world = g.cellTopLeft(cell);
      final screen = cam.worldToScreen(world);
      final rect = Rect.fromLTWH(
        screen.x,
        screen.y,
        g.cellSize * cam.zoom,
        g.cellSize * cam.zoom,
      );
      canvas.drawRect(rect, fill);
    }
  }

  void _drawBuildings(Canvas canvas) {
    final g = grid;
    if (g == null) return;

    for (final id in world.buildingIds) {
      final type = world.buildingTypes[id];
      final pos = world.buildingPositions[id];
      final team = world.buildingTeams[id];

      if (type == null || pos == null) continue;

      final fp = footprintFor(type);
      final width = fp.cols * g.cellSize.toDouble();
      final height = fp.rows * g.cellSize.toDouble();

      final topLeftWorld = Vec2(pos.x - width / 2, pos.y - height / 2);
      final topLeftScreen = cam.worldToScreen(topLeftWorld);

      final rect = Rect.fromLTWH(
        topLeftScreen.x,
        topLeftScreen.y,
        width * cam.zoom,
        height * cam.zoom,
      );

      final fill = Paint()
        ..color = _buildingColor(type, team?.id ?? 1);
      canvas.drawRect(rect, fill);

      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF0F172A);
      canvas.drawRect(rect, border);

      final tp = TextPainter(
        text: TextSpan(
          text: type.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width - 8);

      tp.paint(canvas, Offset(rect.left + 4, rect.top + 4));
    }
  }

  Color _buildingColor(BuildingType type, int teamId) {
    switch (type) {
      case BuildingType.hq:
        return const Color(0xFF1D4ED8);
      case BuildingType.powerPlant:
        return const Color(0xFFEAB308);
      case BuildingType.barracks:
        return const Color(0xFF7C3AED);
      case BuildingType.refinery:
        return const Color(0xFFEA580C);
      case BuildingType.mobileHqCenter:
        return teamId == 2 ? const Color(0xFFEF4444) : const Color(0xFF60A5FA);
    }
  }

  void _drawUnits(Canvas canvas) {
    for (final id in world.entities) {
      final pos = world.positions[id];
      if (pos == null) continue;

      final hp = world.health[id];
      final team = world.teams[id];
      final kind = world.unitKinds[id] ?? 'tank';

      final Vec2 screen = cam.worldToScreen(pos.value);
      final center = Offset(screen.x, screen.y);

      final body = Paint()
        ..color = (team?.id == 2)
            ? const Color(0xFFEF4444)
            : const Color(0xFF60A5FA);

      if (kind == 'mobile_hq_center') {
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 28, height: 20),
          body,
        );
      } else {
        canvas.drawCircle(center, 14, body);
      }

      if (selected.contains(id)) {
        final ring = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFEAB308);
        canvas.drawCircle(center, 18, ring);
      }

      if (hp != null && hp.max > 0) {
        final frac = (hp.current / hp.max).clamp(0.0, 1.0);
        const barW = 40.0;
        const barH = 6.0;

        final topLeft = Offset(center.dx - barW / 2, center.dy - 26);

        canvas.drawRect(
          topLeft & const Size(barW, barH),
          Paint()..color = const Color(0xFF2A3440),
        );

        canvas.drawRect(
          topLeft & Size(barW * frac, barH),
          Paint()..color = const Color(0xFF42D392),
        );
      }
    }
  }

  void _drawHudHint(Canvas canvas, Size size) {
    final hint = pendingType == null
        ? 'Tap units to move. Deploy Mobile HQ, then build.'
        : 'Build mode: ${pendingType!.label}';

    final tp = TextPainter(
      text: TextSpan(
        text: hint,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 16);

    tp.paint(canvas, Offset(8, size.height - 24));
  }

  @override
  bool shouldRepaint(covariant WorldPainter oldDelegate) {
    return true;
  }
}
DART

cat > lib/screens/game_screen.dart <<'DART'
import 'dart:async';

import 'package:flutter/material.dart';

import '../game/buildings/build_placement.dart';
import '../game/buildings/build_radius.dart';
import '../game/buildings/building_footprint.dart';
import '../game/buildings/building_type.dart';
import '../game/core/entity_id.dart';
import '../game/core/game_loop.dart';
import '../game/map/map_definition.dart';
import '../game/map/map_grid.dart';
import '../game/map/map_loader.dart';
import '../game/map/occupancy_map.dart';
import '../game/math/vec2.dart';
import '../game/state/build_mode.dart';
import '../game/ui/camera_view.dart';
import '../game/ui/input_controller.dart';
import '../game/ui/world_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameLoop loop = GameLoop();
  final CameraView cam = CameraView(offset: const Vec2(0, 0), zoom: 1.0);
  final InputController input = InputController();
  final OccupancyMap occupancy = OccupancyMap();
  final BuildMode buildMode = BuildMode();

  Timer? _timer;

  MapDefinition? _map;
  MapGrid? _grid;
  bool _loading = true;
  String _status = 'Loading map...';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final loadedMap = await MapLoader.loadAsset('assets/maps/dev_map_01.json');
    _map = loadedMap;
    _grid = MapGrid(loadedMap);

    final spawn = loadedMap.spawns.first;
    final mobileHq = loop.world.spawnMobileHqCenter(
      Vec2(spawn.x, spawn.y),
      teamId: 1,
      hp: 35,
    );

    input.selected
      ..clear()
      ..add(mobileHq);

    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      loop.tick(1 / 60);
      setState(() {});
    });

    setState(() {
      _loading = false;
      _status = 'Move the Mobile HQ Center, then tap Deploy HQ.';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _rebuildOccupancy() {
    occupancy.clear();
    final g = _grid;
    if (g == null) return;

    for (final id in loop.world.buildingIds) {
      final type = loop.world.buildingTypes[id];
      final pos = loop.world.buildingPositions[id];
      if (type == null || pos == null) continue;

      final fp = footprintFor(type);
      occupancy.occupy(
        g.footprintCellsForCenter(pos, fp.cols, fp.rows),
      );
    }
  }

  EntityId? _singleSelectedMobileHq() {
    if (input.selected.length != 1) return null;
    final id = input.selected.first;
    if (!loop.world.isMobileHqCenter(id)) return null;
    return id;
  }

  bool get _hasFriendlyHq {
    for (final id in loop.world.buildingIds) {
      if (loop.world.buildingTeams[id]?.id != 1) continue;
      if (loop.world.buildingTypes[id] == BuildingType.hq) return true;
    }
    return false;
  }

  void _deploySelectedMobileHq() {
    final selected = _singleSelectedMobileHq();
    final g = _grid;
    if (selected == null || g == null) {
      setState(() {
        _status = 'Select the Mobile HQ Center first.';
      });
      return;
    }

    final pos = loop.world.positions[selected]?.value;
    if (pos == null) return;

    _rebuildOccupancy();

    final result = BuildPlacement.validate(
      world: loop.world,
      grid: g,
      occupancy: occupancy,
      teamId: 1,
      type: BuildingType.hq,
      center: pos,
      ignoreBuildRadius: true,
    );

    if (!result.ok) {
      setState(() {
        _status = 'Deploy failed: ${result.reason}';
      });
      return;
    }

    loop.world.destroy(selected);
    input.selected.remove(selected);
    loop.world.spawnBuilding(
      BuildingType.hq,
      result.snappedCenter,
      teamId: 1,
    );
    _rebuildOccupancy();

    setState(() {
      _status = 'HQ established. Build radius is now active.';
    });
  }

  void _toggleBuildMode(BuildingType type) {
    if (!_hasFriendlyHq) {
      setState(() {
        _status = 'Deploy the HQ first.';
      });
      return;
    }

    setState(() {
      if (buildMode.pendingType == type) {
        buildMode.clear();
        _status = 'Build mode cancelled.';
      } else {
        buildMode.select(type);
        _status = 'Tap the map to place ${type.label}.';
      }
    });
  }

  void _handleTapDown(TapDownDetails details) {
    final g = _grid;
    if (_loading || g == null) return;

    final local = details.localPosition;
    final worldTap = cam.screenToWorld(Vec2(local.dx, local.dy));

    if (buildMode.isActive && buildMode.pendingType != null) {
      _rebuildOccupancy();

      final type = buildMode.pendingType!;
      final result = BuildPlacement.validate(
        world: loop.world,
        grid: g,
        occupancy: occupancy,
        teamId: 1,
        type: type,
        center: worldTap,
      );

      if (result.ok) {
        loop.world.spawnBuilding(
          type,
          result.snappedCenter,
          teamId: 1,
        );
        _rebuildOccupancy();
        setState(() {
          buildMode.clear();
          _status = '${type.label} placed.';
        });
      } else {
        setState(() {
          _status = 'Cannot place ${type.label}: ${result.reason}';
        });
      }
      return;
    }

    setState(() {
      input.onTapDown(details: details, world: loop.world, cam: cam);
    });
  }

  Widget _buildToolbar() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton(
            onPressed: _singleSelectedMobileHq() != null ? _deploySelectedMobileHq : null,
            child: const Text('Deploy HQ'),
          ),
          ElevatedButton(
            onPressed: _hasFriendlyHq ? () => _toggleBuildMode(BuildingType.powerPlant) : null,
            child: const Text('Power Plant'),
          ),
          ElevatedButton(
            onPressed: _hasFriendlyHq ? () => _toggleBuildMode(BuildingType.barracks) : null,
            child: const Text('Barracks'),
          ),
          ElevatedButton(
            onPressed: _hasFriendlyHq ? () => _toggleBuildMode(BuildingType.refinery) : null,
            child: const Text('Refinery'),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                buildMode.clear();
                input.clearSelection();
                _status = 'Selection cleared.';
              });
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = _grid;

    if (_loading || _map == null || g == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final buildRadius = BuildRadius.coverageForTeam(
      world: loop.world,
      grid: g,
      teamId: 1,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('SwiftConquer • Phase 171–180'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF111827),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              _status,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTapDown: _handleTapDown,
              child: CustomPaint(
                painter: WorldPainter(
                  world: loop.world,
                  cam: cam,
                  selected: input.selected,
                  map: _map,
                  grid: g,
                  buildRadiusCells: buildRadius,
                  pendingType: buildMode.pendingType,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }
}
DART

python3 - <<'PY'
from pathlib import Path

p = Path("pubspec.yaml")
text = p.read_text()

if "assets/maps/" not in text and "assets/" in text:
    text = text.replace(
        "  assets:\n    - assets/\n",
        "  assets:\n    - assets/\n    - assets/maps/\n",
    )

p.write_text(text)
print("Patched pubspec.yaml")
PY

chmod +x phase171_180_basebuilding.sh

echo
echo "Phase 171-180 files written."
echo "Next:"
echo "  git status --short"
echo "  git add assets/maps lib/game/map lib/game/buildings lib/game/state lib/game/core/world_state.dart lib/game/ui/input_controller.dart lib/game/ui/world_painter.dart lib/screens/game_screen.dart pubspec.yaml phase171_180_basebuilding.sh"
echo "  git commit -m \"Phase 171-180: add map foundation and base-building demo\""
echo "  git push origin working/phase170-movement-ci"

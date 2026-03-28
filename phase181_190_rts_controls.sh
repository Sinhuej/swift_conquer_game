#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "== SwiftConquer Phase 181-190: RTS controls + HQ sidebar + group slots =="

mkdir -p lib/game/state

cat > lib/game/state/selection_groups.dart <<'DART'
import '../core/entity_id.dart';
import '../core/world_state.dart';

class SelectionGroups {
  final Map<int, Set<EntityId>> _groups = <int, Set<EntityId>>{};

  void assign(int slot, Iterable<EntityId> ids) {
    _groups[slot] = Set<EntityId>.from(ids);
  }

  Set<EntityId> recall(int slot, WorldState world) {
    final src = _groups[slot] ?? const <EntityId>{};
    return src.where(world.exists).toSet();
  }

  bool hasMembers(int slot, WorldState world) {
    return recall(slot, world).isNotEmpty;
  }

  int count(int slot, WorldState world) {
    return recall(slot, world).length;
  }
}
DART

cat > lib/game/ui/camera_view.dart <<'DART'
import '../math/vec2.dart';

class CameraView {
  Vec2 offset;
  double zoom;

  CameraView({
    required this.offset,
    required this.zoom,
  });

  Vec2 worldToScreen(Vec2 world) {
    return Vec2(
      (world.x - offset.x) * zoom,
      (world.y - offset.y) * zoom,
    );
  }

  Vec2 screenToWorld(Vec2 screen) {
    return Vec2(
      offset.x + (screen.x / zoom),
      offset.y + (screen.y / zoom),
    );
  }

  void panByScreenDelta(Vec2 deltaScreen) {
    offset = Vec2(
      offset.x - (deltaScreen.x / zoom),
      offset.y - (deltaScreen.y / zoom),
    );
  }
}
DART

cat > lib/game/buildings/building_type.dart <<'DART'
enum BuildingType {
  mobileHqCenter,
  hq,
  powerPlant,
  barracks,
  refinery,
  warFactory,
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
      case BuildingType.warFactory:
        return 'War Factory';
    }
  }

  bool get projectsBuildRadius {
    switch (this) {
      case BuildingType.mobileHqCenter:
        return false;
      case BuildingType.hq:
      case BuildingType.powerPlant:
      case BuildingType.barracks:
      case BuildingType.refinery:
      case BuildingType.warFactory:
        return true;
    }
  }

  bool get isBuildMenuType {
    switch (this) {
      case BuildingType.powerPlant:
      case BuildingType.barracks:
      case BuildingType.refinery:
      case BuildingType.warFactory:
        return true;
      case BuildingType.mobileHqCenter:
      case BuildingType.hq:
        return false;
    }
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
    case BuildingType.warFactory:
      return const BuildingFootprint(3, 2);
  }
}
DART

cat > lib/game/buildings/build_radius.dart <<'DART'
import '../core/world_state.dart';
import '../map/map_definition.dart';
import '../map/map_grid.dart';
import 'building_footprint.dart';
import 'building_type.dart';

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

cat > lib/game/ui/input_controller.dart <<'DART'
import 'dart:ui';

import '../buildings/building_footprint.dart';
import '../core/entity_id.dart';
import '../core/world_state.dart';
import '../math/vec2.dart';
import 'camera_view.dart';

class InputController {
  final Set<EntityId> selected = <EntityId>{};

  void onTapAt({
    required Offset localPos,
    required WorldState world,
    required CameraView cam,
  }) {
    final worldTap = cam.screenToWorld(Vec2(localPos.dx, localPos.dy));
    final hit = _hitTest(world: world, cam: cam, localPos: localPos, worldTap: worldTap);

    if (hit != null) {
      if (selected.contains(hit)) {
        selected.remove(hit);
        return;
      }

      selected
        ..clear()
        ..add(hit);
      return;
    }

    if (selected.isNotEmpty) {
      for (final id in selected) {
        final move = world.moveOrders[id];
        if (move != null) {
          move.target = worldTap;
        }
      }
    }
  }

  void selectBox({
    required Rect screenRect,
    required WorldState world,
    required CameraView cam,
    required int teamId,
  }) {
    selected.clear();

    for (final id in world.entities) {
      final team = world.teams[id];
      final pos = world.positions[id];
      if (team == null || pos == null) continue;
      if (team.id != teamId) continue;

      final screen = cam.worldToScreen(pos.value);
      if (screenRect.contains(Offset(screen.x, screen.y))) {
        selected.add(id);
      }
    }
  }

  EntityId? _hitTest({
    required WorldState world,
    required CameraView cam,
    required Offset localPos,
    required Vec2 worldTap,
  }) {
    EntityId? bestUnit;
    double bestDist2 = 999999999.0;

    for (final id in world.entities) {
      final pos = world.positions[id];
      if (pos == null) continue;
      final d = pos.value - worldTap;
      final dist2 = d.x * d.x + d.y * d.y;
      if (dist2 < bestDist2) {
        bestDist2 = dist2;
        bestUnit = id;
      }
    }

    if (bestUnit != null && bestDist2 <= (30 * 30)) {
      return bestUnit;
    }

    for (final id in world.buildingIds) {
      final type = world.buildingTypes[id];
      final center = world.buildingPositions[id];
      if (type == null || center == null) continue;

      final fp = footprintFor(type);
      final halfW = fp.cols * 40.0 / 2.0;
      final halfH = fp.rows * 40.0 / 2.0;

      final left = center.x - halfW;
      final top = center.y - halfH;
      final right = center.x + halfW;
      final bottom = center.y + halfH;

      if (worldTap.x >= left &&
          worldTap.x <= right &&
          worldTap.y >= top &&
          worldTap.y <= bottom) {
        return id;
      }
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
  final Rect? selectionBoxScreen;

  WorldPainter({
    required this.world,
    required this.cam,
    required this.selected,
    required this.map,
    required this.grid,
    required this.buildRadiusCells,
    required this.pendingType,
    required this.selectionBoxScreen,
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
    _drawSelectionBox(canvas);
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

    canvas.drawRect(rect, Paint()..color = const Color(0xFF101A28));
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

      canvas.drawRect(rect, Paint()..color = _buildingColor(type, team?.id ?? 1));
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF0F172A),
      );

      if (selected.contains(id)) {
        canvas.drawRect(
          rect.inflate(4),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFFEAB308),
        );
      }

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
      case BuildingType.warFactory:
        return const Color(0xFF475569);
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

      final screen = cam.worldToScreen(pos.value);
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
        canvas.drawCircle(
          center,
          18,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = const Color(0xFFEAB308),
        );
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

  void _drawSelectionBox(Canvas canvas) {
    final rect = selectionBoxScreen;
    if (rect == null) return;

    canvas.drawRect(
      rect,
      Paint()..color = const Color(0x2238BDF8),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF38BDF8),
    );
  }

  void _drawHudHint(Canvas canvas, Size size) {
    final hint = pendingType == null
        ? 'Tap to act. Drag to box-select. Two fingers pan.'
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
import 'dart:ui';

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
import '../game/state/selection_groups.dart';
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
  final SelectionGroups groups = SelectionGroups();

  Timer? _timer;

  MapDefinition? _map;
  MapGrid? _grid;
  bool _loading = true;
  String _status = 'Loading map...';

  int _activePointers = 0;
  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _dragSelecting = false;
  Offset? _lastScaleFocal;

  static const double _dragThreshold = 12.0;

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

  Rect? get _selectionBoxScreen {
    if (!_dragSelecting || _dragStart == null || _dragCurrent == null) {
      return null;
    }
    return Rect.fromPoints(_dragStart!, _dragCurrent!);
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

  EntityId? _singleSelectedHq() {
    if (input.selected.length != 1) return null;
    final id = input.selected.first;
    if (!loop.world.buildingIds.contains(id)) return null;
    if (loop.world.buildingTypes[id] != BuildingType.hq) return null;
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

    final hq = loop.world.spawnBuilding(
      BuildingType.hq,
      result.snappedCenter,
      teamId: 1,
    );

    input.selected
      ..clear()
      ..add(hq);

    _rebuildOccupancy();

    setState(() {
      _status = 'HQ established. Select it to open the build panel.';
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

  void _handleTapAt(Offset localPos) {
    final g = _grid;
    if (_loading || g == null) return;

    final worldTap = cam.screenToWorld(Vec2(localPos.dx, localPos.dy));

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
        final built = loop.world.spawnBuilding(
          type,
          result.snappedCenter,
          teamId: 1,
        );
        _rebuildOccupancy();

        setState(() {
          buildMode.clear();
          input.selected
            ..clear()
            ..add(built);
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
      input.onTapAt(localPos: localPos, world: loop.world, cam: cam);
      _status = input.selected.isEmpty
          ? 'Selection cleared.'
          : '${input.selected.length} item(s) selected.';
    });
  }

  void _finishSelectionDrag() {
    final rect = _selectionBoxScreen;
    if (rect != null && rect.width >= _dragThreshold && rect.height >= _dragThreshold) {
      input.selectBox(
        screenRect: rect,
        world: loop.world,
        cam: cam,
        teamId: 1,
      );
      _status = '${input.selected.length} unit(s) box-selected.';
    }
    _dragStart = null;
    _dragCurrent = null;
    _dragSelecting = false;
  }

  void _assignGroup(int slot) {
    groups.assign(slot, input.selected);
    setState(() {
      _status = 'Assigned ${input.selected.length} item(s) to group $slot.';
    });
  }

  void _recallGroup(int slot) {
    final recalled = groups.recall(slot, loop.world);
    setState(() {
      input.selected
        ..clear()
        ..addAll(recalled);
      _status = recalled.isEmpty
          ? 'Group $slot is empty.'
          : 'Recalled group $slot (${recalled.length}).';
    });
  }

  Widget _buildGroupChip(int slot) {
    final count = groups.count(slot, loop.world);
    return GestureDetector(
      onLongPress: () => _assignGroup(slot),
      child: OutlinedButton(
        onPressed: () => _recallGroup(slot),
        child: Text('$slot${count > 0 ? "($count)" : ""}'),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _singleSelectedMobileHq() != null ? _deploySelectedMobileHq : null,
                child: const Text('Deploy HQ'),
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
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List<Widget>.generate(7, (i) => _buildGroupChip(i + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildHqSidebar() {
    if (_singleSelectedHq() == null) {
      return const SizedBox.shrink();
    }

    final buttons = <BuildingType>[
      BuildingType.powerPlant,
      BuildingType.barracks,
      BuildingType.refinery,
      BuildingType.warFactory,
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 180,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xEE111827),
          border: Border.all(color: const Color(0xFF334155)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'HQ Build Panel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            for (final type in buttons)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _toggleBuildMode(type),
                    child: Text(type.label),
                  ),
                ),
              ),
          ],
        ),
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
        title: const Text('SwiftConquer • Phase 181–190'),
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
            child: Listener(
              onPointerDown: (event) {
                _activePointers++;
                if (_activePointers == 1 && !buildMode.isActive) {
                  _dragStart = event.localPosition;
                  _dragCurrent = event.localPosition;
                  _dragSelecting = false;
                } else {
                  _dragStart = null;
                  _dragCurrent = null;
                  _dragSelecting = false;
                }
                setState(() {});
              },
              onPointerMove: (event) {
                if (_activePointers == 1 && _dragStart != null && !buildMode.isActive) {
                  _dragCurrent = event.localPosition;
                  final delta = _dragCurrent! - _dragStart!;
                  if (delta.distance >= _dragThreshold) {
                    _dragSelecting = true;
                  }
                  setState(() {});
                }
              },
              onPointerUp: (event) {
                if (_activePointers == 1) {
                  if (_dragSelecting) {
                    setState(_finishSelectionDrag);
                  } else {
                    _dragStart = null;
                    _dragCurrent = null;
                    _dragSelecting = false;
                    _handleTapAt(event.localPosition);
                  }
                }
                _activePointers = (_activePointers - 1).clamp(0, 99);
                if (_activePointers < 2) {
                  _lastScaleFocal = null;
                }
                setState(() {});
              },
              onPointerCancel: (_) {
                _activePointers = 0;
                _dragStart = null;
                _dragCurrent = null;
                _dragSelecting = false;
                _lastScaleFocal = null;
                setState(() {});
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: (details) {
                  if (_activePointers >= 2) {
                    _lastScaleFocal = details.focalPoint;
                    _dragStart = null;
                    _dragCurrent = null;
                    _dragSelecting = false;
                  }
                },
                onScaleUpdate: (details) {
                  if (_activePointers >= 2) {
                    final current = details.focalPoint;
                    final last = _lastScaleFocal;
                    if (last != null) {
                      final delta = current - last;
                      cam.panByScreenDelta(Vec2(delta.dx, delta.dy));
                    }
                    _lastScaleFocal = current;
                    setState(() {});
                  }
                },
                onScaleEnd: (_) {
                  _lastScaleFocal = null;
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: WorldPainter(
                          world: loop.world,
                          cam: cam,
                          selected: input.selected,
                          map: _map,
                          grid: g,
                          buildRadiusCells: buildRadius,
                          pendingType: buildMode.pendingType,
                          selectionBoxScreen: _selectionBoxScreen,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    _buildHqSidebar(),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }
}
DART

chmod +x phase181_190_rts_controls.sh

echo
echo "Phase 181-190 files written."
echo "Next:"
echo "  git status --short"
echo "  git add lib/game/state/selection_groups.dart lib/game/ui/camera_view.dart lib/game/buildings/building_type.dart lib/game/buildings/building_footprint.dart lib/game/buildings/build_radius.dart lib/game/ui/input_controller.dart lib/game/ui/world_painter.dart lib/screens/game_screen.dart phase181_190_rts_controls.sh"
echo "  git commit -m \"Phase 181-190: add RTS controls, HQ sidebar, and group slots\""
echo "  git push origin working/phase170-movement-ci"

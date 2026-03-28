#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "== SwiftConquer Phase 196-205: central HQ, real sidebar, bookmarks, and first production loop =="

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
import '../game/state/camera_bookmarks.dart';
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
  final CameraBookmarks bookmarks = CameraBookmarks();

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
  double? _lastScaleValue;

  bool _cameraPrimed = false;
  Vec2? _homeCenter;

  static const double _dragThreshold = 12.0;
  static const double _sidebarWidth = 220.0;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final loadedMap = await MapLoader.loadAsset('assets/maps/dev_map_01.json');
    _map = loadedMap;
    _grid = MapGrid(loadedMap);

    final center = Vec2(
      loadedMap.worldWidth / 2.0,
      loadedMap.worldHeight / 2.0,
    );

    final hq = loop.world.spawnBuilding(
      BuildingType.hq,
      center,
      teamId: 1,
    );

    _homeCenter = center;

    input.selected
      ..clear()
      ..add(hq);

    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      loop.tick(1 / 60);
      if (mounted) {
        setState(() {});
      }
    });

    setState(() {
      _loading = false;
      _status = 'Central HQ ready. Build from the right sidebar.';
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

  bool get _hasFriendlyHq {
    for (final id in loop.world.buildingIds) {
      if (loop.world.buildingTeams[id]?.id != 1) continue;
      if (loop.world.buildingTypes[id] == BuildingType.hq) return true;
    }
    return false;
  }

  EntityId? _singleSelectedBuildingOfType(BuildingType type) {
    if (input.selected.length != 1) return null;
    final id = input.selected.first;
    if (!loop.world.buildingIds.contains(id)) return null;
    if (loop.world.buildingTypes[id] != type) return null;
    return id;
  }

  void _primeCameraIfNeeded(Size playfieldSize) {
    if (_cameraPrimed || _map == null || _homeCenter == null) return;

    final world = _map!;
    final center = _homeCenter!;

    final visibleWorldW = playfieldSize.width / cam.zoom;
    final visibleWorldH = playfieldSize.height / cam.zoom;

    final maxX = (world.worldWidth - visibleWorldW).clamp(0.0, double.infinity);
    final maxY = (world.worldHeight - visibleWorldH).clamp(0.0, double.infinity);

    final targetX = (center.x - visibleWorldW / 2.0).clamp(0.0, maxX.toDouble());
    final targetY = (center.y - visibleWorldH / 2.0).clamp(0.0, maxY.toDouble());

    cam.offset = Vec2(targetX, targetY);
    _cameraPrimed = true;
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

  void _toggleBuildMode(BuildingType type) {
    if (!_hasFriendlyHq) {
      setState(() {
        _status = 'An HQ is required before building.';
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

  void _spawnProducedUnit({
    required EntityId buildingId,
    required String unitKind,
    required int hp,
    required String statusText,
  }) {
    final type = loop.world.buildingTypes[buildingId];
    final center = loop.world.buildingPositions[buildingId];
    final team = loop.world.buildingTeams[buildingId];

    if (type == null || center == null || team == null) return;

    final fp = footprintFor(type);
    final spawn = Vec2(
      center.x + (fp.cols * 40.0 / 2.0) + 38.0,
      center.y,
    );

    final unit = loop.world.spawnUnit(
      spawn,
      teamId: team.id,
      hp: hp,
      kind: unitKind,
    );

    setState(() {
      input.selected
        ..clear()
        ..add(unit);
      _status = statusText;
    });
  }

  void _produceInfantry() {
    final barracks = _singleSelectedBuildingOfType(BuildingType.barracks);
    if (barracks == null) return;
    _spawnProducedUnit(
      buildingId: barracks,
      unitKind: 'infantry',
      hp: 30,
      statusText: 'Infantry produced from Barracks.',
    );
  }

  void _produceHarvester() {
    final refinery = _singleSelectedBuildingOfType(BuildingType.refinery);
    if (refinery == null) return;
    _spawnProducedUnit(
      buildingId: refinery,
      unitKind: 'harvester',
      hp: 80,
      statusText: 'Harvester produced from Refinery.',
    );
  }

  void _produceTank() {
    final wf = _singleSelectedBuildingOfType(BuildingType.warFactory);
    if (wf == null) return;
    _spawnProducedUnit(
      buildingId: wf,
      unitKind: 'tank',
      hp: 120,
      statusText: 'Tank produced from War Factory.',
    );
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
          _dragStart = null;
          _dragCurrent = null;
          _dragSelecting = false;
          _lastScaleFocal = null;
          _lastScaleValue = null;
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
    if (rect != null &&
        rect.width >= _dragThreshold &&
        rect.height >= _dragThreshold) {
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

  void _saveBookmark(int slot) {
    bookmarks.save(
      slot: slot,
      offset: cam.offset,
      zoom: cam.zoom,
    );
    setState(() {
      _status = 'Saved bookmark $slot.';
    });
  }

  void _recallBookmark(int slot) {
    final mark = bookmarks.recall(slot);
    if (mark == null) {
      setState(() {
        _status = 'Bookmark $slot is empty.';
      });
      return;
    }

    setState(() {
      cam.offset = Vec2(mark.offset.x, mark.offset.y);
      cam.zoom = mark.zoom;
      _status = 'Jumped to bookmark $slot.';
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

  Widget _buildBookmarkChip(int slot) {
    final filled = bookmarks.hasSlot(slot);
    return GestureDetector(
      onLongPress: () => _saveBookmark(slot),
      child: OutlinedButton(
        onPressed: () => _recallBookmark(slot),
        child: Text('B$slot${filled ? "*" : ""}'),
      ),
    );
  }

  Widget _buildTopBookmarkBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Bookmarks:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(width: 8),
            ...List<Widget>.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _buildBookmarkChip(i + 1),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isBarracks = _singleSelectedBuildingOfType(BuildingType.barracks) != null;
    final isRefinery = _singleSelectedBuildingOfType(BuildingType.refinery) != null;
    final isWarFactory = _singleSelectedBuildingOfType(BuildingType.warFactory) != null;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isBarracks)
                ElevatedButton(
                  onPressed: _produceInfantry,
                  child: const Text('Produce Infantry'),
                ),
              if (isRefinery)
                ElevatedButton(
                  onPressed: _produceHarvester,
                  child: const Text('Produce Harvester'),
                ),
              if (isWarFactory)
                ElevatedButton(
                  onPressed: _produceTank,
                  child: const Text('Produce Tank'),
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

  Widget _buildPersistentBuildSidebar() {
    final buttons = <BuildingType>[
      BuildingType.powerPlant,
      BuildingType.barracks,
      BuildingType.refinery,
      BuildingType.warFactory,
    ];

    return Container(
      width: _sidebarWidth,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: SafeArea(
        left: false,
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Build',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),
            for (final type in buttons)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: _hasFriendlyHq ? () => _toggleBuildMode(type) : null,
                  child: Text(
                    buildMode.pendingType == type
                        ? 'Cancel ${type.label}'
                        : type.label,
                  ),
                ),
              ),
            const Spacer(),
            const Text(
              'Build directly on the map.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
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
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: ColoredBox(
          color: const Color(0xFF0B1220),
          child: Column(
            children: [
              _buildTopBookmarkBar(),
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
                child: Row(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final playfieldSize = Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                          _primeCameraIfNeeded(playfieldSize);

                          return Listener(
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
                              if (_activePointers == 1 &&
                                  _dragStart != null &&
                                  !buildMode.isActive) {
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
                              if (_activePointers < 3) {
                                _lastScaleValue = null;
                              }
                              setState(() {});
                            },
                            onPointerCancel: (_) {
                              _activePointers = 0;
                              _dragStart = null;
                              _dragCurrent = null;
                              _dragSelecting = false;
                              _lastScaleFocal = null;
                              _lastScaleValue = null;
                              setState(() {});
                            },
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onScaleStart: (details) {
                                if (_activePointers >= 2) {
                                  _lastScaleFocal = details.focalPoint;
                                }
                                if (_activePointers >= 3) {
                                  _lastScaleValue = 1.0;
                                } else {
                                  _lastScaleValue = null;
                                }
                                if (_activePointers >= 2) {
                                  _dragStart = null;
                                  _dragCurrent = null;
                                  _dragSelecting = false;
                                }
                              },
                              onScaleUpdate: (details) {
                                if (_activePointers == 2) {
                                  final current = details.focalPoint;
                                  final last = _lastScaleFocal;
                                  if (last != null) {
                                    final delta = current - last;
                                    cam.panByScreenDelta(Vec2(delta.dx, delta.dy));
                                  }
                                  _lastScaleFocal = current;
                                  setState(() {});
                                } else if (_activePointers >= 3) {
                                  final current = details.focalPoint;
                                  final lastScale = _lastScaleValue ?? 1.0;
                                  final deltaScale = details.scale / lastScale;
                                  cam.zoomByScale(
                                    scaleDelta: deltaScale,
                                    focalScreen: Vec2(current.dx, current.dy),
                                  );
                                  _lastScaleFocal = current;
                                  _lastScaleValue = details.scale;
                                  setState(() {});
                                }
                              },
                              onScaleEnd: (_) {
                                _lastScaleFocal = null;
                                _lastScaleValue = null;
                              },
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
                          );
                        },
                      ),
                    ),
                    _buildPersistentBuildSidebar(),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }
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
      final hp = world.buildingHealth[id];

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

      if (hp != null && hp.max > 0) {
        final frac = (hp.current / hp.max).clamp(0.0, 1.0);
        const barH = 6.0;
        final barW = rect.width.clamp(28.0, 96.0);
        final topLeft = Offset(rect.left, rect.top - 10);

        canvas.drawRect(
          topLeft & Size(barW, barH),
          Paint()..color = const Color(0xFF2A3440),
        );

        canvas.drawRect(
          topLeft & Size(barW * frac, barH),
          Paint()..color = const Color(0xFF42D392),
        );
      }
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
      } else if (kind == 'harvester') {
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 30, height: 18),
          body,
        );
      } else if (kind == 'tank') {
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 26, height: 16),
          body,
        );
      } else if (kind == 'infantry') {
        canvas.drawCircle(center, 9, body);
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
        ? '1 finger select. 2 fingers pan. 3 fingers zoom.'
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
  bool shouldRepaint(covariant WorldPainter oldDelegate) => true;
}
DART

chmod +x phase196_205_layout_and_production.sh

echo
echo "Phase 196-205 files written."
echo "Next:"
echo "  git status --short"
echo "  git add lib/screens/game_screen.dart lib/game/ui/world_painter.dart phase196_205_layout_and_production.sh"
echo "  git commit -m \"Phase 196-205: central HQ start, real sidebar, bookmarks, and first production loop\""
echo "  git push origin working/phase170-movement-ci"

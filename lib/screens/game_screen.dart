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

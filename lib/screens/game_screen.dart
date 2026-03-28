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

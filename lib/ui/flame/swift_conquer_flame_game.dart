import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

import '../render_models/render_world.dart';
import 'camera/camera_smoother.dart';
import 'render/debug_entity_layer.dart';
import 'render/interpolation_buffer.dart';
import 'render/parallax_layer.dart';
import 'render/snapshot_flattener.dart';

class SwiftConquerFlameGame extends FlameGame {
  final CameraSmoother _cam = CameraSmoother(
    initialPosition: Vector2.zero(),
    initialZoom: 1.0,
    positionSharpness: 12.0,
    zoomSharpness: 10.0,
  );

  late final ParallaxLayer _bgFar;
  late final ParallaxLayer _bgMid;
  late final ParallaxLayer _bgNear;

  final InterpolationBuffer _interp = InterpolationBuffer(tickSeconds: 1 / 60);
  final SnapshotFlattener _flattener = const SnapshotFlattener();
  late final DebugEntityLayer _debugEntities;

  RenderWorld? _latestSnapshot;

  void pushSnapshot(RenderWorld snapshot) {
    _latestSnapshot = snapshot;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _bgFar = ParallaxLayer(
      parallaxFactor: 0.2,
      size: canvasSize,
      child: RectangleComponent(
        size: canvasSize,
        paint: Paint()..color = const Color(0xFF101820),
      ),
    );
    _bgMid = ParallaxLayer(
      parallaxFactor: 0.4,
      size: canvasSize,
      child: RectangleComponent(
        size: canvasSize,
        paint: Paint()..color = const Color(0xFF182430),
      ),
    );
    _bgNear = ParallaxLayer(
      parallaxFactor: 0.6,
      size: canvasSize,
      child: RectangleComponent(
        size: canvasSize,
        paint: Paint()..color = const Color(0xFF202E3A),
      ),
    );

    addAll([_bgFar, _bgMid, _bgNear]);
    _debugEntities = DebugEntityLayer(buffer: _interp)..priority = 10;
    add(_debugEntities);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _interp.update(dt);

    final targetWorldPos = _getCameraTargetWorldPosFromSnapshot();
    const targetZoom = 1.0;

    _cam.update(
      dt: dt,
      targetPosition: targetWorldPos,
      targetZoom: targetZoom,
    );

    _applyCamera(_cam.position, _cam.zoom);
    _bgFar.updateFromCamera(_cam.position);
    _bgMid.updateFromCamera(_cam.position);
    _bgNear.updateFromCamera(_cam.position);

    final snap = _latestSnapshot;
    if (snap == null) return;

    final flattened = _flattener.flatten(snap);
    if (flattened.isNotEmpty) {
      _interp.ingest(flattened);
    }
  }

  Vector2 _getCameraTargetWorldPosFromSnapshot() {
    final snap = _latestSnapshot;
    if (snap == null || snap.units.isEmpty) {
      return Vector2.zero();
    }

    double sx = 0;
    double sy = 0;
    int n = 0;

    for (final unit in snap.units) {
      if (!unit.alive) continue;
      sx += unit.x;
      sy += unit.y;
      n++;
    }

    if (n == 0) {
      return Vector2.zero();
    }

    return Vector2(sx / n, sy / n);
  }

  void _applyCamera(Vector2 worldPos, double zoom) {
    camera.viewfinder.position = worldPos;
    camera.viewfinder.zoom = zoom;
  }
}

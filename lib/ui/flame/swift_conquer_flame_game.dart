import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/extensions.dart';
import 'package:flame/components.dart';

import 'camera/camera_smoother.dart';
import 'render/parallax_layer.dart';

import 'render/interpolation_buffer.dart';
import 'render/snapshot_flattener.dart';
import 'render/debug_entity_layer.dart';

class SwiftConquerFlameGame extends FlameGame {
  // ---------------- Stage 1 (camera) ----------------
  final CameraSmoother _cam = CameraSmoother(
    initialPosition: Vector2.zero(),
    initialZoom: 1.0,
    positionSharpness: 12.0,
    zoomSharpness: 10.0,
  );

  late final ParallaxLayer _bgFar;
  late final ParallaxLayer _bgMid;
  late final ParallaxLayer _bgNear;

  // ---------------- Stage 2 (interpolation) ----------------
  final InterpolationBuffer _interp = InterpolationBuffer(tickSeconds: 1 / 20);
  final SnapshotFlattener _flattener = const SnapshotFlattener();
  late final DebugEntityLayer _debugEntities;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Stage 1 backgrounds (placeholders for now)
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

    // Stage 2 debug render (shows interpolation is working)
    _debugEntities = DebugEntityLayer(buffer: _interp)
      ..priority = 0; // background-relative; entities can go above later
    add(_debugEntities);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ---- Stage 2: advance render-time between ticks
    _interp.update(dt);

    // ---- Stage 1: camera smoothing (visual only)
    final targetWorldPos = _getCameraTargetWorldPosFromSnapshot();
    final targetZoom = _getTargetZoomFromSnapshotOrDefault();

    _cam.update(
      dt: dt,
      targetPosition: targetWorldPos,
      targetZoom: targetZoom,
    );

    _applyCamera(_cam.position, _cam.zoom);

    // Parallax update (visual only)
    _bgFar.updateFromCamera(_cam.position);
    _bgMid.updateFromCamera(_cam.position);
    _bgNear.updateFromCamera(_cam.position);

    // ---- Stage 2: ingest snapshot when available (once per sim tick)
    final snap = _tryReadLatestWorldSnapshotForViz();
    if (snap != null) {
      final flattened = _flattener.flatten(snap);
      _interp.ingest(flattened);
    }
  }

  // ---------------------------------------------------------------------------
  // Snapshot hooks (READ-ONLY)
  // ---------------------------------------------------------------------------

  dynamic _tryReadLatestWorldSnapshotForViz() {
    // TODO: wire to your real snapshot feed
    return null;
  }

  Vector2 _getCameraTargetWorldPosFromSnapshot() {
    return Vector2.zero();
  }

  double _getTargetZoomFromSnapshotOrDefault() {
    return 1.0;
  }

  void _applyCamera(Vector2 worldPos, double zoom) {
    camera.viewfinder.position = worldPos;
    camera.viewfinder.zoom = zoom;
  }
}

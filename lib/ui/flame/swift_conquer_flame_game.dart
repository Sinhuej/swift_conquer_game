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

    // Painter's algorithm (Y-based draw order)
    children.register<PositionComponent>()
      ..comparator = (a, b) => a.position.y.compareTo(b.position.y);

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
    _debugEntities = DebugEntityLayer(buffer: _interp);
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
    // This hook MUST remain read-only. It should consume the canonical snapshot (B)
    // that your visualization layer already receives.
    final snap = _tryReadLatestWorldSnapshotForViz();
    if (snap != null) {
      final flattened = _flattener.flatten(snap); // B -> A (Flame-side)
      _interp.ingest(flattened);
    }
  }

  // ---------------------------------------------------------------------------
  // Snapshot hooks (READ-ONLY)
  // ---------------------------------------------------------------------------

  /// Return the latest canonical snapshot (B) used for visualization, or null if none.
  /// IMPORTANT: do NOT import core sim types here if they live outside UI layer;
  /// this should reference only visualization DTOs.
  dynamic _tryReadLatestWorldSnapshotForViz() {
    // TODO: Wire this to your existing snapshot feed.
    // Examples:
    // - a Stream/ValueNotifier updated by your Flutter layer
    // - a cached lastSnapshot your Flame game is already receiving
    return null;
  }

  Vector2 _getCameraTargetWorldPosFromSnapshot() {
    // v1 safe default until wired to snapshot
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

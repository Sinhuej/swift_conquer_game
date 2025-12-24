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
  final InterpolationBuffer _interp = InterpolationBuffer(tickSeconds: 1 / 60);
  final SnapshotFlattener _flattener = const SnapshotFlattener();
  late final DebugEntityLayer _debugEntities;

  // Latest canonical snapshot (B) pushed from Flutter/UI bridge.
  dynamic _latestSnapshot;

  /// Read-only push from Flutter.
  /// Flame does NOT tick the simulation. Flame only renders what it is given.
  void pushSnapshot(dynamic snapshot) {
    _latestSnapshot = snapshot;
  }

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

    // Debug render layer: proves interpolation is working with real snapshot data.
    _debugEntities = DebugEntityLayer(buffer: _interp)..priority = 10;
    add(_debugEntities);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Stage 2: advance render-time between ticks (visual only)
    _interp.update(dt);

    // Stage 1: camera smoothing (visual only)
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

    // Stage 2: ingest canonical snapshot (B) when available
    final snap = _tryReadLatestWorldSnapshotForViz();
    if (snap != null) {
      final flattened = _flattener.flatten(snap); // B -> A (Flame-side)
      if (flattened.isNotEmpty) {
        _interp.ingest(flattened);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Snapshot hooks (READ-ONLY)
  // ---------------------------------------------------------------------------

  dynamic _tryReadLatestWorldSnapshotForViz() => _latestSnapshot;

  Vector2 _getCameraTargetWorldPosFromSnapshot() {
    // v1: action centroid (best feel) derived from snapshot if possible
    try {
      final snap = _latestSnapshot;
      if (snap == null) return Vector2.zero();
      final list = (snap as dynamic).entities as dynamic;
      if (list == null) return Vector2.zero();

      double sx = 0, sy = 0;
      int n = 0;

      for (final e in list) {
        final dx = _readNum(e, 'x');
        final dy = _readNum(e, 'y');
        if (dx == null || dy == null) continue;
        sx += dx;
        sy += dy;
        n++;
      }
      if (n == 0) return Vector2.zero();
      return Vector2(sx / n, sy / n);
    } catch (_) {
      return Vector2.zero();
    }
  }

  double _getTargetZoomFromSnapshotOrDefault() => 1.0;

  void _applyCamera(Vector2 worldPos, double zoom) {
    camera.viewfinder.position = worldPos;
    camera.viewfinder.zoom = zoom;
  }

  double? _readNum(dynamic obj, String key) {
    try {
      if (obj is Map) {
        final v = obj[key];
        if (v is num) return v.toDouble();
        return null;
      }
      final v = (obj as dynamic).__getattr__(key); // will throw; kept for safety
      if (v is num) return v.toDouble();
      return null;
    } catch (_) {
      // Typed DTO path
      try {
        final v = (obj as dynamic).toJson?.call();
        if (v is Map) {
          final m = v[key];
          if (m is num) return m.toDouble();
        }
      } catch (_) {}
      try {
        final v = (obj as dynamic).x;
        if (key == 'x' && v is num) return v.toDouble();
      } catch (_) {}
      try {
        final v = (obj as dynamic).y;
        if (key == 'y' && v is num) return v.toDouble();
      } catch (_) {}
      return null;
    }
  }
}

import 'dart:math' as math;
import 'package:flame/extensions.dart';
import 'render_entity.dart';

/// Frame-smoothing layer between sim ticks.
/// - Holds previous + current render-lists (A) derived from canonical snapshot (B)
/// - Computes alpha each frame
/// - Interpolates pose per entity id
///
/// IMPORTANT: This is visual only. No sim authority.
class InterpolationBuffer {
  // Maps id -> entity for prev/curr
  final Map<int, RenderEntity> _prev = <int, RenderEntity>{};
  final Map<int, RenderEntity> _curr = <int, RenderEntity>{};

  // Time since last ingest (seconds)
  double _t = 0.0;

  // Sim tick duration (seconds)
  double tickSeconds;

  InterpolationBuffer({this.tickSeconds = 1 / 20});

  /// Call when a NEW snapshot arrives (once per sim tick / snapshot update).
  /// `entities` is the flattened list (A) derived in Flame from snapshot (B).
  void ingest(List<RenderEntity> entities) {
    _prev
      ..clear()
      ..addAll(_curr);
    _curr
      ..clear();
    for (final e in entities) {
      _curr[e.id] = e;
    }
    _t = 0.0;
  }

  /// Call every frame from FlameGame.update(dt)
  void update(double dt) {
    if (!dt.isFinite) return;
    _t += dt.clamp(0.0, 0.1);
  }

  /// Alpha in [0..1] between prev and curr.
  double get alpha {
    final denom = tickSeconds <= 0 ? 0.05 : tickSeconds;
    return (_t / denom).clamp(0.0, 1.0);
  }

  /// Returns interpolated pose for entity id.
  RenderPose? pose(int id) {
    final a = alpha;
    final c = _curr[id];
    if (c == null) return null;

    final p = _prev[id];
    if (p == null) {
      // First frame we see it — no interpolation possible yet.
      return RenderPose(c.pos, c.rot);
    }

    final pos = p.pos.clone()..lerp(c.pos, a);
    final rot = _lerpAngle(p.rot, c.rot, a);
    return RenderPose(pos, rot);
  }

  Iterable<int> get currentIds => _curr.keys;

  static double _lerpAngle(double a, double b, double t) {
    // shortest-path angle lerp
    final diff = ((b - a + math.pi) % (2 * math.pi)) - math.pi;
    return a + diff * t;
  }
}

import 'dart:math' as math;
import 'package:flame/extensions.dart';

/// Pure visual camera smoothing (read-only).
/// NO simulation access. NO mutation.
class CameraSmoother {
  Vector2 _pos;
  double _zoom;

  final double positionSharpness;
  final double zoomSharpness;

  CameraSmoother({
    Vector2? initialPosition,
    double initialZoom = 1.0,
    this.positionSharpness = 12.0,
    this.zoomSharpness = 10.0,
  })  : _pos = initialPosition?.clone() ?? Vector2.zero(),
        _zoom = initialZoom;

  Vector2 get position => _pos;
  double get zoom => _zoom;

  void update({
    required double dt,
    required Vector2 targetPosition,
    required double targetZoom,
  }) {
    final clampedDt = dt.isFinite ? dt.clamp(0.0, 0.1) : 0.016;

    final posAlpha = _alpha(positionSharpness, clampedDt);
    final zoomAlpha = _alpha(zoomSharpness, clampedDt);

    _pos.lerp(targetPosition, posAlpha);
    _zoom += (targetZoom - _zoom) * zoomAlpha;
  }

  double _alpha(double sharpness, double dt) {
    return (1.0 - math.exp(-sharpness * dt)).clamp(0.0, 1.0);
  }
}

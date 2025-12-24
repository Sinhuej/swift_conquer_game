import 'package:flame/components.dart';

/// Mixin for components that should be depth-sorted by Y.
/// Lower Y draws first, higher Y draws on top.
mixin DepthSortable on PositionComponent {
  double get depthY => position.y;
}

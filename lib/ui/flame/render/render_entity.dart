import 'package:flame/extensions.dart';

/// Render-only entity DTO (Flame-side).
/// Derived from canonical world snapshot (B). No sim references.
class RenderEntity {
  final int id;
  final Vector2 pos;
  final double rot; // radians
  final int type;   // whatever you need (enum index, etc.)
  final int flags;  // bitfield for alive/moving/attacking/etc.

  const RenderEntity({
    required this.id,
    required this.pos,
    required this.rot,
    required this.type,
    required this.flags,
  });
}

/// Interpolated pose used by renderer.
class RenderPose {
  final Vector2 pos;
  final double rot;

  const RenderPose(this.pos, this.rot);
}

import 'package:flame/extensions.dart';
import 'render_entity.dart';

/// Flame-only adapter that derives a render-ready list (A) from your canonical snapshot (B).
/// This MUST NOT import or mutate core sim. It should only read snapshot DTOs that
/// are already intended for visualization.
///
/// By default it returns empty until you wire the snapshot shape.
class SnapshotFlattener {
  const SnapshotFlattener();

  /// Replace the body with your actual snapshot read.
  /// `snapshot` is whatever your visualization layer already receives (B).
  List<RenderEntity> flatten(dynamic snapshot) {
    // TODO: Wire to your real canonical snapshot (B).
    //
    // Example pseudocode (adapt to your real fields):
    // final entities = <RenderEntity>[];
    // for (final e in snapshot.entities) {
    //   entities.add(RenderEntity(
    //     id: e.id,
    //     pos: Vector2(e.x, e.y),
    //     rot: e.rot,
    //     type: e.typeIndex,
    //     flags: e.flags,
    //   ));
    // }
    // return entities;

    return const <RenderEntity>[];
  }
}

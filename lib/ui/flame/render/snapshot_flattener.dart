import 'package:flame/extensions.dart';
import 'render_entity.dart';

/// Flame-only adapter that derives a render-ready list (A) from canonical snapshot (B).
/// Must remain READ-ONLY and UI-safe.
class SnapshotFlattener {
  const SnapshotFlattener();

  List<RenderEntity> flatten(dynamic snapshot) {
    try {
      final dyn = snapshot as dynamic;
      final entities = dyn.entities as dynamic;
      if (entities == null) return const <RenderEntity>[];

      final out = <RenderEntity>[];
      for (final e in entities) {
        final id = _readInt(e, 'id');
        final x = _readNum(e, 'x');
        final y = _readNum(e, 'y');

        if (id == null || x == null || y == null) continue;

        final rot = _readNum(e, 'rot') ?? 0.0;
        final type = _readInt(e, 'type') ?? 0;
        final flags = _readInt(e, 'flags') ?? 0;

        out.add(RenderEntity(
          id: id,
          pos: Vector2(x, y),
          rot: rot,
          type: type,
          flags: flags,
        ));
      }
      return out;
    } catch (_) {
      return const <RenderEntity>[];
    }
  }

  double? _readNum(dynamic obj, String key) {
    try {
      if (obj is Map) {
        final v = obj[key];
        return v is num ? v.toDouble() : null;
      }
      final v = (obj as dynamic).toJson?.call();
      if (v is Map) {
        final m = v[key];
        return m is num ? m.toDouble() : null;
      }
      // Typed DTO common field names
      if (key == 'x') return ((obj as dynamic).x as num).toDouble();
      if (key == 'y') return ((obj as dynamic).y as num).toDouble();
      if (key == 'rot') return ((obj as dynamic).rot as num).toDouble();
      return null;
    } catch (_) {
      return null;
    }
  }

  int? _readInt(dynamic obj, String key) {
    try {
      if (obj is Map) {
        final v = obj[key];
        return v is num ? v.toInt() : null;
      }
      final v = (obj as dynamic).toJson?.call();
      if (v is Map) {
        final m = v[key];
        return m is num ? m.toInt() : null;
      }
      // Typed DTO common field names
      if (key == 'id') return ((obj as dynamic).id as num).toInt();
      if (key == 'type') return ((obj as dynamic).type as num).toInt();
      if (key == 'flags') return ((obj as dynamic).flags as num).toInt();
      return null;
    } catch (_) {
      return null;
    }
  }
}

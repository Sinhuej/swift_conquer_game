import '../math/vec2.dart';

class CameraBookmark {
  final Vec2 offset;
  final double zoom;

  const CameraBookmark({
    required this.offset,
    required this.zoom,
  });
}

class CameraBookmarks {
  final Map<int, CameraBookmark> _slots = <int, CameraBookmark>{};

  void save({
    required int slot,
    required Vec2 offset,
    required double zoom,
  }) {
    _slots[slot] = CameraBookmark(
      offset: Vec2(offset.x, offset.y),
      zoom: zoom,
    );
  }

  CameraBookmark? recall(int slot) => _slots[slot];

  bool hasSlot(int slot) => _slots.containsKey(slot);
}

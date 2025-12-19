import '../../math/vec2.dart';

class SelectionBox {
  Vec2? start;
  Vec2? end;

  bool get active => start != null && end != null;

  void begin(Vec2 p) {
    start = p;
    end = p;
  }

  void update(Vec2 p) {
    end = p;
  }

  void clear() {
    start = null;
    end = null;
  }
}

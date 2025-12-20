import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class CameraInput extends Component
    with DragCallbacks, ScrollCallbacks, HasGameRef<FlameGame> {
  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Pan camera by dragging.
    gameRef.camera.viewfinder.position -= event.delta;
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final zoom = gameRef.camera.viewfinder.zoom;
    final factor = info.scrollDelta.game.y > 0 ? 0.9 : 1.1;
    gameRef.camera.viewfinder.zoom = (zoom * factor).clamp(0.5, 3.0);
  }
}

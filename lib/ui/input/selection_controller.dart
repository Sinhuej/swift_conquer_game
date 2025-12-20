import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '../flame/unit_component.dart';

class SelectionController extends Component
    with TapCallbacks, HasGameRef<FlameGame> {
  UnitComponent? selected;

  @override
  void onTapUp(TapUpEvent event) {
    final tapped = gameRef.componentsAtPoint(event.canvasPosition)
        .whereType<UnitComponent>()
        .firstOrNull;

    if (tapped != null) {
      selected?.selected = false;
      selected = tapped;
      selected!.selected = true;
    }
  }
}

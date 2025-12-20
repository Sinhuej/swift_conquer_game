import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../../sim_ext/ai_integration/command_sink.dart';
import '../../sim_ext/ai_wiring/command_envelope.dart';

class PlayerInput extends Component
    with TapCallbacks, HasGameRef<FlameGame> {
  final CommandSink sink;

  /// Temporary: hardcoded selected unit until we add selection.
  int selectedUnitId = 1;

  /// Tick is 0 for now; later we’ll pass real sim tick from a UI controller.
  int tick = 0;

  PlayerInput(this.sink);

  @override
  void onTapUp(TapUpEvent event) {
    final p = event.canvasPosition;

    sink.submit(CommandEnvelope(
      tick: tick,
      agentId: selectedUnitId.toString(),
      commandType: 'MOVE_TO',
      payload: {
        'unitId': selectedUnitId,
        'x': p.x,
        'y': p.y,
      },
    ));
  }
}

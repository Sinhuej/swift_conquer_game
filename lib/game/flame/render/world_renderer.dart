import 'package:flame/components.dart';
import '../../core/world_state.dart';

class WorldRenderer extends Component {
  final WorldState world;

  WorldRenderer(this.world);

  @override
  void render(Canvas canvas) {
    // Phase 32 placeholder render
    // Later: tiles, units, fog, etc.
  }
}

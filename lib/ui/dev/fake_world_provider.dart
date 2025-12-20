import '../render_models/render_world.dart';
import '../render_models/render_unit.dart';

class FakeWorldProvider {
  static RenderWorld build() {
    final units = <RenderUnit>[];
    for (int i = 0; i < 10; i++) {
      units.add(RenderUnit(
        id: i + 1,
        x: 100 + i * 40,
        y: 200 + (i.isEven ? 0 : 40),
        teamId: i < 5 ? 1 : 2,
        alive: true,
      ));
    }
    return RenderWorld(units: units);
  }
}

import 'package:test/test.dart';
import 'package:swift_conquer_game/sim_ext/content/scenario.dart';
import 'package:swift_conquer_game/sim_ext/content/scenario_catalog.dart';

void main() {
  test('ScenarioCatalog returns stable ordering', () {
    final cat = ScenarioCatalog();
    cat.add(const Scenario(id: 'b', name: 'B', description: ''));
    cat.add(const Scenario(id: 'a', name: 'A', description: ''));

    final ids = cat.all.map((s) => s.id).toList();
    expect(ids, equals(['a', 'b']));
  });
}

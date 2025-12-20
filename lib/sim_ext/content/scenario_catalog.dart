import 'scenario.dart';

class ScenarioCatalog {
  final Map<String, Scenario> _scenarios = {};

  void add(Scenario s) {
    _scenarios[s.id] = s;
  }

  Scenario? get(String id) => _scenarios[id];

  List<Scenario> get all {
    final out = _scenarios.values.toList();
    out.sort((a, b) => a.id.compareTo(b.id));
    return out;
  }
}

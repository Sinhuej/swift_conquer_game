import '../core/engine.dart';
import '../map/sc_map.dart';

class EngineAPI {
  final SCEngine engine = SCEngine();
  final SCMap map = SCMap(20, 20);

  void init() {
    engine.initialize();
  }
}

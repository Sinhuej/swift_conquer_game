import '../core/world_state.dart';

class SaveGame {
  static Map<String, dynamic> serialize(WorldState world) {
    return {
      'entities': world.entityCount,
    };
  }
}

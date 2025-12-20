import '../ai/ai_types.dart';

/// Phase 128–130: observation template helpers.
/// Real observation building from WorldState happens in later phases.
class ObservationTemplate {
  static AiObservation minimal({
    required int enemiesNearby,
    required int resources,
    required bool underAttack,
  }) {
    return AiObservation({
      'enemiesNearby': enemiesNearby,
      'resources': resources,
      'underAttack': underAttack,
    });
  }
}

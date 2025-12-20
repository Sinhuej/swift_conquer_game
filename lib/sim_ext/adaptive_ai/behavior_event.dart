/// Phase 163: generic behavior events.
/// Engine code can emit these later without coupling.
enum BehaviorEventType {
  attackIssued,
  retreatIssued,
  expandStarted,
  techStarted,
  idleTick,
  moveIssued,
}

class BehaviorEvent {
  final int tick;
  final BehaviorEventType type;

  /// Optional numeric context (e.g., "unitsInvolved", "distance", etc.)
  final Map<String, num> metrics;

  const BehaviorEvent({
    required this.tick,
    required this.type,
    this.metrics = const {},
  });

  Map<String, Object?> toJson() => {
        'tick': tick,
        'type': type.name,
        'metrics': metrics,
      };
}

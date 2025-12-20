/// Phase 136–140: faction/strategy profile (data-only).
class FactionProfile {
  final String id;
  final String name;

  /// Strategy knobs (0..1) for content sweeps
  final double rushBias;
  final double turtleBias;
  final double techBias;

  const FactionProfile({
    required this.id,
    required this.name,
    required this.rushBias,
    required this.turtleBias,
    required this.techBias,
  });
}

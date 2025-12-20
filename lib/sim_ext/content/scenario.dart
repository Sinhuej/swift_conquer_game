/// Phase 131–135: headless scenario definition (data-only).
class Scenario {
  final String id;
  final String name;
  final String description;

  /// Optional tags for CI sweeps: "micro", "macro", "combat", etc.
  final List<String> tags;

  const Scenario({
    required this.id,
    required this.name,
    required this.description,
    this.tags = const [],
  });
}

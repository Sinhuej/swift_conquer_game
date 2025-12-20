/// Phase 141–145: balance preset (data-only).
class BalancePreset {
  final String id;
  final String name;
  final Map<String, num> tunables;

  const BalancePreset({
    required this.id,
    required this.name,
    required this.tunables,
  });
}

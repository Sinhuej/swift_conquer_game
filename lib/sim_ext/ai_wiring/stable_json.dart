/// Phase 122–123: stable JSON helpers (sorted keys).
/// Used to keep CI hashes stable across platforms.
class StableJson {
  static Map<String, Object?> sortObject(Map<String, Object?> input) {
    final keys = input.keys.toList()..sort();
    final out = <String, Object?>{};
    for (final k in keys) {
      final v = input[k];
      if (v is Map<String, Object?>) {
        out[k] = sortObject(v);
      } else if (v is List) {
        out[k] = sortList(v);
      } else {
        out[k] = v;
      }
    }
    return out;
  }

  static List<Object?> sortList(List input) {
    return input.map((e) {
      if (e is Map<String, Object?>) return sortObject(e);
      if (e is List) return sortList(e);
      return e;
    }).toList();
  }
}

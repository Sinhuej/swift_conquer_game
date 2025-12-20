import 'dart:convert';

class SimHasher {
  /// Returns a stable, deterministic 64-bit-ish hex string (FNV-1a style).
  static String stableHash(Object? value) {
    final normalized = _normalize(value);
    final bytes = utf8.encode(jsonEncode(normalized));
    final hash = _fnv1a64(bytes);
    return hash.toRadixString(16).padLeft(16, '0');
  }

  static Object? _normalize(Object? v) {
    if (v == null) return null;
    if (v is num || v is bool || v is String) return v;

    if (v is List) {
      return v.map(_normalize).toList(growable: false);
    }

    if (v is Map) {
      // sort keys for stable output
      final keys = v.keys.map((k) => k.toString()).toList()..sort();
      final out = <String, Object?>{};
      for (final k in keys) {
        out[k] = _normalize(v[k]);
      }
      return out;
    }

    // If a non-json-safe object sneaks in, stringify it (debug only).
    return v.toString();
  }

  static int _fnv1a64(List<int> bytes) {
    // 64-bit FNV-1a
    const int fnvOffsetBasis = 0xcbf29ce484222325;
    const int fnvPrime = 0x100000001b3;

    var hash = fnvOffsetBasis;
    for (final b in bytes) {
      hash ^= (b & 0xff);
      // simulate 64-bit overflow
      hash = (hash * fnvPrime) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash;
  }
}

import 'dart:convert';

class SimStateCodec {
  /// Encode a json-safe map to canonical JSON string (stable key ordering).
  static String encodeCanonical(Map<String, Object?> state) {
    final normalized = _normalize(state);
    return jsonEncode(normalized);
  }

  /// Decode canonical JSON to map.
  static Map<String, Object?> decode(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map) {
      throw FormatException('Expected JSON object at root');
    }
    return decoded.cast<String, Object?>();
  }

  static Object? _normalize(Object? v) {
    if (v == null) return null;
    if (v is num || v is bool || v is String) return v;

    if (v is List) {
      return v.map(_normalize).toList(growable: false);
    }

    if (v is Map) {
      final keys = v.keys.map((k) => k.toString()).toList()..sort();
      final out = <String, Object?>{};
      for (final k in keys) {
        out[k] = _normalize(v[k]);
      }
      return out;
    }

    // fail fast to keep it "pure data"
    throw ArgumentError('Non-json-safe value in state: ${v.runtimeType}');
  }
}

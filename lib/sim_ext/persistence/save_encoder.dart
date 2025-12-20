import 'dart:convert';
import 'save_blob.dart';

class SaveEncoder {
  static String encode(SaveBlob blob) {
    return jsonEncode(blob.toJson());
  }

  static SaveBlob decode(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, Object?>) {
      throw FormatException('Invalid save blob');
    }
    return SaveBlob(decoded);
  }
}

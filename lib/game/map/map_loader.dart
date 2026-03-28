import 'package:flutter/services.dart' show rootBundle;

import 'map_definition.dart';

class MapLoader {
  static Future<MapDefinition> loadAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return mapDefinitionFromJsonString(raw);
  }
}

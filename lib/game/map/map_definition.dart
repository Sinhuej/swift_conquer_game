import 'dart:convert';

class GridCell {
  final int col;
  final int row;

  const GridCell(this.col, this.row);

  @override
  bool operator ==(Object other) {
    return other is GridCell && other.col == col && other.row == row;
  }

  @override
  int get hashCode => Object.hash(col, row);

  @override
  String toString() => '($col,$row)';
}

class MapSpawnPoint {
  final double x;
  final double y;

  const MapSpawnPoint(this.x, this.y);

  factory MapSpawnPoint.fromJson(Map<String, Object?> json) {
    return MapSpawnPoint(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }
}

class MapResourcePoint {
  final double x;
  final double y;
  final String type;
  final int amount;

  const MapResourcePoint({
    required this.x,
    required this.y,
    required this.type,
    required this.amount,
  });

  factory MapResourcePoint.fromJson(Map<String, Object?> json) {
    return MapResourcePoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      type: (json['type'] as String?) ?? 'ore',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
    );
  }
}

class MapDefinition {
  final String id;
  final String name;
  final double worldWidth;
  final double worldHeight;
  final int cellSize;
  final List<MapSpawnPoint> spawns;
  final Set<GridCell> blocked;
  final List<MapResourcePoint> resources;

  const MapDefinition({
    required this.id,
    required this.name,
    required this.worldWidth,
    required this.worldHeight,
    required this.cellSize,
    required this.spawns,
    required this.blocked,
    required this.resources,
  });

  factory MapDefinition.fromJson(Map<String, Object?> json) {
    final blockedRaw = (json['blocked'] as List?) ?? const [];
    final spawnsRaw = (json['spawns'] as List?) ?? const [];
    final resourcesRaw = (json['resources'] as List?) ?? const [];

    return MapDefinition(
      id: (json['id'] as String?) ?? 'unknown_map',
      name: (json['name'] as String?) ?? 'Unknown Map',
      worldWidth: (json['worldWidth'] as num).toDouble(),
      worldHeight: (json['worldHeight'] as num).toDouble(),
      cellSize: (json['cellSize'] as num).toInt(),
      spawns: spawnsRaw
          .map((e) => MapSpawnPoint.fromJson((e as Map).cast<String, Object?>()))
          .toList(),
      blocked: blockedRaw
          .map((e) {
            final m = (e as Map).cast<String, Object?>();
            return GridCell(
              (m['col'] as num).toInt(),
              (m['row'] as num).toInt(),
            );
          })
          .toSet(),
      resources: resourcesRaw
          .map((e) => MapResourcePoint.fromJson((e as Map).cast<String, Object?>()))
          .toList(),
    );
  }
}

MapDefinition mapDefinitionFromJsonString(String raw) {
  return MapDefinition.fromJson(jsonDecode(raw) as Map<String, Object?>);
}

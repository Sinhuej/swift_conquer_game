class Tile {
  final int id;
  final int gridX;
  final int gridY;
  bool blocked;

  Tile({
    required this.id,
    required this.gridX,
    required this.gridY,
    this.blocked = false,
  });
}

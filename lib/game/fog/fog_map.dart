class FogMap {
  final Map<int, Set<int>> visibleTilesByTeam = {};

  bool isVisible(int teamId, int tileId) {
    return visibleTilesByTeam[teamId]?.contains(tileId) ?? false;
  }

  void reveal(int teamId, int tileId) {
    visibleTilesByTeam.putIfAbsent(teamId, () => {}).add(tileId);
  }

  void clearTeam(int teamId) {
    visibleTilesByTeam[teamId]?.clear();
  }
}

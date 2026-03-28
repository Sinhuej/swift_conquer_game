enum BuildingType {
  mobileHqCenter,
  hq,
  powerPlant,
  barracks,
  refinery,
}

extension BuildingTypeX on BuildingType {
  String get label {
    switch (this) {
      case BuildingType.mobileHqCenter:
        return 'Mobile HQ Center';
      case BuildingType.hq:
        return 'HQ';
      case BuildingType.powerPlant:
        return 'Power Plant';
      case BuildingType.barracks:
        return 'Barracks';
      case BuildingType.refinery:
        return 'Refinery';
    }
  }

  bool get projectsBuildRadius => this != BuildingType.mobileHqCenter;

  bool get isBuildMenuType {
    return this == BuildingType.powerPlant ||
        this == BuildingType.barracks ||
        this == BuildingType.refinery;
  }
}

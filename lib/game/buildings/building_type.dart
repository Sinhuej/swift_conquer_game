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

  bool get projectsBuildRadius {
    switch (this) {
      case BuildingType.mobileHqCenter:
        return false;
      case BuildingType.hq:
      case BuildingType.powerPlant:
      case BuildingType.barracks:
      case BuildingType.refinery:
        return true;
    }
  }

  bool get isBuildMenuType {
    switch (this) {
      case BuildingType.powerPlant:
      case BuildingType.barracks:
      case BuildingType.refinery:
        return true;
      case BuildingType.mobileHqCenter:
      case BuildingType.hq:
        return false;
    }
  }
}

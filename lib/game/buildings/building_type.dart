enum BuildingType {
  mobileHqCenter,
  hq,
  powerPlant,
  barracks,
  refinery,
  warFactory,
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
      case BuildingType.warFactory:
        return 'War Factory';
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
      case BuildingType.warFactory:
        return true;
    }
  }

  bool get isBuildMenuType {
    switch (this) {
      case BuildingType.powerPlant:
      case BuildingType.barracks:
      case BuildingType.refinery:
      case BuildingType.warFactory:
        return true;
      case BuildingType.mobileHqCenter:
      case BuildingType.hq:
        return false;
    }
  }
}

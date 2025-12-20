import 'faction_profile.dart';

class ProfileSet {
  final Map<String, FactionProfile> _profiles = {};

  void add(FactionProfile p) => _profiles[p.id] = p;

  FactionProfile? get(String id) => _profiles[id];

  List<FactionProfile> get all {
    final out = _profiles.values.toList();
    out.sort((a, b) => a.id.compareTo(b.id));
    return out;
  }
}

import 'balance_preset.dart';

class BalanceCatalog {
  final Map<String, BalancePreset> _presets = {};

  void add(BalancePreset p) => _presets[p.id] = p;

  BalancePreset? get(String id) => _presets[id];

  List<BalancePreset> get all {
    final out = _presets.values.toList();
    out.sort((a, b) => a.id.compareTo(b.id));
    return out;
  }
}

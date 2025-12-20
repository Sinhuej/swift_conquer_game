class SnapshotDiff {
  static Map<String, Object?> diff(
    Map<String, Object?> a,
    Map<String, Object?> b,
  ) {
    final out = <String, Object?>{};
    for (final k in {...a.keys, ...b.keys}) {
      if (a[k] != b[k]) {
        out[k] = {'a': a[k], 'b': b[k]};
      }
    }
    return out;
  }
}

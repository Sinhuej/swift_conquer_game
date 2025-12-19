class EntityId {
  final int value;
  const EntityId(this.value);

  @override
  String toString() => value.toString();

  @override
  bool operator ==(Object other) => other is EntityId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

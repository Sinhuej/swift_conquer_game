class ResourceNode {
  int amount;
  final int type; // 0 = gold, 1 = energy, etc.

  ResourceNode({required this.amount, required this.type});
}

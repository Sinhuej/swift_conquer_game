class SaveBlob {
  final Map<String, Object?> state;

  SaveBlob(this.state);

  Map<String, Object?> toJson() => state;
}

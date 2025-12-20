class DeterminismReport {
  final bool success;
  final String message;

  const DeterminismReport({
    required this.success,
    required this.message,
  });

  static DeterminismReport ok() =>
      const DeterminismReport(success: true, message: 'Determinism OK');

  static DeterminismReport fail(String reason) =>
      DeterminismReport(success: false, message: reason);
}

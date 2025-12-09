class BloodPressureRecord {
  final String id;
  final DateTime date;
  final int systolic;
  final int diastolic;
  final int pulse;
  final String? notes;

  BloodPressureRecord({
    required this.id,
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    this.notes,
  });
}

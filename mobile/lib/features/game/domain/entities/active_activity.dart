enum ActivityType { earning, training, sport, work, jobApplication }

class ActiveActivity {
  const ActiveActivity({
    required this.type,
    required this.sourceId,
    required this.remainingHours,
    required this.totalHours,
    required this.energyCost,
    required this.startedDay,
    required this.startedHour,
    this.payload = const <String, String>{},
  });

  final ActivityType type;
  final String sourceId;
  final int remainingHours;
  final int totalHours;
  final int energyCost;
  final int startedDay;
  final int startedHour;
  final Map<String, String> payload;

  ActiveActivity copyWith({
    ActivityType? type,
    String? sourceId,
    int? remainingHours,
    int? totalHours,
    int? energyCost,
    int? startedDay,
    int? startedHour,
    Map<String, String>? payload,
  }) {
    return ActiveActivity(
      type: type ?? this.type,
      sourceId: sourceId ?? this.sourceId,
      remainingHours: remainingHours ?? this.remainingHours,
      totalHours: totalHours ?? this.totalHours,
      energyCost: energyCost ?? this.energyCost,
      startedDay: startedDay ?? this.startedDay,
      startedHour: startedHour ?? this.startedHour,
      payload: payload ?? this.payload,
    );
  }

  double get progress =>
      ((totalHours - remainingHours) / totalHours).clamp(0, 1).toDouble();
}

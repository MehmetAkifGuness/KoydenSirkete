import 'dart:convert';

import '../../domain/entities/active_activity.dart';

class ActiveActivityCodec {
  String? encode(ActiveActivity? activity) {
    if (activity == null) {
      return null;
    }
    return jsonEncode({
      'type': activity.type.name,
      'source_id': activity.sourceId,
      'remaining_hours': activity.remainingHours,
      'total_hours': activity.totalHours,
      'energy_cost': activity.energyCost,
      'started_day': activity.startedDay,
      'started_hour': activity.startedHour,
      'payload': activity.payload,
    });
  }

  ActiveActivity? decode(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      final type = ActivityType.values.byName(json['type'] as String);
      final payload = (json['payload'] as Map<String, dynamic>? ?? const {}).map(
        (key, item) => MapEntry(key, item.toString()),
      );
      return ActiveActivity(
        type: type,
        sourceId: json['source_id'] as String,
        remainingHours: json['remaining_hours'] as int,
        totalHours: json['total_hours'] as int,
        energyCost: json['energy_cost'] as int,
        startedDay: json['started_day'] as int,
        startedHour: json['started_hour'] as int,
        payload: payload,
      );
    } on Object {
      return null;
    }
  }
}

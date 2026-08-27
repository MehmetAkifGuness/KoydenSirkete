import 'dart:convert';

import '../../domain/entities/active_activity.dart';

class ActiveActivityCodec {
  String? encode(ActiveActivity? activity) {
    if (activity == null) {
      return null;
    }
    return jsonEncode(_toJson(activity));
  }

  String? encodeList(List<ActiveActivity> activities) {
    if (activities.isEmpty) {
      return null;
    }
    return jsonEncode(activities.map(_toJson).toList());
  }

  List<ActiveActivity> decodeList(String? value, {String? legacyValue}) {
    if (value != null && value.isNotEmpty) {
      try {
        final json = jsonDecode(value) as List<dynamic>;
        return List<ActiveActivity>.unmodifiable(
          json.map((item) => _fromJson(item as Map<String, dynamic>)),
        );
      } on Object {
        return _decodeLegacy(legacyValue);
      }
    }
    return _decodeLegacy(legacyValue);
  }

  List<ActiveActivity> _decodeLegacy(String? value) {
    final legacy = decode(value);
    return legacy == null ? const <ActiveActivity>[] : <ActiveActivity>[legacy];
  }

  Map<String, dynamic> _toJson(ActiveActivity activity) => {
    'type': activity.type.name,
    'source_id': activity.sourceId,
    'remaining_hours': activity.remainingHours,
    'total_hours': activity.totalHours,
    'energy_cost': activity.energyCost,
    'started_day': activity.startedDay,
    'started_hour': activity.startedHour,
    'payload': activity.payload,
  };

  ActiveActivity? decode(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      return _fromJson(jsonDecode(value) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  ActiveActivity _fromJson(Map<String, dynamic> json) {
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
  }
}

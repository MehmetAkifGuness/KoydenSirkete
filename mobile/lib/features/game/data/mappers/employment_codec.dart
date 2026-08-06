import 'dart:convert';

import '../../../employment/domain/entities/employment.dart';

class EmploymentCodec {
  String? encode(Employment? employment) {
    if (employment == null) return null;
    return jsonEncode({
      'job_id': employment.jobId,
      'city_id': employment.cityId,
      'salary': employment.salary,
      'company': employment.company,
      'started_day': employment.startedDay,
      'last_task_day': employment.lastTaskDay,
    });
  }

  Employment? decode(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return Employment(
        jobId: json['job_id'] as int,
        cityId: json['city_id'] as int,
        salary: json['salary'] as int,
        company: json['company'] as String,
        startedDay: json['started_day'] as int,
        lastTaskDay: json['last_task_day'] as int? ?? 0,
      );
    } on Object {
      return null;
    }
  }
}

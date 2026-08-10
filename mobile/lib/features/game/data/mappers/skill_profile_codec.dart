import 'dart:convert';

import '../../../skills/domain/entities/skill_id.dart';
import '../../../skills/domain/entities/skill_profile.dart';

class SkillProfileCodec {
  String encode(SkillProfile profile) {
    return jsonEncode({for (final skill in SkillId.values) skill.name: profile[skill]});
  }

  SkillProfile decode(String? value, {int scale = 1}) {
    if (value == null || value.isEmpty) {
      return SkillProfile.empty;
    }
    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return SkillProfile({
        for (final skill in SkillId.values)
            skill: ((json[skill.name] as num?)?.toInt() ?? 0) * scale,
      });
    } on Object {
      return SkillProfile.empty;
    }
  }
}

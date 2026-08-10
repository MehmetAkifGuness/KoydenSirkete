import 'skill_id.dart';

class SkillProfile {
  const SkillProfile([this._values = const {}]);

  static const maxValue = 1000;

  final Map<SkillId, int> _values;

  static const empty = SkillProfile();

  int operator [](SkillId skill) => _clamp(_values[skill] ?? 0);

  Map<SkillId, int> get values => Map.unmodifiable(_values);

  SkillProfile add(Map<SkillId, int> deltas) {
    return SkillProfile({
      for (final skill in SkillId.values) skill: this[skill] + (deltas[skill] ?? 0),
    });
  }

  int weightedScore() => _values.values.fold(0, (total, value) => total + value);

  static int _clamp(int value) => value.clamp(0, maxValue);
}

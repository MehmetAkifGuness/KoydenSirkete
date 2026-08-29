class PersonalEvent {
  const PersonalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
  });

  final int id;
  final String title;
  final String description;
  final List<PersonalEventChoice> choices;
}

class PersonalEventChoice {
  const PersonalEventChoice({
    required this.id,
    required this.title,
    required this.outcome,
    this.moneyDelta = 0,
    this.energyDelta = 0,
    this.knowledgeDelta = 0,
    this.experienceDelta = 0,
  });

  final String id;
  final String title;
  final String outcome;
  final int moneyDelta;
  final int energyDelta;
  final int knowledgeDelta;
  final int experienceDelta;

  String get effects => [
    if (moneyDelta != 0) 'Para ${_signed(moneyDelta, prefix: '₺')}',
    if (energyDelta != 0) 'Enerji ${_signed(energyDelta)}',
    if (knowledgeDelta != 0) 'Bilgi ${_signed(knowledgeDelta)}',
    if (experienceDelta != 0) 'Tecrübe ${_signed(experienceDelta)}',
  ].join(' · ');

  static String _signed(int value, {String prefix = ''}) =>
      value > 0 ? '+$prefix$value' : '-$prefix${value.abs()}';
}

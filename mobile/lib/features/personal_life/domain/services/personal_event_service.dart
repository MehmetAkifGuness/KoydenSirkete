import '../../../../core/errors/game_rule_exception.dart';
import '../../../finance/domain/entities/finance_ledger.dart';
import '../../../game/domain/entities/player_state.dart';
import '../entities/personal_event.dart';

class PersonalEventService {
  const PersonalEventService();

  static const firstEventDay = 4;

  static const events = <PersonalEvent>[
    PersonalEvent(
      id: 0,
      title: 'Telefon arızası',
      description:
          'Telefonun beklenmedik şekilde arızalandı. Günlük planını nasıl koruyacaksın?',
      choices: [
        PersonalEventChoice(
          id: 'repair',
          title: 'Hemen tamir ettir',
          outcome: 'İşlerini aksatmadan devam ettin.',
          moneyDelta: -80,
          experienceDelta: 2,
        ),
        PersonalEventChoice(
          id: 'manage_offline',
          title: 'Bir süre idare et',
          outcome: 'Masraftan kaçındın ama işleri takip etmek yorucuydu.',
          energyDelta: -10,
          knowledgeDelta: 2,
        ),
      ],
    ),
    PersonalEvent(
      id: 1,
      title: 'Eski bir dosttan davet',
      description: 'Uzun süredir görmediğin bir dostun bugün buluşmak istiyor.',
      choices: [
        PersonalEventChoice(
          id: 'join',
          title: 'Davete katıl',
          outcome: 'Keyifli sohbet sana iyi geldi.',
          moneyDelta: -35,
          energyDelta: 15,
        ),
        PersonalEventChoice(
          id: 'stay_focused',
          title: 'Planına sadık kal',
          outcome: 'Günü kişisel gelişime ayırdın.',
          energyDelta: -5,
          knowledgeDelta: 4,
        ),
      ],
    ),
    PersonalEvent(
      id: 2,
      title: 'Kısa eğitim fırsatı',
      description: 'Mahallendeki atölyede bugün için son bir kontenjan açıldı.',
      choices: [
        PersonalEventChoice(
          id: 'enroll',
          title: 'Kontenjanı al',
          outcome: 'Yeni yöntemler öğrenip uygulama fırsatı buldun.',
          moneyDelta: -50,
          knowledgeDelta: 7,
          experienceDelta: 2,
        ),
        PersonalEventChoice(
          id: 'self_study',
          title: 'Evde çalış',
          outcome: 'Ücretsiz kaynaklarla daha sakin ilerledin.',
          energyDelta: -5,
          knowledgeDelta: 3,
        ),
      ],
    ),
    PersonalEvent(
      id: 3,
      title: 'Komşuya yardım',
      description:
          'Komşunun acil bir işi çıktı ve birkaç saatlik desteğe ihtiyacı var.',
      choices: [
        PersonalEventChoice(
          id: 'help',
          title: 'Yardım et',
          outcome:
              'Emeğinin karşılığını aldın ve faydalı bir deneyim kazandın.',
          moneyDelta: 30,
          energyDelta: -12,
          experienceDelta: 3,
        ),
        PersonalEventChoice(
          id: 'rest',
          title: 'Nazikçe reddet',
          outcome: 'Kendi ihtiyaçlarına zaman ayırıp dinlendin.',
          energyDelta: 8,
        ),
      ],
    ),
  ];

  PersonalEvent? currentEvent(PlayerState state) {
    final id = state.pendingPersonalEventId;
    if (id == null) return null;
    return events.where((event) => event.id == id).firstOrNull;
  }

  PlayerState schedule(PlayerState state) {
    if (state.pendingPersonalEventId != null) return state;
    final dueDay = state.lastPersonalEventDay == 0
        ? firstEventDay
        : state.lastPersonalEventDay + 6 + state.lastPersonalEventDay % 4;
    if (state.day < dueDay) return state;
    final event =
        events[(state.day * 17 + state.currentCityId) % events.length];
    return state.copyWith(
      pendingPersonalEventId: event.id,
      lastPersonalEventDay: state.day,
    );
  }

  PlayerState resolve(PlayerState state, PersonalEventChoice choice) {
    final event = currentEvent(state);
    if (event == null || !event.choices.any((item) => item.id == choice.id)) {
      throw const GameRuleException('Bu kişisel olay artık aktif değil.');
    }
    if (state.money + choice.moneyDelta < 0) {
      throw const GameRuleException(
        'Bu seçim için kişisel cüzdanında yeterli para yok.',
      );
    }
    final ledger = state.financeLedger.record(
      day: state.day,
      category: FinanceCategory.personalEvent,
      amount: choice.moneyDelta,
    );
    return state.copyWith(
      pendingPersonalEventId: null,
      money: state.money + choice.moneyDelta,
      energy: (state.energy + choice.energyDelta).clamp(0, state.maxEnergy),
      knowledge: (state.knowledge + choice.knowledgeDelta).clamp(0, 1 << 31),
      experience: (state.experience + choice.experienceDelta).clamp(0, 1 << 31),
      financeLedger: ledger,
    );
  }
}

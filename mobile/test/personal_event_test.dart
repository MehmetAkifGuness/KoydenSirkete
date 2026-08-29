import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/core/errors/game_rule_exception.dart';
import 'package:kariyerden_sirkete/features/finance/domain/entities/finance_ledger.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/personal_life/domain/services/personal_event_service.dart';

void main() {
  const service = PersonalEventService();

  test('events appear at fair deterministic intervals with two choices', () {
    final early = service.schedule(PlayerState.initial.copyWith(day: 3));
    final offered = service.schedule(PlayerState.initial.copyWith(day: 4));

    expect(early.pendingPersonalEventId, isNull);
    expect(service.currentEvent(offered), isNotNull);
    expect(service.currentEvent(offered)!.choices, hasLength(2));
    expect(
      service.currentEvent(offered)!.choices.every((c) => c.effects.isNotEmpty),
      isTrue,
    );

    final unchanged = service.schedule(offered.copyWith(day: 30));
    expect(unchanged.pendingPersonalEventId, offered.pendingPersonalEventId);
    expect(unchanged.lastPersonalEventDay, 4);
  });

  test('a choice applies only to personal state and is recorded once', () {
    final offered = PlayerState.initial.copyWith(
      day: 4,
      money: 200,
      companyFunds: 500,
      pendingPersonalEventId: 0,
      lastPersonalEventDay: 4,
    );
    final choice = PersonalEventService.events.first.choices.first;
    final resolved = service.resolve(offered, choice);

    expect(resolved.money, 120);
    expect(resolved.companyFunds, 500);
    expect(resolved.experience, 2);
    expect(resolved.pendingPersonalEventId, isNull);
    expect(
      resolved.financeLedger.entries.single.category,
      FinanceCategory.personalEvent,
    );
    expect(
      () => service.resolve(resolved, choice),
      throwsA(isA<GameRuleException>()),
    );
  });

  test('unaffordable choice is rejected while free alternative remains', () {
    final state = PlayerState.initial.copyWith(
      money: 0,
      pendingPersonalEventId: 0,
    );
    final event = service.currentEvent(state)!;

    expect(
      () => service.resolve(state, event.choices.first),
      throwsA(isA<GameRuleException>()),
    );
    expect(() => service.resolve(state, event.choices.last), returnsNormally);
  });
}

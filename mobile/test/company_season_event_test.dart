import 'package:flutter_test/flutter_test.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_competition_state.dart';
import 'package:kariyerden_sirkete/features/company/domain/entities/company_market_event.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_market_event_catalog.dart';
import 'package:kariyerden_sirkete/features/company/domain/services/company_season_event_service.dart';

void main() {
  const service = CompanySeasonEventService();

  test('event pool contains four balanced categories with bounded effects', () {
    final events = CompanyMarketEventCatalog.events;

    expect(events, hasLength(16));
    expect(events.map((event) => event.id).toSet(), hasLength(events.length));
    for (final category in CompanyMarketEventCategory.values) {
      expect(events.where((event) => event.category == category), hasLength(4));
    }
    for (final event in events) {
      expect(event.revenuePercent, inInclusiveRange(-12, 15));
      expect(event.payrollPercent, inInclusiveRange(-4, 10));
      expect(event.description, isNotEmpty);
    }
  });

  test('season schedules are deterministic, unique and category-balanced', () {
    final observed = <String>{};
    String? previousId;

    for (var season = 1; season <= 64; season++) {
      final first = service.scheduleForSeason(season);
      final second = service.scheduleForSeason(season);
      final ids = first.map((event) => event.id).toList(growable: false);

      expect(second.map((event) => event.id), ids);
      expect(first, hasLength(CompanySeasonEventService.eventsPerSeason));
      expect(ids.toSet(), hasLength(first.length));
      expect(
        first.map((event) => event.category).toSet(),
        containsAll(CompanyMarketEventCategory.values),
      );
      for (final event in first) {
        expect(event.id, isNot(previousId));
        previousId = event.id;
        observed.add(event.id);
      }
    }

    expect(observed, hasLength(CompanyMarketEventCatalog.events.length));
  });

  test('five event slots cover each season without gaps or overflow', () {
    for (var season = 1; season <= 12; season++) {
      final slots = service.slotsForSeason(season);
      expect(slots.first.startDay, CompanyCompetitionState.startDay(season));
      expect(slots.last.endDay, CompanyCompetitionState.endDay(season));

      for (var index = 0; index < slots.length; index++) {
        final slot = slots[index];
        if (index > 0) {
          expect(slot.startDay, slots[index - 1].endDay + 1);
        }
        for (var day = slot.startDay; day <= slot.endDay; day++) {
          expect(service.eventForDay(day).id, slot.event.id);
        }
        expect(service.daysRemainingForDay(slot.endDay), 1);
      }
    }
  });
}

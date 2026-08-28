import '../entities/company_competition_state.dart';
import '../entities/company_market_event.dart';
import 'company_market_event_catalog.dart';

class CompanySeasonEventService {
  const CompanySeasonEventService();

  static const eventDurationDays = 7;
  static const eventsPerSeason = 5;
  static final _pools = {
    for (final category in CompanyMarketEventCategory.values)
      category: CompanyMarketEventCatalog.events
          .where((event) => event.category == category)
          .toList(growable: false),
  };

  List<CompanyMarketEvent> scheduleForSeason(int seasonNumber) {
    final season = seasonNumber.clamp(1, 1 << 31).toInt();
    final schedule = _rawSchedule(season);
    if (season > 1) {
      final previousLast = _rawSchedule(season - 1).last;
      if (schedule.first.id == previousLast.id) {
        final first = schedule.first;
        schedule[0] = schedule[1];
        schedule[1] = first;
      }
    }
    return List<CompanyMarketEvent>.unmodifiable(schedule);
  }

  List<CompanySeasonEventSlot> slotsForSeason(int seasonNumber) {
    final season = seasonNumber.clamp(1, 1 << 31).toInt();
    final seasonStart = CompanyCompetitionState.startDay(season);
    final seasonEnd = CompanyCompetitionState.endDay(season);
    final schedule = scheduleForSeason(season);
    return List<CompanySeasonEventSlot>.unmodifiable([
      for (var index = 0; index < schedule.length; index++)
        CompanySeasonEventSlot(
          index: index,
          startDay: seasonStart + index * eventDurationDays,
          endDay: (seasonStart + (index + 1) * eventDurationDays - 1).clamp(
            seasonStart,
            seasonEnd,
          ),
          event: schedule[index],
        ),
    ]);
  }

  CompanyMarketEvent eventForDay(int day) {
    final safeDay = day.clamp(1, 1 << 31).toInt();
    final season = CompanyCompetitionState.seasonForDay(safeDay);
    final start = CompanyCompetitionState.startDay(season);
    final offset = (safeDay - start).clamp(
      0,
      CompanyCompetitionState.seasonDurationDays - 1,
    );
    final index = (offset ~/ eventDurationDays).clamp(0, eventsPerSeason - 1);
    return scheduleForSeason(season)[index];
  }

  int daysRemainingForDay(int day) {
    final safeDay = day.clamp(1, 1 << 31).toInt();
    final season = CompanyCompetitionState.seasonForDay(safeDay);
    final start = CompanyCompetitionState.startDay(season);
    if (safeDay < start) return start - safeDay;
    final end = CompanyCompetitionState.endDay(season);
    final offset = safeDay - start;
    final periodRemaining = eventDurationDays - offset % eventDurationDays;
    final seasonRemaining = end - safeDay + 1;
    return periodRemaining < seasonRemaining
        ? periodRemaining
        : seasonRemaining;
  }

  List<CompanyMarketEvent> _rawSchedule(int season) {
    final selected = <CompanyMarketEvent>[
      _pick(CompanyMarketEventCategory.stable, (season - 1) * 11),
      _pick(CompanyMarketEventCategory.opportunity, (season - 1) * 3),
      _pick(CompanyMarketEventCategory.threat, (season - 1) * 5),
      _pick(CompanyMarketEventCategory.workforce, (season - 1) * 7),
    ];
    final selectedIds = selected.map((event) => event.id).toSet();
    final remaining = CompanyMarketEventCatalog.events
        .where((event) => !selectedIds.contains(event.id))
        .toList(growable: false);
    selected.add(remaining[(season * 13 + 5) % remaining.length]);
    final offset = ((season - 1) * 2) % eventsPerSeason;
    return [
      for (var index = 0; index < eventsPerSeason; index++)
        selected[(offset + index * 2) % eventsPerSeason],
    ];
  }

  CompanyMarketEvent _pick(CompanyMarketEventCategory category, int seed) {
    final pool = _pools[category]!;
    return pool[seed % pool.length];
  }
}

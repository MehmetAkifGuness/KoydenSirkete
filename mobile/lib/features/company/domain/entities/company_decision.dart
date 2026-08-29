import 'company_market_event.dart';

class CompanyDecisionChoice {
  const CompanyDecisionChoice({
    required this.id,
    required this.title,
    required this.description,
    required this.costPerLevel,
    required this.projectProgress,
    required this.reputation,
    required this.morale,
    required this.burnout,
  });

  final String id;
  final String title;
  final String description;
  final int costPerLevel;
  final int projectProgress;
  final int reputation;
  final int morale;
  final int burnout;
}

class CompanyDecision {
  const CompanyDecision({
    required this.key,
    required this.title,
    required this.description,
    required this.event,
    required this.choices,
  });

  final String key;
  final String title;
  final String description;
  final CompanyMarketEvent event;
  final List<CompanyDecisionChoice> choices;
}

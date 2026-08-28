import 'company_specialty.dart';

enum CompanyMarketEventCategory {
  opportunity('Fırsat'),
  threat('Tehdit'),
  workforce('İş gücü'),
  stable('Dengeli');

  const CompanyMarketEventCategory(this.label);

  final String label;
}

class CompanyMarketEvent {
  const CompanyMarketEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.specialty,
    required this.revenuePercent,
    required this.payrollPercent,
  });

  final String id;
  final String title;
  final String description;
  final CompanyMarketEventCategory category;
  final CompanySpecialty specialty;
  final int revenuePercent;
  final int payrollPercent;
}

class CompanySeasonEventSlot {
  const CompanySeasonEventSlot({
    required this.index,
    required this.startDay,
    required this.endDay,
    required this.event,
  });

  final int index;
  final int startDay;
  final int endDay;
  final CompanyMarketEvent event;

  bool contains(int day) => day >= startDay && day <= endDay;
}

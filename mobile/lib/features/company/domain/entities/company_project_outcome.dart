enum CompanyProjectQuality {
  rejected('Reddedildi', 0),
  low('Düşük', 85),
  standard('Standart', 100),
  high('Yüksek', 110),
  excellent('Mükemmel', 125);

  const CompanyProjectQuality(this.label, this.rewardPercent);

  final String label;
  final int rewardPercent;
}

class CompanyProjectOutcome {
  const CompanyProjectOutcome({
    required this.projectId,
    required this.completedDay,
    required this.elapsedDays,
    required this.delayed,
    required this.succeeded,
    required this.quality,
    required this.netIncome,
  });

  final int projectId;
  final int completedDay;
  final int elapsedDays;
  final bool delayed;
  final bool succeeded;
  final CompanyProjectQuality quality;
  final int netIncome;
}

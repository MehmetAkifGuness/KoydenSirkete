import 'company_competitor.dart';

class CompanyRivalProgress {
  const CompanyRivalProgress({
    required this.competitor,
    required this.seasonNumber,
    required this.elapsedDays,
    required this.startingBranchCount,
    required this.branchCount,
    required this.startingEmployeeCount,
    required this.employeeCount,
    required this.startingCompanyFunds,
    required this.companyFunds,
    required this.startingCompletedProjects,
    required this.completedProjects,
    required this.projectProgress,
  });

  final CompanyCompetitor competitor;
  final int seasonNumber;
  final int elapsedDays;
  final int startingBranchCount;
  final int branchCount;
  final int startingEmployeeCount;
  final int employeeCount;
  final int startingCompanyFunds;
  final int companyFunds;
  final int startingCompletedProjects;
  final int completedProjects;
  final int projectProgress;

  int get branchGrowth => branchCount - startingBranchCount;
  int get employeeGrowth => employeeCount - startingEmployeeCount;
  int get fundsGrowth => companyFunds - startingCompanyFunds;
  int get completedProjectGrowth =>
      completedProjects - startingCompletedProjects;

  int get competitiveStrengthBonus =>
      (branchGrowth * 2 +
              employeeGrowth ~/ 3 +
              completedProjectGrowth * 2 +
              (fundsGrowth > 0 ? fundsGrowth ~/ 5000 : 0))
          .clamp(0, 12)
          .toInt();
}

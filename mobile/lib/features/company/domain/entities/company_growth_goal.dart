import '../../../game/domain/entities/player_state.dart';

class CompanyGrowthGoal {
  const CompanyGrowthGoal({
    required this.title,
    required this.description,
    required this.target,
    required this.measure,
  });

  final String title;
  final String description;
  final int target;
  final int Function(PlayerState state) measure;

  int progress(PlayerState state) => measure(state).clamp(0, target);
  bool isCompleted(PlayerState state) => progress(state) >= target;
  double ratio(PlayerState state) => progress(state) / target;
}

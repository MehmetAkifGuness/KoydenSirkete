import 'package:flutter/material.dart';

import '../../../../core/constants/app_features.dart';
import '../../../../core/widgets/feature_card.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../../daily_goals/domain/entities/daily_goal.dart';
import '../models/dashboard_models.dart';
import '../state/dashboard_view_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({required this.session, required this.onFeatureTap, super.key});

  final GameSessionController session;
  final ValueChanged<AppFeature> onFeatureTap;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardViewModel _viewModel = DashboardViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_viewModel, widget.session]),
      builder: (context, _) {
        final state = DashboardDesignState.fromPlayer(widget.session.state);
        return SafeArea(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            _Header(state: state),
            const SizedBox(height: 24),
            _GoalCard(status: widget.session.dailyGoalStatus, session: widget.session),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Bugünkü durum'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.metrics.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 116, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemBuilder: (_, index) {
                final metric = state.metrics[index];
                return MetricTile(label: metric.label, value: metric.value, icon: metric.icon, color: metric.color);
              },
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: 'İlk adımlar'),
            const SizedBox(height: 12),
            _ActionRow(viewModel: _viewModel, session: widget.session),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Keşfet'),
            const SizedBox(height: 12),
            for (final feature in const [AppFeatures.earning, AppFeatures.training, AppFeatures.jobs, AppFeatures.cities])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FeatureCard(feature: feature, onTap: () => widget.onFeatureTap(feature)),
              ),
          ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final DashboardDesignState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(state.greeting, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Kariyerden Şirkete', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          ]),
        ),
        const CircleAvatar(radius: 22, child: Icon(Icons.person_outline)),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.status, required this.session});

  final DailyGoalStatus status;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      color: color.withValues(alpha: .15),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.flag_outlined, color: color),
            const SizedBox(width: 14),
            const Expanded(child: Text('Günlük hedef', style: TextStyle(color: Colors.white60, fontSize: 12))),
            Text('₺${status.reward}', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 8),
          Text(status.isClaimed ? 'Bugünün ödülü alındı.' : '${status.progress}/${status.target} üretken aksiyon tamamlandı.', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: status.ratio),
          if (status.isComplete && !status.isClaimed) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: session.isBusy ? null : () => _claim(context),
                child: const Text('Ödülü al'),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Future<void> _claim(BuildContext context) async {
    final message = await session.claimDailyGoal();
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.viewModel, required this.session});

  final DashboardViewModel viewModel;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final selected = viewModel.selectedAction;
    return Row(
      children: [
        _ActionButton(label: 'Dinlen', icon: Icons.bedtime_outlined, selected: selected == 'Dinlen', onTap: () => _rest(context)),
        const SizedBox(width: 10),
        _ActionButton(label: 'Planla', icon: Icons.calendar_today_outlined, selected: selected == 'Planla', onTap: () => viewModel.selectAction('Planla')),
      ],
    );
  }

  Future<void> _rest(BuildContext context) async {
    viewModel.selectAction('Dinlen');
    final message = await session.rest();
    if (!context.mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FilledButton.tonalIcon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(selected ? '$label ✓' : label),
      ),
    );
  }
}

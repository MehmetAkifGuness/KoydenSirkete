import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/services/company_employee_wellbeing_service.dart';
import '../../domain/services/company_market_service.dart';

class CompanyMarketPanel extends StatelessWidget {
  const CompanyMarketPanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final forecast = CompanyMarketService().forecast(state);
    final wellbeing = CompanyEmployeeWellbeingService().summary(state);
    final won = forecast.won;
    final accent = won ? AppPalette.success : AppPalette.warning;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Piyasa ve rekabet',
          caption: '7 günlük koşul ve 30 günlük sezon kuralı birlikte işler.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      forecast.event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AppPill(label: '${forecast.daysRemaining} gün kaldı'),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                forecast.event.description,
                style: const TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppPill(
                    label: forecast.event.category.label,
                    icon: Icons.event_repeat_rounded,
                    color: AppPalette.secondary,
                  ),
                  AppPill(
                    label: _percentLabel(
                      'Toplam gelir',
                      forecast.totalRevenuePercent,
                    ),
                  ),
                  AppPill(
                    label: _percentLabel(
                      'Toplam maaş',
                      forecast.totalPayrollPercent,
                    ),
                  ),
                  AppPill(
                    label: 'Sezon · ${forecast.seasonRule.title}',
                    color: AppPalette.secondary,
                    icon: Icons.calendar_month_outlined,
                  ),
                  AppPill(
                    label:
                        'Şirket kasası ${_signedCurrency(forecast.fundsDelta)}',
                    color: forecast.fundsDelta >= 0
                        ? AppPalette.success
                        : AppPalette.warning,
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                '${forecast.competitor.name} · '
                '${won ? 'Avantaj sende' : 'Rakip önde'}',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${forecast.competitor.leaderName} · '
                '${forecast.competitor.personality}',
                style: const TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppPill(
                    label: '${forecast.competitor.specialty.label} uzmanı',
                    icon: Icons.psychology_alt_outlined,
                  ),
                  AppPill(
                    label:
                        'Profil ${_signedScore(forecast.competitorProfileModifier)} güç',
                    color: _profileColor(forecast.competitorProfileModifier),
                    icon: forecast.competitorProfileModifier > 0
                        ? Icons.trending_up_rounded
                        : forecast.competitorProfileModifier < 0
                        ? Icons.trending_down_rounded
                        : Icons.horizontal_rule_rounded,
                  ),
                  AppPill(
                    label:
                        'Sezon: Sen ${_signedScore(forecast.playerSeasonRuleModifier)} · '
                        'Rakip ${_signedScore(forecast.competitorSeasonRuleModifier)}',
                    color: AppPalette.secondary,
                    icon: Icons.balance_rounded,
                  ),
                  AppPill(
                    label: forecast.strategy.isSelected
                        ? '${forecast.strategy.title} +${forecast.strategyStrengthModifier}'
                        : 'Strateji seçilmedi',
                    color: forecast.strategy.isSelected
                        ? AppPalette.tertiary
                        : AppPalette.warning,
                    icon: Icons.flag_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                forecast.competitorProfileReason,
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 10,
                ),
              ),
              if (forecast.strategy.isSelected) ...[
                const SizedBox(height: 4),
                Text(
                  forecast.strategyReason,
                  style: const TextStyle(
                    color: AppPalette.tertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              AppProgressLine(
                value: forecast.playerScore / 100,
                color: AppPalette.primary,
              ),
              const SizedBox(height: 5),
              Text(
                'Şirket gücü ${forecast.playerScore} · '
                'Rakip gücü ${forecast.competitorScore}',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppPill(label: 'Moral %${wellbeing.averageMorale}'),
                  AppPill(label: 'Sadakat %${wellbeing.averageLoyalty}'),
                  if (wellbeing.burnoutRiskCount > 0)
                    AppPill(
                      label: '${wellbeing.burnoutRiskCount} tükenmişlik riski',
                      color: AppPalette.warning,
                    ),
                  if (wellbeing.atRiskCount > 0)
                    AppPill(
                      label: '${wellbeing.atRiskCount} ayrılma riski',
                      color: AppPalette.error,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _percentLabel(String title, int value) =>
      '$title ${value >= 0 ? '+' : '-'}%${value.abs()}';

  String _signedCurrency(int value) =>
      '${value >= 0 ? '+' : '-'}₺${value.abs()}';

  String _signedScore(int value) => value > 0 ? '+$value' : '$value';

  Color _profileColor(int value) => value > 0
      ? AppPalette.warning
      : value < 0
      ? AppPalette.success
      : AppPalette.textMuted;
}

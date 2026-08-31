import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/services/company_growth_service.dart';

class CompanyGrowthPanel extends StatelessWidget {
  const CompanyGrowthPanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final service = CompanyGrowthService();
    final dailyNet = service.dailyNetIncome(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Şirket göstergeleri',
          caption: 'Finansal güç ve pazardaki mevcut konumun.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: AppPalette.secondary,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppPill(
                label: 'Değer ₺${service.valuation(state)}',
                color: AppPalette.tertiary,
              ),
              AppPill(
                label: 'İtibar ${service.reputation(state)}/100',
                color: AppPalette.primary,
              ),
              AppPill(
                label:
                    'Pazar %${AppFormatters.decimal(service.marketShare(state), fractionDigits: 1)}',
                color: AppPalette.secondary,
              ),
              AppPill(
                label:
                    'Şirket net ${dailyNet >= 0 ? '+' : '-'}₺${dailyNet.abs()}/gün',
                color: dailyNet >= 0 ? AppPalette.success : AppPalette.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

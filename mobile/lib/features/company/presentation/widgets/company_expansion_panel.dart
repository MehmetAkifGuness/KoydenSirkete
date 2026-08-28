import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/company_deal.dart';
import '../../domain/entities/company_stage.dart';
import '../../domain/services/company_expansion_service.dart';

class CompanyExpansionPanel extends StatelessWidget {
  const CompanyExpansionPanel({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final service = CompanyExpansionService();
    final completed = service.completedDeals(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Satın alma ve birleşmeler',
          caption: 'Şirket kasasıyla kalıcı pazar kazanımları elde et.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: AppPalette.tertiary,
          padding: const EdgeInsets.all(14),
          child: Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              AppPill(
                label:
                    '${completed.length}/${CompanyExpansionService.deals.length} işlem',
                color: AppPalette.tertiary,
                icon: Icons.handshake_outlined,
              ),
              AppPill(
                label:
                    'Değer +₺${AppFormatters.compactNumber(service.valuationGain(state))}',
                color: AppPalette.success,
              ),
              AppPill(
                label: 'Pazar +%${service.marketShareGain(state)}',
                color: AppPalette.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        for (final deal in CompanyExpansionService.deals) ...[
          _CompanyDealCard(deal: deal, session: session),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _CompanyDealCard extends StatelessWidget {
  const _CompanyDealCard({required this.deal, required this.session});

  final CompanyDeal deal;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final state = session.state;
    final completed = state.companyExpansion.hasCompleted(deal.id);
    final check = session.checkCompanyDeal(deal);
    final accent = _accentFor(deal.type);
    return AppInfoCard(
      key: ValueKey('company-deal-${deal.id}'),
      accent: completed ? AppPalette.success : accent,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed ? Icons.verified_rounded : _iconFor(deal.type),
                color: completed ? AppPalette.success : accent,
                size: 21,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  deal.title,
                  style: const TextStyle(
                    color: AppPalette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AppPill(
                label: deal.type.label,
                color: completed ? AppPalette.success : accent,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            deal.description,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AppPill(label: _stageName(deal.minimumStage)),
              if (deal.requiredControlledRegions > 0)
                AppPill(
                  label: '${deal.requiredControlledRegions} bölge',
                  icon: Icons.public_rounded,
                ),
              if (deal.requiredChampionships > 0)
                AppPill(
                  label: '${deal.requiredChampionships} şampiyonluk',
                  icon: Icons.emoji_events_outlined,
                ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AppPill(
                label:
                    '+₺${AppFormatters.compactNumber(deal.valuationGain)} değer',
                color: AppPalette.success,
              ),
              AppPill(
                label: '+${deal.reputationGain} itibar',
                color: AppPalette.success,
              ),
              AppPill(
                label: '+%${deal.marketShareGain} pazar',
                color: AppPalette.secondary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            check.reason,
            style: TextStyle(
              color: completed
                  ? AppPalette.success
                  : check.isEligible
                  ? AppPalette.textSecondary
                  : AppPalette.warning,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: ValueKey('complete-company-deal-${deal.id}'),
              onPressed: check.isEligible && !session.isBusy
                  ? () => _confirm(context)
                  : null,
              icon: Icon(
                completed ? Icons.check_rounded : Icons.account_balance_rounded,
                size: 18,
              ),
              label: Text(
                completed
                    ? 'Tamamlandı'
                    : check.isEligible
                    ? 'Şirket kasası · ₺${deal.cost}'
                    : 'Kilitli · ₺${deal.cost}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(deal.type.label),
        content: Text(
          '${deal.title} için şirket kasasından ₺${deal.cost} ödenecek. '
          'İşlem tek seferliktir ve geri alınamaz. Devam edilsin mi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('İşlemi tamamla'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final message = await session.completeCompanyDeal(deal);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Color _accentFor(CompanyDealType type) => switch (type) {
    CompanyDealType.acquisition => AppPalette.tertiary,
    CompanyDealType.merger => AppPalette.primary,
    CompanyDealType.marketShareTransfer => AppPalette.secondary,
  };

  IconData _iconFor(CompanyDealType type) => switch (type) {
    CompanyDealType.acquisition => Icons.domain_add_outlined,
    CompanyDealType.merger => Icons.handshake_outlined,
    CompanyDealType.marketShareTransfer => Icons.pie_chart_outline_rounded,
  };

  String _stageName(CompanyStage stage) => switch (stage) {
    CompanyStage.localEnterprise => 'Yerel girişim',
    CompanyStage.regionalCompany => 'Bölgesel şirket',
    CompanyStage.nationalBrand => 'Ulusal marka',
    CompanyStage.holding => 'Holding',
  };
}

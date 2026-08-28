import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../game/domain/entities/player_state.dart';
import '../../domain/entities/company_region.dart';
import '../../domain/services/company_region_service.dart';

class CompanyRegionPanel extends StatelessWidget {
  const CompanyRegionPanel({required this.state, super.key});

  final PlayerState state;

  @override
  Widget build(BuildContext context) {
    final progress = CompanyRegionService().allProgress(state);
    final controlled = progress.where((item) => item.isControlled).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(
          title: 'Bölgesel hâkimiyet',
          caption: 'Bayi seviyelerinin toplamını 4 yaparak avantajı aç.',
        ),
        const SizedBox(height: 12),
        AppInfoCard(
          accent: AppPalette.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$controlled/7 bölge kontrol altında',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const AppPill(
                    label: 'Seviye = etki',
                    color: AppPalette.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final item in progress) ...[
                _RegionRow(progress: item),
                if (item != progress.last) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RegionRow extends StatelessWidget {
  const _RegionRow({required this.progress});

  final CompanyRegionProgress progress;

  @override
  Widget build(BuildContext context) {
    final controlled = progress.isControlled;
    final accent = controlled ? AppPalette.success : AppPalette.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              controlled ? Icons.verified_rounded : Icons.location_on_outlined,
              color: accent,
              size: 17,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                progress.definition.name,
                style: const TextStyle(
                  color: AppPalette.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${progress.influence}/${CompanyRegionProgress.controlTarget} etki · ${progress.branchCount} bayi',
              style: TextStyle(
                color: accent,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          progress.definition.advantage,
          style: const TextStyle(color: AppPalette.textMuted, fontSize: 9),
        ),
        const SizedBox(height: 5),
        AppProgressLine(value: progress.ratio, color: accent),
      ],
    );
  }
}

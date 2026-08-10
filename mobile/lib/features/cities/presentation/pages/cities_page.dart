import 'package:flutter/material.dart';
import '../../../../app/theme/app_palette.dart';

import '../../../../core/widgets/app_feedback.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/city.dart';
import '../../domain/services/city_catalog.dart';
import '../../domain/services/city_service.dart';
import '../../../assets/domain/services/asset_service.dart';

class CitiesPage extends StatelessWidget {
  const CitiesPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şehirler')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final currentCity = CityCatalog.findById(session.state.currentCityId);
          final currentDailyCost = currentCity != null && AssetService().hasHomeInCity(session.state, currentCity.id) ? 0 : currentCity?.dailyCost ?? 0;
          return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: CityCatalog.cities.length + 1,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text('Mevcut şehir: ${currentCity?.name ?? 'Bilinmiyor'} · Günlük gider: ₺$currentDailyCost');
            }
            return _CityCard(city: CityCatalog.cities[index - 1], session: session);
          },
          );
        },
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  const _CityCard({required this.city, required this.session});

  final City city;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final isCurrent = city.id == session.state.currentCityId;
    final check = session.checkCityMove(city);
    final moveCost = CityService().moveCost(session.state, city);
    return Card(
      child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(city.name, style: const TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w700))),
                Text('₺${city.dailyCost}/gün', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(city.description, style: const TextStyle(color: AppPalette.textSecondary)),
            const SizedBox(height: 10),
            Text('Taşınma: ₺$moveCost · Maaş x${city.salaryMultiplier.toStringAsFixed(2)} · ${city.opportunityCount} fırsat'),
            const SizedBox(height: 6),
            Text('Nüfus: ${city.population} · Teknoloji: ${city.technologyLevel}/100 · Pazar: ${city.marketLevel}'),
            const SizedBox(height: 6),
            _CityPill(text: 'EKONOMİK SEVİYE: ${city.economicLevel.name.toUpperCase()}'),
            const SizedBox(height: 6),
            _CityPill(text: 'KARİYER SEVİYESİ: ${city.minimumCareerLevel}'),
            const SizedBox(height: 10),
            Text(isCurrent ? 'Şu anda buradasın.' : check.reason, style: TextStyle(color: isCurrent || check.isEligible ? AppPalette.success : AppPalette.warning)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: isCurrent || !check.isEligible || session.isBusy ? null : () => _move(context),
                child: Text(isCurrent ? 'Mevcut şehir' : 'Taşın'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _move(BuildContext context) async {
    final message = await session.moveCity(city);
    if (!context.mounted || message == null) {
      return;
    }
    AppFeedback.show(context, message);
  }
}

class _CityPill extends StatelessWidget {
  const _CityPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: AppPalette.surfaceMuted, border: Border.all(color: AppPalette.outline), borderRadius: BorderRadius.circular(14)),
    child: Text(text, style: TextStyle(color: AppPalette.primary, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

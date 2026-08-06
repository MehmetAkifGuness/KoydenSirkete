import 'package:flutter/material.dart';

import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/city.dart';
import '../../domain/services/city_catalog.dart';

class CitiesPage extends StatelessWidget {
  const CitiesPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final currentCity = CityCatalog.findById(session.state.currentCityId);
    return Scaffold(
      appBar: AppBar(title: const Text('Şehirler')),
      body: AnimatedBuilder(
        animation: session,
        builder: (context, _) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: CityCatalog.cities.length + 1,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text('Mevcut şehir: ${currentCity?.name ?? 'Bilinmiyor'} · Günlük gider: ₺${currentCity?.dailyCost ?? 0}');
            }
            return _CityCard(city: CityCatalog.cities[index - 1], session: session);
          },
        ),
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
            Text(city.description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Text('Taşınma: ₺${city.moveCost} · Maaş x${city.salaryMultiplier.toStringAsFixed(2)} · ${city.opportunityCount} fırsat'),
            const SizedBox(height: 6),
            _CityPill(text: 'EKONOMİK SEVİYE: ${city.economicLevel.name.toUpperCase()}'),
            const SizedBox(height: 6),
            _CityPill(text: 'KARİYER SEVİYESİ: ${city.minimumCareerLevel}'),
            const SizedBox(height: 10),
            Text(isCurrent ? 'Şu anda buradasın.' : check.reason, style: TextStyle(color: isCurrent || check.isEligible ? Colors.greenAccent : Colors.orangeAccent)),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CityPill extends StatelessWidget {
  const _CityPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: const Color(0xFF0B0B08), border: Border.all(color: const Color(0xFF554A1C)), borderRadius: BorderRadius.circular(14)),
    child: Text(text, style: const TextStyle(color: Color(0xFFDDBA3E), fontSize: 10, fontWeight: FontWeight.w700)),
  );
}

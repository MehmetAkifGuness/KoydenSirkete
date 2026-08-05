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
          padding: const EdgeInsets.all(20),
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(city.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                Text('₺${city.dailyCost}/gün', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(city.description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Text('Taşınma: ₺${city.moveCost} · Kariyer seviyesi: ${city.minimumCareerLevel}'),
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

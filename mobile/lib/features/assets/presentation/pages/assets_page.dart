import 'package:flutter/material.dart';

import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/feature_error_view.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/car_asset.dart';
import '../../domain/entities/home_asset.dart';
import '../../domain/services/car_catalog.dart';
import '../../domain/services/home_catalog.dart';

class AssetsPage extends StatelessWidget {
  const AssetsPage({required this.session, super.key});

  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Varlıklarım')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            try {
              final state = session.state;
          final city = CityCatalog.findById(state.currentCityId);
          final ownedHomes = state.ownedHomeIds.map(HomeCatalog.findById).whereType<HomeAsset>().toList(growable: false);
          final ownedCar = CarCatalog.findById(state.ownedCarId);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
              Text('Para: ₺${state.money}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(city == null ? 'Şehir bulunamadı.' : 'Mevcut şehir: ${city.name} · Ev alınca bu şehirde kira ödemezsin.'),
              const SizedBox(height: 20),
              const Text('Evler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              if (ownedHomes.isNotEmpty) ...[
                for (final home in ownedHomes) _OwnedHomeTile(home: home),
                const SizedBox(height: 4),
              ],
              if (city != null) for (final home in HomeCatalog.forCity(city)) _HomeTile(home: home, session: session, city: city),
              const SizedBox(height: 20),
              const Text('Arabalar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              if (ownedCar != null) _OwnedCarTile(car: ownedCar),
              for (final car in CarCatalog.cars) _CarTile(car: car, session: session),
                ],
              );
            } on Object {
              return const FeatureErrorView(title: 'Varlık bilgileri okunamadı.');
            }
          },
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({required this.home, required this.session, required this.city});

  final HomeAsset home;
  final GameSessionController session;
  final City city;

  @override
  Widget build(BuildContext context) {
    final check = session.checkHome(home, city);
    final owned = session.state.ownedHomeIds.contains(home.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(home.name),
        subtitle: Text('${home.description}\nKonfor: ${home.comfort}/100 · ₺${home.price} · ${check.reason}'),
        isThreeLine: true,
        trailing: SizedBox(
          width: 92,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44), padding: const EdgeInsets.symmetric(horizontal: 6)),
            onPressed: owned || !check.isEligible || session.isBusy ? null : () => _buy(context),
            child: FittedBox(child: Text(owned ? 'Sahipsin' : 'Satın al')),
          ),
        ),
      ),
    );
  }

  Future<void> _buy(BuildContext context) async {
    final message = await session.buyHome(home, city);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _OwnedHomeTile extends StatelessWidget {
  const _OwnedHomeTile({required this.home});

  final HomeAsset home;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.home_outlined),
          title: Text('${home.name} · Kira muafiyeti'),
          subtitle: Text('Şehir ID: ${home.cityId} · Konfor: ${home.comfort}/100'),
          trailing: const Icon(Icons.check_circle_outline),
        ),
      );
}

class _CarTile extends StatelessWidget {
  const _CarTile({required this.car, required this.session});

  final CarAsset car;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final check = session.checkCar(car);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(car.name),
        subtitle: Text('${car.description}\nTaşınma avantajı: %${car.moveDiscountPercent} · ₺${car.price}\n${check.reason}'),
        isThreeLine: true,
        trailing: SizedBox(
          width: 92,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44), padding: const EdgeInsets.symmetric(horizontal: 6)),
            onPressed: check.isEligible && !session.isBusy ? () => _buy(context) : null,
            child: const FittedBox(child: Text('Satın al')),
          ),
        ),
      ),
    );
  }

  Future<void> _buy(BuildContext context) async {
    final message = await session.buyCar(car);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _OwnedCarTile extends StatelessWidget {
  const _OwnedCarTile({required this.car});

  final CarAsset car;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.directions_car_outlined),
          title: Text('${car.name} · Sahip olduğun araç'),
          subtitle: Text('Şehir değişim maliyeti %${car.moveDiscountPercent} azalır.'),
          trailing: const Icon(Icons.check_circle_outline),
        ),
      );
}

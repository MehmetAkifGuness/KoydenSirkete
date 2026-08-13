import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feature_error_view.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
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
    return AppPage(
      title: 'Varlıklarım',
      subtitle: 'Geleceğin için kalıcı yatırımlar',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          try {
            final state = session.state;
            final city = CityCatalog.findById(state.currentCityId);
            final ownedHomes = state.ownedHomeIds
                .map(HomeCatalog.findById)
                .whereType<HomeAsset>()
                .toList(growable: false);
            final ownedCar = CarCatalog.findById(state.ownedCarId);
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                AppInfoCard(
                  accent: AppPalette.tertiary,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppPalette.tertiary.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppPalette.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Yatırım bütçen',
                              style: TextStyle(
                                color: AppPalette.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '₺${state.money}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              city == null ? 'Konum bulunamadı' : city.name,
                              style: const TextStyle(
                                color: AppPalette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const AppSectionHeader(
                  title: 'Evler',
                  caption: 'Kira giderini azalt, konforunu artır.',
                ),
                const SizedBox(height: 12),
                if (ownedHomes.isNotEmpty) ...[
                  for (final home in ownedHomes) ...[
                    _OwnedHomeCard(home: home),
                    const SizedBox(height: 10),
                  ],
                ],
                if (city != null)
                  for (final home in HomeCatalog.forCity(city)) ...[
                    _HomeCard(home: home, session: session, city: city),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 18),
                const AppSectionHeader(
                  title: 'Arabalar',
                  caption: 'Şehir değişimlerinde avantaj kazan.',
                ),
                const SizedBox(height: 12),
                if (ownedCar != null) ...[
                  _OwnedCarCard(car: ownedCar),
                  const SizedBox(height: 10),
                ],
                for (final car in CarCatalog.cars) ...[
                  _CarCard(car: car, session: session),
                  const SizedBox(height: 10),
                ],
              ],
            );
          } on Object {
            return const FeatureErrorView(title: 'Varlık bilgileri okunamadı.');
          }
        },
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.home,
    required this.session,
    required this.city,
  });

  final HomeAsset home;
  final GameSessionController session;
  final City city;

  @override
  Widget build(BuildContext context) {
    final check = session.checkHome(home, city);
    final owned = session.state.ownedHomeIds.contains(home.id);
    return AppInfoCard(
      accent: AppPalette.primary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppPalette.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.home_rounded, color: AppPalette.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  home.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  home.description,
                  style: const TextStyle(
                    color: AppPalette.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Konfor ${home.comfort}/100 · ₺${home.price}',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  check.reason,
                  style: TextStyle(
                    color: check.isEligible
                        ? AppPalette.success
                        : AppPalette.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: owned || !check.isEligible || session.isBusy
                ? null
                : () => _buy(context),
            child: Text(owned ? 'Sahipsin' : 'Al'),
          ),
        ],
      ),
    );
  }

  Future<void> _buy(BuildContext context) async {
    final message = await session.buyHome(home, city);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _OwnedHomeCard extends StatelessWidget {
  const _OwnedHomeCard({required this.home});

  final HomeAsset home;

  @override
  Widget build(BuildContext context) => AppInfoCard(
    accent: AppPalette.primary,
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppPalette.primary.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.verified_rounded, color: AppPalette.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                home.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                'Kira muafiyeti · Konfor ${home.comfort}/100',
                style: const TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CarCard extends StatelessWidget {
  const _CarCard({required this.car, required this.session});

  final CarAsset car;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final check = session.checkCar(car);
    return AppInfoCard(
      accent: AppPalette.secondary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppPalette.secondary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: AppPalette.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  car.description,
                  style: const TextStyle(
                    color: AppPalette.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Taşınma avantajı %${car.moveDiscountPercent} · ₺${car.price}',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  check.reason,
                  style: TextStyle(
                    color: check.isEligible
                        ? AppPalette.success
                        : AppPalette.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: check.isEligible && !session.isBusy
                ? () => _buy(context)
                : null,
            child: const Text('Al'),
          ),
        ],
      ),
    );
  }

  Future<void> _buy(BuildContext context) async {
    final message = await session.buyCar(car);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

class _OwnedCarCard extends StatelessWidget {
  const _OwnedCarCard({required this.car});

  final CarAsset car;

  @override
  Widget build(BuildContext context) => AppInfoCard(
    accent: AppPalette.secondary,
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppPalette.secondary.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.verified_rounded,
            color: AppPalette.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                car.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                'Sahipsin · Taşınma maliyeti %${car.moveDiscountPercent} azalır.',
                style: const TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

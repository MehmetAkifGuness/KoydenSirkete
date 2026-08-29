import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feature_error_view.dart';
import '../../../cities/domain/entities/city.dart';
import '../../../cities/domain/services/city_catalog.dart';
import '../../../economy/domain/services/investment_return_service.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/car_asset.dart';
import '../../domain/entities/home_asset.dart';
import '../../domain/services/asset_service.dart';
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
            final assetService = AssetService();
            final monthlyRentalIncome = assetService.monthlyRentalIncome(state);
            final monthlyNetRentalIncome = assetService.monthlyNetRentalIncome(
              state,
            );
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
                      if (monthlyRentalIncome > 0)
                        AppPill(
                          label: '+₺$monthlyNetRentalIncome/ay net',
                          color: AppPalette.success,
                          icon: Icons.key_rounded,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const AppSectionHeader(
                  title: 'Evler',
                  caption:
                      'Evinde otur veya kiraya ver. Toplam kira geliri aktif iş kazancı seviyesinde sınırlanır.',
                ),
                const SizedBox(height: 12),
                if (ownedHomes.isNotEmpty) ...[
                  for (final home in ownedHomes) ...[
                    _OwnedHomeCard(home: home, session: session),
                    const SizedBox(height: 10),
                  ],
                ],
                if (city != null)
                  for (final home in HomeCatalog.forCity(city))
                    if (!state.ownedHomeIds.contains(home.id)) ...[
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
                  _OwnedCarCard(car: ownedCar, session: session),
                  const SizedBox(height: 10),
                ] else
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
                  'Konfor ${home.comfort}/100 · Enerji +${home.energyRecoveryBonus}/dk · ₺${home.price} · Aylık brüt kira ₺${AssetService().monthlyRent(home)}\n'
                  '${InvestmentReturnService.summary(InvestmentType.home, InvestmentReturnService.homeDays(home))}',
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
            onPressed: !check.isEligible || session.isBusy
                ? null
                : () => _buy(context),
            child: const Text('Al'),
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
  const _OwnedHomeCard({required this.home, required this.session});

  final HomeAsset home;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final cityName = CityCatalog.findById(home.cityId)?.name ?? 'Bilinmeyen';
    final assetService = AssetService();
    final saleValue = assetService.homeSaleValue(home);
    final monthlyRent = assetService.monthlyRent(home);
    final monthlyMaintenance =
        monthlyRent * AssetService.rentalMaintenancePercent ~/ 100;
    final monthlyNetRent = monthlyRent - monthlyMaintenance;
    final dailyRent = assetService.dailyRent(home);
    final isRented = session.state.rentedHomeIds.contains(home.id);
    final isCurrentCity = home.cityId == session.state.currentCityId;
    final status = isRented
        ? 'Kirada · Net ₺$monthlyNetRent/ay · ₺$dailyRent/gün brüt'
        : isCurrentCity
        ? 'Kullanımda · Konut kirası ödemezsin'
        : 'Boş mülk · Kiraya verilebilir';
    return AppInfoCard(
      accent: isRented ? AppPalette.success : AppPalette.primary,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (isRented ? AppPalette.success : AppPalette.primary)
                      .withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isRented ? Icons.key_rounded : Icons.verified_rounded,
                  color: isRented ? AppPalette.success : AppPalette.primary,
                ),
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
                      '$cityName mülkü · $status',
                      style: const TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isRented
                          ? 'Bakım ₺$monthlyMaintenance/ay · Satış değeri ₺$saleValue'
                          : 'Konfor ${home.comfort}/100 · Enerji +${home.energyRecoveryBonus}/dk · Satış değeri ₺$saleValue',
                      style: const TextStyle(
                        color: AppPalette.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: session.isBusy
                      ? null
                      : () => _toggleRental(context, isRented),
                  icon: Icon(isRented ? Icons.home_rounded : Icons.key_rounded),
                  label: Text(isRented ? 'Kiradan çıkar' : 'Kiraya ver'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: session.isBusy
                      ? null
                      : () => _sell(context, saleValue, isRented),
                  child: const Text('Sat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRental(BuildContext context, bool isRented) async {
    final message = isRented
        ? await session.stopRentingHome(home)
        : await session.rentOutHome(home);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }

  Future<void> _sell(BuildContext context, int saleValue, bool isRented) async {
    final confirmed = await _confirmSale(
      context,
      title: '${home.name} satılsın mı?',
      message: isRented
          ? '₺$saleValue hesabına eklenecek ve kira geliri sona erecek.'
          : '₺$saleValue hesabına eklenecek. Bu evde oturuyorsan konut kirası yeniden uygulanacak.',
    );
    if (!confirmed || !context.mounted) return;
    final message = await session.sellHome(home);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
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
                  'Ulaşım %${car.moveDiscountPercent} indirim · +${car.opportunityBonus} iş fırsatı · ₺${car.price}\n'
                  '${InvestmentReturnService.summary(InvestmentType.car, InvestmentReturnService.carDays(car))}',
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
  const _OwnedCarCard({required this.car, required this.session});

  final CarAsset car;
  final GameSessionController session;

  @override
  Widget build(BuildContext context) {
    final saleValue = AssetService().carSaleValue(car);
    return AppInfoCard(
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
                  'Ulaşım %${car.moveDiscountPercent} indirim · Günde +${car.opportunityBonus} iş fırsatı',
                  style: const TextStyle(
                    color: AppPalette.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Satış değeri ₺$saleValue',
                  style: const TextStyle(
                    color: AppPalette.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: session.isBusy ? null : () => _sell(context, saleValue),
            child: const Text('Sat'),
          ),
        ],
      ),
    );
  }

  Future<void> _sell(BuildContext context, int saleValue) async {
    final confirmed = await _confirmSale(
      context,
      title: '${car.name} satılsın mı?',
      message: '₺$saleValue hesabına eklenecek ve taşınma indirimi kalkacak.',
    );
    if (!confirmed || !context.mounted) return;
    final message = await session.sellCar(car);
    if (context.mounted && message != null) AppFeedback.show(context, message);
  }
}

Future<bool> _confirmSale(
  BuildContext context, {
  required String title,
  required String message,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sat'),
          ),
        ],
      ),
    ) ??
    false;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../assets/domain/services/car_catalog.dart';
import '../../../game/presentation/state/game_session_controller.dart';
import '../../domain/entities/city.dart';
import '../../domain/services/city_catalog.dart';
import '../../domain/services/city_service.dart';
import '../../domain/services/living_cost_service.dart';
import '../models/city_filter.dart';

class CitiesPage extends StatefulWidget {
  const CitiesPage({required this.session, super.key});

  final GameSessionController session;

  @override
  State<CitiesPage> createState() => _CitiesPageState();
}

class _CitiesPageState extends State<CitiesPage> {
  CityFilter _filter = CityFilter.all;
  String _query = '';
  bool _costFirst = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return AppPage(
      title: 'Şehirler',
      subtitle: 'Kariyerini taşıyabileceğin 81 pazar',
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          final currentCity = CityCatalog.findById(session.state.currentCityId);
          final livingCosts = currentCity == null
              ? LivingCostBreakdown.empty
              : LivingCostService().breakdown(session.state, currentCity.id);
          final cityService = CityService();
          final cities = filterCities(CityCatalog.cities, _filter)
              .where(
                (city) => city.name.toLowerCase().contains(
                  _query.trim().toLowerCase(),
                ),
              )
              .toList();
          if (_costFirst) {
            cities.sort(
              (left, right) => cityService
                  .moveCost(session.state, left)
                  .compareTo(cityService.moveCost(session.state, right)),
            );
          } else if (_filter != CityFilter.highestTechnology) {
            cities.sort((left, right) => left.name.compareTo(right.name));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              AppInfoCard(
                accent: AppPalette.primary,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppPalette.primary.withValues(alpha: .13),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppPalette.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Şu anki konumun',
                            style: TextStyle(
                              color: AppPalette.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            currentCity?.name ?? 'Bilinmiyor',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Günlük gider ₺${livingCosts.totalExpenses} · Kira geliri +₺${livingCosts.rentalIncome}',
                            style: const TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Konut ₺${livingCosts.housing} · Yemek ₺${livingCosts.food} · Fatura ₺${livingCosts.utilities} · Ulaşım ₺${livingCosts.transportation}${livingCosts.rentalMaintenance == 0 ? '' : ' · Bakım ₺${livingCosts.rentalMaintenance}'}',
                            style: const TextStyle(
                              color: AppPalette.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const AppSectionHeader(
                title: 'Yeni bir şehir seç',
                caption: 'Daha iyi pazarlar, daha yüksek hedefler.',
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('city-search'),
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Şehir ara',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    tooltip: _costFirst
                        ? 'Taşınma maliyetine göre sıralı'
                        : 'Ada göre sıralı',
                    onPressed: () => setState(() => _costFirst = !_costFirst),
                    icon: Icon(
                      _costFirst
                          ? Icons.payments_outlined
                          : Icons.sort_by_alpha_rounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              _CityFilterBar(
                selected: _filter,
                onSelected: (filter) => setState(() => _filter = filter),
              ),
              const SizedBox(height: 9),
              Text(
                '${cities.length}/${CityCatalog.cities.length} şehir · ${_costFirst
                    ? "maliyet"
                    : _filter == CityFilter.highestTechnology
                    ? "teknoloji"
                    : "ad"} sırası',
                style: const TextStyle(
                  color: AppPalette.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 9),
              if (cities.isEmpty)
                const AppEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Şehir bulunamadı',
                  message: 'Arama metnini veya pazar filtresini değiştir.',
                ),
              for (final city in cities) ...[
                _CityCard(city: city, session: session),
                const SizedBox(height: 10),
              ],
            ],
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
    final livingCosts = LivingCostService().breakdown(session.state, city.id);
    final car = CarCatalog.findById(session.state.ownedCarId);
    return AppInfoCard(
      accent: isCurrent ? AppPalette.primary : AppPalette.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  city.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              AppPill(
                label: '₺${livingCosts.totalExpenses}/gün',
                color: AppPalette.tertiary,
                icon: Icons.home_work_outlined,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            city.description,
            style: const TextStyle(
              color: AppPalette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              AppPill(
                label: 'Nüfus ${city.population}',
                color: AppPalette.textSecondary,
              ),
              AppPill(
                label: 'Teknoloji ${city.technologyLevel}',
                color: AppPalette.secondary,
              ),
              AppPill(
                label: '${city.opportunityCount} fırsat',
                color: AppPalette.primary,
              ),
              AppPill(
                label: livingCosts.housing == 0
                    ? 'Konut senin'
                    : 'Kira ₺${livingCosts.housing}',
                color: livingCosts.housing == 0
                    ? AppPalette.success
                    : AppPalette.tertiary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Taşınma ₺$moveCost${car == null ? '' : ' · Araç indirimi %${car.moveDiscountPercent}'} · Maaş x${city.salaryMultiplier.toStringAsFixed(2)} · Pazar ${city.marketLevel}',
            style: const TextStyle(color: AppPalette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 9),
          Text(
            isCurrent ? 'Şu anda buradasın.' : check.reason,
            style: TextStyle(
              color: isCurrent || check.isEligible
                  ? AppPalette.success
                  : AppPalette.warning,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: isCurrent || !check.isEligible || session.isBusy
                  ? null
                  : () => _move(context),
              child: Text(isCurrent ? 'Mevcut konum' : 'Bu şehre taşın'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _move(BuildContext context) async {
    final message = await session.moveCity(city);
    if (context.mounted && message != null) {
      AppFeedback.show(context, message);
    }
  }
}

class _CityFilterBar extends StatelessWidget {
  const _CityFilterBar({required this.selected, required this.onSelected});

  final CityFilter selected;
  final ValueChanged<CityFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in CityFilter.values) ...[
            ChoiceChip(
              label: Text(filter.label),
              selected: filter == selected,
              onSelected: (_) => onSelected(filter),
              selectedColor: AppPalette.primary.withValues(alpha: .18),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: filter == selected
                    ? AppPalette.primary
                    : AppPalette.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (filter != CityFilter.values.last) const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}

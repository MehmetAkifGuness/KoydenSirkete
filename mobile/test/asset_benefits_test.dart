import 'package:flutter_test/flutter_test.dart';

import 'package:kariyerden_sirkete/features/assets/domain/services/asset_service.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/car_catalog.dart';
import 'package:kariyerden_sirkete/features/assets/domain/services/home_catalog.dart';
import 'package:kariyerden_sirkete/features/cities/domain/services/city_catalog.dart';
import 'package:kariyerden_sirkete/features/game/domain/entities/player_state.dart';
import 'package:kariyerden_sirkete/features/game/domain/services/energy_recovery_service.dart';
import 'package:kariyerden_sirkete/features/jobs/domain/services/job_listing_service.dart';

void main() {
  test('occupied home comfort accelerates energy recovery', () {
    final city = CityCatalog.cities.first;
    final home = HomeCatalog.forCity(city).last;
    final anchor = DateTime(2026);
    final state = PlayerState.initial.copyWith(
      energy: 50,
      maxEnergy: 100,
      currentCityId: city.id,
      ownedHomeIds: [home.id],
      energyRecoveryAt: anchor,
    );

    final recovered = EnergyRecoveryService().recover(
      state,
      now: anchor.add(const Duration(minutes: 1)),
    );

    expect(recovered.energy, 50 + 10 + home.energyRecoveryBonus);
    expect(
      EnergyRecoveryService().recover(
        state.copyWith(rentedHomeIds: [home.id]),
        now: anchor.add(const Duration(minutes: 1)),
      ).energy,
      60,
    );
  });

  test('car adds deterministic daily job opportunities', () {
    final car = CarCatalog.cars.last;
    final state = PlayerState.initial.copyWith(ownedCarId: car.id);
    final base = JobListingService().forPlayer(PlayerState.initial);
    final withCar = JobListingService().forPlayer(state);

    expect(withCar.length, base.length + car.opportunityBonus);
    expect(AssetService().opportunityBonus(state), car.opportunityBonus);
  });
}

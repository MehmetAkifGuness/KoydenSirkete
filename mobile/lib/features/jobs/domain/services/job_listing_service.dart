import '../../../game/domain/entities/player_state.dart';
import '../../../assets/domain/services/asset_service.dart';
import '../entities/job_listing.dart';
import '../../../cities/domain/services/city_opportunity_service.dart';

class JobListingService {
  JobListingService({
    CityOpportunityService? opportunityService,
    AssetService? assetService,
  }) : _opportunityService = opportunityService ?? CityOpportunityService(),
       _assetService = assetService ?? AssetService();

  final CityOpportunityService _opportunityService;
  final AssetService _assetService;

  List<JobListing> forPlayer(PlayerState state) {
    return _opportunityService.listings(
      cityId: state.currentCityId,
      day: state.day,
      opportunityBonus: _assetService.opportunityBonus(state),
    );
  }
}

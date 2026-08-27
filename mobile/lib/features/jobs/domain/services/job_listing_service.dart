import '../../../game/domain/entities/player_state.dart';
import '../entities/job_listing.dart';
import '../../../cities/domain/services/city_opportunity_service.dart';

class JobListingService {
  JobListingService({CityOpportunityService? opportunityService})
    : _opportunityService = opportunityService ?? CityOpportunityService();

  final CityOpportunityService _opportunityService;

  List<JobListing> forPlayer(PlayerState state) {
    return _opportunityService.listings(
      cityId: state.currentCityId,
      day: state.day,
    );
  }
}

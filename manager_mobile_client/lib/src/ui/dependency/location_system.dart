import 'package:manager_mobile_client/src/logic/external/places_service.dart';

class LocationSystem {
  final PlacesService placesService;

  LocationSystem(
    this.placesService
  );

  factory LocationSystem.standard() {
    final placesService = makeDefaultPlacesService();

    return LocationSystem(
      placesService
    );
  }
}

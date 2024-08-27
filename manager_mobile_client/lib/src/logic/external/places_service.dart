import 'dart:async';
import 'dart:io';
import 'package:google_maps_webservice/places.dart' as google;
import 'package:google_maps_webservice/geocoding.dart' as google;
import 'package:manager_mobile_client/src/logic/core/uuid.dart';
import 'package:manager_mobile_client/src/logic/core/location.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

export 'package:manager_mobile_client/src/logic/core/location.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class PlacesSearchResult {
  String id;
  String description;
  PlacesSearchResult(this.id, this.description);
}

class PlacesDetailsResult {
  String address;
  LatLng coordinate;
  PlacesDetailsResult(this.address, this.coordinate);
}

class PlacesService {
  final String sessionToken;
  final String language;

  PlacesService({this.sessionToken, this.language, String apiKey}) :
    _placesService = google.GoogleMapsPlaces(apiKey: apiKey),
    _geocodingService = google.GoogleMapsGeocoding(apiKey: apiKey);

  Future<List<PlacesSearchResult>> search(String searchString) async {
    final response = await _placesService.autocomplete(searchString, sessionToken: sessionToken, language: language);
    if (response.isOkay) {
      return response.predictions.map((prediction) => PlacesSearchResult(prediction.placeId, prediction.description)).toList();
    } else if (response.hasNoResults) {
      return [];
    } else {
      print(response.errorMessage);
      throw RequestFailedException();
    }
  }

  Future<PlacesDetailsResult> getDetails(PlacesSearchResult searchResult) async {
    final response = await _placesService.getDetailsByPlaceId(searchResult.id, sessionToken: sessionToken, language: language);
    if (response.isOkay) {
      final location = response.result.geometry.location;
      return PlacesDetailsResult(response.result.formattedAddress, LatLng(location.lat, location.lng));
    } else {
      print(response.errorMessage);
      throw RequestFailedException();
    }
  }

  Future<PlacesDetailsResult> getAddress(LatLng coordinate) async {
    final response = await _geocodingService.searchByLocation(google.Location(lat: coordinate.latitude, lng: coordinate.longitude), language: language);
    if (response.isOkay && response.results.isNotEmpty) {
      final result = response.results.first;
      final location = result.geometry.location;
      return PlacesDetailsResult(result.formattedAddress, LatLng(location.lat, location.lng));
    } else {
      print(response.errorMessage);
      throw RequestFailedException();
    }
  }

  Future<PlacesDetailsResult> getCoordinate(String address) async {
    final response = await _geocodingService.searchByAddress(address, language: language);
    if (response.isOkay && response.results.isNotEmpty) {
      final result = response.results.first;
      final location = result.geometry.location;
      return PlacesDetailsResult(result.formattedAddress, LatLng(location.lat, location.lng));
    } else {
      print(response.errorMessage);
      throw RequestFailedException();
    }
  }

  final google.GoogleMapsPlaces _placesService;
  final google.GoogleMapsGeocoding _geocodingService;
}

PlacesService makeDefaultPlacesService() => PlacesService(
  sessionToken: Uuid().generateV4(),
  language: 'ru',
  apiKey: _getApiKey()
);

String _getApiKey() {
  if (Platform.isIOS) {
    return 'AIzaSyC6UWjJLfSWWOXrnTUfraCSQj5KUTKvhUU';
  } else {
    return 'AIzaSyAPWau_f1LeAaDLfesK-tYtqfYwKTQ92d4';
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:manager_mobile_client/src/logic/core/location.dart';
import 'package:manager_mobile_client/src/logic/core/uuid.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

export 'package:manager_mobile_client/src/logic/core/location.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class PlacesSearchResult {
  String? id;
  String? description;
  PlacesSearchResult(this.id, this.description);
}

class PlacesDetailsResult {
  String? address;
  LatLng? coordinate;
  PlacesDetailsResult(this.address, this.coordinate);
}

class PlacesService {
  final String? sessionToken;
  final String? language;
  final String apiKey;

  PlacesService({this.sessionToken, this.language, required this.apiKey});

  /// Поиск мест по строке запроса (autocomplete)
  Future<List<PlacesSearchResult>> search(String searchString) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchString&key=$apiKey&language=$language&sessiontoken=$sessionToken");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == "OK") {
        return (data["predictions"] as List)
            .map((prediction) => PlacesSearchResult(
                prediction["place_id"], prediction["description"]))
            .toList();
      } else if (data["status"] == "ZERO_RESULTS") {
        return [];
      } else {
        print(data["error_message"]);
        throw RequestFailedException();
      }
    } else {
      throw RequestFailedException();
    }
  }

  /// Получение деталей места по `place_id`
  Future<PlacesDetailsResult> getDetails(
      PlacesSearchResult searchResult) async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=${searchResult.id}&key=$apiKey&language=$language&sessiontoken=$sessionToken");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == "OK") {
        final result = data["result"];
        final location = result["geometry"]["location"];
        return PlacesDetailsResult(
          result["formatted_address"],
          LatLng(location["lat"], location["lng"]),
        );
      } else {
        print(data["error_message"]);
        throw RequestFailedException();
      }
    } else {
      throw RequestFailedException();
    }
  }

  /// Получение адреса по координатам
  Future<PlacesDetailsResult> getAddress(LatLng coordinate) async {
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          coordinate.latitude, coordinate.longitude);

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks.first;
        return PlacesDetailsResult(
            "${place.street}, ${place.locality}, ${place.country}", coordinate);
      } else {
        throw RequestFailedException();
      }
    } catch (e) {
      print(e);
      throw RequestFailedException();
    }
  }

  /// Получение координат по адресу
  Future<PlacesDetailsResult> getCoordinate(String address) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        geo.Location location = locations.first;
        return PlacesDetailsResult(
            address, LatLng(location.latitude, location.longitude));
      } else {
        throw RequestFailedException();
      }
    } catch (e) {
      print(e);
      throw RequestFailedException();
    }
  }
}

PlacesService makeDefaultPlacesService() => PlacesService(
    sessionToken: Uuid().generateV4(), language: 'ru', apiKey: _getApiKey());

String _getApiKey() {
  if (Platform.isIOS) {
    return 'AIzaSyC6UWjJLfSWWOXrnTUfraCSQj5KUTKvhUU';
  } else {
    return 'AIzaSyAPWau_f1LeAaDLfesK-tYtqfYwKTQ92d4';
  }
}

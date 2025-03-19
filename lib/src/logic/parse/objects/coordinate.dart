import 'package:manager_mobile_client/src/logic/core/location.dart';
import 'package:manager_mobile_client/src/logic/core/safe_cast.dart';
import 'package:manager_mobile_client/src/logic/parse/constants.dart';

LatLng? coordinateFromJson(Map<String, dynamic>? json) {
  if (json == null) {
    return null;
  }
  final latitude = safeCast<num>(json['latitude']);
  final longitude = safeCast<num>(json['longitude']);
  if (latitude == null || longitude == null) {
    return null;
  }
  return LatLng(latitude.toDouble(), longitude.toDouble());
}

Map<String, dynamic>? jsonFromCoordinate(LatLng? coordinate) {
  if (coordinate == null) {
    return null;
  }
  return {
    typeKey: 'GeoPoint',
    'latitude': coordinate.latitude,
    'longitude': coordinate.longitude
  };
}

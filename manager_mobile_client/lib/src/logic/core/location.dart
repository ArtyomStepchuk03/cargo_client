import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

export 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

double radiansFromDegrees(double degrees) => degrees * pi / 180.0;
double degreesFromRadians(double radians) => radians * 180.0 / pi;

double getDistance(LatLng one, LatLng other) {
  if (one == other) {
    return 0;
  }

  double theta = one.longitude - other.longitude;

  double distance =
    sin(radiansFromDegrees(one.latitude)) * sin(radiansFromDegrees(other.latitude)) +
    cos(radiansFromDegrees(one.latitude)) * cos(radiansFromDegrees(other.latitude)) * cos(radiansFromDegrees(theta));

  distance = acos(distance);
  distance = degreesFromRadians(distance);
  return distance * 60 * 1.1515 * 1.609344 * 1000;
}

double getHeading(LatLng one, LatLng other) {
  double longitudeDelta = other.longitude - one.longitude;

  double y = sin(radiansFromDegrees(longitudeDelta)) * cos(radiansFromDegrees(other.latitude));

  double x =
    cos(radiansFromDegrees(one.latitude)) * sin(radiansFromDegrees(other.latitude)) -
    sin(radiansFromDegrees(one.latitude)) * cos(radiansFromDegrees(other.latitude)) * cos(radiansFromDegrees(longitudeDelta));

  double heading = atan2(y, x);
  if (heading < 0) {
      heading += 2 * pi;
  }

  return degreesFromRadians(heading);
}

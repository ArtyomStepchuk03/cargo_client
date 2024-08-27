import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLngBounds;
import 'location.dart';

export 'package:google_maps_flutter/google_maps_flutter.dart' show LatLngBounds;
export 'location.dart';

class LatLngSpan {
  final double latitudeSpan;
  final double longitudeSpan;
  const LatLngSpan(this.latitudeSpan, this.longitudeSpan);
}

extension LatLngBoundsUtility on LatLngBounds {
  LatLng get center {
    final latitude = southwest.latitude + (northeast.latitude - southwest.latitude) / 2;
    final longitude = southwest.longitude + (northeast.longitude - southwest.longitude) / 2;
    return LatLng(latitude, longitude);
  }

  LatLngSpan get span {
    return LatLngSpan(northeast.latitude - southwest.latitude, northeast.longitude - southwest.longitude);
  }

  static LatLngBounds fromCenterAndSpan(LatLng center, LatLngSpan span) {
    final southwest = LatLng(center.latitude - span.latitudeSpan / 2, center.longitude - span.longitudeSpan / 2);
    final northeast = LatLng(center.latitude + span.latitudeSpan / 2, center.longitude + span.longitudeSpan / 2);
    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  static LatLngBounds circumscribed(Iterable<LatLng> coordinates) {
    double south = 90;
    double north = -90;
    double west = 180;
    double east = -180;
    for (final coordinate in coordinates) {
      south = min(south, coordinate.latitude);
      north = max(north, coordinate.latitude);
      west = min(west, coordinate.longitude);
      east = max(east, coordinate.longitude);
    }
    return LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east));
  }

  bool containsBounds(LatLngBounds other) {
    return contains(other.southwest) && contains(other.northeast);
  }

  bool intersects(LatLngBounds other) {
    if (other.southwest.latitude >= northeast.latitude) {
      return false;
    }
    if (other.northeast.latitude <= southwest.latitude) {
      return false;
    }
    if (other.southwest.longitude >= northeast.longitude) {
      return false;
    }
    if (other.northeast.longitude <= southwest.longitude) {
      return false;
    }
    return true;
  }
}

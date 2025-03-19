import 'package:geohash_plus/geohash_plus.dart' as geohash_plus;
import 'package:manager_mobile_client/src/logic/core/algorithm.dart';
import 'package:manager_mobile_client/src/logic/core/location_bounds.dart';

import 'map_cluster.dart';

export 'map_cluster.dart';

class GeohashMapClusterItem<T> {
  final LatLng coordinate;
  final String geohash;
  final T value;

  factory GeohashMapClusterItem.encode(LatLng coordinate, T value) {
    return GeohashMapClusterItem._(
        coordinate,
        geohash_plus.GeoHash.encode(coordinate.latitude, coordinate.longitude,
                precision: _geohashLevelCount)
            .toString(),
        value);
  }

  GeohashMapClusterItem<T> toLevel(int level) {
    return GeohashMapClusterItem._(
        coordinate, geohash.substring(0, level), this.value);
  }

  GeohashMapClusterItem._(this.coordinate, this.geohash, this.value);
}

extension GeohashMapCluster<T> on List<GeohashMapClusterItem<T>> {
  List<MapCluster<T>> buildClusters(double? zoom) {
    final level = _getGeohashLevel(zoom!);
    var unprocessed = map((item) => item.toLevel(level)).toList();
    var clusters = <MapCluster<T>>[];

    while (unprocessed.length != 0) {
      final current = unprocessed[0];
      final nearest = unprocessed
          .removeAndReturnWhere((other) => other.geohash == current.geohash);
      final bounds = LatLngBoundsUtility.circumscribed(
          nearest.map((item) => item.coordinate));
      final center = bounds.center;
      clusters.add(
          MapCluster<T>(center, nearest.map((item) => item.value).toList()));
    }

    return clusters;
  }
}

bool shouldRebuildClusters(double previousZoom, double currentZoom) {
  return (currentZoom.truncate() - previousZoom.truncate()).abs() >= 1;
}

const _geohashLevelCount = 20;

int _getGeohashLevel(double zoom) {
  if (zoom <= 3) {
    return 1;
  } else if (zoom < 6) {
    return 2;
  } else if (zoom < 8) {
    return 3;
  } else if (zoom < 11) {
    return 4;
  } else if (zoom < 13) {
    return 5;
  } else if (zoom < 16) {
    return 7;
  }
  return _geohashLevelCount;
}

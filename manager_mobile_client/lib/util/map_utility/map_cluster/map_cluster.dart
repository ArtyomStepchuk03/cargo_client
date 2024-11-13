import 'package:manager_mobile_client/src/logic/core/location.dart';

class MapCluster<T> {
  final LatLng coordinate;
  final List<T> values;
  MapCluster(this.coordinate, this.values);
}

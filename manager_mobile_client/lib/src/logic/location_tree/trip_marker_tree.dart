import 'package:manager_mobile_client/src/logic/location_tree/location_tree.dart';
import 'package:manager_mobile_client/src/logic/location_tree/location_tree_build.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show Marker;

export 'package:manager_mobile_client/src/logic/location_tree/location_tree.dart';

class MarkerTreeItem implements LocationTreeItem {
  final Marker underlying;
  MarkerTreeItem(this.underlying);
  LatLng get coordinate => underlying.position;
}

Future<LocationTree<MarkerTreeItem>> buildTripMarkerTree(Set<Marker> markers) async {
  return buildLocationTree(markers.map((marker) => MarkerTreeItem(marker)), _targetSpan, _targetItemCount);
}

bool shouldUpdateMarkers(LatLng oldCoordinate, LatLng newCoordinate) {
  return (oldCoordinate.latitude - newCoordinate.latitude).abs() > 0.05 || (oldCoordinate.longitude - newCoordinate.longitude).abs() > 0.05;
}

Set<Marker> getMarkers(LocationTree<MarkerTreeItem> markerTree, LatLng coordinate) {
  final bounds = LatLngBoundsUtility.fromCenterAndSpan(coordinate, _requestSpan);
  final items = markerTree.itemsInBounds(bounds);
  return items.map((item) => item.underlying).toSet();
}

const _targetSpan = LatLngSpan(0.05, 0.05);
const _requestSpan = LatLngSpan(0.1, 0.1);
const _targetItemCount = 50;

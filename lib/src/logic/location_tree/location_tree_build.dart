import 'location_tree.dart';
import 'location_tree_node.dart';

Future<LocationTree<T>> buildLocationTree<T extends LocationTreeItem>(Iterable<T> items, LatLngSpan targetSpan, int targetItemCount) async {
  return Future(() {
    final bounds = LatLngBoundsUtility.circumscribed(items.map((item) => item.coordinate));
    final root = _buildLocationSubtreeSync(items, bounds, targetSpan, targetItemCount);
    return LocationTree<T>(bounds, root);
  });
}

LocationTreeNode<T> _buildLocationSubtreeSync<T extends LocationTreeItem>(Iterable<T> items, LatLngBounds bounds, LatLngSpan targetSpan, int targetItemCount) {
  final span = bounds.span;
  if (span.latitudeSpan <= targetSpan.latitudeSpan && span.longitudeSpan <= targetSpan.longitudeSpan || items.length <= targetItemCount) {
    return LocationTreeNode.leaf(items.toList());
  }

  final center = bounds.center;

  var southwestItems = <T>[];
  var northwestItems = <T>[];
  var northeastItems = <T>[];
  var southeastItems = <T>[];

  for (final item in items) {
    if (item.coordinate.latitude > center.latitude) {
      if (item.coordinate.longitude < center.longitude) {
        northwestItems.add(item);
      } else {
        northeastItems.add(item);
      }
    } else {
      if (item.coordinate.longitude < center.longitude) {
        southwestItems.add(item);
      } else {
        southeastItems.add(item);
      }
    }
  }

  final westCenter = LatLng(center.latitude, bounds.southwest.longitude);
  final eastCenter = LatLng(center.latitude, bounds.northeast.longitude);
  final southCenter = LatLng(bounds.southwest.latitude, center.longitude);
  final northCenter = LatLng(bounds.northeast.latitude, center.longitude);

  final southwestBounds = LatLngBounds(southwest: bounds.southwest, northeast: center);
  final northwestBounds = LatLngBounds(southwest: westCenter, northeast: northCenter);
  final northeastBounds = LatLngBounds(southwest: center, northeast: bounds.northeast);
  final southeastBounds = LatLngBounds(southwest: southCenter, northeast: eastCenter);

  final southwest = _buildLocationSubtreeSync(southwestItems, southwestBounds, targetSpan, targetItemCount);
  final northwest = _buildLocationSubtreeSync(northwestItems, northwestBounds, targetSpan, targetItemCount);
  final northeast = _buildLocationSubtreeSync(northeastItems, northeastBounds, targetSpan, targetItemCount);
  final southeast = _buildLocationSubtreeSync(southeastItems, southeastBounds, targetSpan, targetItemCount);

  return LocationTreeNode<T>(southwest, northwest, northeast, southeast);
}

import 'package:manager_mobile_client/src/logic/core/location_bounds.dart';
import 'location_tree_node.dart';

export 'package:manager_mobile_client/src/logic/core/location_bounds.dart';
export 'location_tree_item.dart';

class LocationTree<T extends LocationTreeItem> {
  final LatLngBounds bounds;
  final LocationTreeNode<T> root;

  LocationTree(this.bounds, this.root);

  List<T> itemsInBounds(LatLngBounds requestedBounds) {
    return _itemsInNode(requestedBounds, root, bounds);
  }

  static List<T> _itemsInNode<T extends LocationTreeItem>(LatLngBounds requestedBounds, LocationTreeNode<T> node, LatLngBounds nodeBounds) {
    if (node.items != null) {
      return node.items;
    }

    final center = nodeBounds.center;
    final westCenter = LatLng(center.latitude, nodeBounds.southwest.longitude);
    final eastCenter = LatLng(center.latitude, nodeBounds.northeast.longitude);
    final southCenter = LatLng(nodeBounds.southwest.latitude, center.longitude);
    final northCenter = LatLng(nodeBounds.northeast.latitude, center.longitude);

    final southwestBounds = LatLngBounds(southwest: nodeBounds.southwest, northeast: center);
    final northwestBounds = LatLngBounds(southwest: westCenter, northeast: northCenter);
    final northeastBounds = LatLngBounds(southwest: center, northeast: nodeBounds.northeast);
    final southeastBounds = LatLngBounds(southwest: southCenter, northeast: eastCenter);

    var items = <T>[];

    if (southwestBounds.intersects(requestedBounds)) {
      items.addAll(_itemsInNode(requestedBounds, node.southwest, southwestBounds));
    }
    if (northwestBounds.intersects(requestedBounds)) {
      items.addAll(_itemsInNode(requestedBounds, node.northwest, northwestBounds));
    }
    if (northeastBounds.intersects(requestedBounds)) {
      items.addAll(_itemsInNode(requestedBounds, node.northeast, northeastBounds));
    }
    if (southeastBounds.intersects(requestedBounds)) {
      items.addAll(_itemsInNode(requestedBounds, node.southeast, southeastBounds));
    }

    return items;
  }
}

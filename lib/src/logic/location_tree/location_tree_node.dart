import 'location_tree_item.dart';

export 'location_tree_item.dart';

class LocationTreeNode<T extends LocationTreeItem> {
  final List<T>? items;
  final LocationTreeNode<T>? southwest;
  final LocationTreeNode<T>? northwest;
  final LocationTreeNode<T>? northeast;
  final LocationTreeNode<T>? southeast;
  LocationTreeNode(
      this.southwest, this.northwest, this.northeast, this.southeast)
      : items = null;
  LocationTreeNode.leaf(this.items)
      : northwest = null,
        northeast = null,
        southeast = null,
        southwest = null;
}

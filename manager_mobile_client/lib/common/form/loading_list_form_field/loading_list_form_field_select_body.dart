import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';

typedef LoadingListFormFieldSelectCallback<T> = void Function(
    BuildContext context, T object);

class LoadingListFormFieldSelectBody<T> extends StatelessWidget {
  final DataSource<T> dataSource;
  final FilterPredicate<T> filterPredicate;
  final LoadingListViewBuilder<T> listViewBuilder;
  final VoidCallback onRefresh;
  final LoadingListFormFieldSelectCallback<T> onSelect;
  final Function(int index) onDelete;
  final Function(T item) onUpdate;
  final T selectedItem;

  LoadingListFormFieldSelectBody(
      {this.dataSource,
      this.filterPredicate,
      this.listViewBuilder,
      this.onRefresh,
      this.onSelect,
      this.onDelete,
      this.onUpdate,
      this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return LoadingListView<T>(
        dataSource: dataSource,
        filterPredicate: filterPredicate,
        builder: (BuildContext context, T object) =>
            _buildListTile(context, object),
        activityFooterTile: ActivityListFooterTile(),
        placeholderFooterTile: PlaceholderListFooterTile(),
        errorFooterTile: ErrorListFooterTile(),
        onRefresh: onRefresh,
        onDelete: onDelete,
        onUpdate: onUpdate,
        onSelect: _select,
        selectedItem: selectedItem);
  }

  Widget _buildListTile(BuildContext context, T object) {
    return listViewBuilder(context, object);
  }

  void _select(BuildContext context, T object) async {
    if (onSelect != null) {
      onSelect(context, object);
    } else {
      Navigator.pop(context, object);
    }
  }
}

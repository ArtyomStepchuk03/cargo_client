import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/common/loading_list_view/loading_list_view_status.dart';
import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
import 'package:manager_mobile_client/src/logic/data_source/data_source.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

export 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
export 'package:manager_mobile_client/src/logic/data_source/data_source.dart';

typedef LoadingListViewBuilder<T> = Widget Function(
    BuildContext context, T object);

class LoadingListView<T> extends StatefulWidget {
  final DataSource<T>? dataSource;
  final FilterPredicate<T?>? filterPredicate;
  final LoadingListViewBuilder<T?>? builder;
  final Widget? activityFooterTile;
  final Widget? placeholderFooterTile;
  final Widget? errorFooterTile;
  final bool? insetForFloatingActionButton;
  final VoidCallback? onRefresh;
  final Function(T? item)? onDelete;
  final Function(BuildContext context, T object)? onSelect;
  final Function(T? item)? onUpdate;
  final T? selectedItem;

  LoadingListView({
    Key? key,
    this.dataSource,
    this.filterPredicate,
    this.builder,
    this.activityFooterTile,
    this.placeholderFooterTile,
    this.errorFooterTile,
    this.insetForFloatingActionButton = false,
    this.onRefresh,
    this.onDelete,
    this.onUpdate,
    this.onSelect,
    this.selectedItem,
  }) : super(key: key);

  @override
  State createState() => LoadingListViewState<T>();
}

class LoadingListViewState<T> extends State<LoadingListView<T>> {
  void addItem(T item) {
    if (_totalItems!.isEmpty && _loading!) {
      return;
    }
    setState(() {
      final totalIndex = _totalItems?.indexOf(item);
      if (totalIndex == -1) {
        _totalItems?.insert(0, item);
      } else {
        _totalItems?[totalIndex!] = item;
      }
      if (_test(item)) {
        final index = _items.indexOf(item);
        if (index == -1) {
          _items.insert(0, item);
        } else {
          _items[index] = item;
        }
      }
    });
  }

  void removeItem(T? item) {
    setState(() {
      _totalItems!.remove(item);
      _items.remove(item);
    });
  }

  void updateItem(T item) {
    setState(() {
      final totalIndex = _totalItems?.indexOf(item);
      if (totalIndex != -1) _totalItems?[totalIndex!] = item;
      final index = _items.indexOf(item);
      if (index != -1) _items[index] = item;
    });
  }

  void setNeedReload() => setState(() => _reset());

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(LoadingListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dataSource != oldWidget.dataSource) {
      _reset();
    } else {
      _items = _filter(_totalItems!).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);

    return RefreshIndicator(
      child: ListView.builder(
        padding: EdgeInsets.all(4),
        itemCount: _items.length + 1,
        itemBuilder: (context, index) => InkWell(
          onTap: () async {
            await widget.onSelect!(context, _items[index]!);
            if (widget.onUpdate != null) {
              await widget.onUpdate!(_items[index]);
            }
          },
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: _buildItemWidget(context, index),
              ),
              if (widget.onDelete != null && index != _items.length)
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(localizationUtil.confirmDeleteContact),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(localizationUtil.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                try {
                                  final currentItem = _items[index];
                                  await widget.onDelete!(currentItem);
                                  removeItem(currentItem);
                                  if (currentItem == widget.selectedItem) {
                                    if (widget.onUpdate != null) {
                                      await widget.onUpdate!(_items[index]);
                                    }
                                  }
                                } catch (e) {
                                  _showExceptionDialog();
                                }
                              },
                              child: Text(localizationUtil.delete),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.black45,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      onRefresh: _refresh,
    );
  }

  static const int _limit = 10;

  List<T?>? _totalItems;
  late List<T?> _items;
  late LoadingListViewStatus _status;
  bool? _loading;

  Widget _buildItemWidget(BuildContext context, int index) {
    if (index == _items.length) {
      _loadNextPortionIfNeeded();
      return _buildFooterWidget(_buildFooterTile());
    }
    final item = _items[index];
    return widget.builder!(context, item);
  }

  Widget? _buildFooterTile() {
    if (_status.more) {
      return widget.activityFooterTile;
    }
    if (_status.failed) {
      return widget.errorFooterTile;
    }
    if (_items.isEmpty) {
      return widget.placeholderFooterTile;
    }
    return null;
  }

  Widget _buildFooterWidget(Widget? child) {
    if (child == null) {
      return buildFloatingActionButtonSpacer(
          widget.insetForFloatingActionButton);
    }
    return Column(children: [
      child,
      buildFloatingActionButtonSpacer(widget.insetForFloatingActionButton),
    ]);
  }

  Future<void> _refresh() async {
    if (widget.onRefresh == null) {
      await _loadPortion(widget.dataSource!, reload: true);
      return;
    }
    widget.onRefresh!();
  }

  void _reset() {
    _loading = false;
    _totalItems = [];
    _items = [];
    _status = LoadingListViewStatus.more(null);
  }

  void _loadNextPortionIfNeeded() {
    if (!_status.finished && !_loading!) {
      _loadPortion(widget.dataSource!);
    }
  }

  Future<void> _loadPortion(DataSource<T> dataSource,
      {bool reload = false}) async {
    try {
      _loading = true;
      final portionToken = reload ? null : _status.nextPortionToken;
      final portion = await dataSource.loadPortion(portionToken, _limit);
      if (mounted && dataSource == widget.dataSource) {
        _loading = false;
        setState(() {
          if (reload) {
            _totalItems = portion.items;
            _items = _filter(_totalItems!).toList();
          } else {
            _totalItems?.addAll(portion.items!);
            _items.addAll(_filter(portion.items!));
          }
          if (portion.finished == true) {
            _status = LoadingListViewStatus.finished();
          } else {
            _status = LoadingListViewStatus.more(portion.nextPortionToken);
          }
        });
      }
    } on Exception catch (exception) {
      if (mounted && dataSource == widget.dataSource) {
        setState(() {
          if (reload) {
            _totalItems = [];
            _items = [];
          }
          _status = LoadingListViewStatus.failed(exception);
        });
      }
    }
  }

  Iterable<T?> _filter(List<T?> items) {
    if (widget.filterPredicate == null) {
      return items;
    }
    return items.where(widget.filterPredicate!);
  }

  bool _test(T item) {
    if (widget.filterPredicate == null) {
      return true;
    }
    return widget.filterPredicate!(item);
  }

  void _showExceptionDialog() {
    final localizationUtil = LocalizationUtil.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationUtil.unableDeleteContact),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizationUtil.ok),
          ),
        ],
      ),
    );
  }
}

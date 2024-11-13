import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_card.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/carrier.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/types.dart';

export 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';
export 'package:manager_mobile_client/src/logic/server_api/carrier_server_api.dart';

class CarriagesListBody extends StatefulWidget {
  final FilterPredicate<Carrier> filterPredicate;
  final ItemTapCallback<Carrier> onTap;
  final bool selecting;
  final Carrier initialValue;
  final ItemSelectCallback<Carrier> onSelect;
  final bool insetForFloatingActionButton;

  CarriagesListBody({
    Key key,
    this.filterPredicate,
    this.onTap,
    this.selecting = false,
    this.initialValue,
    this.onSelect,
    this.insetForFloatingActionButton = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CarriagesListBodyState();
}

class CarriagesListBodyState extends State<CarriagesListBody> {
  void select(Carrier carrier) => setState(() => _selectedValue = carrier);

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingListView<Carrier>(
      dataSource: SkipPagedDataSourceAdapter(
          DependencyHolder.of(context).network.serverAPI.carriers),
      filterPredicate: widget.filterPredicate,
      builder: (BuildContext context, Carrier carrier) =>
          _buildCard(context, carrier),
      activityFooterTile: ActivityListFooterTile(),
      placeholderFooterTile: PlaceholderListFooterTile(),
      errorFooterTile: ErrorListFooterTile(),
      insetForFloatingActionButton: widget.insetForFloatingActionButton,
    );
  }

  Carrier _selectedValue;

  Widget _buildCard(BuildContext context, Carrier carrier) {
    final children = [
      ListCardField(value: short.formatCarrierSafe(context, carrier)),
    ];
    if (widget.selecting) {
      return SelectableListCard(
        children: children,
        checked: _selectedValue != null && carrier == _selectedValue,
        onTap: () => _select(carrier),
      );
    } else {
      return ListCard(
        children: children,
        onTap: widget.onTap != null ? () => widget.onTap(carrier) : null,
      );
    }
  }

  void _select(Carrier carrier) {
    if (_selectedValue == null || carrier.id != _selectedValue.id) {
      setState(() => _selectedValue = carrier);
      if (widget.onSelect != null) {
        widget.onSelect(carrier);
      }
    }
  }
}

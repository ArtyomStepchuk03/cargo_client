import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_card.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/util/format/format.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/format/transport_unit_status.dart';
import 'package:manager_mobile_client/util/format/vehicle_pass.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/types.dart';

import 'transport_unit_data_source.dart';

export 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';
export 'package:manager_mobile_client/src/logic/server_api/transport_unit_server_api.dart';

class TransportUnitListBody extends StatefulWidget {
  final TransportUnitStatus status;
  final Carrier carrier;
  final FilterPredicate<TransportUnit> filterPredicate;
  final ItemTapCallback<TransportUnit> onTap;
  final bool selecting;
  final ItemWidgetBuilder<TransportUnit> expandedBuilder;
  final TransportUnit initialValue;
  final ItemSelectCallback<TransportUnit> onSelect;
  final bool insetForFloatingActionButton;

  TransportUnitListBody({
    Key key,
    this.status,
    this.carrier,
    this.filterPredicate,
    this.onTap,
    this.selecting = false,
    this.expandedBuilder,
    this.initialValue,
    this.onSelect,
    this.insetForFloatingActionButton = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransportUnitListBodyState();
}

class TransportUnitListBodyState extends State<TransportUnitListBody> {
  void select(TransportUnit transportUnit) =>
      setState(() => _selectedValue = transportUnit);

  void addTransportUnit(TransportUnit transportUnit) =>
      _listViewKey.currentState.addItem(transportUnit);
  void removeTransportUnit(TransportUnit transportUnit) =>
      _listViewKey.currentState.removeItem(transportUnit);

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingListView(
      key: _listViewKey,
      dataSource: SkipPagedDataSourceAdapter(TransportUnitDataSource(
          DependencyHolder.of(context).network.serverAPI.transportUnits,
          widget.status,
          widget.carrier)),
      filterPredicate: widget.filterPredicate,
      builder: (BuildContext context, TransportUnit transportUnit) =>
          _buildCard(context, transportUnit),
      activityFooterTile: ActivityListFooterTile(),
      placeholderFooterTile: PlaceholderListFooterTile(),
      errorFooterTile: ErrorListFooterTile(),
      insetForFloatingActionButton: widget.insetForFloatingActionButton,
    );
  }

  final _listViewKey = GlobalKey<LoadingListViewState>();
  TransportUnit _selectedValue;
  TransportUnit _expandedValue;

  Widget _buildCard(BuildContext context, TransportUnit transportUnit) {
    final List<Widget> children = _buildChildren(transportUnit);
    if (widget.selecting) {
      return SelectableListCard(
        children: children,
        checked: _selectedValue != null && transportUnit == _selectedValue,
        onTap: () => _select(transportUnit),
      );
    } else {
      return ListCard(
        children: children,
        expandedWidget: widget.expandedBuilder != null &&
                _expandedValue != null &&
                transportUnit == _expandedValue
            ? widget.expandedBuilder(context, transportUnit)
            : null,
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap(transportUnit);
          } else if (widget.expandedBuilder != null) {
            setState(() {
              if (_expandedValue != null && _expandedValue == transportUnit) {
                _expandedValue = null;
              } else {
                _expandedValue = transportUnit;
              }
            });
          }
        },
      );
    }
  }

  List<Widget> _buildChildren(TransportUnit transportUnit) {
    final localizationUtil = LocalizationUtil.of(context);
    final List<Widget> children = [
      Row(children: [
        Expanded(
            flex: 2,
            child: ListCardField(
                name: localizationUtil.vehicleFullName,
                value: formatVehicleModelSafe(
                    context, transportUnit.vehicle?.model))),
        Expanded(
            flex: 1,
            child: ListCardField(
                name: localizationUtil.stateNumber,
                value: textOrEmpty(transportUnit.vehicle?.number))),
      ]),
      Row(children: [
        Expanded(
            flex: 2,
            child: ListCardField(
                name: localizationUtil.personName,
                value: short.formatDriverSafe(context, transportUnit.driver))),
        if (transportUnit.trailer != null)
          Expanded(
              flex: 1,
              child: ListCardField(
                  name: localizationUtil.trailerNumber,
                  value: textOrEmpty(transportUnit.trailer.number))),
      ]),
    ];
    if (transportUnit.vehicle?.passes != null &&
        transportUnit.vehicle.passes.length > 0) {
      transportUnit.vehicle.passes.forEach((element) {
        final passText = formatVehiclePassSafe(context, element);
        if (passText != null) {
          final passItem = ListCardField(
              name: localizationUtil.pass,
              value: passText,
              textColor: _getVehiclePassTextColor(element));
          children.add(passItem);
        }
      });
    }
    children.add(Row(children: [
      Expanded(
          flex: 2,
          child: ListCardField(
              name: localizationUtil.status,
              value: formatTransportUnitStatusSafe(
                  context, transportUnit.status))),
      Expanded(
          flex: 1,
          child: ListCardField(
              name: localizationUtil.tonnage,
              value: numberOrEmpty(transportUnit.vehicle?.tonnage))),
    ]));
    return children;
  }

  Color _getVehiclePassTextColor(VehiclePass vehiclePass) {
    if (vehiclePass.canceled != null && vehiclePass.canceled) {
      return Colors.red;
    }
    return Colors.green;
  }

  void _select(TransportUnit transportUnit) {
    if (_selectedValue == null || transportUnit.id != _selectedValue.id) {
      setState(() => _selectedValue = transportUnit);
      if (widget.onSelect != null) {
        widget.onSelect(transportUnit);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/button.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/floating_action_button.dart';
import 'package:manager_mobile_client/feature/auth_page/cubit/auth_cubit.dart';
import 'package:manager_mobile_client/feature/create_carriage_page/create_carriage_page.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/transport_unit/view/transport_unit_map_body.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/util/format/transport_unit_status.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/types.dart';

import '../view/transport_unit_list_body.dart';
import 'transport_unit_search/transport_unit_search.dart';

class TransportUnitTabWidget extends StatefulWidget {
  final User? user;
  final bool? selecting;
  final String? confirmButtonTitle;
  final ItemConfirmCallback<TransportUnit>? onConfirm;
  final Drawer? drawer;
  final TransitionBuilder? containerBuilder;

  TransportUnitTabWidget(
      {this.user,
      this.selecting = false,
      this.confirmButtonTitle,
      this.onConfirm,
      this.drawer,
      this.containerBuilder});

  factory TransportUnitTabWidget.main(
      {required BuildContext context,
      Drawer? drawer,
      TransitionBuilder? containerBuilder}) {
    final authorizationState = context.read<AuthCubit>().state;
    return TransportUnitTabWidget(
        user: authorizationState.user,
        drawer: drawer,
        containerBuilder: containerBuilder);
  }

  @override
  State<StatefulWidget> createState() => TransportUnitTabState();
}

class TransportUnitTabState extends State<TransportUnitTabWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.carriages),
        actions: _buildActions(context),
        bottom: TabBar(
          controller: _tabController,
          tabs: _buildTabs(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.8),
        ),
      ),
      drawer: widget.drawer,
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: _buildTabWidgets(context),
      ),
      floatingActionButton: _buildConfirmButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  final _listBodyKey = GlobalKey<TransportUnitListBodyState>();
  final _mapBodyKey = GlobalKey<TransportUnitMapBodyState>();
  TabController? _tabController;
  TransportUnitStatus? _status;
  TransportUnit? _transportUnitToShowOnMap;
  TransportUnit? _selectedValue;

  List<Widget> _buildActions(BuildContext context) {
    var actions = <Widget>[];
    final filterMenuButton = _buildFilterMenuButton(context);
    final searchButton = _buildSearchButton(context);
    final moreMenuButton = _buildMoreMenuButton(context);
    actions.add(filterMenuButton);
    actions.add(searchButton);
    if (moreMenuButton != null) {
      actions.add(moreMenuButton);
    }
    return actions;
  }

  PopupMenuButton _buildFilterMenuButton(BuildContext context) {
    final items = [
      _buildPopupMenuItem(null),
      _buildPopupMenuItem(TransportUnitStatus.working),
      _buildPopupMenuItem(TransportUnitStatus.ready),
      _buildPopupMenuItem(TransportUnitStatus.notReady),
    ];
    return PopupMenuButton<FilterValue<TransportUnitStatus>>(
      icon: Icon(Icons.filter_list),
      itemBuilder: (BuildContext context) => items,
      onSelected: (FilterValue<TransportUnitStatus> value) {
        setState(() => _status = value.underlying);
      },
    );
  }

  CheckedPopupMenuItem<FilterValue<TransportUnitStatus>> _buildPopupMenuItem(
      TransportUnitStatus? status) {
    final localizationUtil = LocalizationUtil.of(context);
    return CheckedPopupMenuItem<FilterValue<TransportUnitStatus>>(
      value: FilterValue<TransportUnitStatus>(status),
      checked: status == _status,
      child: Text(status != null
          ? formatTransportUnitStatus(context, status)!
          : localizationUtil.all),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        final searchListBodyKey = GlobalKey<TransportUnitListBodyState>();
        showTransportUnitSearch(
          context: context,
          listBodyKey: searchListBodyKey,
          status: _status,
          carrier: widget.user?.carrier,
          onTap: widget.selecting == true
              ? (TransportUnit? transportUnit) {
                  Navigator.pop(context);
                  if (_listBodyKey.currentState != null) {
                    _listBodyKey.currentState!.select(transportUnit);
                  }
                  if (_mapBodyKey.currentState != null) {
                    _mapBodyKey.currentState!.select(transportUnit);
                  }
                  setState(() => _selectedValue = transportUnit);
                }
              : null,
          expandedBuilder: widget.selecting == false
              ? (BuildContext context, TransportUnit? item) =>
                  _buildListBodyExpandedWidget(
                    context: context,
                    onDisband: () async {
                      bool disbanded = await _disband(context, item);
                      if (!disbanded) {
                        return;
                      }
                      searchListBodyKey.currentState?.removeTransportUnit(item);
                      if (_listBodyKey.currentState != null) {
                        _listBodyKey.currentState!.removeTransportUnit(item);
                      }
                    },
                    onShowOnMap: item?.coordinate != null
                        ? () {
                            Navigator.pop(context);
                            if (_tabController?.index == 0) {
                              _transportUnitToShowOnMap = item;
                              _tabController?.index = 1;
                            } else {
                              _mapBodyKey.currentState!
                                  .select(item, centerInView: true);
                            }
                          }
                        : null,
                  )
              : null,
        );
      },
    );
  }

  PopupMenuButton? _buildMoreMenuButton(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    if (widget.user?.canAddTransportUnits() == false) {
      return null;
    }

    var items = <PopupMenuItem<GestureTapCallback>>[];
    items.add(PopupMenuItem<GestureTapCallback>(
        value: () => _showAddWidget(context),
        child: Text(localizationUtil.createCarriage)));

    return PopupMenuButton<GestureTapCallback>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => items,
      onSelected: (GestureTapCallback action) => action(),
    );
  }

  bool _needsConfirmButton() =>
      widget.selecting == true &&
      widget.confirmButtonTitle != null &&
      widget.onConfirm != null &&
      _selectedValue != null;

  Widget? _buildConfirmButton(context) {
    if (!_needsConfirmButton()) {
      return null;
    }
    return buildFloatingActionButtonContainer(
      child: FloatingActionButton.extended(
        icon: Container(),
        label: Text(widget.confirmButtonTitle!),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => widget.onConfirm!(_selectedValue!),
      ),
    );
  }

  void _showAddWidget(BuildContext context) async {
    final transportUnit = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              CreateCarriagePage(user: widget.user),
          fullscreenDialog: true,
        ));
    if (transportUnit != null) {
      if (_listBodyKey.currentState != null) {
        _listBodyKey.currentState!.addTransportUnit(transportUnit);
        if (widget.selecting == true) {
          _listBodyKey.currentState?.select(transportUnit);
          setState(() => _selectedValue = transportUnit);
        }
      }
    }
  }

  List<Widget> _buildTabWidgets(BuildContext context) {
    return [
      _buildContainer(context, _buildListBody()),
      _buildContainer(context, _buildMapBody()),
    ];
  }

  Widget _buildListBody() {
    return TransportUnitListBody(
      key: _listBodyKey,
      status: _status,
      carrier: widget.user?.carrier,
      expandedBuilder: (BuildContext context, TransportUnit? item) =>
          _buildListBodyExpandedWidget(
        context: context,
        onDisband: () async {
          bool disbanded = await _disband(context, item);
          if (!disbanded) {
            return;
          }
          _listBodyKey.currentState?.removeTransportUnit(item);
        },
        onShowOnMap: item?.coordinate != null
            ? () {
                _transportUnitToShowOnMap = item;
                _tabController?.index = 1;
              }
            : null,
      ),
      selecting: widget.selecting,
      initialValue: _selectedValue,
      onSelect: (TransportUnit? transportUnit) {
        if (_mapBodyKey.currentState != null) {
          _mapBodyKey.currentState!.select(transportUnit);
        }
        setState(() => _selectedValue = transportUnit);
      },
      insetForFloatingActionButton: _needsConfirmButton(),
    );
  }

  Widget _buildMapBody() {
    return TransportUnitMapBody(
      key: _mapBodyKey,
      status: _status,
      carrier: widget.user?.carrier,
      onCreated: () {
        if (_transportUnitToShowOnMap != null) {
          _mapBodyKey.currentState!
              .select(_transportUnitToShowOnMap!, centerInView: true);
          _transportUnitToShowOnMap = null;
        }
      },
      selecting: widget.selecting,
      initialValue: _selectedValue,
      onSelect: (TransportUnit transportUnit) {
        if (_listBodyKey.currentState != null) {
          _listBodyKey.currentState!.select(transportUnit);
        }
        setState(() => _selectedValue = transportUnit);
      },
    );
  }

  Widget _buildListBodyExpandedWidget(
      {required BuildContext context,
      VoidCallback? onDisband,
      VoidCallback? onShowOnMap}) {
    final localizationUtil = LocalizationUtil.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            children: [
              _buildCardButton(
                  child: Text(localizationUtil.disband),
                  color: Colors.red,
                  onPressed: onDisband),
              _buildCardButton(
                  child: Text(localizationUtil.showOnMap),
                  color: Theme.of(context).primaryColor,
                  onPressed: onShowOnMap),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCardButton(
      {VoidCallback? onPressed, Color? color, required Widget child}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateColorUtility.allExceptDisabled(color),
        elevation: WidgetStateProperty.all(0),
      ),
      child: child,
    );
  }

  Future<bool> _disband(
      BuildContext context, TransportUnit? transportUnit) async {
    final localizationUtil = LocalizationUtil.of(context);
    final confirmed =
        await showQuestionDialog(context, localizationUtil.confirmDisband);
    if (!confirmed) {
      return false;
    }
    showDefaultActivityDialog(context);
    final serverAPI =
        DependencyHolder.of(context)!.network.serverAPI.transportUnits;
    try {
      await serverAPI.disband(transportUnit);
      Navigator.pop(context);
      return true;
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
      return false;
    }
  }

  List<Tab> _buildTabs() {
    final localizationUtil = LocalizationUtil.of(context);
    return [
      Tab(text: localizationUtil.list),
      Tab(text: localizationUtil.showOnMap),
    ];
  }

  Widget _buildContainer(BuildContext context, Widget child) {
    if (widget.containerBuilder != null) {
      return widget.containerBuilder!(context, child);
    }
    return child;
  }
}

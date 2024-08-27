import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/split_widget.dart';
import 'package:manager_mobile_client/src/ui/common/split_builder.dart';
import 'package:manager_mobile_client/src/ui/authorization/authorization_widget.dart';
import 'package:manager_mobile_client/src/ui/message/message_list_widget.dart';

import 'package:manager_mobile_client/src/ui/reservation/reservation_list_factory.dart';
import 'package:manager_mobile_client/src/ui/order/order_list_widget.dart';
import 'package:manager_mobile_client/src/ui/customer/customer_list_widget.dart';
import 'package:manager_mobile_client/src/ui/supplier/supplier_list_widget.dart';
import 'package:manager_mobile_client/src/ui/transport_unit/transport_unit_tab_widget.dart';
import 'package:manager_mobile_client/src/ui/customer/customer_details/customer_my_data_widget.dart';

import 'main_menu/main_menu_widget.dart';
import 'main_screen.dart';
import 'push_notification_widget.dart';
import 'reachability_watch_widget.dart';

class MainWidget extends StatefulWidget {
  static MainState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MainScopeWidget>().state;
  }

  @override
  State createState() => MainState();
}

class MainState extends State<MainWidget> {
  void menuItemSelected() {
    if (!_split) {
      Navigator.pop(context);
    }
  }

  MainScreen get screen => _screen;
  set screen(MainScreen screen) => setState(() => _screen = screen);

  @override
  void didChangeDependencies() {
    if (_screen == null) {
      final user = AuthorizationWidget.of(context).user;
      _screen = buildMainScreens(user).first;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _MainScopeWidget(
      state: this,
      child: _buildContent(),
    );
  }

  bool _split;
  MainScreen _screen;

  Widget _buildContent() {
    return SplitBuilder(
      builder: (BuildContext context, bool split) {
        _split = split;
        if (_split) {
          return SplitWidget(
            leftChild: _buildMenu(),
            rightChild: _buildCurrentScreen(context),
          );
        } else {
          return _buildCurrentScreen(context, Drawer(
            child: _buildMenu())
          );
        }
      },
    );
  }

  Widget _buildCurrentScreen(BuildContext context, [Drawer drawer]) {
    return _buildScreen(
      context: context,
      screen: _screen,
      drawer: drawer,
      containerBuilder: (BuildContext context, Widget child) {
        return PushNotificationWidget(child: ReachabilityWatchWidget(child: child));
      }
    );
  }

  Widget _buildMenu() {
    return MainMenuWidget();
  }

  Widget _buildScreen({BuildContext context, MainScreen screen, Drawer drawer, TransitionBuilder containerBuilder}) {
    switch (screen) {
      case MainScreen.reservations: return ReservationListFactory.build(context, drawer, containerBuilder);
      case MainScreen.orders: return OrderListWidget(drawer, containerBuilder);
      case MainScreen.customers: return CustomerListWidget(drawer, containerBuilder);
      case MainScreen.suppliers: return SupplierListWidget(drawer, containerBuilder);
      case MainScreen.transportUnits: return TransportUnitTabWidget.main(context: context, drawer: drawer, containerBuilder: containerBuilder);
      case MainScreen.messages: return MessageListWidget(drawer, containerBuilder);
      case MainScreen.myData: return CustomerMyDataWidget(drawer, containerBuilder);
    }
    return null;
  }
}

class _MainScopeWidget extends InheritedWidget {
  final MainState state;

  const _MainScopeWidget({this.state, Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_MainScopeWidget old) => state.screen != old.state.screen;
}

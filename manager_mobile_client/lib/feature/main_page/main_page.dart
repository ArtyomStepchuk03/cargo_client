import 'package:flutter/material.dart';
import 'package:manager_mobile_client/feature/customer_page/view/customer_page.dart';
import 'package:manager_mobile_client/feature/customer_page/widget/customer_details/customer_my_data_widget.dart';
import 'package:manager_mobile_client/feature/messages_page/view/messages_page.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_page.dart';
import 'package:manager_mobile_client/feature/reservation_page/view/reservation_list_factory.dart';
import 'package:manager_mobile_client/feature/supplier_page/view/supplier_page.dart';
import 'package:manager_mobile_client/feature/transport_unit/widget/transport_unit_tab_widget.dart';

import 'main_menu/main_menu_widget.dart';
import 'main_screen.dart';
import 'push_notification_widget.dart';
import 'reachability_watch_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage(this.screen, {Key key}) : super(key: key);

  final MainScreen screen;

  @override
  State createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    return _buildCurrentScreen(
      context,
      Drawer(
        child: _buildMenu(),
      ),
    );
  }

  Widget _buildCurrentScreen(BuildContext context, [Drawer drawer]) {
    return _buildScreen(
      context: context,
      screen: widget.screen,
      drawer: drawer,
      containerBuilder: (BuildContext context, Widget child) =>
          PushNotificationWidget(
        child: ReachabilityWatchWidget(child: child),
      ),
    );
  }

  Widget _buildMenu() => MainMenuWidget();

  Widget _buildScreen(
      {BuildContext context,
      MainScreen screen,
      Drawer drawer,
      TransitionBuilder containerBuilder}) {
    switch (screen) {
      case MainScreen.reservations:
        return ReservationListFactory.build(context, drawer, containerBuilder);
      case MainScreen.orders:
        return OrderPage(drawer, containerBuilder);
      case MainScreen.customers:
        return CustomerListWidget(drawer, containerBuilder);
      case MainScreen.suppliers:
        return SupplierPage(drawer, containerBuilder);
      case MainScreen.transportUnits:
        return TransportUnitTabWidget.main(
            context: context,
            drawer: drawer,
            containerBuilder: containerBuilder);
      case MainScreen.messages:
        return MessagesPage(drawer, containerBuilder);
      case MainScreen.myData:
        return CustomerMyDataWidget(drawer, containerBuilder);
    }
    return null;
  }
}

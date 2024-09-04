import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/authorization/authorization_widget.dart';
import 'package:manager_mobile_client/src/ui/customer/customer_details/customer_my_data_strings.dart'
    as customer_my_data_strings;
import 'package:manager_mobile_client/src/ui/customer/customer_list_strings.dart'
    as customer_list_strings;
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/main/main_screen.dart';
import 'package:manager_mobile_client/src/ui/main/main_widget.dart';
import 'package:manager_mobile_client/src/ui/message/message_list_strings.dart'
    as message_list_strings;
import 'package:manager_mobile_client/src/ui/order/order_list_strings.dart'
    as order_list_strings;
import 'package:manager_mobile_client/src/ui/reservation/reservation_list_strings.dart'
    as reservation_list_strings;
import 'package:manager_mobile_client/src/ui/supplier/supplier_list_strings.dart'
    as supplier_list_strings;
import 'package:manager_mobile_client/src/ui/transport_unit/transport_unit_tab_strings.dart'
    as transport_unit_tab_strings;

import '../../utility/image.dart';
import 'main_menu_strings.dart' as strings;

class MainMenuWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: _buildItems(context),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authorizationState = AuthorizationWidget.of(context);
    return Material(
      elevation: 4.0,
      child: UserAccountsDrawerHeader(
        decoration:
            BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
        margin: EdgeInsets.zero,
        accountName: Text(authorizationState.userTitle),
        accountEmail: null,
        currentAccountPicture: FittedBox(
          fit: BoxFit.fill,
          child: ImageUtility.named('menu/logo'),
        ),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final user = AuthorizationWidget.of(context).user;
    return [
      ...buildMainScreens(user)
          .map((screen) => _buildItemForScreen(context, screen)),
      _buildItem(
          context: context,
          icon: Icons.exit_to_app,
          title: strings.logOut,
          onTap: () => _logOut(context)),
    ];
  }

  Widget _buildItemForScreen(BuildContext context, MainScreen mainScreen) {
    switch (mainScreen) {
      case MainScreen.reservations:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.table_view,
          title: reservation_list_strings.title,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.orders:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.departure_board,
          title: order_list_strings.title,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.customers:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.assignment_ind,
          title: customer_list_strings.title,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.suppliers:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.warehouse,
          title: supplier_list_strings.title,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.transportUnits:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.people,
          title: transport_unit_tab_strings.title,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.messages:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.message,
          title: message_list_strings.title,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.myData:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.account_circle,
          title: customer_my_data_strings.title,
          onTap: () => _showScreen(context, mainScreen),
        );
    }
    return null;
  }

  Widget _buildItem({
    BuildContext context,
    MainScreen mainScreen,
    IconData icon,
    String title,
    VoidCallback onTap,
  }) {
    final mainState = MainWidget.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: mainScreen != null && mainState.screen == mainScreen,
      onTap: onTap,
    );
  }

  void _showScreen(BuildContext context, MainScreen mainScreen) {
    final mainState = MainWidget.of(context);
    mainState.menuItemSelected();
    mainState.screen = mainScreen;
  }

  void _logOut(BuildContext context) async {
    final dependencyState = DependencyHolder.of(context);
    final authorizationState = AuthorizationWidget.of(context);

    final serverManager = dependencyState.network.serverManager;
    final installationManager = dependencyState.network.installationManager;
    final userManager = dependencyState.network.userManager;

    MainWidget.of(context).menuItemSelected();
    authorizationState.setLoading();

    await installationManager.detachUser();
    try {
      serverManager.liveQueryManager.disconnect();
      await userManager.logOut();
      await serverManager.unsetConfiguration();

      authorizationState.setUnauthorized();
    } on Exception {
      authorizationState.setErrored();
    }
  }
}

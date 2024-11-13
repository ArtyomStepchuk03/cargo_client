import 'package:flutter/material.dart';
import 'package:manager_mobile_client/feature/auth_page/auth_page.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/main_page/main_screen.dart';
import 'package:manager_mobile_client/feature/main_page/main_widget.dart';
import 'package:manager_mobile_client/util/image.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

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
    final authorizationState = AuthPage.of(context);
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
    final localizationUtil = LocalizationUtil.of(context);
    final user = AuthPage.of(context).user;
    return [
      ...buildMainScreens(user)
          .map((screen) => _buildItemForScreen(context, screen)),
      _buildItem(
          context: context,
          icon: Icons.exit_to_app,
          title: localizationUtil.logOut,
          onTap: () => _logOut(context)),
    ];
  }

  Widget _buildItemForScreen(BuildContext context, MainScreen mainScreen) {
    final localizationUtil = LocalizationUtil.of(context);
    switch (mainScreen) {
      case MainScreen.reservations:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.table_view,
          title: localizationUtil.requests,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.orders:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.departure_board,
          title: localizationUtil.order,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.customers:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.assignment_ind,
          title: localizationUtil.customers,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.suppliers:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.warehouse,
          title: localizationUtil.suppliers,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.transportUnits:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.people,
          title: localizationUtil.carriages,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.messages:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.message,
          title: localizationUtil.messages,
          onTap: () => _showScreen(context, mainScreen),
        );
      case MainScreen.myData:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.account_circle,
          title: localizationUtil.myDetails,
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
    final authorizationState = AuthPage.of(context);

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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_mobile_client/feature/auth_page/cubit/auth_cubit.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/main_page/main_screen.dart';
import 'package:manager_mobile_client/util/format/user.dart';
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
    final authorizationState = context.read<AuthCubit>().state;
    return Material(
      elevation: 4.0,
      child: UserAccountsDrawerHeader(
        decoration:
            BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
        margin: EdgeInsets.zero,
        accountName: Text(formatUserSafe(context, authorizationState.user)),
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
    final user = context.read<AuthCubit>().state.user;
    return [
      ...buildMainScreens(user!)
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
          onTap: () => context.go('/reservations'),
        );
      case MainScreen.orders:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.departure_board,
          title: localizationUtil.order,
          onTap: () => context.go('/orders'),
        );
      case MainScreen.customers:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.assignment_ind,
          title: localizationUtil.customers,
          onTap: () => context.go('/customers'),
        );
      case MainScreen.suppliers:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.warehouse,
          title: localizationUtil.suppliers,
          onTap: () => context.go('/suppliers'),
        );
      case MainScreen.transportUnits:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.people,
          title: localizationUtil.carriages,
          onTap: () => context.go('/transportUnits'),
        );
      case MainScreen.messages:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.message,
          title: localizationUtil.messages,
          onTap: () => context.go('/messages'),
        );
      case MainScreen.myData:
        return _buildItem(
          context: context,
          mainScreen: mainScreen,
          icon: Icons.account_circle,
          title: localizationUtil.myDetails,
          onTap: () => context.go('/myData'),
        );
    }
  }

  Widget _buildItem({
    required BuildContext context,
    MainScreen? mainScreen,
    IconData? icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: mainScreen != null &&
          GoRouterState.of(context).path!.contains(mainScreen.name),
      onTap: onTap,
    );
  }

  void _logOut(BuildContext context) async {
    final dependencyState = DependencyHolder.of(context);
    final authorizationState = context.read<AuthCubit>();

    final serverManager = dependencyState?.network.serverManager;
    final installationManager = dependencyState?.network.installationManager;
    final userManager = dependencyState?.network.userManager;

    authorizationState.setLoading();

    await installationManager?.detachUser();
    try {
      serverManager?.liveQueryManager?.disconnect();
      await userManager?.logOut();
      await serverManager?.unsetConfiguration();

      authorizationState.setUnauthorized();
    } on Exception {
      authorizationState.setError();
    }

    context.go('/auth');
  }
}

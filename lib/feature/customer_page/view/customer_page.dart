import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/feature/auth_page/cubit/auth_cubit.dart';
import 'package:manager_mobile_client/feature/customer_page/customer_data_source.dart';
import 'package:manager_mobile_client/feature/customer_page/widget/customer_add/customer_add_widget.dart';
import 'package:manager_mobile_client/feature/customer_page/widget/customer_search/customer_search.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'customer_list_body.dart';

class CustomerListWidget extends StatelessWidget {
  CustomerListWidget(this.drawer, this.containerBuilder);

  final Drawer? drawer;
  final TransitionBuilder? containerBuilder;
  final _listViewKey = GlobalKey<LoadingListViewState>();

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    final authorizationState = context.read<AuthCubit>().state;
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.customers),
        actions: _buildActions(context),
      ),
      drawer: drawer,
      body: containerBuilder!(
          context, CustomerListBody(manager: authorizationState.user?.manager)),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    var actions = <Widget>[];
    final searchButton = _buildSearchButton(context);
    final moreMenuButton = _buildMoreMenuButton(context);
    actions.add(searchButton);
    if (moreMenuButton != null) {
      actions.add(moreMenuButton);
    }
    return actions;
  }

  Widget _buildSearchButton(BuildContext context) {
    final authorizationState = context.read<AuthCubit>().state;
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        showCustomerSearch(
            context: context, manager: authorizationState.user?.manager);
      },
    );
  }

  PopupMenuButton? _buildMoreMenuButton(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    final authorizationState = context.read<AuthCubit>().state;
    if (authorizationState.user!.canAddCustomers() == false) {
      return null;
    }
    final items = [
      PopupMenuItem<GestureTapCallback>(
          value: () => _showAddWidget(context),
          child: Text(localizationUtil.newCustomer))
    ];
    return PopupMenuButton<GestureTapCallback>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => items,
      onSelected: (GestureTapCallback action) => action(),
    );
  }

  void _showAddWidget(BuildContext context) async {
    final authorizationState = context.read<AuthCubit>().state;
    final customer = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              CustomerAddWidget(manager: authorizationState.user?.manager),
          fullscreenDialog: true,
        ));
    if (customer != null) {
      addCustomer(customer);
    }
  }

  void addCustomer(Customer customer) =>
      _listViewKey.currentState?.addItem(customer);
}

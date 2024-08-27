import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/ui/authorization/authorization_widget.dart';
import '../common/app_bar.dart';
import 'customer_search/customer_search.dart';
import 'customer_add/customer_add_widget.dart';
import 'customer_add/customer_add_strings.dart' as customer_add_strings;
import 'customer_list_body.dart';
import 'customer_list_strings.dart' as strings;

class CustomerListWidget extends StatefulWidget {
  final Drawer drawer;
  final TransitionBuilder containerBuilder;

  CustomerListWidget(this.drawer, this.containerBuilder);

  @override
  State<StatefulWidget> createState() => CustomerListState();
}

class CustomerListState extends State<CustomerListWidget> {
  @override
  Widget build(BuildContext context) {
    final authorizationState = AuthorizationWidget.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      drawer: widget.drawer,
      body: widget.containerBuilder(context, CustomerListBody(key: _bodyKey, manager: authorizationState.user.manager)),
    );
  }

  final _bodyKey = GlobalKey<CustomerListBodyState>();

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
    final authorizationState = AuthorizationWidget.of(context);
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        showCustomerSearch(context: context, manager: authorizationState.user.manager);
      },
    );
  }

  PopupMenuButton _buildMoreMenuButton(BuildContext context) {
    final authorizationState = AuthorizationWidget.of(context);
    if (!authorizationState.user.canAddCustomers()) {
      return null;
    }
    final items = [
      PopupMenuItem<GestureTapCallback>(value: () => _showAddWidget(context), child: Text(customer_add_strings.title))
    ];
    return PopupMenuButton<GestureTapCallback>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => items,
      onSelected: (GestureTapCallback action) => action(),
    );
  }

  void _showAddWidget(BuildContext context) async {
    final authorizationState = AuthorizationWidget.of(context);
    final customer = await Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => CustomerAddWidget(manager: authorizationState.user.manager),
      fullscreenDialog: true,
    ));
    if (customer != null) {
      _bodyKey.currentState.addCustomer(customer);
    }
  }
}

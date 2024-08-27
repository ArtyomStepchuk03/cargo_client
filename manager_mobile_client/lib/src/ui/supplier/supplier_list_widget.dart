import 'package:flutter/material.dart';
import 'supplier_search/supplier_search.dart';
import 'supplier_list_body.dart';
import 'supplier_list_strings.dart' as strings;

class SupplierListWidget extends StatelessWidget {
  final Drawer drawer;
  final TransitionBuilder containerBuilder;

  SupplierListWidget(this.drawer, this.containerBuilder);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      drawer: drawer,
      body: containerBuilder(context, SupplierListBody()),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [_buildSearchButton(context)];
  }

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        showSupplierSearch(context: context);
      },
    );
  }
}

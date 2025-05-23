import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/feature/supplier_page/widget/supplier_search/supplier_search.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'supplier_list_body.dart';

class SupplierPage extends StatelessWidget {
  final Drawer? drawer;
  final TransitionBuilder? containerBuilder;

  SupplierPage(this.drawer, this.containerBuilder);

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.suppliers),
        actions: [_buildSearchButton(context)],
      ),
      drawer: drawer,
      body: containerBuilder!(context, SupplierListBody()),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () => showSupplierSearch(context: context),
    );
  }
}

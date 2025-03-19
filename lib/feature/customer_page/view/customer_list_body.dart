import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/color.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_card.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';
import 'package:manager_mobile_client/feature/customer_page/widget/customer_details/customer_details_widget.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';

import '../customer_data_source.dart';

export 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';

class CustomerListBody extends StatelessWidget {
  CustomerListBody({Key? key, this.manager, this.filterPredicate})
      : super(key: key);

  final Manager? manager;
  final FilterPredicate<Customer>? filterPredicate;
  final _listViewKey = GlobalKey<LoadingListViewState>();

  @override
  Widget build(BuildContext context) {
    return LoadingListView(
      key: _listViewKey,
      dataSource: SkipPagedDataSourceAdapter(
        CustomerDataSource(
            serverAPI:
                DependencyHolder.of(context)!.network.serverAPI.customers,
            manager: manager),
      ),
      filterPredicate: filterPredicate,
      builder: (BuildContext context, Customer? customer) =>
          _buildCard(context, customer),
      activityFooterTile: ActivityListFooterTile(),
      placeholderFooterTile: PlaceholderListFooterTile(),
      errorFooterTile: ErrorListFooterTile(),
    );
  }

  Widget _buildCard(BuildContext context, Customer? customer) {
    final localizationUtil = LocalizationUtil.of(context);
    return ListCard(
      backgroundColor: customer?.deleted == true
          ? CommonColors.deletedBackground
          : Colors.white,
      children: [
        ListCardField(value: short.formatCustomerSafe(context, customer)),
        ListCardField(
            name: localizationUtil.itn, value: textOrEmpty(customer?.itn)),
      ],
      onTap: () => _showDetails(context, customer),
    );
  }

  void _showDetails(BuildContext context, Customer? customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) =>
            CustomerDetailsWidget(customer: customer),
      ),
    );
  }
}

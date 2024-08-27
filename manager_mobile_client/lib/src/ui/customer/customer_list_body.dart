import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/ui/common/color.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_card.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/loading_list_view.dart';
import 'package:manager_mobile_client/src/ui/format/safe_format.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'customer_details/customer_details_widget.dart';
import 'customer_list_strings.dart' as strings;
import 'customer_data_source.dart';

export 'package:manager_mobile_client/src/ui/common/loading_list_view/loading_list_view.dart';

class CustomerListBody extends StatefulWidget {
  final Manager manager;
  final FilterPredicate<Customer> filterPredicate;

  CustomerListBody({Key key, this.manager, this.filterPredicate}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CustomerListBodyState();
}

class CustomerListBodyState extends State<CustomerListBody> {
  void addCustomer(Customer customer) => _listViewKey.currentState.addItem(customer);

  @override
  Widget build(BuildContext context) {
    return LoadingListView(
      key: _listViewKey,
      dataSource: SkipPagedDataSourceAdapter(CustomerDataSource(serverAPI: DependencyHolder.of(context).network.serverAPI.customers, manager: widget.manager)),
      filterPredicate: widget.filterPredicate,
      builder: (BuildContext context, Customer customer) {
        return _buildCard(context, customer);
      },
      activityFooterTile: ActivityListFooterTile(),
      placeholderFooterTile: PlaceholderListFooterTile(),
      errorFooterTile: ErrorListFooterTile(),
    );
  }

  final _listViewKey = GlobalKey<LoadingListViewState>();

  Widget _buildCard(BuildContext context, Customer customer) {
    return ListCard(
      backgroundColor: customer.deleted ? CommonColors.deletedBackground : Colors.white,
      children: [
        ListCardField(value: short.formatCustomerSafe(customer)),
        ListCardField(name: strings.itn, value: textOrEmpty(customer.itn)),
      ],
      onTap: () => _showDetails(context, customer),
    );
  }

  void _showDetails(BuildContext context, Customer customer) {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => CustomerDetailsWidget(customer: customer),
    ));
  }
}

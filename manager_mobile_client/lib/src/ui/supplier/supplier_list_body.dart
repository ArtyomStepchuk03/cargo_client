import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/ui/common/color.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_card.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/loading_list_view.dart';
import 'package:manager_mobile_client/src/ui/format/safe_format.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'supplier_details/supplier_details_widget.dart';
import 'supplier_list_strings.dart' as strings;
import 'supplier_data_source.dart';

export 'package:manager_mobile_client/src/ui/common/loading_list_view/loading_list_view.dart';

class SupplierListBody extends StatelessWidget {
  final FilterPredicate<Supplier> filterPredicate;

  SupplierListBody({Key key, this.filterPredicate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingListView(
      dataSource: SkipPagedDataSourceAdapter(SupplierDataSource(serverAPI: DependencyHolder.of(context).network.serverAPI.suppliers)),
      filterPredicate: filterPredicate,
      builder: (BuildContext context, Supplier supplier) {
        return _buildCard(context, supplier);
      },
      activityFooterTile: ActivityListFooterTile(),
      placeholderFooterTile: PlaceholderListFooterTile(),
      errorFooterTile: ErrorListFooterTile(),
    );
  }

  Widget _buildCard(BuildContext context, Supplier supplier) {
    return ListCard(
      backgroundColor: supplier.deleted ? CommonColors.deletedBackground : Colors.white,
      children: [
        ListCardField(value: short.formatSupplierSafe(supplier)),
        ListCardField(name: strings.itn, value: textOrEmpty(supplier.itn)),
      ],
      onTap: () => _showDetails(context, supplier),
    );
  }

  void _showDetails(BuildContext context, Supplier supplier) {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => SupplierDetailsWidget(supplier: supplier),
    ));
  }
}

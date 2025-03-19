import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/color.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_card.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/supplier_page/widget/supplier_details/supplier_details_widget.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';

import 'supplier_data_source.dart';

export 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';

class SupplierListBody extends StatelessWidget {
  final FilterPredicate<Supplier>? filterPredicate;

  SupplierListBody({Key? key, this.filterPredicate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingListView(
      dataSource: SkipPagedDataSourceAdapter(SupplierDataSource(
          serverAPI:
              DependencyHolder.of(context)!.network.serverAPI.suppliers)),
      filterPredicate: filterPredicate,
      builder: (BuildContext context, Supplier? supplier) {
        return _buildCard(context, supplier);
      },
      activityFooterTile: ActivityListFooterTile(),
      placeholderFooterTile: PlaceholderListFooterTile(),
      errorFooterTile: ErrorListFooterTile(),
    );
  }

  Widget _buildCard(BuildContext context, Supplier? supplier) {
    final localizationUtil = LocalizationUtil.of(context);
    return ListCard(
      backgroundColor: supplier?.deleted == true
          ? CommonColors.deletedBackground
          : Colors.white,
      children: [
        ListCardField(value: short.formatSupplierSafe(context, supplier)),
        ListCardField(
            name: localizationUtil.itn, value: textOrEmpty(supplier?.itn)),
      ],
      onTap: () => _showDetails(context, supplier),
    );
  }

  void _showDetails(BuildContext context, Supplier? supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) =>
            SupplierDetailsWidget(supplier: supplier),
      ),
    );
  }
}

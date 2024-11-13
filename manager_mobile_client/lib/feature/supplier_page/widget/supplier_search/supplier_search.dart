import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/search/search_widget.dart';
import 'package:manager_mobile_client/feature/supplier_page/view/supplier_list_body.dart';

import 'supplier_search_filter_predicate.dart';

void showSupplierSearch({BuildContext context}) {
  showCustomSearch(
    context: context,
    builder: (BuildContext context, String query) {
      return SupplierListBody(
        filterPredicate:
            query != null ? SupplierSearchFilterPredicate(query) : null,
      );
    },
  );
}

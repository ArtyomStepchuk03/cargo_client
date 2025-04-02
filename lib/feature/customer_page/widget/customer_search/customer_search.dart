import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/search/search_widget.dart';
import 'package:manager_mobile_client/feature/customer_page/view/customer_list_body.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/manager.dart';

import 'customer_search_filter_predicate.dart';

void showCustomerSearch({required BuildContext context, Manager? manager}) {
  showCustomSearch(
    context: context,
    builder: (BuildContext context, String? query) {
      return CustomerListBody(
        manager: manager,
        filterPredicate:
            query != null ? CustomerSearchFilterPredicate(query) : null,
      );
    },
  );
}

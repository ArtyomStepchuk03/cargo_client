import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/manager.dart';
import 'package:manager_mobile_client/src/ui/common/search/search_widget.dart';
import 'package:manager_mobile_client/src/ui/customer/customer_list_body.dart';
import 'customer_search_filter_predicate.dart';

void showCustomerSearch({BuildContext context, Manager manager}) {
  showCustomSearch(
    context: context,
    builder: (BuildContext context, String query) {
      return CustomerListBody(
        manager: manager,
        filterPredicate: query != null ? CustomerSearchFilterPredicate(query) : null,
      );
    }
  );
}

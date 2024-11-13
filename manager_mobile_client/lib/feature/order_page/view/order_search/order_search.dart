import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/search/search_widget.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_list_body.dart';
import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';

import 'order_search_filter_predicate.dart';

void showOrderSearch(
    {BuildContext context,
    User user,
    OrderFilter filter,
    FilterPredicate<Order> filterPredicate,
    OrderSort sort}) {
  showCustomSearch(
      context: context,
      builder: (BuildContext context, String query) {
        var filterPredicates = <FilterPredicate<Order>>[];
        if (filterPredicate != null) {
          filterPredicates.add(filterPredicate);
        }
        if (query != null) {
          filterPredicates
              .add(OrderSearchFilterPredicate(context, user, query));
        }
        return OrderListBody(
          user: user,
          filter: filter,
          filterPredicate: AndFilterPredicate(filterPredicates),
          sort: sort,
        );
      });
}

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/search/search_widget.dart';
import 'package:manager_mobile_client/src/ui/carrier/carrier_list_body.dart';
import 'carrier_search_filter_predicate.dart';

void showCarrierSearch({
  BuildContext context,
  ItemTapCallback<Carrier> onTap,
}) {
  showCustomSearch(
    context: context,
    builder: (BuildContext context, String query) {
      return CarrierListBody(
        filterPredicate: query != null ? CarrierSearchFilterPredicate(query) : null,
        onTap: onTap,
      );
    }
  );
}

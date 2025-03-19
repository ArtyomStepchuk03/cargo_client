import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/search/search_widget.dart';
import 'package:manager_mobile_client/feature/carriages_page/widget/carriages_list_body.dart';
import 'package:manager_mobile_client/util/types.dart';

import 'carriage_search_filter_predicate.dart';

void showCarrierSearch({
  required BuildContext context,
  ItemTapCallback<Carrier>? onTap,
}) {
  showCustomSearch(
    context: context,
    builder: (BuildContext context, String? query) => CarriagesListBody(
      filterPredicate:
          query != null ? CarrierSearchFilterPredicate(query) : null,
      onTap: onTap,
    ),
  );
}

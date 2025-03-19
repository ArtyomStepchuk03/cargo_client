import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/search/search_widget.dart';
import 'package:manager_mobile_client/feature/transport_unit/view/transport_unit_list_body.dart';
import 'package:manager_mobile_client/feature/transport_unit/widget/transport_unit_search/transport_unit_search_filter_predicate.dart';
import 'package:manager_mobile_client/util/types.dart';

void showTransportUnitSearch({
  required BuildContext context,
  Key? listBodyKey,
  TransportUnitStatus? status,
  Carrier? carrier,
  ItemTapCallback<TransportUnit?>? onTap,
  ItemWidgetBuilder<TransportUnit?>? expandedBuilder,
}) {
  showCustomSearch(
    context: context,
    builder: (BuildContext context, String? query) {
      FilterPredicate<TransportUnit>? filterPredicate;
      if (query != null) {
        filterPredicate = TransportUnitSearchFilterPredicate(query);
      }
      return TransportUnitListBody(
        key: listBodyKey,
        status: status,
        carrier: carrier,
        filterPredicate: filterPredicate,
        onTap: onTap,
        expandedBuilder: expandedBuilder,
      );
    } as SearchWidgetBuilder,
  );
}

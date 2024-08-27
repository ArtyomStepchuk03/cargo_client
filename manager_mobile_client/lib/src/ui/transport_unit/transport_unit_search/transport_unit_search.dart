import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/search/search_widget.dart';
import 'package:manager_mobile_client/src/ui/transport_unit/transport_unit_list_body.dart';
import 'transport_unit_search_filter_predicate.dart';

void showTransportUnitSearch({
  BuildContext context,
  Key listBodyKey,
  TransportUnitStatus status,
  Carrier carrier,
  ItemTapCallback<TransportUnit> onTap,
  ItemWidgetBuilder<TransportUnit> expandedBuilder,
}) {
  showCustomSearch(
    context: context,
    builder: (BuildContext context, String query) {
      FilterPredicate<TransportUnit> filterPredicate;
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
    }
  );
}

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/carrier/carrier_list_widget.dart';
import 'carrier_prior_assign_strings.dart' as strings;

bool isPriorAssignmentAllowed(Order reservation) => !reservation.hasTripOnMinimumStage(TripStage.loaded);

Widget buildCarrierPriorAssignWidget(BuildContext context, Order reservation) {
  return CarrierListWidget(
    selecting: true,
    confirmButtonTitle: strings.assignFloatingActionButton,
    onConfirm: (Carrier carrier) async => await _processAssignment(context, reservation, carrier),
  );
}

Future<void> _processAssignment(BuildContext context, Order reservation, Carrier carrier) async {
  final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
  showDefaultActivityDialog(context);

  try {
    await serverAPI.fetchProgress(reservation);
    if (!isPriorAssignmentAllowed(reservation)) {
      Navigator.pop(context);
      await showErrorDialog(context, strings.cannotAssign);
      return;
    }

    await serverAPI.assignCarrier(reservation, carrier);
    Navigator.pop(context);
    Navigator.pop(context, reservation);
  } on Exception {
    Navigator.pop(context);
    await showDefaultErrorDialog(context);
  }
}

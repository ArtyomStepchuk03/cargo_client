import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/feature/carriages_page/carriages_page.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

bool isPriorAssignmentAllowed(Order? reservation) =>
    reservation?.hasTripOnMinimumStage(TripStage.loaded) == false;

Widget buildCarrierPriorAssignWidget(BuildContext context, Order? reservation) {
  final localizationUtil = LocalizationUtil.of(context);
  return CarriagePage(
    selecting: true,
    confirmButtonTitle: localizationUtil.assignFloatingActionButton,
    onConfirm: (Carrier carrier) async =>
        await _processAssignment(context, reservation, carrier),
  );
}

Future<void> _processAssignment(
    BuildContext context, Order? reservation, Carrier? carrier) async {
  final localizationUtil = LocalizationUtil.of(context);
  final serverAPI = DependencyHolder.of(context)!.network.serverAPI.orders;
  showDefaultActivityDialog(context);

  try {
    await serverAPI.fetchProgress(reservation);
    if (!isPriorAssignmentAllowed(reservation)) {
      Navigator.pop(context);
      await showErrorDialog(context, localizationUtil.cannotAssign);
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

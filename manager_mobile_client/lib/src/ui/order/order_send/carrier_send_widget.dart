import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/carrier/carrier_list_widget.dart';
import 'order_send_strings.dart' as strings;

Widget buildCarrierSendWidget(BuildContext context, Order order, User user) {
  return CarrierListWidget(
    selecting: true,
    confirmButtonTitle: strings.sendFloatingActionButton,
    onConfirm: (Carrier carrier) => _processOrderSending(context, order, user, carrier),
  );
}

void _processOrderSending(BuildContext context, Order order, User user, Carrier carrier) async {
  final dependencyState = DependencyHolder.of(context);
  final serverAPI = dependencyState.network.serverAPI.orders;

  showDefaultActivityDialog(context);

  try {
    await serverAPI.fetchProgress(order);

    if (!_canSendOrder(order)) {
      Navigator.pop(context);
      await showDefaultErrorDialog(context);
      return;
    }

    final cancelOffers = _shouldCancelOffers(order);
    final cancelCarriers = _shouldCancelCarrierOffers(order, user);

    if (cancelOffers || cancelCarriers) {
      Navigator.pop(context);
      final confirmed = await showContinueDialog(context, strings.alreadySent, confirmButtonTitle: strings.send);
      if (!confirmed) {
        return;
      }
      showDefaultActivityDialog(context);
      if (cancelOffers) {
        await serverAPI.cancel(order);
      }
      if (cancelCarriers) {
        await serverAPI.assignCarrier(order, null);
      }
    }

    await serverAPI.assignCarrier(order, carrier);

    Navigator.pop(context);
    Navigator.pop(context, order);
  } on Exception {
    Navigator.pop(context);
    await showDefaultErrorDialog(context);
  }
}

bool _shouldCancelOffers(Order order) {
  return order.offers != null && order.offers.isNotEmpty;
}

bool _shouldCancelCarrierOffers(Order order, User user) {
  if (user.role == Role.dispatcher) {
    return false;
  }
  return order.carrierOffers != null && order.carrierOffers.isNotEmpty;
}

bool _canSendOrder(Order order) {
  return order.distributedTonnage == 0;
}

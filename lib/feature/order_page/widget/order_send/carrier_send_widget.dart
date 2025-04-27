import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/feature/carriages_page/carriages_page.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

Widget buildCarrierSendWidget(BuildContext context, Order? order, User? user) {
  final localizationUtil = LocalizationUtil.of(context);
  return CarriagePage(
    selecting: true,
    confirmButtonTitle: localizationUtil.sendFloatingActionButton,
    onConfirm: (Carrier carrier) =>
        _processOrderSending(context, order, user, carrier),
  );
}

void _processOrderSending(
    BuildContext context, Order? order, User? user, Carrier? carrier) async {
  final localizationUtil = LocalizationUtil.of(context);
  final dependencyState = DependencyHolder.of(context);
  final serverAPI = dependencyState!.network.serverAPI.orders;

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
    final shouldConsist = _shouldConsist(order, user);

    if (shouldConsist) {
      final consist = await showContinueDialog(
          context, localizationUtil.needConsist,
          confirmButtonTitle: localizationUtil.agreeButton);
      if (consist) {
        order?.consistency = AgreeOrderType.agree().raw;
        await serverAPI.consistOrder(order);
      }
    }

    if (cancelOffers || cancelCarriers) {
      Navigator.pop(context);
      final confirmed = await showContinueDialog(
          context, localizationUtil.alreadySent,
          confirmButtonTitle: localizationUtil.send);
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

bool _shouldConsist(Order? order, User? user) {
  if ([Role.logistician, Role.administrator, Role.manager]
      .contains(user?.role)) {
    return order?.consistency == AgreeOrderType.notAgree().raw;
  }
  return false;
}

bool _shouldCancelOffers(Order? order) {
  return order?.offers != null && order!.offers!.isNotEmpty;
}

bool _shouldCancelCarrierOffers(Order? order, User? user) {
  if (user?.role == Role.dispatcher) {
    return false;
  }
  return order?.carrierOffers != null && order!.carrierOffers!.isNotEmpty;
}

bool _canSendOrder(Order? order) {
  return order?.distributedTonnage == 0;
}

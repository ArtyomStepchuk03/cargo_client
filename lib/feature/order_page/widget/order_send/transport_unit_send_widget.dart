import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/transport_unit/widget/transport_unit_tab_widget.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';
import 'package:manager_mobile_client/src/logic/vehicle/vehicle_admission.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

Widget buildTransportUnitSendWidget(
    BuildContext context, Order order, User user) {
  final localizationUtil = LocalizationUtil.of(context);
  return TransportUnitTabWidget(
    user: user,
    selecting: true,
    confirmButtonTitle: localizationUtil.sendFloatingActionButton,
    onConfirm: (TransportUnit transportUnit) =>
        _processOrderSending(context, order, user, transportUnit),
  );
}

void _processOrderSending(BuildContext context, Order order, User user,
    TransportUnit transportUnit) async {
  final localizationUtil = LocalizationUtil.of(context);
  final serverAPI = DependencyHolder.of(context)!.network.serverAPI;

  try {
    showDefaultActivityDialog(context);

    await serverAPI.transportUnits.fetch(transportUnit);

    final admissionProblems = transportUnit.checkAdmission(DateTime.now());
    if (admissionProblems.hasProblems) {
      Navigator.pop(context);
      final confirmed =
          await _showAdmissionProblemsDialog(context, admissionProblems);
      if (!confirmed) {
        return;
      }
      showDefaultActivityDialog(context);
    }

    if (transportUnit.driver?.internal == false) {
      final powerOfAttorney =
          await serverAPI.drivers.verify(transportUnit.driver);
      if (!powerOfAttorney) {
        Navigator.pop(context);
        final confirmed = await showContinueDialog(
            context, localizationUtil.noPowerOfAttorney);
        if (!confirmed) {
          return;
        }
        showDefaultActivityDialog(context);
      }
    }

    await serverAPI.orders.fetchProgress(order);

    if (!_canSendOrder(order)) {
      Navigator.pop(context);
      await showDefaultErrorDialog(context);
      return;
    }

    final cancelOffers = _shouldCancelOffers(order);
    final cancelCarriers =
        _shouldCancelCarrierOffers(order, user, transportUnit.driver?.carrier);
    final consistOrder = _isConsistOrder(order, user);

    if (consistOrder) {
      final confirmed = await showContinueDialog(
          context, localizationUtil.needConsist,
          confirmButtonTitle: localizationUtil.agreeButton);
      if (confirmed) {
        order.consistency = AgreeOrderType.agree().raw;
        await serverAPI.orders.consistOrder(order);
      } else {
        Navigator.pop(context); // Закрытие диалога активности (если открыт)
        return;
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
        await serverAPI.orders.cancel(order);
      }
      if (cancelCarriers) {
        await serverAPI.orders.assignCarrier(order, null);
      }
    }

    await _deliverOrder(serverAPI.orders, order, transportUnit);

    Navigator.pop(context);

    Navigator.pop(context, order);
  } on CloudFunctionFailedException catch (exception) {
    Navigator.pop(context);
    if (exception.error == ServerError.notApproved) {
      await showErrorDialog(context, localizationUtil.driverNotApproved);
      return;
    }
    await showDefaultErrorDialog(context);
  } on Exception {
    Navigator.pop(context);
    await showDefaultErrorDialog(context);
  }
}

bool _isConsistOrder(Order order, User user) {
  if ([Role.manager, Role.administrator, Role.logistician]
      .contains(user.role)) {
    return order.consistency == AgreeOrderType.notAgree().raw;
  }
  return false;
}

Future<bool> _showAdmissionProblemsDialog(
    BuildContext context, VehicleAdmissionProblems problems) async {
  final localizationUtil = LocalizationUtil.of(context);
  final problemStrings = [
    if (problems.vehicleInspectionExpired)
      localizationUtil.vehicleInspectionExpired,
    if (problems.trailerInspectionExpired)
      localizationUtil.trailerInspectionExpired,
    if (problems.mtplExpired) localizationUtil.mtplExpired,
    if (problems.passExpired) localizationUtil.passExpired,
    if (problems.passCanceled) localizationUtil.passCanceled,
  ];
  final text =
      '${localizationUtil.admissionProblems}:\n\n${problemStrings.join('\n')}\n\n${localizationUtil.continueQuestion}';
  return await showContinueDialog(context, text);
}

bool _shouldCancelOffers(Order order) {
  return order.offers != null && order.offers!.isNotEmpty;
}

bool _shouldCancelCarrierOffers(Order? order, User? user, Carrier? carrier) {
  if (user?.role == Role.dispatcher) {
    return false;
  }
  if (order?.carrierOffers == null || order!.carrierOffers!.isEmpty) {
    return false;
  }
  return !order.carrierOffers!
      .any((carrierOffer) => carrierOffer?.carrier == carrier);
}

bool _canSendOrder(Order order) {
  return order.distributedTonnage == 0;
}

Future<void> _deliverOrder(
    OrderServerAPI serverAPI, Order order, TransportUnit transportUnit) async {
  if (transportUnit.application == true) {
    await serverAPI.sendOffer(order, transportUnit);
  } else {
    await serverAPI.assignTransportUnit(order, transportUnit);
  }
}

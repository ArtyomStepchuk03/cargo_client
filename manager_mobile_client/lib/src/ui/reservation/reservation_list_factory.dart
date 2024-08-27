import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/ui/authorization/authorization_widget.dart';
import 'reservation_list_widget.dart';
import 'ungrouped_reservation_list_body.dart';
import 'supplier_group_reservation_list_body.dart';

extension ReservationListFactory on ReservationListWidget {
  static ReservationListWidget build(BuildContext context, Drawer drawer, TransitionBuilder containerBuilder) {
    final user = AuthorizationWidget.of(context).user;
    if (user.canReserveOrders()) {
      return supplierGroup(drawer, containerBuilder);
    }
    return ungrouped(drawer, containerBuilder);
  }

  static ReservationListWidget ungrouped(Drawer drawer, TransitionBuilder containerBuilder) {
    return ReservationListWidget(drawer, containerBuilder, (context, loadResult, sharedData, user, date) {
      return UngroupedReservationListBody(
        loadResult.reservations,
        user: user,
        date: date,
      );
    });
  }

  static ReservationListWidget supplierGroup(Drawer drawer, TransitionBuilder containerBuilder) {
    return ReservationListWidget(drawer, containerBuilder, (context, loadResult, sharedData, user, date) {
      return SupplierGroupReservationListBody.fromList(
        loadResult.reservations,
        reservationsDayBefore: loadResult.reservationsDayBefore,
        configuration: sharedData.configuration,
        purchaseTariffMap: sharedData.purchaseTariffMap,
        user: user,
        date: date,
      );
    });
  }
}

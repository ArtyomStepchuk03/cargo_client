import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manager_mobile_client/feature/auth_page/cubit/auth_cubit.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';

import 'reservation_page.dart';
import 'supplier_group_reservation_list_body.dart';
import 'ungrouped_reservation_list_body.dart';

extension ReservationListFactory on ReservationPage {
  static ReservationPage build(BuildContext context, Drawer? drawer,
      TransitionBuilder? containerBuilder) {
    final user = context.read<AuthCubit>().state.user;
    if (user?.canReserveOrders() == true) {
      return supplierGroup(drawer, containerBuilder);
    }
    return ungrouped(drawer, containerBuilder);
  }

  static ReservationPage ungrouped(
      Drawer? drawer, TransitionBuilder? containerBuilder) {
    return ReservationPage(drawer, containerBuilder,
        (context, loadResult, sharedData, user, date) {
      return UngroupedReservationListBody(
        loadResult?.reservations,
        user: user,
        date: date,
      );
    });
  }

  static ReservationPage supplierGroup(
      Drawer? drawer, TransitionBuilder? containerBuilder) {
    return ReservationPage(drawer, containerBuilder,
        (context, loadResult, sharedData, user, date) {
      return SupplierGroupReservationListBody.fromList(
        loadResult?.reservations,
        reservationsDayBefore: loadResult?.reservationsDayBefore,
        configuration: sharedData?.configuration,
        purchaseTariffMap: sharedData?.purchaseTariffMap,
        user: user,
        date: date,
      );
    });
  }
}

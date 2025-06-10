import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_card.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/core/intersperse.dart';
import 'package:manager_mobile_client/util/format/common_format.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/format/stage.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

Widget buildReservationListCell(BuildContext context,
    {Order? reservation,
    User? user,
    bool? showArticle = false,
    BoxBorder? border,
    VoidCallback? onTap}) {
  final localizationUtil = LocalizationUtil.of(context);
  return buildReservationListMultipleFieldCell(
    context: context,
    children: [
      if (reservation?.customer != null) ...[
        ListCardField(
            name: localizationUtil.customer,
            value: short.formatCustomerSafe(context, reservation?.customer)),
        ListCardField(
            name: localizationUtil.address,
            value: short.formatUnloadingPointSafe(
                context, reservation?.unloadingPoint)),
      ] else
        ListCardField(
            value: localizationUtil.unassignedReservation,
            textColor: Colors.redAccent),
      if (showArticle == true)
        ListCardField(
            name: localizationUtil.article,
            value: short.formatArticleBrandSafe(
                context, reservation?.articleBrand)),
      if (user?.role != Role.dispatcher &&
          reservation?.carriers != null &&
          reservation!.carriers!.isNotEmpty)
        ListCardField(
            name: localizationUtil.carrier,
            value: short.formatCarrierSafe(context, reservation.carriers?[0])),
      Row(children: [
        Expanded(
            flex: 2,
            child: ListCardField(
                name: localizationUtil.tonnage,
                value: formatTonnage(context, reservation!.tonnage!))),
        Expanded(
          flex: 3,
          child: ListCardField(
            name: localizationUtil.time,
            value: (reservation.unloadingEndDate == null)
                ? formatTimeOnly(reservation.unloadingBeginDate!)
                : '${localizationUtil.dateTimeRangeSince} ${formatTimeOnly(reservation.unloadingBeginDate!)}'
                    ' ${localizationUtil.timeRangeTo} ${formatTimeOnly(reservation.unloadingEndDate!)}',
          ),
        ),
      ]),
      Row(children: [
        Expanded(
          flex: 2,
          child: ListCardField(
            name: localizationUtil.reservationNumber,
            value: numberOrEmpty(reservation.number),
          ),
        ),
        if (reservation.customer != null)
          Expanded(
            flex: 3,
            child: ListCardField(
              name: localizationUtil.status,
              value: formatOrderStatus(context, reservation, user,
                  reservation: true,
                  flags: OrderStatusFormatFlags(inWork: true)),
              textColor: _getReservationStatusTextColor(reservation, user),
            ),
          ),
      ]),
    ],
    color: _getReservationCellColor(reservation),
    border: border,
    onTap: onTap,
  );
}

Widget buildReservationListPlaceholderCell(
    {required BuildContext context, required String text, BoxBorder? border}) {
  return _buildReservationListCellContainer(
    context: context,
    child: Row(children: [Text(text)]),
    border: border,
  );
}

Widget buildReservationListMultipleFieldCell(
    {required BuildContext context,
    required List<Widget> children,
    Color? color = Colors.white,
    BoxBorder? border,
    VoidCallback? onTap}) {
  return _buildReservationListCellContainer(
    context: context,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children.intersperse(SizedBox(height: 2)).toList(),
    ),
    color: color,
    border: border,
    onTap: onTap,
  );
}

Widget _buildReservationListCellContainer(
    {required BuildContext context,
    Widget? child,
    Color? color = Colors.white,
    BoxBorder? border,
    VoidCallback? onTap}) {
  return Material(
    color: color,
    child: InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: border,
        ),
        child: child,
      ),
      onTap: onTap,
    ),
  );
}

Color _getReservationCellColor(Order reservation) {
  if (_shouldMarkAsNew(reservation)) {
    return Colors.yellowAccent;
  }
  return Colors.white;
}

Color _getReservationStatusTextColor(Order? reservation, User? user) {
  if (_shouldMarkAsDeclined(reservation, user)) {
    return Colors.red;
  }
  if (_shouldMarkAsRequiresAction(reservation)) {
    return Colors.amber[800]!;
  }
  if (_shouldMarkAsNew(reservation)) {
    return Colors.green;
  }
  return Colors.black;
}

bool _shouldMarkAsDeclined(Order? reservation, User? user) {
  if (reservation?.carrierOffers != null &&
      reservation!.carrierOffers!.isNotEmpty) {
    final carrierOffer = reservation.carrierOffers?[0];
    if (carrierOffer?.accepted != null && !carrierOffer!.accepted!) {
      return true;
    }
  }
  return false;
}

bool _shouldMarkAsRequiresAction(Order? reservation) {
  if (reservation?.carrierOffers != null &&
      reservation!.carrierOffers!.isNotEmpty) {
    final carrierOffer = reservation.carrierOffers?[0];
    if (carrierOffer?.accepted == null) {
      return true;
    }
  }
  return false;
}

bool _shouldMarkAsNew(Order? reservation) {
  if (reservation?.status == OrderStatus.ready) {
    return false;
  }

  if (reservation?.status == OrderStatus.customerRequest ||
      reservation?.status == OrderStatus.inWork) {
    return true;
  }

  return false;
}

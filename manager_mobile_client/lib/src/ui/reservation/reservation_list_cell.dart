import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/intersperse.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/ui/format/format_strings.dart' as format_strings;
import 'package:manager_mobile_client/src/ui/format/date.dart';
import 'package:manager_mobile_client/src/ui/format/safe_format.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/format/common_format.dart';
import 'package:manager_mobile_client/src/ui/format/stage.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_card.dart';
import 'reservation_list_strings.dart' as strings;

Widget buildReservationListCell({BuildContext context, Order reservation, User user, bool showArticle = false, BoxBorder border, VoidCallback onTap}) {
  return buildReservationListMultipleFieldCell(
    context: context,
    children: [
      if (reservation.customer != null) ...[
        ListCardField(name: strings.customer, value: short.formatCustomerSafe(reservation.customer)),
        ListCardField(name: strings.address, value: short.formatUnloadingPointSafe(reservation.unloadingPoint)),
      ] else
        ListCardField(value: strings.unassignedReservation, textColor: Colors.redAccent),
      if (showArticle)
        ListCardField(name: strings.article, value: short.formatArticleBrandSafe(reservation.articleBrand)),
      if (user.role != Role.dispatcher && reservation.carriers != null && reservation.carriers.isNotEmpty)
        ListCardField(name: strings.carrier, value: short.formatCarrierSafe(reservation.carriers[0])),
      Row(children: [
        Expanded(flex: 2, child: ListCardField(name: strings.tonnage, value: formatTonnage(reservation.tonnage))),
        Expanded(flex: 3, child: ListCardField(name: strings.time, value: (reservation.unloadingEndDate == null)
            ? formatTimeOnly(reservation.unloadingBeginDate)
            : format_strings.timeRange(formatTimeOnly(reservation.unloadingBeginDate), formatTimeOnly(reservation.unloadingEndDate)))),
      ]),
      Row(children: [
        Expanded(flex: 2, child: ListCardField(name: strings.reservationNumber, value: numberOrEmpty(reservation.number))),
        if (reservation.customer != null)
          Expanded(flex: 3, child: ListCardField(
            name: strings.stageShort,
            value: formatOrderStatus(reservation, user, reservation: true, flags: OrderStatusFormatFlags(inWork: true)),
            textColor: _getReservationStatusTextColor(reservation, user),
          )),
      ]),
    ],
    color: _getReservationCellColor(reservation),
    border: border,
    onTap: onTap,
  );
}

Widget buildReservationListPlaceholderCell({BuildContext context, String text, BoxBorder border}) {
  return _buildReservationListCellContainer(
    context: context,
    child: Row(children: [Text(text)]),
    border: border,
  );
}

Widget buildReservationListMultipleFieldCell({BuildContext context, List<Widget> children, Color color = Colors.white, BoxBorder border, VoidCallback onTap}) {
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

Widget _buildReservationListCellContainer({BuildContext context, Widget child, Color color = Colors.white, BoxBorder border, VoidCallback onTap}) {
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

Color _getReservationStatusTextColor(Order reservation, User user) {
  if (_shouldMarkAsDeclined(reservation, user)) {
    return Colors.red;
  }
  if (_shouldMarkAsRequiresAction(reservation)) {
    return Colors.amber[800];
  }
  if (_shouldMarkAsNew(reservation)) {
    return Colors.green;
  }
  return Colors.black;
}

bool _shouldMarkAsDeclined(Order reservation, User user) {
  if (reservation.carrierOffers != null && reservation.carrierOffers.isNotEmpty) {
    final carrierOffer = reservation.carrierOffers[0];
    if (carrierOffer.accepted != null && !carrierOffer.accepted) {
      return true;
    }
  }
  return false;
}

bool _shouldMarkAsRequiresAction(Order reservation) {
  if (reservation.carrierOffers != null && reservation.carrierOffers.isNotEmpty) {
    final carrierOffer = reservation.carrierOffers[0];
    if (carrierOffer.accepted == null) {
      return true;
    }
  }
  return false;
}

bool _shouldMarkAsNew(Order reservation) {
  if (reservation.status != OrderStatus.customerRequest) {
    return false;
  }
  if (reservation.carrierOffers != null && reservation.carrierOffers.isNotEmpty) {
    return false;
  }
  return true;
}

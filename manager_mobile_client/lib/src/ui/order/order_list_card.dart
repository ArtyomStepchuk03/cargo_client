import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/configuration.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/order/entrance_coordinate_mismatch.dart';
import 'package:manager_mobile_client/src/ui/format/format_strings.dart'
    as format_strings;
import 'package:manager_mobile_client/src/ui/format/common_format.dart';
import 'package:manager_mobile_client/src/ui/format/safe_format.dart';
import 'package:manager_mobile_client/src/ui/format/date.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/format/stage.dart';
import 'package:manager_mobile_client/src/ui/common/color.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_card.dart';
import 'order_list_strings.dart' as strings;

class OrderListCard extends StatelessWidget {
  final Order order;
  final User user;
  final Configuration configuration;
  final GestureTapCallback onTap;

  OrderListCard({this.order, this.user, this.configuration, this.onTap});

  Widget build(BuildContext context) {
    return ListCard(
      backgroundColor: _getCardBackgroundColor(),
      highlightColor: _getCardHighlightColor(context),
      children: [
        if (order.isQueue())
          Text('В очереди', style: TextStyle(color: Colors.black)),
        if (user.role == Role.dispatcher)
          ListCardField(
              name: strings.intermediary,
              value: short.formatIntermediarySafe(order.intermediary)),
        if (user.role != Role.customer)
          ListCardField(
              name: strings.customer,
              value: short.formatCustomerSafe(order.customer)),
        ListCardField(
            name: strings.address,
            value: short.formatUnloadingPointSafe(order.unloadingPoint)),
        Row(children: [
          Expanded(
              flex: 2,
              child: ListCardField(
                  name: strings.tonnage, value: formatTonnage(order.tonnage))),
          Expanded(
              flex: 3,
              child: ListCardField(
                  name: strings.time, value: _formatUnloadingTime())),
        ]),
        Row(children: [
          Expanded(
              flex: 2,
              child: ListCardField(
                  name: strings.orderNumber,
                  value: numberOrEmpty(order.number))),
          Expanded(
              flex: 3,
              child: ListCardField(
                  name: strings.unloading, value: _formatUnloadingText())),
        ]),
        if (user.role == Role.customer)
          ListCardField(
              name: strings.article,
              value: short.formatArticleBrandSafe(order.articleBrand)),
        ListCardField(
            name: strings.stageShort,
            value: formatOrderStatus(order, user,
                flags: OrderStatusFormatFlags.all(user.role != Role.customer)))
      ],
      onTap: onTap,
    );
  }

  String _formatUnloadingTime() {
    if (order.unloadingEndDate == null) {
      return formatTimeOnly(order.unloadingBeginDate);
    }
    return format_strings.timeRange(formatTimeOnly(order.unloadingBeginDate),
        formatTimeOnly(order.unloadingEndDate));
  }

  String _formatUnloadingText() {
    final tripHistoryRecord =
        order.getAcceptedOffer()?.trip?.getHistoryRecord(TripStage.unloaded);
    if (tripHistoryRecord == null) {
      if (order.unloadingBeginDate == null) {
        return '';
      }
      return formatDateOnlyShort(order.unloadingBeginDate);
    }
    if (tripHistoryRecord.date == null) {
      return '';
    }
    final datePart = formatDateOnlyShort(tripHistoryRecord.date);
    if (tripHistoryRecord.tonnage == null) {
      return datePart;
    }
    final tonnagePart = formatTonnage(tripHistoryRecord.tonnage);
    return '$datePart, $tonnagePart';
  }

  Color _getCardBackgroundColor() {
    if (order.deleted) {
      return CommonColors.deletedBackground;
    }
    final colorPaletter = _getColorPalette();
    if (order.offers == null || order.offers.isEmpty) {
      if (user.role != Role.dispatcher &&
          order.carriers != null &&
          order.carriers.isNotEmpty) {
        return colorPaletter.transferred;
      }
      return colorPaletter.untouched;
    }
    final offer = order.offers.first;

    if (offer.trip == null) {
      if (!order.isQueue()) return Color.fromARGB(0xFF, 0xFC, 0xB7, 0x68);
      else return colorPaletter.transferred;
    }
    if (offer.trip.stage != TripStage.unloaded) {
      return colorPaletter.inProgress;
    }
    return colorPaletter.finished;
  }

  Color _getCardHighlightColor(BuildContext context) {
    if (user.role == Role.customer) {
      return null;
    }
    if (hasAnyEntranceCoordinateMismatch(order, configuration)) {
      return Colors.red[300];
    }
    return null;
  }

  _OrderStatusColorPalette _getColorPalette() {
    if (user.role == Role.customer) {
      return _OrderStatusColorPalette.customer;
    }
    return _OrderStatusColorPalette.standard;
  }
}

class _OrderStatusColorPalette {
  final Color untouched;
  final Color transferred;
  final Color inProgress;
  final Color finished;

  const _OrderStatusColorPalette(
      {this.untouched, this.transferred, this.inProgress, this.finished});

  static const standard = _OrderStatusColorPalette(
    untouched: Color.fromARGB(0xFF, 0xFF, 0x6E, 0x40),
    transferred: Colors.yellowAccent,
    inProgress: Colors.greenAccent,
    finished: Colors.white,
  );

  static const customer = _OrderStatusColorPalette(
    untouched: Color.fromARGB(0xFF, 0xA3, 0xD7, 0xEF),
    transferred: Color.fromARGB(0xFF, 0xA3, 0xD7, 0xEF),
    inProgress: Color.fromARGB(0xFF, 0x94, 0xF3, 0xC4),
    finished: Colors.white,
  );
}

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/color.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_card.dart';
import 'package:manager_mobile_client/feature/order_page/view/order_data_source.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/configuration.dart';
import 'package:manager_mobile_client/src/logic/order/entrance_coordinate_mismatch.dart';
import 'package:manager_mobile_client/util/format/common_format.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/format/stage.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class OrderListCard extends StatelessWidget {
  final Order? order;
  final User? user;
  final Configuration? configuration;
  final GestureTapCallback? onTap;

  OrderListCard({this.order, this.user, this.configuration, this.onTap});

  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return ListCard(
      backgroundColor: _getCardBackgroundColor(),
      highlightColor: _getCardHighlightColor(context),
      children: [
        if (order?.isQueue() == true)
          Text('В очереди', style: TextStyle(color: Colors.black)),
        if (user?.role == Role.dispatcher)
          ListCardField(
              name: localizationUtil.intermediary,
              value:
                  short.formatIntermediarySafe(context, order?.intermediary)),
        if (user?.role != Role.customer)
          ListCardField(
              name: localizationUtil.customer,
              value: short.formatCustomerSafe(context, order?.customer)),
        ListCardField(
            name: localizationUtil.address,
            value:
                short.formatUnloadingPointSafe(context, order?.unloadingPoint)),
        Row(children: [
          Expanded(
              flex: 2,
              child: ListCardField(
                  name: localizationUtil.tonnage,
                  value: formatTonnage(context, order!.tonnage!))),
          Expanded(
              flex: 3,
              child: ListCardField(
                  name: localizationUtil.time,
                  value: _formatUnloadingTime(context))),
        ]),
        Row(children: [
          Expanded(
              flex: 2,
              child: ListCardField(
                  name: localizationUtil.orderNumber,
                  value: numberOrEmpty(order?.number))),
          Expanded(
              flex: 3,
              child: ListCardField(
                  name: localizationUtil.unloading,
                  value: _formatUnloadingText(context))),
        ]),
        if (user?.role == Role.customer)
          ListCardField(
              name: localizationUtil.article,
              value:
                  short.formatArticleBrandSafe(context, order?.articleBrand)),
        ListCardField(
            name: localizationUtil.status,
            value: formatOrderStatus(context, order, user,
                flags: OrderStatusFormatFlags.all(user?.role != Role.customer)))
      ],
      onTap: onTap,
    );
  }

  String _formatUnloadingTime(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    if (order?.unloadingEndDate == null) {
      return formatTimeOnly(order!.unloadingBeginDate!);
    }

    return '${localizationUtil.dateTimeRangeSince} ${formatTimeOnly(order!.unloadingBeginDate!)}'
        ' ${localizationUtil.timeRangeTo} ${formatTimeOnly(order!.unloadingEndDate!)}';
  }

  String _formatUnloadingText(BuildContext context) {
    final tripHistoryRecord =
        order?.getAcceptedOffer()?.trip?.getHistoryRecord(TripStage.unloaded);
    if (tripHistoryRecord == null) {
      if (order!.unloadingBeginDate == null) {
        return '';
      }
      return formatDateOnlyShort(order!.unloadingBeginDate!);
    }
    if (tripHistoryRecord.date == null) {
      return '';
    }
    final datePart = formatDateOnlyShort(tripHistoryRecord.date!);
    if (tripHistoryRecord.tonnage == null) {
      return datePart;
    }
    final tonnagePart = formatTonnage(context, tripHistoryRecord.tonnage!);
    return '$datePart, $tonnagePart';
  }

  Color _getCardBackgroundColor() {
    if (order?.consistency == AgreeOrderType.notAgree().raw) {
      return Color.fromARGB(0xff, 0xff, 0xc0, 0xcb);
    }
    if (order?.deleted == true) {
      return CommonColors.deletedBackground;
    }
    final colorPaletter = _getColorPalette();
    if (order?.offers == null || order!.offers!.isEmpty) {
      if (user?.role != Role.dispatcher &&
          order?.carriers != null &&
          order!.carriers!.isNotEmpty) {
        return colorPaletter.transferred!;
      }
      return colorPaletter.untouched!;
    }
    final offer = order?.offers?.first;

    if (offer?.trip == null) {
      if (order?.isQueue() == false)
        return Color.fromARGB(0xFF, 0xFC, 0xB7, 0x68);
      if (order?.isQueue() == true) return Color(0xFFB9F6CA);
      return colorPaletter.transferred!;
    }
    if (offer?.trip?.stage != TripStage.unloaded) {
      return colorPaletter.inProgress!;
    }
    return colorPaletter.finished!;
  }

  Color? _getCardHighlightColor(BuildContext context) {
    if (user?.role == Role.customer) {
      return null;
    }
    if (hasAnyEntranceCoordinateMismatch(order, configuration)) {
      return Colors.red[300];
    }
    return null;
  }

  _OrderStatusColorPalette _getColorPalette() {
    if (user?.role == Role.customer) {
      return _OrderStatusColorPalette.customer;
    }
    return _OrderStatusColorPalette.standard;
  }
}

class _OrderStatusColorPalette {
  final Color? untouched;
  final Color? transferred;
  final Color? inProgress;
  final Color? finished;

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

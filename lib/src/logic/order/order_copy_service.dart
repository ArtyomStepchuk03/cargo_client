import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/util/format/common_format.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';

class OrderCopyService {
  static Future<void> copyOrderInfo(
      BuildContext context, Order? order, User? user) async {
    if (order == null) return;

    final localizationUtil = LocalizationUtil.of(context);
    final orderInfo = _buildOrderInfoText(context, order, user);

    await Clipboard.setData(ClipboardData(text: orderInfo));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizationUtil.informationCopied),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static Future<void> copyOrderStatus(
      BuildContext context, Order? order, User? user) async {
    final localizationUtil = LocalizationUtil.of(context);
    if (order == null) return;

    final statusInfo = _buildOrderStatusText(context, order, user);

    await Clipboard.setData(ClipboardData(text: statusInfo));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizationUtil.statusCopied),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static String _buildOrderInfoText(
      BuildContext context, Order order, User? user) {
    final l = LocalizationUtil.of(context);
    final List<String> lines = [];

    lines.add(
        '${l.unloadingPoint}: ${short.formatUnloadingPointSafe(context, order.unloadingPoint)}');

    final unloadingContact = order.unloadingContact;
    String contactInfo = '';
    if (unloadingContact != null) {
      if (unloadingContact.phoneNumber?.isNotEmpty ?? false) {
        contactInfo = unloadingContact.phoneNumber!;
        if (unloadingContact.name?.isNotEmpty ?? false) {
          contactInfo += ' (${unloadingContact.name})';
        }
      } else if (unloadingContact.name?.isNotEmpty ?? false) {
        contactInfo = unloadingContact.name!;
      }
    }
    lines.add('${l.unloadingContact}: $contactInfo');

    final unloadingDate = order.unloadingBeginDate != null
        ? formatDateOnly(order.unloadingBeginDate!)
        : '';
    lines.add('${l.unloadingDate}: $unloadingDate');

    final from = order.unloadingBeginDate != null
        ? formatTimeOnly(order.unloadingBeginDate!)
        : '';
    final to = order.unloadingEndDate != null
        ? formatTimeOnly(order.unloadingEndDate!)
        : '';
    lines.add(
        '${l.unloadingTime}: ${l.unloadingTimeBegin} $from ${l.unloadingTimeEnd} $to');

    final supplier = short.formatSupplierSafe(context, order.supplier);
    lines.add('${l.supplier}: $supplier');

    final loadingPoint =
        short.formatLoadingPointSafe(context, order.loadingPoint);
    lines.add('${l.loadingPoint}: $loadingPoint');

    final loadDate =
        order.loadingDate != null ? formatDateOnly(order.loadingDate!) : '';
    final loadTime =
        order.loadingDate != null ? formatTimeOnly(order.loadingDate!) : '';
    lines.add('${l.loadingDateTime}: $loadDate, $loadTime');

    final articleType = order.articleBrand?.type?.name ?? '';
    lines.add('${l.articleType}: $articleType');

    final articleBrand =
        short.formatArticleBrandSafe(context, order.articleBrand);
    lines.add('${l.articleBrand}: $articleBrand');

    final tonnage =
        order.tonnage != null ? formatTonnage(context, order.tonnage!) : '';
    lines.add('${l.tonnage}: $tonnage');

    final distance =
        order.distance != null ? '${order.distance} ${l.kilometers}' : '';
    lines.add('${l.distanceInKilometers}: $distance');

    final comment = textOrEmpty(order.comment);
    lines.add('${l.comment}: $comment');

    return lines.join('\n');
  }

  static String _buildOrderStatusText(
      BuildContext context, Order order, User? user) {
    final l = LocalizationUtil.of(context);
    final List<String> lines = [];

    final offer = order.getAcceptedOffer();
    if (offer != null && offer.transportUnit != null) {
      final unit = offer.transportUnit!;

      final vehicleName = textOrEmpty(unit.vehicle?.model?.name);
      lines.add('${l.vehicleFullName}: $vehicleName');

      final vehicleNumber = textOrEmpty(unit.vehicle?.number);
      lines.add('${l.stateNumber}: $vehicleNumber');

      final trailerNumber = textOrEmpty(unit.trailer?.number);
      lines.add('${l.trailerNumber}: $trailerNumber');

      final driverName = textOrEmpty(unit.driver?.name);
      lines.add('${l.personName}: $driverName');

      final phone = textOrEmpty(unit.driver?.phoneNumber);
      lines.add('${l.phoneNumber}: $phone');
    }

    return lines.join('\n');
  }
}

import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'safe_format.dart';

String formatWithNumberSafe(String text, int? number) {
  if (number == null) {
    return text;
  }
  return '$text №$number';
}

String formatSpeed(BuildContext context, num speed) {
  final localizationUtil = LocalizationUtil.of(context);
  return '${speed.toStringAsFixed(1)} ${localizationUtil.kilometersPerHour}';
}

String formatTonnage(BuildContext context, num tonnage) {
  final localizationUtil = LocalizationUtil.of(context);
  String tonnageString;
  if (tonnage.toInt() != tonnage) {
    tonnageString = tonnage.toStringAsFixed(2);
  } else {
    tonnageString = tonnage.toStringAsFixed(0);
  }
  return '$tonnageString ${localizationUtil.tons}';
}

String formatDistance(BuildContext context, num distance) {
  final localizationUtil = LocalizationUtil.of(context);
  return '$distance ${localizationUtil.kilometers}';
}

String formatSpeedSafe(BuildContext context, num? speed) {
  return textOrEmpty(speed != null ? formatSpeed(context, speed) : null);
}

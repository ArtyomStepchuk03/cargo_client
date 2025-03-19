import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'safe_format.dart';

String formatHours(int timeInterval) => '${timeInterval ~/ 1000 ~/ 60 ~/ 60}';

String formatMinutes(int timeInterval) => '${timeInterval ~/ 1000 ~/ 60}';

int scanHours(String string) {
  final hours = int.parse(string);
  return hours * 1000 * 60 * 60;
}

int scanMinutes(String string) {
  final minutes = int.parse(string);
  return minutes * 1000 * 60;
}

String formatTimeInterval(BuildContext context, int timeInterval) {
  final localizationUtil = LocalizationUtil.of(context);

  final totalMinutes = timeInterval ~/ 1000 ~/ 60;
  final totalHours = totalMinutes ~/ 60;
  final days = totalHours ~/ 24;
  final hours = totalHours % 24;
  final minutes = totalMinutes % 60;

  final components = <String>[];

  if (days != 0) {
    components.add('$days ${localizationUtil.days}');
  }
  if (hours != 0) {
    components.add('$hours ${localizationUtil.hours}');
  }
  if ((days == 0 && hours == 0) || minutes != 0) {
    components.add('$minutes ${localizationUtil.minutes}');
  }

  return components.join(' ');
}

String formatHoursSafe(int? timeInterval) =>
    textOrEmpty(timeInterval != null ? formatHours(timeInterval) : null);

String formatMinutesSafe(int? timeInterval) =>
    textOrEmpty(timeInterval != null ? formatMinutes(timeInterval) : null);

String formatTimeIntervalSafe(BuildContext context, int? timeInterval) =>
    textOrEmpty(timeInterval != null
        ? formatTimeInterval(context, timeInterval)
        : null);

String formatDateOnly(DateTime date) {
  final localDate = date.toLocal();
  final day = '${localDate.day}'.padLeft(2, '0');
  final month = '${localDate.month}'.padLeft(2, '0');
  final year = '${localDate.year}';
  return '$day.$month.$year';
}

String formatDateOnlyShort(DateTime date) {
  final localDate = date.toLocal();
  final day = '${localDate.day}'.padLeft(2, '0');
  final month = '${localDate.month}'.padLeft(2, '0');
  var year = '${localDate.year}'.substring(2, 4);
  if (year.length == 4) {
    year = year.substring(2, 4);
  }
  return '$day.$month.$year';
}

String formatTimeOnly(DateTime date) {
  final localDate = date.toLocal();
  final hour = '${localDate.hour}'.padLeft(2, '0');
  final minute = '${localDate.minute}'.padLeft(2, '0');
  return '$hour:$minute';
}

String formatDate(DateTime date) {
  final datePart = formatDateOnly(date);
  final timePart = formatTimeOnly(date);
  return '$datePart $timePart';
}

String formatDateOnlySafe(DateTime? date) =>
    textOrEmpty(date != null ? formatDateOnly(date) : null);

String formatDateOnlyShortSafe(DateTime? date) =>
    textOrEmpty(date != null ? formatDateOnlyShort(date) : null);

String formatTimeOnlySafe(DateTime? date) =>
    textOrEmpty(date != null ? formatTimeOnly(date) : null);

String formatDateSafe(DateTime? date) =>
    textOrEmpty(date != null ? formatDate(date) : null);

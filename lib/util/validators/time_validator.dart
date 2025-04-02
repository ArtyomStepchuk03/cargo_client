import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/time_parse.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

// TODO Если переключаемся на 12-часовой формат, необходимо изменить валидацию времени.
class TimeValidator {
  TimeValidator(this.context);

  final BuildContext context;

  String? call(String? value) {
    final localizationUtil = LocalizationUtil.of(context);
    if (value == null || value.isEmpty) {
      return null;
    }

    final hour = parseHour(value);
    if (hour == null) {
      return '$value ${localizationUtil.isNotCorrectTime}';
    }

    if (hour < 0) {
      return '${localizationUtil.less} 0';
    }

    if (hour > 23) {
      return '${localizationUtil.greater} 23';
    }

    return null;
  }
}

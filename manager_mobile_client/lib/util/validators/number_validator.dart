import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/number_parse.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'multiple_validator.dart';
import 'required_validator.dart';

class NumberValidator {
  final bool decimal;
  final num minimum;
  final num maximum;
  final BuildContext context;

  NumberValidator(this.context,
      {this.decimal = false, this.minimum = 0, this.maximum});

  String call(String value) {
    final localizationUtil = LocalizationUtil.of(context);
    if (value == null || value.isEmpty) {
      return null;
    }
    num number;
    if (decimal) {
      number = tryParseDecimal(value);
      if (number == null) {
        return '$value ${localizationUtil.isNotNumber}';
      }
    } else {
      number = int.tryParse(value);
      if (number == null) {
        return '$value ${localizationUtil.isNotInteger}';
      }
    }
    if (minimum != null && number < minimum) {
      if (decimal) {
        return '${localizationUtil.less} ${minimum.toStringAsFixed(2)}.';
      }
      return '${localizationUtil.less} $minimum.';
    }
    if (maximum != null && number > maximum) {
      if (decimal) {
        return '${localizationUtil.greater} ${maximum.toStringAsFixed(2)}.';
      }
      return '${localizationUtil.greater} $maximum.';
    }
    return null;
  }

  static FormFieldValidator<String> required(BuildContext context,
      {bool decimal = false, num minimum = 0, num maximum}) {
    return MultipleValidator<String>([
      RequiredValidator(context),
      NumberValidator(context,
          decimal: decimal, minimum: minimum, maximum: maximum)
    ]);
  }
}

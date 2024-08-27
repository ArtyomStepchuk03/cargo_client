import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/number_parse.dart';
import 'validators_strings.dart' as strings;
import 'multiple_validator.dart';
import 'required_validator.dart';

class NumberValidator {
  final bool decimal;
  final num minimum;
  final num maximum;

  NumberValidator({this.decimal = false, this.minimum = 0, this.maximum});

  String call(String value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    num number;
    if (decimal) {
      number = tryParseDecimal(value);
      if (number == null) {
        return strings.notNumber(value);
      }
    } else {
      number = int.tryParse(value);
      if (number == null) {
        return strings.notInteger(value);
      }
    }
    if (minimum != null && number < minimum) {
      if (decimal) {
        return strings.lessThan(minimum.toStringAsFixed(2));
      } else {
        return strings.lessThan('$minimum');
      }
    }
    if (maximum != null && number > maximum) {
      if (decimal) {
        return strings.greaterThan(maximum.toStringAsFixed(2));
      } else {
        return strings.greaterThan('$maximum');
      }
    }
    return null;
  }

  static FormFieldValidator<String> required({bool decimal = false, num minimum = 0, num maximum}) {
    return MultipleValidator<String>([RequiredValidator(), NumberValidator(decimal: decimal, minimum: minimum, maximum: maximum)]);
  }
}

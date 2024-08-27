import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/time_parse.dart';
import 'validators_strings.dart' as strings;
import 'multiple_validator.dart';
import 'required_validator.dart';

class HourValidator {
  String call(String value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final hour = parseHour(value);
    if (hour == null) {
      return strings.notTime(value);
    }
    if (hour < 0) {
      return strings.lessThan('0');
    }
    if (hour > 23) {
      return strings.greaterThan('23');
    }
    return null;
  }

  static FormFieldValidator<String> required() {
    return MultipleValidator<String>([RequiredValidator(), HourValidator()]);
  }
}

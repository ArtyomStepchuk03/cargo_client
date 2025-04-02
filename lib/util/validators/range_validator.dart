import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/time_parse.dart';

typedef ValidatorComparer = int Function(String one, String other);

class RangeBeginValidator {
  final ValidatorComparer comparer;
  final GlobalKey<FormFieldState<String>> endKey;
  final String errorString;

  RangeBeginValidator(this.comparer, this.endKey, this.errorString);

  factory RangeBeginValidator.buildHourRangeBeginValidator(
          GlobalKey<FormFieldState<String>> endKey, String errorString) =>
      RangeBeginValidator(_compareHourStrings, endKey, errorString);

  String? call(String? value) {
    final endValue = endKey.currentState!.value;
    if (endValue == null || endValue.isEmpty) {
      return null;
    }
    if (endKey.currentState!.hasError) {
      return null;
    }
    if (comparer(value!, endValue) > 0) {
      return errorString;
    }
    return null;
  }
}

class RangeEndValidator {
  final ValidatorComparer comparer;
  final GlobalKey<FormFieldState<String>> beginKey;
  final String errorString;

  RangeEndValidator(this.comparer, this.beginKey, this.errorString);

  factory RangeEndValidator.buildHourRangeEndValidator(
          GlobalKey<FormFieldState<String>> endKey, String errorString) =>
      RangeEndValidator(_compareHourStrings, endKey, errorString);

  String? call(String? value) {
    final beginValue = beginKey.currentState!.value;
    if (beginValue == null || beginValue.isEmpty) {
      return null;
    }
    if (beginKey.currentState!.hasError) {
      return null;
    }
    if (comparer(value!, beginValue) < 0) {
      return errorString;
    }
    return null;
  }
}

int _compareHourStrings(String one, String other) {
  final oneNumber = parseHour(one);
  final otherNumber = parseHour(other);
  return oneNumber! - otherNumber!;
}

import 'package:flutter/material.dart';
import 'validators_strings.dart' as strings;
import 'multiple_validator.dart';
import 'required_validator.dart';

class VehicleNumberValidator {
  String call(String value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final expression = RegExp(r'^[АВЕКМНОРСТУХ]\d{3}[АВЕКМНОРСТУХ]{2}\d{2,3}$', caseSensitive: false);
    if (expression.firstMatch(value) == null) {
      return strings.invalidVehicleNumber;
    }
    return null;
  }

  static FormFieldValidator<String> required() {
    return MultipleValidator<String>([RequiredValidator(), VehicleNumberValidator()]);
  }
}

class TrailerNumberValidator {
  String call(String value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final expression = RegExp(r'^[АВЕКМНОРСТУХ]{2}\d{4}\d{2,3}$', caseSensitive: false);
    if (expression.firstMatch(value) == null) {
      return strings.invalidTrailerNumber;
    }
    return null;
  }

  static FormFieldValidator<String> required() {
    return MultipleValidator<String>([RequiredValidator(), TrailerNumberValidator()]);
  }
}

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'multiple_validator.dart';
import 'required_validator.dart';

class VehicleNumberValidator {
  VehicleNumberValidator(this.context);

  final BuildContext context;

  String? call(String? value) {
    final localizationUtil = LocalizationUtil.of(context);
    if (value == null || value.isEmpty) {
      return null;
    }
    final expression = RegExp(r'^[АВЕКМНОРСТУХ]\d{3}[АВЕКМНОРСТУХ]{2}\d{2,3}$',
        caseSensitive: false);
    if (expression.firstMatch(value) == null) {
      return localizationUtil.invalidVehicleNumber;
    }
    return null;
  }

  static FormFieldValidator<String?> required(BuildContext context) {
    return MultipleValidator<String?>([
      RequiredValidator(context),
      VehicleNumberValidator(context),
    ]);
  }
}

class TrailerNumberValidator {
  TrailerNumberValidator(this.context);

  final BuildContext context;

  String? call(String? value) {
    final localizationUtil = LocalizationUtil.of(context);
    if (value == null || value.isEmpty) {
      return null;
    }
    final expression =
        RegExp(r'^[АВЕКМНОРСТУХ]{2}\d{4}\d{2,3}$', caseSensitive: false);
    if (expression.firstMatch(value) == null) {
      return localizationUtil.invalidTrailerNumber;
    }
    return null;
  }

  static FormFieldValidator<String?> required(BuildContext context) {
    return MultipleValidator<String?>([
      RequiredValidator(context),
      TrailerNumberValidator(context),
    ]);
  }
}

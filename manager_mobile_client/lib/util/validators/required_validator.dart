import 'package:flutter/material.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class RequiredValidator<T> {
  RequiredValidator(this.context);

  final BuildContext context;

  String call(T value) {
    final localizationUtil = LocalizationUtil.of(context);
    if (value == null) {
      return localizationUtil.empty;
    }
    if (value is String && value.isEmpty) {
      return localizationUtil.empty;
    }
    return null;
  }
}

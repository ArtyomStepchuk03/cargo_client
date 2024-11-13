import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

String formatRole(BuildContext context, String role) {
  final localizationUtil = LocalizationUtil.of(context);

  switch (role) {
    case Role.administrator:
      return localizationUtil.administrators;
    case Role.logistician:
      return localizationUtil.logisticians;
    case Role.manager:
      return localizationUtil.managers;
    case Role.dispatcher:
      return localizationUtil.dispatchers;
    case Role.driver:
      return localizationUtil.drivers;
    case Role.customer:
      return localizationUtil.customers;
    case Role.supplier:
      return localizationUtil.suppliers;
    default:
      return '';
  }
}

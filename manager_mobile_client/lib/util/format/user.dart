import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';

import 'safe_format.dart';
import 'short_format.dart' as short;

String formatUserSafe(BuildContext context, User user) {
  if (user == null) {
    return '';
  }

  switch (user.role) {
    case Role.logistician:
      return short.formatLogisticianSafe(context, user.logistician);
    case Role.manager:
      return short.formatManagerSafe(context, user.manager);
    case Role.dispatcher:
      return short.formatDispatcherSafe(context, user.dispatcher);
    case Role.driver:
      return short.formatDriverSafe(context, user.driver);
    case Role.customer:
      return short.formatCustomerSafe(context, user.customer);
    case Role.supplier:
      return short.formatSupplierSafe(context, user.supplier);
    default:
      return textOrEmpty(user.name);
  }
}

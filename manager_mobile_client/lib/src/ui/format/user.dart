import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'safe_format.dart';
import 'short_format.dart' as short;

String formatUserSafe(User user) {
  if (user == null) {
    return '';
  }
  if (user.role == Role.logistician) {
    return short.formatLogisticianSafe(user.logistician);
  }
  if (user.role == Role.manager) {
    return short.formatManagerSafe(user.manager);
  }
  if (user.role == Role.dispatcher) {
    return short.formatDispatcherSafe(user.dispatcher);
  }
  if (user.role == Role.driver) {
    return short.formatDriverSafe(user.driver);
  }
  if (user.role == Role.customer) {
    return short.formatCustomerSafe(user.customer);
  }
  if (user.role == Role.supplier) {
    return short.formatSupplierSafe(user.supplier);
  }
  return textOrEmpty(user.name);
}

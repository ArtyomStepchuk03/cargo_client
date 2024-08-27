import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'format_strings.dart' as strings;

String formatRole(String role) {
  if (role == Role.administrator) return strings.administrators;
  if (role == Role.logistician) return strings.logisticians;
  if (role == Role.manager) return strings.managers;
  if (role == Role.dispatcher) return strings.dispatchers;
  if (role == Role.driver) return strings.drivers;
  if (role == Role.customer) return strings.customers;
  if (role == Role.supplier) return strings.suppliers;
  return '';
}

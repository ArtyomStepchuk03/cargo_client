import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/contact.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle_model.dart';

import 'safe_format.dart';
import 'short_format.dart' as short;

String formatContact(Contact value) {
  if (value.name == null && value.phoneNumber == null) {
    return '';
  }
  if (value.name == null) {
    return value.phoneNumber;
  }
  if (value.phoneNumber == null) {
    return value.name;
  }
  return '${value.phoneNumber} (${value.name})';
}

String formatContactSafe(BuildContext context, Contact value) {
  return textOrEmpty(value != null ? formatContact(value) : null);
}

String formatVehicleModel(BuildContext context, VehicleModel value) {
  if (value.brand == null || value.brand.name == null) {
    return short.formatVehicleModelSafe(context, value);
  }
  if (value.name == null) {
    return short.formatVehicleBrandSafe(context, value.brand);
  }
  return '${value.brand.name} ${value.name}';
}

String formatVehicleModelSafe(BuildContext context, VehicleModel value) {
  return textOrEmpty(value != null ? formatVehicleModel(context, value) : null);
}

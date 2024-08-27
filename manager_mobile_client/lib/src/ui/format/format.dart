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

String formatContactSafe(Contact value) {
  return textOrEmpty(value != null ? formatContact(value) : null);
}

String formatVehicleModel(VehicleModel value) {
  if (value.brand == null || value.brand.name == null) {
    return short.formatVehicleModelSafe(value);
  }
  if (value.name == null) {
    return short.formatVehicleBrandSafe(value.brand);
  }
  return '${value.brand.name} ${value.name}';
}

String formatVehicleModelSafe(VehicleModel value) {
  return textOrEmpty(value != null ? formatVehicleModel(value) : null);
}

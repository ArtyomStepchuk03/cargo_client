import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'date.dart';
import 'format_strings.dart' as strings;

String formatVehiclePass(VehiclePass vehiclePass) {
  var string = _formatVehiclePassMoscowZone(vehiclePass.zone);
  if (vehiclePass.timeOfAction != null) {
    string += ', ${_formatVehiclePassTimeOfAction(vehiclePass.timeOfAction)}';
  }
  if (vehiclePass.canceled != null && vehiclePass.canceled) {
    string += ', ${strings.canceled}';
  } else {
    string += ', ${strings.dateRange(formatDateOnly(vehiclePass.beginDate), formatDateOnly(vehiclePass.endDate))}';
  }
  return string;
}

String formatVehiclePassSafe(VehiclePass vehiclePass) {
  if (!_isValidVehiclePass(vehiclePass)) {
    return null;
  }
  return formatVehiclePass(vehiclePass);
}

String _formatVehiclePassMoscowZone(VehiclePassMoscowZone vehiclePassMoscowZone) {
  switch (vehiclePassMoscowZone) {
    case VehiclePassMoscowZone.gardenRing: return strings.gardenRing;
    case VehiclePassMoscowZone.thirdRingRoad: return strings.thirdRingRoad;
    case VehiclePassMoscowZone.mkad: return strings.mkad;
    default: return '';
  }
}

String _formatVehiclePassTimeOfAction(VehiclePassTimeOfAction timeOfAction) {
  switch (timeOfAction) {
    case VehiclePassTimeOfAction.day: return strings.day;
    case VehiclePassTimeOfAction.night: return strings.night;
    default: return '';
  }
}

bool _isValidVehiclePass(VehiclePass vehiclePass) {
  if (vehiclePass.zone == null) {
    return false;
  }
  if (vehiclePass.canceled != null && vehiclePass.canceled) {
    return true;
  }
  if (vehiclePass.beginDate == null || vehiclePass.endDate == null) {
    return false;
  }
  return true;
}

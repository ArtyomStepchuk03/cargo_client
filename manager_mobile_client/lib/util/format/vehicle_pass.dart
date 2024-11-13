import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'date.dart';

String formatVehiclePass(BuildContext context, VehiclePass vehiclePass) {
  final localizationUtil = LocalizationUtil.of(context);
  var string = _formatVehiclePassMoscowZone(context, vehiclePass.zone);
  if (vehiclePass.timeOfAction != null) {
    string +=
        ', ${_formatVehiclePassTimeOfAction(context, vehiclePass.timeOfAction)}';
  }
  if (vehiclePass.canceled != null && vehiclePass.canceled) {
    string += ', ${localizationUtil.canceled}';
  } else {
    string +=
        ', ${localizationUtil.dateTimeRangeSince} ${formatDateOnly(vehiclePass.beginDate)}'
        ' ${localizationUtil.dateRangeTo} ${formatDateOnly(vehiclePass.endDate)}';
  }
  return string;
}

String formatVehiclePassSafe(BuildContext context, VehiclePass vehiclePass) {
  if (!_isValidVehiclePass(vehiclePass)) {
    return null;
  }
  return formatVehiclePass(context, vehiclePass);
}

String _formatVehiclePassMoscowZone(
    BuildContext context, VehiclePassMoscowZone vehiclePassMoscowZone) {
  final localizationUtil = LocalizationUtil.of(context);
  switch (vehiclePassMoscowZone) {
    case VehiclePassMoscowZone.gardenRing:
      return localizationUtil.gardenRing;
    case VehiclePassMoscowZone.thirdRingRoad:
      return localizationUtil.thirdRingRoad;
    case VehiclePassMoscowZone.mkad:
      return localizationUtil.mkad;
    default:
      return '';
  }
}

String _formatVehiclePassTimeOfAction(
    BuildContext context, VehiclePassTimeOfAction timeOfAction) {
  final localizationUtil = LocalizationUtil.of(context);
  switch (timeOfAction) {
    case VehiclePassTimeOfAction.day:
      return localizationUtil.day;
    case VehiclePassTimeOfAction.night:
      return localizationUtil.night;
    default:
      return '';
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

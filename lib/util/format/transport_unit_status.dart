import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'safe_format.dart';

String? formatTransportUnitStatus(
    BuildContext context, TransportUnitStatus? transportUnitStatus) {
  final localizationUtil = LocalizationUtil.of(context);
  switch (transportUnitStatus) {
    case TransportUnitStatus.notReady:
      return localizationUtil.transportUnitNotReady;
    case TransportUnitStatus.ready:
      return localizationUtil.transportUnitReady;
    case TransportUnitStatus.breakage:
      return localizationUtil.transportUnitBreakage;
    case TransportUnitStatus.invisible:
      return localizationUtil.transportUnitInvisible;
    case TransportUnitStatus.working:
      return localizationUtil.transportUnitWorking;
    case TransportUnitStatus.resting:
      return localizationUtil.transportUnitResting;
    case TransportUnitStatus.underRepair:
      return localizationUtil.transportUnitUnderRepair;
    default:
      return null;
  }
}

String formatTransportUnitStatusSafe(
    BuildContext context, TransportUnitStatus? transportUnitStatus) {
  return textOrEmpty(transportUnitStatus != null
      ? formatTransportUnitStatus(context, transportUnitStatus)
      : null);
}

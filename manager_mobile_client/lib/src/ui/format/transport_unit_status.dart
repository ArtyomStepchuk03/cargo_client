import 'package:manager_mobile_client/src/logic/concrete_data/transport_unit.dart';
import 'safe_format.dart';
import 'format_strings.dart' as strings;

String formatTransportUnitStatus(TransportUnitStatus transportUnitStatus) {
  switch (transportUnitStatus) {
    case TransportUnitStatus.notReady: return strings.transportUnitNotReady;
    case TransportUnitStatus.ready: return strings.transportUnitReady;
    case TransportUnitStatus.breakage: return strings.transportUnitBreakage;
    case TransportUnitStatus.invisible: return strings.transportUnitInvisible;
    case TransportUnitStatus.working: return strings.transportUnitWorking;
    case TransportUnitStatus.resting: return strings.transportUnitResting;
    case TransportUnitStatus.underRepair: return strings.transportUnitUnderRepair;
    default: return null;
  }
}

String formatTransportUnitStatusSafe(TransportUnitStatus transportUnitStatus) {
  return textOrEmpty(transportUnitStatus != null ? formatTransportUnitStatus(transportUnitStatus) : null);
}

import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/src/ui/order/common_order_strings.dart' as strings;

String formatEquipmentRequirements(UnloadingPoint unloadingPoint) {
  if (unloadingPoint == null) {
    return null;
  }
  if (unloadingPoint.equipmentRequirements.compressor) {
    return strings.compressorRequired;
  }
  return null;
}

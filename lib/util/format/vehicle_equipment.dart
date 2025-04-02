import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

String? formatEquipmentRequirements(
    BuildContext context, UnloadingPoint? unloadingPoint) {
  final localizationUtil = LocalizationUtil.of(context);
  if (unloadingPoint == null) {
    return null;
  }
  if (unloadingPoint.equipmentRequirements!.compressor) {
    return localizationUtil.compressorRequired;
  }
  return null;
}

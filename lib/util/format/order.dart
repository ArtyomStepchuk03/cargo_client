import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'safe_format.dart';

enum LoadingType { supplier, transfer }

extension SupplierLoadingType on Supplier {
  LoadingType getLoadingType() {
    if (transfer!) {
      return LoadingType.transfer;
    }
    return LoadingType.supplier;
  }
}

String formatOrderType(BuildContext context, OrderType? type) {
  final localizationUtil = LocalizationUtil.of(context);
  if (type == OrderType.carriage()) {
    return localizationUtil.orderTypeCarriage;
  }
  if (type == OrderType.normal()) {
    return localizationUtil.orderTypeNormal;
  }
  return 'Unknown order type';
}

String formatAgreeOrderType(BuildContext context, AgreeOrderType? type) {
  final localizationUtil = LocalizationUtil.of(context);
  print(type?.raw);
  if (type == AgreeOrderType.agree()) {
    return localizationUtil.agree;
  }
  if (type == AgreeOrderType.notAgree()) {
    return localizationUtil.notAgree;
  }

  return '';
}

String? formatLoadingType(BuildContext context, LoadingType loadingType) {
  final localizationUtil = LocalizationUtil.of(context);
  switch (loadingType) {
    case LoadingType.supplier:
      return localizationUtil.loadingTypeSupplier;
    case LoadingType.transfer:
      return localizationUtil.loadingTypeTransfer;
    default:
      return null;
  }
}

String formatLoadingTypeSafe(BuildContext context, LoadingType? loadingType) {
  return textOrEmpty(
      loadingType != null ? formatLoadingType(context, loadingType) : null);
}

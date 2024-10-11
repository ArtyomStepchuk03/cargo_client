import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';

import 'format_strings.dart' as strings;
import 'safe_format.dart';

enum LoadingType { supplier, transfer }

extension SupplierLoadingType on Supplier {
  LoadingType getLoadingType() {
    if (transfer) {
      return LoadingType.transfer;
    }
    return LoadingType.supplier;
  }
}

String formatOrderType(OrderType type) {
  if (type == OrderType.carriage()) {
    return strings.orderTypeCarriage;
  }
  if (type == OrderType.normal()) {
    return strings.orderTypeNormal;
  }
  return 'Unknown order type';
}

String formatAgreeOrderType(AgreeOrderType type) {
  print(type?.raw);
  if (type == AgreeOrderType.agree()) {
    return strings.agree;
  }
  if (type == AgreeOrderType.notAgree()) {
    return strings.notAgree;
  }

  return '';
}

String formatLoadingType(LoadingType loadingType) {
  switch (loadingType) {
    case LoadingType.supplier:
      return strings.loadingTypeSupplier;
    case LoadingType.transfer:
      return strings.loadingTypeTransfer;
    default:
      return null;
  }
}

String formatLoadingTypeSafe(LoadingType loadingType) {
  return textOrEmpty(
      loadingType != null ? formatLoadingType(loadingType) : null);
}

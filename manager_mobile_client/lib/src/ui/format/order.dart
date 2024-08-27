import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'safe_format.dart';
import 'format_strings.dart' as strings;

enum LoadingType {
  supplier,
  transfer
}

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
  return strings.orderTypeNormal;
}

String formatLoadingType(LoadingType loadingType) {
  switch (loadingType) {
    case LoadingType.supplier: return strings.loadingTypeSupplier;
    case LoadingType.transfer: return strings.loadingTypeTransfer;
    default: return null;
  }
}

String formatLoadingTypeSafe(LoadingType loadingType) {
  return textOrEmpty(loadingType != null ? formatLoadingType(loadingType) : null);
}

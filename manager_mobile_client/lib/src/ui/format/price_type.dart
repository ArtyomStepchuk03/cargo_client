import 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';
import 'safe_format.dart';
import 'format_strings.dart' as strings;

String formatPriceType(PriceType priceType) {
  switch (priceType) {
    case PriceType.oneTime: return strings.oneTime;
    case PriceType.notOneTime: return strings.notOneTime;
    default: return null;
  }
}

String formatPriceTypeSafe(PriceType priceType) {
  return textOrEmpty(priceType != null ? formatPriceType(priceType) : null);
}

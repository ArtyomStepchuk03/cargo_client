import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import 'safe_format.dart';

String formatPriceType(BuildContext context, PriceType priceType) {
  final localizationUtil = LocalizationUtil.of(context);
  switch (priceType) {
    case PriceType.oneTime:
      return localizationUtil.oneTime;
    case PriceType.notOneTime:
      return localizationUtil.notOneTime;
    default:
      return null;
  }
}

String formatPriceTypeSafe(BuildContext context, PriceType priceType) =>
    textOrEmpty(priceType != null ? formatPriceType(context, priceType) : null);

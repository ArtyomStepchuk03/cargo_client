import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/core/identifiable.dart';

import 'article_brand.dart';
import 'intermediary.dart';
import 'supplier.dart';

class PurchaseTariff extends Identifiable<String> {
  String? id;
  ArticleBrand? articleBrand;
  Intermediary? intermediary;
  Supplier? supplier;
  LoadingPoint? loadingPoint;
  num? tariff;

  PurchaseTariff();

  static const className = 'PurchaseTariff';

  static PurchaseTariff? decode(Decoder decoder) {
    if (!decoder.isValid()) {
      return null;
    }
    final decoded = PurchaseTariff();
    decoded.id = decoder.decodeId();
    decoded.articleBrand =
        ArticleBrand.decode(decoder.getDecoder('articleBrand'));
    decoded.intermediary =
        Intermediary.decode(decoder.getDecoder('intermediary'));
    decoded.supplier = Supplier.decode(decoder.getDecoder('supplier'));
    decoded.loadingPoint =
        LoadingPoint.decode(decoder.getDecoder('loadingPoint'));
    decoded.tariff = decoder.decodeNumber('tariff');
    return decoded;
  }
}

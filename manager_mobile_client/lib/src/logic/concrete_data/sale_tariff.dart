import 'package:manager_mobile_client/src/logic/core/identifiable.dart';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'article_brand.dart';
import 'intermediary.dart';
import 'supplier.dart';
import 'unloading_point.dart';

class SaleTariff extends Identifiable<String> {
  String id;
  ArticleBrand articleBrand;
  Intermediary intermediary;
  Supplier supplier;
  LoadingPoint loadingPoint;
  UnloadingPoint unloadingPoint;
  num tariff;

  SaleTariff();

  static const className = 'SaleTariff';

  factory SaleTariff.decode(Decoder decoder) {
    if (!decoder.isValid()) {return null;}
    final decoded = SaleTariff();
    decoded.id = decoder.decodeId();
    decoded.articleBrand = ArticleBrand.decode(decoder.getDecoder('articleBrand'));
    decoded.intermediary = Intermediary.decode(decoder.getDecoder('intermediary'));
    decoded.supplier = Supplier.decode(decoder.getDecoder('supplier'));
    decoded.loadingPoint = LoadingPoint.decode(decoder.getDecoder('loadingPoint'));
    decoded.unloadingPoint = UnloadingPoint.decode(decoder.getDecoder('unloadingPoint'));
    decoded.tariff = decoder.decodeNumber('tariff');
    return decoded;
  }
}

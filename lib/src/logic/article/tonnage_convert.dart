import 'package:manager_mobile_client/src/logic/concrete_data/article_brand.dart';

num tonnageFromTruckCount(int truckCount, ArticleBrand articleBrand) {
  return truckCount * articleBrand.tonnagePerTruck!;
}

int truckCountFromTonnage(num tonnage, ArticleBrand articleBrand) {
  final fractional = tonnage / articleBrand.tonnagePerTruck!;
  return fractional.ceil();
}

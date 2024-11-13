import 'package:manager_mobile_client/src/logic/data_cache/data_cache.dart';
import 'package:manager_mobile_client/src/logic/data_cache/data_cache_map.dart';

import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';

import 'package:manager_mobile_client/src/logic/concrete_data/article_shape.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/article_brand.dart';

import 'package:manager_mobile_client/src/logic/concrete_data/intermediary.dart';

import 'package:manager_mobile_client/src/logic/concrete_data/driver.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/supplier.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';

import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/trailer.dart';

class CacheCollection {
  final articleShape = SkipPagedDataCache<ArticleShape>();
  final articleType = SkipPagedDataCache<ArticleType>();
  final articleBrand = SkipPagedDataCacheMap<ArticleBrand, ArticleType>();
  final vehicleBrand = SkipPagedDataCache<VehicleBrand>();
  final vehicleModel = SkipPagedDataCacheMap<VehicleModel, VehicleBrand>();
  final intermediary = SkipPagedDataCache<Intermediary>();
  final carrier = SkipPagedDataCache<Carrier>();
  final driver = SkipPagedDataCacheMap<Driver, Carrier>();
  final supplier = SkipPagedDataCacheMap<Supplier, bool>();
  final customer = SkipPagedDataCache<Customer>();
  final allowedSupplier = LimitedDataCacheMap<Supplier, Carrier>();
  final allowedCustomer = LimitedDataCacheMap<Customer, Carrier>();
  final supplierArticleBrand = LimitedDataCacheMap<ArticleBrand, Supplier>();
  final supplierArticleType = LimitedDataCacheMap<ArticleType, Supplier>();
  final vehicle = SkipPagedDataCacheMap<Vehicle, Carrier>();
  final trailer = SkipPagedDataCacheMap<Trailer, Carrier>();
  final unloadingContact = LimitedDataCacheMap<Contact, UnloadingPoint>();
  final loadingPoint = LimitedDataCacheMap<LoadingPoint, Supplier>();
  final unloadingPoint = LimitedDataCacheMap<UnloadingPoint, Customer>();
  final loadingEntrance = LimitedDataCacheMap<Entrance, LoadingPoint>();
  final unloadingEntrance = LimitedDataCacheMap<Entrance, UnloadingPoint>();
  final messageUser = SkipPagedDataCache<User>();
}

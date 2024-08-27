import 'package:manager_mobile_client/src/logic/concrete_data/article_shape.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/article_brand.dart';

import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/trailer.dart';

import 'package:manager_mobile_client/src/logic/concrete_data/intermediary.dart';

import 'package:manager_mobile_client/src/logic/concrete_data/logistician.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/manager.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/dispatcher.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/driver.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/supplier.dart';

import 'safe_format.dart';

String formatArticleShapeSafe(ArticleShape value) {return textOrEmpty(value?.name);}
String formatArticleTypeSafe(ArticleType value) {return textOrEmpty(value?.name);}
String formatArticleBrandSafe(ArticleBrand value) {return textOrEmpty(value?.name);}

String formatVehicleBrandSafe(VehicleBrand value) {return textOrEmpty(value?.name);}
String formatVehicleModelSafe(VehicleModel value) {return textOrEmpty(value?.name);}
String formatVehicleSafe(Vehicle value) {return textOrEmpty(value?.number);}
String formatTrailerSafe(Trailer value) {return textOrEmpty(value?.number);}

String formatIntermediarySafe(Intermediary value) {return textOrEmpty(value?.name);}

String formatCarrierSafe(Carrier value) {return textOrEmpty(value?.name);}
String formatLogisticianSafe(Logistician value) {return textOrEmpty(value?.name);}
String formatManagerSafe(Manager value) {return textOrEmpty(value?.name);}
String formatDispatcherSafe(Dispatcher value) {return textOrEmpty(value?.name);}
String formatDriverSafe(Driver value) {return textOrEmpty(value?.name);}
String formatCustomerSafe(Customer value) {return textOrEmpty(value?.name);}
String formatSupplierSafe(Supplier value) {return textOrEmpty(value?.name);}

String formatLoadingPointSafe(LoadingPoint value) {return textOrEmpty(value?.address);}
String formatUnloadingPointSafe(UnloadingPoint value) {return textOrEmpty(value?.address);}
String formatEntranceSafe(Entrance value) {return textOrEmpty(value?.name);}

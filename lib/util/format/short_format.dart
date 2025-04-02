import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/article_brand.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/article_shape.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/customer.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/dispatcher.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/driver.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/intermediary.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/logistician.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/manager.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/supplier.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/trailer.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';

import 'safe_format.dart';

String formatArticleShapeSafe(BuildContext context, ArticleShape? value) =>
    textOrEmpty(value?.name);

String formatArticleTypeSafe(BuildContext context, ArticleType? value) =>
    textOrEmpty(value?.name);

String formatArticleBrandSafe(BuildContext context, ArticleBrand? value) =>
    textOrEmpty(value?.name);

String formatVehicleBrandSafe(BuildContext context, VehicleBrand? value) =>
    textOrEmpty(value?.name);

String formatVehicleModelSafe(BuildContext context, VehicleModel? value) =>
    textOrEmpty(value?.name);

String formatVehicleSafe(BuildContext context, Vehicle? value) =>
    textOrEmpty(value?.number);

String formatTrailerSafe(BuildContext context, Trailer? value) =>
    textOrEmpty(value?.number);

String formatIntermediarySafe(BuildContext context, Intermediary? value) =>
    textOrEmpty(value?.name);

String formatCarrierSafe(BuildContext context, Carrier? value) =>
    textOrEmpty(value?.name);

String formatLogisticianSafe(BuildContext context, Logistician? value) =>
    textOrEmpty(value?.name);

String formatManagerSafe(BuildContext context, Manager? value) =>
    textOrEmpty(value?.name);

String formatDispatcherSafe(BuildContext context, Dispatcher? value) =>
    textOrEmpty(value?.name);

String formatDriverSafe(BuildContext context, Driver? value) =>
    textOrEmpty(value?.name);

String formatCustomerSafe(BuildContext context, Customer? value) =>
    textOrEmpty(value?.name);

String formatSupplierSafe(BuildContext context, Supplier? value) =>
    textOrEmpty(value?.name);

String formatLoadingPointSafe(BuildContext context, LoadingPoint? value) =>
    textOrEmpty(value?.address);

String formatUnloadingPointSafe(BuildContext context, UnloadingPoint? value) =>
    textOrEmpty(value?.address);

String formatEntranceSafe(BuildContext context, Entrance? value) =>
    textOrEmpty(value?.name);

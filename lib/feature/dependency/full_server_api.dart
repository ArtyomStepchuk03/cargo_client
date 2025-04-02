import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

import 'package:manager_mobile_client/src/logic/server_api/remote_file_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/installation_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/user_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/configuration_server_api.dart';

import 'package:manager_mobile_client/src/logic/server_api/article_shape_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/article_type_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/article_brand_server_api.dart';

import 'package:manager_mobile_client/src/logic/server_api/vehicle_brand_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/vehicle_model_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/vehicle_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/trailer_server_api.dart';

import 'package:manager_mobile_client/src/logic/server_api/carrier_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/driver_server_api.dart';

import 'package:manager_mobile_client/src/logic/server_api/intermediary_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/customer_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/supplier_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/loading_point_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/unloading_point_server_api.dart';

import 'package:manager_mobile_client/src/logic/server_api/transport_unit_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/trip_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/offer_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/order_server_api.dart';

import 'package:manager_mobile_client/src/logic/server_api/purchase_tariff_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/sale_tariff_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_api/distance_server_api.dart';

import 'package:manager_mobile_client/src/logic/server_api/message_server_api.dart';

class FullServerAPI {
  final RemoteFileServerAPI files;
  final InstallationServerAPI installations;
  final UserServerAPI users;
  final ConfigurationServerAPI configuration;
  final ArticleShapeServerAPI articleShapes;
  final ArticleTypeServerAPI articleTypes;
  final ArticleBrandServerAPI articleBrands;
  final VehicleBrandServerAPI vehicleBrands;
  final VehicleModelServerAPI vehicleModels;
  final VehicleServerAPI vehicles;
  final TrailerServerAPI trailers;
  final CarrierServerAPI carriers;
  final DriverServerAPI drivers;
  final IntermediaryServerAPI intermediaries;
  final SupplierServerAPI suppliers;
  final CustomerServerAPI customers;
  final LoadingPointServerAPI loadingPoints;
  final UnloadingPointServerAPI unloadingPoints;
  final TransportUnitServerAPI transportUnits;
  final TripServerAPI trips;
  final OfferServerAPI offers;
  final OrderServerAPI orders;
  final PurchaseTariffServerAPI purchaseTariffs;
  final SaleTariffServerAPI saleTariffs;
  final DistanceServerAPI distances;
  final MessageServerAPI messages;

  FullServerAPI(
    this.files,
    this.installations,
    this.users,
    this.configuration,
    this.articleShapes,
    this.articleTypes,
    this.articleBrands,
    this.vehicleBrands,
    this.vehicleModels,
    this.vehicles,
    this.trailers,
    this.carriers,
    this.drivers,
    this.intermediaries,
    this.suppliers,
    this.customers,
    this.loadingPoints,
    this.unloadingPoints,
    this.transportUnits,
    this.trips,
    this.offers,
    this.orders,
    this.purchaseTariffs,
    this.saleTariffs,
    this.distances,
    this.messages,
  );

  factory FullServerAPI.standard(ServerManager serverManager) {
    return FullServerAPI(
      RemoteFileServerAPI(serverManager),
      InstallationServerAPI(serverManager),
      UserServerAPI(serverManager),
      ConfigurationServerAPI(serverManager),
      ArticleShapeServerAPI(serverManager),
      ArticleTypeServerAPI(serverManager),
      ArticleBrandServerAPI(serverManager),
      VehicleBrandServerAPI(serverManager),
      VehicleModelServerAPI(serverManager),
      VehicleServerAPI(serverManager),
      TrailerServerAPI(serverManager),
      CarrierServerAPI(serverManager),
      DriverServerAPI(serverManager),
      IntermediaryServerAPI(serverManager),
      SupplierServerAPI(serverManager),
      CustomerServerAPI(serverManager),
      LoadingPointServerAPI(serverManager),
      UnloadingPointServerAPI(serverManager),
      TransportUnitServerAPI(serverManager),
      TripServerAPI(serverManager),
      OfferServerAPI(serverManager),
      OrderServerAPI(serverManager),
      PurchaseTariffServerAPI(serverManager),
      SaleTariffServerAPI(serverManager),
      DistanceServerAPI(serverManager),
      MessageServerAPI(serverManager),
    );
  }
}

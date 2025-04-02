import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/feature/add_driver_page/view/add_driver_page.dart';
import 'package:manager_mobile_client/feature/add_trailer_page/view/add_trailer_page.dart';
import 'package:manager_mobile_client/feature/add_vehicle_page/view/add_vehicle_page.dart';
import 'package:manager_mobile_client/src/logic/data_cache/cached_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_cache/data_cache_map.dart';
import 'package:manager_mobile_client/src/logic/server_api/carrier_server_api.dart';
import 'package:manager_mobile_client/util/format/format.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/required_validator.dart';

import '../../../../feature/create_carriage_page/view/transport_unit_add_data_sources.dart';

class CarrierSearchPredicate implements SearchPredicate<Carrier> {
  bool call(Carrier object, String query) => satisfiesQuery(object.name, query);
}

Widget buildCarrierFormField(
  BuildContext context, {
  Key? key,
  required CarrierServerAPI serverAPI,
  required SkipPagedDataCache<Carrier> cache,
  ValueChanged<Carrier?>? onChanged,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<Carrier>(
    context,
    key: key,
    dataSource:
        SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(serverAPI, cache)),
    searchPredicate: CarrierSearchPredicate(),
    formatter: short.formatCarrierSafe,
    listViewBuilder: (BuildContext context, Carrier? object) =>
        SimpleListTile(object?.name),
    onChanged: onChanged,
    onRefresh: cache.clear,
    label: localizationUtil.carrier,
    validator: RequiredValidator(context),
  );
}

class DriverSearchPredicate implements SearchPredicate<Driver> {
  bool call(Driver object, String query) => satisfiesQuery(object.name, query);
}

Widget buildDriverFormField(
  BuildContext context, {
  Key? key,
  required DriverServerAPI serverAPI,
  SkipPagedDataCacheMap<Driver, Carrier>? cacheMap,
  Carrier? carrier,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<Driver>(
    context,
    key: key,
    dataSource: carrier != null
        ? SkipPagedDataSourceAdapter(
            CachedSkipPagedDataSource(
              DriverDataSource(serverAPI, carrier),
              cacheMap!.getCache(carrier),
            ),
          )
        : null,
    searchPredicate: DriverSearchPredicate(),
    formatter: short.formatDriverSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, Driver? object) =>
        SimpleListTile(object?.name),
    onRefresh:
        carrier != null ? () => cacheMap!.getCache(carrier).clear() : null,
    onAdd: (context) async {
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => AddDriverPage(carrier: carrier),
          fullscreenDialog: true,
        ),
      );
    },
    label: localizationUtil.driver,
    validator: RequiredValidator(context),
    enabled: carrier != null,
  );
}

class VehicleSearchPredicate implements SearchPredicate<Vehicle> {
  VehicleSearchPredicate(this.context);

  final BuildContext context;

  bool call(Vehicle object, String query) {
    if (satisfiesQuery(object.number, query)) {
      return true;
    }
    final vehicleModelString = formatVehicleModelSafe(context, object.model);
    if (satisfiesQuery(vehicleModelString, query)) {
      return true;
    }
    return false;
  }
}

Widget buildVehicleFormField(
  BuildContext context, {
  Key? key,
  required VehicleServerAPI serverAPI,
  SkipPagedDataCacheMap<Vehicle, Carrier>? cacheMap,
  Carrier? carrier,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<Vehicle>(
    context,
    key: key,
    dataSource: carrier != null
        ? SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(
            VehicleDataSource(serverAPI, carrier), cacheMap!.getCache(carrier)))
        : null,
    searchPredicate: VehicleSearchPredicate(context),
    formatter: short.formatVehicleSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, Vehicle? object) => SimpleListTile(
        object?.number, formatVehicleModelSafe(context, object?.model)),
    onRefresh:
        carrier != null ? () => cacheMap!.getCache(carrier).clear() : null,
    onAdd: (context) async {
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => AddVehiclePage(carrier: carrier),
          fullscreenDialog: true,
        ),
      );
    },
    label: localizationUtil.vehicle,
    validator: RequiredValidator(context),
    enabled: carrier != null,
  );
}

class TrailerSearchPredicate implements SearchPredicate<Trailer> {
  bool call(Trailer object, String query) =>
      satisfiesQuery(object.number, query);
}

Widget buildTrailerFormField(
  BuildContext context, {
  Key? key,
  required TrailerServerAPI serverAPI,
  SkipPagedDataCacheMap<Trailer, Carrier>? cacheMap,
  Carrier? carrier,
}) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<Trailer>(
    context,
    key: key,
    dataSource: carrier != null
        ? SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(
            TrailerDataSource(serverAPI, carrier), cacheMap!.getCache(carrier)))
        : null,
    searchPredicate: TrailerSearchPredicate(),
    formatter: short.formatTrailerSafe,
    listViewBuilder: (BuildContext context, Trailer? object) =>
        SimpleListTile(object?.number),
    onRefresh:
        carrier != null ? () => cacheMap!.getCache(carrier).clear() : null,
    onAdd: (context) async {
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => AddTrailerPage(carrier: carrier),
          fullscreenDialog: true,
        ),
      );
    },
    label: localizationUtil.trailer,
    validator: RequiredValidator(context),
    enabled: carrier != null,
  );
}

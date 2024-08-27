import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/data_cache/cached_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_cache/data_cache_map.dart';
import 'package:manager_mobile_client/src/logic/server_api/carrier_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/src/ui/format/format.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/validators/required_validator.dart';
import 'package:manager_mobile_client/src/ui/driver/driver_add_widget.dart';
import 'package:manager_mobile_client/src/ui/vehicle/vehicle_add/vehicle_add_widget.dart';
import 'package:manager_mobile_client/src/ui/vehicle/trailer_add/trailer_add_widget.dart';
import 'transport_unit_add_data_sources.dart';
import 'transport_unit_add_strings.dart' as strings;

class CarrierSearchPredicate implements SearchPredicate<Carrier> {
  bool call(Carrier object, String query) => satisfiesQuery(object.name, query);
}

Widget buildCarrierFormField({
  Key key,
  CarrierServerAPI serverAPI,
  SkipPagedDataCache<Carrier> cache,
  ValueChanged<Carrier> onChanged,
}) {
  return LoadingListFormField<Carrier>(
    key: key,
    dataSource: SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(serverAPI, cache)),
    searchPredicate: CarrierSearchPredicate(),
    formatter: short.formatCarrierSafe,
    listViewBuilder: (BuildContext context, Carrier object) => SimpleListTile(object.name),
    onChanged: onChanged,
    onRefresh: cache.clear,
    label: strings.carrier,
    validator: RequiredValidator(),
  );
}

class DriverSearchPredicate implements SearchPredicate<Driver> {
  bool call(Driver object, String query) => satisfiesQuery(object.name, query);
}

Widget buildDriverFormField({
  Key key,
  DriverServerAPI serverAPI,
  SkipPagedDataCacheMap<Driver, Carrier> cacheMap,
  Carrier carrier,
}) {
  return LoadingListFormField<Driver>(
    key: key,
    dataSource: carrier != null ? SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(DriverDataSource(serverAPI, carrier), cacheMap.getCache(carrier))) : null,
    searchPredicate: DriverSearchPredicate(),
    formatter: short.formatDriverSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, Driver object) => SimpleListTile(object.name),
    onRefresh: carrier != null ? () =>  cacheMap.getCache(carrier).clear() : null,
    onAdd: (context) async {
      return await Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => DriverAddWidget(carrier: carrier),
        fullscreenDialog: true,
      ));
    },
    label: strings.driver,
    validator: RequiredValidator(),
    enabled: carrier != null,
  );
}

class VehicleSearchPredicate implements SearchPredicate<Vehicle> {
  bool call(Vehicle object, String query) {
    if (satisfiesQuery(object.number, query)) {
      return true;
    }
    final vehicleModelString = formatVehicleModelSafe(object.model);
    if (satisfiesQuery(vehicleModelString, query)) {
      return true;
    }
    return false;
  }
}

Widget buildVehicleFormField({
  Key key,
  VehicleServerAPI serverAPI,
  SkipPagedDataCacheMap<Vehicle, Carrier> cacheMap,
  Carrier carrier,
}) {
  return LoadingListFormField<Vehicle>(
    key: key,
    dataSource: carrier != null ? SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(VehicleDataSource(serverAPI, carrier), cacheMap.getCache(carrier))) : null,
    searchPredicate: VehicleSearchPredicate(),
    formatter: short.formatVehicleSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, Vehicle object) => SimpleListTile(object.number, formatVehicleModelSafe(object.model)),
    onRefresh: carrier != null ? () =>  cacheMap.getCache(carrier).clear() : null,
    onAdd: (context) async {
      return await Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => VehicleAddWidget(carrier: carrier),
        fullscreenDialog: true,
      ));
    },
    label: strings.vehicle,
    validator: RequiredValidator(),
    enabled: carrier != null,
  );
}

class TrailerSearchPredicate implements SearchPredicate<Trailer> {
  bool call(Trailer object, String query) => satisfiesQuery(object.number, query);
}

Widget buildTrailerFormField({
  Key key,
  TrailerServerAPI serverAPI,
  SkipPagedDataCacheMap<Trailer, Carrier> cacheMap,
  Carrier carrier,
}) {
  return LoadingListFormField<Trailer>(
    key: key,
    dataSource: carrier != null ? SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(TrailerDataSource(serverAPI, carrier), cacheMap.getCache(carrier))) : null,
    searchPredicate: TrailerSearchPredicate(),
    formatter: short.formatTrailerSafe,
    listViewBuilder: (BuildContext context, Trailer object) => SimpleListTile(object.number),
    onRefresh: carrier != null ? () =>  cacheMap.getCache(carrier).clear() : null,
    onAdd: (context) async {
      return await Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => TrailerAddWidget(carrier: carrier),
        fullscreenDialog: true,
      ));
    },
    label: strings.trailer,
    validator: RequiredValidator(),
    enabled: carrier != null,
  );
}

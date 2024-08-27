import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/data_cache/cached_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_cache/data_cache_map.dart';
import 'package:manager_mobile_client/src/logic/server_api/vehicle_brand_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/src/ui/format/short_format.dart' as short;
import 'package:manager_mobile_client/src/ui/validators/required_validator.dart';
import 'vehicle_add_data_sources.dart';
import 'vehicle_add_strings.dart' as strings;

class VehicleBrandSearchPredicate implements SearchPredicate<VehicleBrand> {
  bool call(VehicleBrand object, String query) => satisfiesQuery(object.name, query);
}

Widget buildVehicleBrandFormField(
  VehicleBrandServerAPI serverAPI,
  SkipPagedDataCache<VehicleBrand> cache,
  ValueChanged<VehicleBrand> onChanged,
) {
  return LoadingListFormField<VehicleBrand>(
    dataSource: SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(serverAPI, cache)),
    searchPredicate: VehicleBrandSearchPredicate(),
    formatter: short.formatVehicleBrandSafe,
    listViewBuilder: (BuildContext context, VehicleBrand object) => SimpleListTile(object.name),
    onChanged: onChanged,
    onRefresh: cache.clear,
    label: strings.brand,
    validator: RequiredValidator(),
  );
}

class VehicleModelSearchPredicate implements SearchPredicate<VehicleModel> {
  bool call(VehicleModel object, String query) => satisfiesQuery(object.name, query);
}

Widget buildVehicleModelFormField(
  Key key,
  VehicleModelServerAPI serverAPI,
  SkipPagedDataCacheMap<VehicleModel, VehicleBrand> cacheMap,
  VehicleBrand brand,
) {
  return LoadingListFormField<VehicleModel>(
    key: key,
    dataSource: brand != null ? SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(
      VehicleModelDataSource(serverAPI, brand),
      cacheMap.getCache(brand),
    )) : null,
    searchPredicate: VehicleModelSearchPredicate(),
    formatter: short.formatVehicleModelSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, VehicleModel object) => SimpleListTile(object.name),
    onRefresh: brand != null ? () => cacheMap.getCache(brand).clear() : null,
    label: strings.model,
    validator: RequiredValidator(),
    enabled: brand != null,
  );
}

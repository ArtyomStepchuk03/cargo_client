import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/common/loading_list_view/list_tile.dart';
import 'package:manager_mobile_client/src/logic/data_cache/cached_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_cache/data_cache_map.dart';
import 'package:manager_mobile_client/src/logic/server_api/vehicle_brand_server_api.dart';
import 'package:manager_mobile_client/util/format/short_format.dart' as short;
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/required_validator.dart';

import '../add_vehicle_data_sources.dart';

class VehicleBrandSearchPredicate implements SearchPredicate<VehicleBrand> {
  bool call(VehicleBrand object, String query) =>
      satisfiesQuery(object.name, query);
}

Widget buildVehicleBrandFormField(
  BuildContext context,
  VehicleBrandServerAPI serverAPI,
  SkipPagedDataCache<VehicleBrand> cache,
  ValueChanged<VehicleBrand> onChanged,
) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<VehicleBrand>(
    context,
    dataSource:
        SkipPagedDataSourceAdapter(CachedSkipPagedDataSource(serverAPI, cache)),
    searchPredicate: VehicleBrandSearchPredicate(),
    formatter: short.formatVehicleBrandSafe,
    listViewBuilder: (BuildContext context, VehicleBrand object) =>
        SimpleListTile(object.name),
    onChanged: onChanged,
    onRefresh: cache.clear,
    label: localizationUtil.brand,
    validator: RequiredValidator(context),
  );
}

class VehicleModelSearchPredicate implements SearchPredicate<VehicleModel> {
  bool call(VehicleModel object, String query) =>
      satisfiesQuery(object.name, query);
}

Widget buildVehicleModelFormField(
  BuildContext context,
  Key key,
  VehicleModelServerAPI serverAPI,
  SkipPagedDataCacheMap<VehicleModel, VehicleBrand> cacheMap,
  VehicleBrand brand,
) {
  final localizationUtil = LocalizationUtil.of(context);
  return LoadingListFormField<VehicleModel>(
    context,
    key: key,
    dataSource: brand != null
        ? SkipPagedDataSourceAdapter(
            CachedSkipPagedDataSource(
              VehicleModelDataSource(serverAPI, brand),
              cacheMap.getCache(brand),
            ),
          )
        : null,
    searchPredicate: VehicleModelSearchPredicate(),
    formatter: short.formatVehicleModelSafe,
    fetchInitialValue: true,
    listViewBuilder: (BuildContext context, VehicleModel object) =>
        SimpleListTile(object.name),
    onRefresh: brand != null ? () => cacheMap.getCache(brand).clear() : null,
    label: localizationUtil.model,
    validator: RequiredValidator(context),
    enabled: brand != null,
  );
}

import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle_model.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/vehicle_model.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class VehicleModelServerAPI implements SkipPagedDataSource<VehicleModel> {
  final ServerManager serverManager;

  VehicleModelServerAPI(this.serverManager);

  Future<List<VehicleModel>> list(int skip, int limit,
      [VehicleBrand? brand]) async {
    final builder = parse.QueryBuilder(VehicleModel.className);
    builder.equalTo('deleted', false);
    if (brand != null) {
      builder.equalToObject('brand', VehicleBrand.className, brand.id);
    }
    builder.include('brand');
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server!);
    return results
        .map((json) => VehicleModel.decode(Decoder(json)))
        .whereType<VehicleModel>()
        .toList();
  }

  @override
  bool operator ==(dynamic other) => other is VehicleModelServerAPI;

  @override
  int get hashCode => super.hashCode;
}

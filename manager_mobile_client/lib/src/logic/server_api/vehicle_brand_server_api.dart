import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle_brand.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/vehicle_brand.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class VehicleBrandServerAPI implements SkipPagedDataSource<VehicleBrand> {
  final ServerManager serverManager;

  VehicleBrandServerAPI(this.serverManager);

  Future<List<VehicleBrand>> list(int skip, int limit) async {
    final builder = parse.QueryBuilder(VehicleBrand.className);
    builder.equalTo('deleted', false);
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server);
    return results.map((json) => VehicleBrand.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }

  @override
  bool operator==(dynamic other) => other is VehicleBrandServerAPI;

  @override
  int get hashCode => super.hashCode;
}

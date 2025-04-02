import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/vehicle.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class VehicleServerAPI {
  final ServerManager serverManager;

  VehicleServerAPI(this.serverManager);

  Future<bool> exists(String? number, Carrier? carrier) async {
    final builder = parse.QueryBuilder(Vehicle.className);
    builder.equalTo('deleted', false);
    builder.equalTo('number', number);
    builder.equalToObject('carrier', Carrier.className, carrier?.id);
    final count = await builder.count(serverManager.server!);
    return count != 0;
  }

  Future<List<Vehicle>> listFree(
      int? skip, int? limit, Carrier? carrier) async {
    final builder = parse.QueryBuilder(Vehicle.className);
    builder.equalTo('deleted', false);
    builder.doesNotExist('transportUnit');
    builder.equalToObject('carrier', Carrier.className, carrier?.id);
    builder.include('model');
    builder.include('model.brand');
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server!);
    return results
        .map((json) => Vehicle.decode(Decoder(json)))
        .whereType<Vehicle>()
        .toList();
  }

  Future<void> create(Vehicle vehicle) async {
    final data = <String, dynamic>{};
    final encoder = Encoder(data);
    vehicle.encode(encoder);
    final id =
        await parse.create(serverManager.server!, Vehicle.className, data);
    vehicle.id = id;
  }
}

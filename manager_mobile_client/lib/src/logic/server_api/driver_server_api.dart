import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/driver.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';
import 'utility.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/driver.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class DriverServerAPI {
  final ServerManager serverManager;

  DriverServerAPI(this.serverManager);

  Future<List<Driver>> listFree(int skip, int limit, Carrier carrier) async {
    final builder = parse.QueryBuilder(Driver.className);
    builder.equalTo('deleted', false);
    builder.doesNotExist('transportUnit');
    builder.equalToObject('carrier', Carrier.className, carrier.id);
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server);
    return results.map((json) => Driver.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }

  Future<void> create(Driver driver) async {
    final data = <String, dynamic>{};
    final encoder = Encoder(data);
    driver.encode(encoder);
    final id = await parse.create(serverManager.server, Driver.className, data);
    driver.id = id;
    driver.internal = true;
  }

  Future<bool> verify(Driver driver) async {
    final parameters = {
      'driverId': driver.id,
    };
    final result = await callCloudFunction(serverManager.server, 'Dispatcher_verifyDriver', parameters);
    final powerOfAttorney = result['powerOfAttorney'];
    if (powerOfAttorney is! bool) {
      throw InvalidResponseException();
    }
    return powerOfAttorney;
  }
}

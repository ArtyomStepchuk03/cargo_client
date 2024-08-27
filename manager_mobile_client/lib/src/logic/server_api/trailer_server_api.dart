import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/trailer.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/trailer.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class TrailerServerAPI {
  final ServerManager serverManager;

  TrailerServerAPI(this.serverManager);

  Future<bool> exists(String number, Carrier carrier) async {
    final builder = parse.QueryBuilder(Trailer.className);
    builder.equalTo('deleted', false);
    builder.equalTo('number', number);
    builder.equalToObject('carrier', Carrier.className, carrier.id);
    final count = await builder.count(serverManager.server);
    return count != 0;
  }

  Future<List<Trailer>> listFree(int skip, int limit, Carrier carrier) async {
    final builder = parse.QueryBuilder(Trailer.className);
    builder.equalTo('deleted', false);
    builder.doesNotExist('transportUnit');
    builder.equalToObject('carrier', Carrier.className, carrier.id);
    builder.skip(skip);
    builder.limit(limit);
    builder.addDescending('createdAt');
    final results = await builder.find(serverManager.server);
    return results.map((json) => Trailer.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }

  Future<void> create(Trailer trailer) async {
    final data = <String, dynamic>{};
    final encoder = Encoder(data);
    trailer.encode(encoder);
    final id = await parse.create(serverManager.server, Trailer.className, data);
    trailer.id = id;
  }
}

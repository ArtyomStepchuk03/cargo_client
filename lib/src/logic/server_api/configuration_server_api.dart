import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/configuration.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/configuration.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class ConfigurationServerAPI {
  final ServerManager serverManager;

  ConfigurationServerAPI(this.serverManager);

  Future<Configuration?> get(User? user) async {
    final builder = parse.QueryBuilder(Configuration.className);
    if (user != null) {
      builder.include('supplierOrder');
      builder.include('supplierOrder.articleBrands.type');
    }
    final result = await builder.findFirst(serverManager.server!);
    return Configuration.decode(Decoder(result));
  }
}

import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/purchase_tariff.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/purchase_tariff.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class PurchaseTariffServerAPI {
  final ServerManager serverManager;

  PurchaseTariffServerAPI(this.serverManager);

  Future<List<PurchaseTariff>> list() async {
    final builder = parse.QueryBuilder(PurchaseTariff.className);
    final results = await builder.findAll(serverManager.server);
    return results.map((json) => PurchaseTariff.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }
}

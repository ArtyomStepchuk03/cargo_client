import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/sale_tariff.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/sale_tariff.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class SaleTariffServerAPI {
  final ServerManager serverManager;

  SaleTariffServerAPI(this.serverManager);

  Future<List<SaleTariff?>> list(UnloadingPoint unloadingPoint) async {
    final builder = parse.QueryBuilder(SaleTariff.className);
    builder.include('articleBrand');
    builder.equalToObject(
        'unloadingPoint', UnloadingPoint.className, unloadingPoint.id);
    final results = await builder.findAll(serverManager.server!);
    return results
        .map((json) => SaleTariff.decode(Decoder(json)))
        .whereType<SaleTariff>()
        .toList();
  }
}

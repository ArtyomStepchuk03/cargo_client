import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/distance.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/distance.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class DistanceServerAPI {
  final ServerManager serverManager;

  DistanceServerAPI(this.serverManager);

  Future<num?> get(
      LoadingPoint loadingPoint, UnloadingPoint unloadingPoint) async {
    final builder = parse.QueryBuilder(Distance.className);
    builder.equalToObject(
        'loadingPoint', LoadingPoint.className, loadingPoint.id);
    builder.equalToObject(
        'unloadingPoint', UnloadingPoint.className, unloadingPoint.id);
    final result = await builder.findFirst(serverManager.server!);
    final distanceObject = Distance.decode(Decoder(result));
    return distanceObject?.distance;
  }
}

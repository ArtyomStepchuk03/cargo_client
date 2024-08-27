import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/loading_point.dart';
import 'package:manager_mobile_client/src/logic/data/deletion_marking.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/loading_point.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class LoadingPointServerAPI {
  final ServerManager serverManager;

  LoadingPointServerAPI(this.serverManager);

  Future<void> fetchEntrances(LoadingPoint loadingPoint) async {
    final fetched = await parse.getById(serverManager.server, LoadingPoint.className, loadingPoint.id, include: ['entrances']);
    if (fetched == null) {
      throw RequestFailedException();
    }
    loadingPoint.entrances = Decoder(fetched).decodeObjectList('entrances', (Decoder decoder) => Entrance.decode(decoder))?.excludeDeleted();
  }
}

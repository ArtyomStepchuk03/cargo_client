import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/installation.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/installation.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class InstallationServerAPI {
  final ServerManager serverManager;

  InstallationServerAPI(this.serverManager);

  Future<Installation> getById(String id) async {
    final result = await parse.getInstallationById(serverManager.server, id);
    if (result == null) {
      return null;
    }
    final installation = Installation.decode(Decoder(result));
    if (installation == null) {
      throw InvalidResponseException();
    }
    return installation;
  }

  Future<Installation> create(String deviceToken, User user) async {
    final data = <String, dynamic>{};
    final encoder = Encoder(data);
    encoder.encodeString('deviceType', 'android');
    encoder.encodeString('pushType', 'gcm');
    encoder.getListEncoder('channels').addString('');
    encoder.encodeDeviceToken(deviceToken);
    encoder.encodeUserPointer('user', user?.id);
    final id = await parse.createInstallation(serverManager.server, data);
    final installation = Installation();
    installation.id = id;
    installation.user = user;
    return installation;
  }

  Future<void> updateUser(Installation installation) async {
    final data = <String, dynamic>{};
    final encoder = Encoder(data);
    encoder.encodeUserPointer('user', installation.user?.id);
    await parse.updateInstallation(serverManager.server, installation.id, data);
  }
}

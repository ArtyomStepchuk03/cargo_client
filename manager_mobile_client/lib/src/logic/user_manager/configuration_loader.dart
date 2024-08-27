import 'package:manager_mobile_client/src/logic/server_api/configuration_server_api.dart';
import 'package:manager_mobile_client/src/logic/user_manager/user_manager.dart';

export 'package:manager_mobile_client/src/logic/server_api/configuration_server_api.dart';

class ConfigurationLoader {
  final ConfigurationServerAPI serverAPI;
  final UserManager userManager;

  ConfigurationLoader(this.serverAPI, this.userManager);

  Configuration get configuration => _configuration;

  Future<void> reload() async {
    if (_configuration == null) print('Loading configuration...');
    try {
      final configuration = await serverAPI.get(userManager.currentUser);
      if (configuration == null) {
        print('Failed to load configuration.');
        return;
      }
      _configuration = configuration;
    } on ConnectionErrorException {
      print('Connection failed trying to load configuration.');
    } on Exception catch (exception) {
      print('Failed to load configuration: $exception.');
    }
  }

  Configuration _configuration;
}

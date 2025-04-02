import 'package:flutter/foundation.dart';
import 'package:manager_mobile_client/src/logic/parse/server_configuration.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/parse_live_query/live_query_manager.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager_storage.dart';

import 'company_server_configuration_source.dart';
import 'default_server.dart';

class ServerManager {
  final ServerManagerStorage? storage;
  final CompanyServerConfigurationSource? companyServerConfigurationSource;

  ServerManager(this.storage, this.companyServerConfigurationSource);

  Future<void> load() async {
    print('Loading server configuration...');
    final storedServerConfiguration = await storage?.getServerConfiguration();
    if (storedServerConfiguration != null && !kDebugMode) {
      _setServer(storedServerConfiguration);
    } else {
      print('No stored server configuration. Using default.');
      _setServer(DefaultServerConfiguration.makeDefault());
    }
  }

  Future<void> configure(String companyName) async {
    _unsetServer();
    await storage?.unsetServerConfiguration();
    final companyServersInformation =
        await companyServerConfigurationSource?.get();
    final companyServerInformation = companyServersInformation?.firstWhere(
        (information) => information.name == companyName,
        orElse: null);
    if (companyServerInformation == null) {
      return;
    }
    _setServer(companyServerInformation.configuration);
    await storage!
        .setServerConfiguration(companyServerInformation.configuration!);
  }

  Future<void> unsetConfiguration() async {
    _unsetServer();
    await storage!.unsetServerConfiguration();
  }

  parse.Server? get server => _server;
  parse.LiveQueryManager? get liveQueryManager => _liveQueryManager;

  void setAuthorized(String sessionToken) {
    parse.ServerConfigurationUtility(_server!).setAuthorized(sessionToken);
    _liveQueryManager?.sessionToken = sessionToken;
  }

  void setUnauthorized() {
    parse.ServerConfigurationUtility(_server!).setUnauthorized();
    liveQueryManager?.sessionToken = null;
  }

  factory ServerManager.standard() =>
      ServerManager(ServerManagerStorage(), CompanyServerConfigurationSource());

  parse.Server? _server;
  parse.LiveQueryManager? _liveQueryManager;

  void _setServer(parse.ServerConfiguration? serverConfiguration) {
    _server = parse.ServerConfigurationUtility.fromConfiguration(
        serverConfiguration!);
    _liveQueryManager = parse.LiveQueryManager(
        parse.LiveQueryConfigurationFactory.fromServer(serverConfiguration));
  }

  void _unsetServer() {
    _server = null;
    _liveQueryManager = null;
  }
}

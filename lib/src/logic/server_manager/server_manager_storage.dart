import 'dart:convert';

import 'package:manager_mobile_client/src/logic/parse/server_configuration.dart'
    as parse;
import 'package:shared_preferences/shared_preferences.dart';

class ServerManagerStorage {
  const ServerManagerStorage();

  Future<void> setServerConfiguration(
      parse.ServerConfiguration serverConfiguration) async {
    final preferences = await SharedPreferences.getInstance();
    final jsonString = _encode(serverConfiguration);
    await preferences.setString(_serverConfigurationKey, jsonString);
  }

  Future<void> unsetServerConfiguration() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_serverConfigurationKey);
  }

  Future<parse.ServerConfiguration?> getServerConfiguration() async {
    final preferences = await SharedPreferences.getInstance();
    final jsonString = preferences.getString(_serverConfigurationKey);
    if (jsonString == null) {
      return null;
    }
    return _decode(jsonString);
  }

  String _encode(parse.ServerConfiguration serverConfiguration) {
    final data = {
      'baseUrl': serverConfiguration.baseUrl,
      'applicationId': serverConfiguration.applicationId,
      'clientKey': serverConfiguration.clientKey,
    };
    return json.encode(data);
  }

  parse.ServerConfiguration? _decode(String jsonString) {
    final data = json.decode(jsonString);
    if (data is! Map<String, dynamic>) {
      return null;
    }
    final baseUrl = data['baseUrl'];
    final applicationId = data['applicationId'];
    final clientKey = data['clientKey'];
    if (baseUrl == null || applicationId == null || clientKey == null) {
      return null;
    }
    if (baseUrl is! String ||
        applicationId is! String ||
        clientKey is! String) {
      return null;
    }
    return parse.ServerConfiguration(
        baseUrl: baseUrl, applicationId: applicationId, clientKey: clientKey);
  }

  static const _serverConfigurationKey =
      'com.macsoftex.CargoDeal.ServerManagerStorage.serverConfiguration';
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/http_utility/content_type.dart' as http_utility;
import 'package:manager_mobile_client/src/logic/http_utility/status_code.dart' as http_utility;
import 'package:manager_mobile_client/src/logic/parse/server_configuration.dart' as parse;

class CompanyServerInformation {
  final String name;
  final parse.ServerConfiguration configuration;
  CompanyServerInformation({this.name, this.configuration});
}

class CompanyServerConfigurationSource {
  Future<List<CompanyServerInformation>> get() async {
    final headers = {'Content-Type': http_utility.contentTypeJson};
    final response = await http.get(Uri.parse('https://config.cargodeal.ru/companies.json'), headers: headers);
    if (http_utility.isServerError(response.statusCode)) {
      throw ConnectionErrorException();
    }
    if (http_utility.isClientError(response.statusCode)) {
      throw RequestFailedException();
    }
    if (response.statusCode != http_utility.statusCodeOk) {
      throw InvalidResponseException();
    }
    final data = json.decode(response.body);
    if (data is! Map<String, dynamic>) {
      throw InvalidResponseException();
    }
    final serversInformation = _decode(data);
    if (serversInformation == null) {
      throw InvalidResponseException();
    }
    return serversInformation;
  }

  List<CompanyServerInformation> _decode(Map<String, dynamic> data) {
    final companiesData = data['companies'];
    if (companiesData == null || companiesData is! List<dynamic>) {
      return null;
    }
    var serversInformation = <CompanyServerInformation>[];
    for (final companyData in companiesData) {
      final serverInformation = _decodeServerInformation(companyData);
      if (serverInformation == null) {
        return null;
      }
      serversInformation.add(serverInformation);
    }
    return serversInformation;
  }

  CompanyServerInformation _decodeServerInformation(Map<String, dynamic> data) {
    final name = data['name'];
    final baseUrl = data['baseUrl'];
    final applicationId = data['appId'];
    final clientKey = data['clientId'];
    if (name == null || baseUrl == null || applicationId == null || clientKey == null) {
      return null;
    }
    if (name is! String || baseUrl is! String || applicationId is! String || clientKey is! String) {
      return null;
    }
    return CompanyServerInformation(name: name, configuration: parse.ServerConfiguration(baseUrl: baseUrl, applicationId: applicationId, clientKey: clientKey));
  }
}

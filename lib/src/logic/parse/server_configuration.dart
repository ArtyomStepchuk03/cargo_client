import 'server.dart';

export 'server.dart';

class ServerConfiguration {
  final String? baseUrl;
  final String applicationId;
  final String clientKey;
  ServerConfiguration(
      {this.baseUrl, required this.applicationId, required this.clientKey});
}

extension ServerConfigurationUtility on Server {
  static Server fromConfiguration(ServerConfiguration configuration) {
    return Server(configuration.baseUrl, {
      'X-Parse-Application-Id': configuration.applicationId,
      'X-Parse-Client-Key': configuration.clientKey,
    });
  }

  void setAuthorized(String sessionToken) =>
      addHeader(_sessionTokenHeaderName, sessionToken);
  void setUnauthorized() => removeHeader(_sessionTokenHeaderName);

  static const _sessionTokenHeaderName = 'X-Parse-Session-Token';
}

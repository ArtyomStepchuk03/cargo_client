import 'package:manager_mobile_client/src/logic/parse/server_configuration.dart';

class LiveQueryConfiguration {
  final String? url;
  final String? applicationId;
  final String? clientKey;
  LiveQueryConfiguration({this.url, this.applicationId, this.clientKey});
}

extension LiveQueryConfigurationFactory on LiveQueryConfiguration {
  static LiveQueryConfiguration fromServer(
      ServerConfiguration serverConfiguration) {
    return LiveQueryConfiguration(
      url: serverConfiguration.baseUrl?.replaceRange(0, 4, 'ws'),
      applicationId: serverConfiguration.applicationId,
      clientKey: serverConfiguration.clientKey,
    );
  }
}

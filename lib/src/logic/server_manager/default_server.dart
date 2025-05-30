import 'package:manager_mobile_client/src/logic/parse/server_configuration.dart'
    as parse;

extension DefaultServerConfiguration on parse.ServerConfiguration {
  static parse.ServerConfiguration makeDefault() => makeDevelop();

  static parse.ServerConfiguration makeProduction() {
    return parse.ServerConfiguration(
      baseUrl: 'http://192.168.43.138:50003/cargodeal/',
      applicationId: 'gtn7enhk9goEASSL7eWqq8VaUGFLg2dE9WUBRIqR',
      clientKey: 'D67YFaFbzGWoYo3LqiBEkNHuTDezr7XktWRFjGYu',
    );
  }

  static parse.ServerConfiguration makeDevelop() {
    return parse.ServerConfiguration(
      baseUrl: 'http://192.168.43.138:50003/cargodeal-dev/',
      applicationId: 'X3nvnkeAubR8L23s8BpzWELQ9uCRAXw0HfHxG9uU',
      clientKey: 'u2ylnpgBkJ52a6q7Ge4VyDJ9OFbUp53luKnzs0NF',
    );
  }
}

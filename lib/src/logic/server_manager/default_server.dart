import 'package:manager_mobile_client/src/logic/parse/server_configuration.dart'
    as parse;

extension DefaultServerConfiguration on parse.ServerConfiguration {
  static parse.ServerConfiguration makeDefault() => makeDevelop();

  static parse.ServerConfiguration makeProduction() {
    return parse.ServerConfiguration(
      baseUrl: 'https://dash.cargodeal.ru/cargodeal-dev/',
      applicationId: 'X3nvnkeAubR8L23s8BpzWELQ9uCRAXw0HfHxG9uU',
      clientKey: 'u2ylnpgBkJ52a6q7Ge4VyDJ9OFbUp53luKnzs0NF',
    );
  }

  static parse.ServerConfiguration makeDevelop() {
    return parse.ServerConfiguration(
      baseUrl: 'https://dash.cargodeal.ru/cargodeal-dev/',
      applicationId: 'X3nvnkeAubR8L23s8BpzWELQ9uCRAXw0HfHxG9uU',
      clientKey: 'u2ylnpgBkJ52a6q7Ge4VyDJ9OFbUp53luKnzs0NF',
    );
  }
}

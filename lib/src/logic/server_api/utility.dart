import 'package:manager_mobile_client/src/logic/coder/encoder.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;

import 'server_error.dart';

Future<void> markDeleted(
    parse.Server server, String className, String? id) async {
  final data = <String, dynamic>{};
  final encoder = Encoder(data);
  encoder.encodeBoolean('deleted', true);
  await parse.update(server, className, id, data);
}

Future<Map<String, dynamic>> callCloudFunction(
    parse.Server server, String functionName,
    [Map<String, dynamic>? parameters]) async {
  final result = await parse.call(server, functionName, parameters);
  if (result is! Map<String, dynamic>) {
    throw InvalidResponseException();
  }
  final status = result['result'];
  if (status is! bool) {
    throw InvalidResponseException();
  }
  if (!status) {
    final error = result['error'];
    if (error is! String) {
      throw InvalidResponseException();
    }
    throw CloudFunctionFailedException(error);
  }
  return result;
}

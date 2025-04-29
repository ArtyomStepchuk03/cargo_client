import 'dart:convert';

import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/http_utility/content_type.dart';

import 'constants.dart';
import 'server.dart';

Future<dynamic> getById(Server? server, String relativeUrl, String? id,
    {List<String>? include}) async {
  var url = '$relativeUrl/$id';
  if (include != null && include.length != 0) {
    final value = include.join(',');
    url += '?include=$value';
  }
  final body = await server?.performGet(url);
  if (body == null) {
    return null;
  }
  return json.decode(body);
}

Future<Map<String, dynamic>?> getObjectById(
    Server? server, String relativeUrl, String? id,
    {List<String>? include}) async {
  final result = await getById(server, relativeUrl, id, include: include);
  if (result == null) {
    return null;
  }
  if (result is! Map<String, dynamic>) {
    throw InvalidResponseException();
  }
  return result;
}

Future<dynamic> getForMe(Server server, String relativeUrl) async {
  final body = await server.performGet('$relativeUrl/me');
  if (body == null) {
    return null;
  }
  return json.decode(body);
}

Future<Map<String, dynamic>?> getObjectForMe(
    Server server, String relativeUrl) async {
  final result = await getForMe(server, relativeUrl);
  if (result == null) {
    return null;
  }
  if (result is! Map<String, dynamic>) {
    throw InvalidResponseException();
  }
  return result;
}

Future<List<dynamic>> find(Server server, String relativeUrl,
    {String? where,
    List<String>? include,
    int? skip = 0,
    int? limit = 100,
    List<String>? order}) async {
  var url = '$relativeUrl?skip=$skip&limit=$limit';
  if (where != null && where.isNotEmpty) {
    url += '&where=${Uri.encodeQueryComponent(where)}';
  }
  if (include != null && include.length != 0) {
    final value = include.join(',');
    url += '&include=$value';
  }
  if (order != null && order.length != 0) {
    final value = order.join(',');
    url += '&order=$value';
  }
  final body = await server.performGet(url);
  final data = json.decode(body);
  if (data is! Map<String, dynamic>) {
    throw InvalidResponseException();
  }
  final results = data['results'];
  if (results == null || results is! List<dynamic>) {
    throw InvalidResponseException();
  }
  return results;
}

Future<int> count(Server server, String relativeUrl, {String? where}) async {
  var url = '$relativeUrl?limit=0&count=1';
  if (where != null && where.isNotEmpty) {
    url += '&where=${Uri.encodeQueryComponent(where)}';
  }
  final body = await server.performGet(url);
  final data = json.decode(body);
  if (data is! Map<String, dynamic>) {
    throw InvalidResponseException();
  }
  final count = data['count'];
  if (count == null || count is! int) {
    throw InvalidResponseException();
  }
  return count;
}

Future<dynamic> create(Server server, String relativeUrl, dynamic body,
    {String? contentType}) async {
  return await server.performPost(relativeUrl,
      body: body, contentType: contentType);
}

Future<String> createObject(
    Server server, String relativeUrl, Map<String, dynamic> data) async {
  final requestBody = json.encode(data);
  final responseBody = await create(server, relativeUrl, requestBody,
      contentType: contentTypeJson);
  final responseData = json.decode(responseBody);
  if (responseData is! Map<String, dynamic>) {
    throw InvalidResponseException();
  }
  final id = responseData[idKey];
  if (id is! String) {
    throw InvalidResponseException();
  }
  return id;
}

Future<void> update(Server server, String relativeUrl, String? id, dynamic body,
    {String? contentType}) async {
  await server.performPut('$relativeUrl/$id',
      body: body, contentType: contentType);
}

Future<void> updateObject(Server server, String relativeUrl, String? id,
    Map<String, dynamic> data) async {
  final requestBody = json.encode(data);
  await update(server, relativeUrl, id, requestBody,
      contentType: contentTypeJson);
}

Future<void> delete(Server server, String relativeUrl, String id) async {
  await server.performDelete('$relativeUrl/$id');
}

Future<dynamic> call(Server? server, String relativeUrl,
    [Map<String, dynamic>? parameters]) async {
  String? requestBody;
  if (parameters != null) {
    requestBody = json.encode(parameters);
  }
  final responseBody =
      await server?.performPost(relativeUrl, body: requestBody);
  final data = json.decode(responseBody);
  if (data is! Map<String, dynamic>) {
    throw InvalidResponseException();
  }
  return data['result'];
}

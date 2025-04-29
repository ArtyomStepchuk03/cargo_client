import 'dart:convert';
import 'dart:io';

import 'package:manager_mobile_client/src/logic/core/remote_file.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

import 'server.dart';
import 'url_requests.dart' as url_requests;
import 'urls.dart';

export 'server.dart';

Future<Map<String, dynamic>?> getById(
    Server? server, String className, String? id,
    {List<String>? include}) async {
  return await url_requests.getObjectById(
      server, getClassRelativeUrl(className), id,
      include: include);
}

Future<Map<String, dynamic>?> getUserById(Server? server, String? id,
    {List<String>? include}) async {
  return await url_requests.getObjectById(server, userRelativeUrl, id,
      include: include);
}

Future<Map<String, dynamic>?> getInstallationById(
    Server server, String id) async {
  return await url_requests.getObjectById(server, installationRelativeUrl, id);
}

Future<Map<String, dynamic>?> getMe(Server server) async {
  return await url_requests.getObjectForMe(server, userRelativeUrl);
}

Future<String> create(
    Server server, String className, Map<String, dynamic> data) async {
  return await url_requests.createObject(
      server, getClassRelativeUrl(className), data);
}

Future<String> createInstallation(
    Server server, Map<String, dynamic> data) async {
  return await url_requests.createObject(server, installationRelativeUrl, data);
}

Future<RemoteFile> createFile(
    Server server, File file, String name, String contentType) async {
  final requestBody = await file.readAsBytes();
  final responseBody = await url_requests.create(
      server, getFileRelativeUrl(name), requestBody,
      contentType: contentType);
  final responseData = json.decode(responseBody);
  if (responseData is! Map<String, dynamic>) {
    throw InvalidResponseException();
  }
  final uniqueName = responseData['name'];
  final url = responseData['url'];
  if (uniqueName is! String || url is! String) {
    throw InvalidResponseException();
  }
  return RemoteFile(uniqueName, url);
}

Future<void> update(Server server, String className, String? id,
    Map<String, dynamic> data) async {
  await url_requests.updateObject(
      server, getClassRelativeUrl(className), id, data);
}

Future<void> updateInstallation(
    Server server, String? id, Map<String, dynamic> data) async {
  await url_requests.updateObject(server, installationRelativeUrl, id, data);
}

Future<void> delete(Server server, String className, String id) async {
  await url_requests.delete(server, getClassRelativeUrl(className), id);
}

Future<dynamic> call(Server? server, String functionName,
    [Map<String, dynamic>? parameters]) async {
  return await url_requests.call(
      server, getFunctionRelativeUrl(functionName), parameters);
}

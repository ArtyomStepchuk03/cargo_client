import 'dart:convert';
import 'package:manager_mobile_client/src/logic/coder/decoder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
import 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';
import 'package:manager_mobile_client/src/logic/parse/query_builder.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/user.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class UserServerAPI {
  final ServerManager serverManager;

  UserServerAPI(this.serverManager);

  Future<User> getById(String id) async {
    final result = await parse.getUserById(serverManager.server, id, include: ['logistician', 'manager', 'dispatcher', 'customer', 'carrier']);
    if (result == null) {
      return null;
    }
    final user = User.decode(Decoder(result));
    if (user == null) {
      throw InvalidResponseException();
    }
    return user;
  }

  Future<User> getMe() async {
    final result = await parse.getMe(serverManager.server);
    if (result == null) {
      return null;
    }
    final user = User.decode(Decoder(result));
    if (user == null || user.sessionToken == null) {
      throw InvalidResponseException();
    }
    return user;
  }

  Future<List<User>> list(List<String> roles, int skip, int limit) async {
    final builder = parse.QueryBuilder.users();
    builder.containedIn('role', roles);
    builder.include('logistician');
    builder.include('manager');
    builder.include('dispatcher');
    builder.include('driver');
    builder.include('customer');
    builder.include('supplier');
    builder.skip(skip);
    builder.limit(limit);
    builder.addAscending('role');
    final results = await builder.find(serverManager.server);
    return results.map((json) => User.decode(Decoder(json))).where((decoded) => decoded != null).toList();
  }

  Future<User> logIn(String userName, String password) async {
    final body = await serverManager.server.performGet('login?username=${Uri.encodeQueryComponent(userName)}&password=${Uri.encodeQueryComponent(password)}', headers: {'X-Parse-Revocable-Session': '1'});
    if (body == null) {
      return null;
    }
    final data = json.decode(body);
    final user = User.decode(Decoder(data));
    if (user == null || user.sessionToken == null) {
      throw InvalidResponseException();
    }
    return user;
  }

  Future<void> logOut() async {
    await serverManager.server.performPost('logout');
  }
}

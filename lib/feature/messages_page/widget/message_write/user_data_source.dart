import 'package:collection/collection.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';
import 'package:manager_mobile_client/src/logic/server_api/user_server_api.dart';

export 'package:manager_mobile_client/src/logic/server_api/user_server_api.dart';

class UserDataSource implements SkipPagedDataSource<User> {
  final UserServerAPI serverAPI;
  final List<String> roles;

  UserDataSource(this.serverAPI, this.roles);

  Future<List<User>> list(int skip, int limit) async {
    return await serverAPI.list(roles, skip, limit);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! UserDataSource) {
      return false;
    }
    final UserDataSource otherSource = other;
    return ListEquality().equals(roles, otherSource.roles);
  }

  @override
  int get hashCode => roles.hashCode;
}

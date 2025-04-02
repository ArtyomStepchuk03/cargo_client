import 'package:manager_mobile_client/src/logic/server_api/user_server_api.dart';
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';

import 'user_storage.dart';

export 'package:manager_mobile_client/src/logic/server_api/user_server_api.dart';

export 'user_storage.dart';

class UserManager {
  final ServerManager serverManager;
  final UserServerAPI serverAPI;
  final UserStorage storage;

  UserManager(this.serverManager, this.serverAPI, this.storage);

  User? get currentUser => _currentUser;

  Future<void> restore() async {
    print('Restoring session...');
    final sessionToken = await storage.getSessionToken();
    if (sessionToken == null) {
      print('Stored session not found.');
      return;
    }
    serverManager.setAuthorized(sessionToken);
    try {
      final rawUser = await serverAPI.getMe();
      if (rawUser != null) {
        _currentUser = await serverAPI.getById(rawUser.id);
        if (_currentUser == null) {
          print('Failed to fetch user.');
        }
      } else {
        print('Failed to verify stored session.');
      }
      if (_currentUser == null) {
        serverManager.setUnauthorized();
        await storage.unsetSessionToken();
        print('Cleared stored session.');
      }
    } on ConnectionErrorException {
      print('Connection failed trying to restore session.');
      serverManager.setUnauthorized();
      rethrow;
    } on Exception catch (exception) {
      print('Failed to restore session: $exception.');
      serverManager.setUnauthorized();
      await storage.unsetSessionToken();
      print('Cleared stored session.');
    }
  }

  Future<void> logIn(String userName, String password) async {
    final rawUser = await serverAPI.logIn(userName, password);
    if (rawUser == null) {
      print('Failed to log in.');
      return;
    }

    if (!_allowedRoles.contains(rawUser.role)) {
      print('User name is unallowed to log in.');
      return;
    }

    await storage.setSessionToken(rawUser.sessionToken!);
    serverManager.setAuthorized(rawUser.sessionToken!);

    try {
      _currentUser = await serverAPI.getById(rawUser.id);
    } on ConnectionErrorException {
      print('Connection failed trying to log in.');
      serverManager.setUnauthorized();
      rethrow;
    } on Exception catch (exception) {
      print('Failed to fetch user: $exception.');
      serverManager.setUnauthorized();
      await storage.unsetSessionToken();
      print('Cleared stored session.');
      rethrow;
    }
    if (_currentUser == null) {
      print('Failed to fetch user.');
      serverManager.setUnauthorized();
      await storage.unsetSessionToken();
      print('Cleared stored session.');
      throw RequestFailedException();
    }
  }

  Future<void> logOut() async {
    try {
      await serverAPI.logOut();
    } on ConnectionErrorException catch (exception) {
      print('Connection failed trying to log out: $exception');
      rethrow;
    } on Exception catch (exception) {
      print('Failed to log out: $exception.');
    }
    serverManager.setUnauthorized();
    await storage.unsetSessionToken();
    print('Cleared stored session.');
    _currentUser = null;
  }

  factory UserManager.standard(
          ServerManager serverManager, UserServerAPI serverAPI) =>
      UserManager(serverManager, serverAPI, UserStorage());

  static const _allowedRoles = {
    Role.manager,
    Role.administrator,
    Role.logistician,
    Role.dispatcher,
    Role.customer
  };

  User? _currentUser;
}

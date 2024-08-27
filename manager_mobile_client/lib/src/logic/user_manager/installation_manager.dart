import 'package:manager_mobile_client/src/logic/external/push_notification_client.dart';
import 'package:manager_mobile_client/src/logic/server_api/installation_server_api.dart';
import 'installation_storage.dart';

export 'package:manager_mobile_client/src/logic/server_api/installation_server_api.dart';
export 'installation_storage.dart';

class InstallationManager {
  final InstallationServerAPI serverAPI;
  final InstallationStorage storage;

  InstallationManager(this.serverAPI, this.storage);

  Installation get currentInstallation => _currentInstallation;

  Future<void> registerDevice(PushNotificationClient pushNotificationClient, User user) async {
    print('Checking if device needs registration...');
    final storedInstallationId = await storage.getInstallationId();
    bool createInstallation = true;
    if (storedInstallationId != null) {
      try {
        _currentInstallation = await serverAPI.getById(storedInstallationId);
        if (_currentInstallation != null) {
          createInstallation = false;
          await _checkUser(user);
        } else {
          print('Failed to fetch installation.');
          await storage.unsetInstallationId();
          print('Cleared stored installation.');
        }
      } on ConnectionErrorException {
        print('Connection failed trying to fetch installation.');
        createInstallation = false;
      } on Exception catch (exception) {
        print('Failed to fetch installation: $exception.');
      }
    } else {
      print('Stored installation not found.');
    }
    if (createInstallation) {
      final token = await pushNotificationClient.getToken();
      if (token != null) {
        try {
          _currentInstallation = await serverAPI.create(token, user);
          print('Installation created.');
          await storage.setInstallationId(_currentInstallation.id);
          print('Installation stored.');
        } on Exception catch (exception) {
          print('Failed to create installation: $exception.');
        }
      } else {
        print('Failed to get push notification token.');
      }
    }
  }

  Future<void> attachUser(PushNotificationClient pushNotificationClient, User user) async {
    if (_currentInstallation == null) {
      print('No installation. Will try to register device.');
      await registerDevice(pushNotificationClient, user);
    } else {
      await _updateUser(user);
    }
  }

  Future<void> detachUser() async {
    if (_currentInstallation != null) {
      await _updateUser(null);
    } else {
      print('No installation. Cannot detach user.');
    }
  }

  factory InstallationManager.standard(InstallationServerAPI serverAPI) => InstallationManager(serverAPI, InstallationStorage());

  Installation _currentInstallation;

  Future<void> _checkUser(User user) async {
    if (_currentInstallation.user?.id != user?.id) {
      print('Installation user mismatch. Updating...');
      await _updateUser(user);
      print('Installation user updated.');
    }
  }

  Future<void> _updateUser(User user) async {
    try {
      _currentInstallation.user = user;
      await serverAPI.updateUser(_currentInstallation);
    } on Exception catch (exception) {
      print('Failed to update installation: $exception.');
    }
  }
}

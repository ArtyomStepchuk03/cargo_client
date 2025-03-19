import 'package:shared_preferences/shared_preferences.dart';

class InstallationStorage {
  const InstallationStorage();

  Future<void> setInstallationId(String installationId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_installationIdKey, installationId);
  }

  Future<void> unsetInstallationId() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_installationIdKey);
  }

  Future<String?> getInstallationId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_installationIdKey);
  }

  static const _installationIdKey =
      'com.macsoftex.CargoDeal.UserStorage.installationId';
}

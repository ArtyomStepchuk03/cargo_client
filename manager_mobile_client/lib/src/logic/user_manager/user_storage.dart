import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  const UserStorage();

  Future<void> setSessionToken(String sessionToken) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionTokenKey, sessionToken);
  }

  Future<void> unsetSessionToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionTokenKey);
  }

  Future<String> getSessionToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_sessionTokenKey);
  }

  static const _sessionTokenKey = 'com.macsoftex.CargoDeal.UserStorage.sessionToken';
}

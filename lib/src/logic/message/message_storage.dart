import 'package:shared_preferences/shared_preferences.dart';

class MessageStorage {
  const MessageStorage();

  Future<void> setLastSeenMessageDate(DateTime date) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
        _lastSeenMessageDateKey, date.millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastSeenMessageDate() async {
    final preferences = await SharedPreferences.getInstance();
    final millisecondsSinceEpoch = preferences.getInt(_lastSeenMessageDateKey);
    if (millisecondsSinceEpoch == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  }

  static const _lastSeenMessageDateKey =
      'com.cargodeal.CargoDeal.MessageStorage.lastSeenMessageDate';
}

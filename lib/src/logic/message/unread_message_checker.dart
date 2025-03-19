import 'package:manager_mobile_client/src/logic/server_api/message_server_api.dart';
import 'package:manager_mobile_client/src/logic/user_manager/user_manager.dart';

import 'message_storage.dart';

class UnreadMessageChecker {
  final MessageServerAPI serverAPI;
  final UserManager? userManager;
  final MessageStorage storage;

  UnreadMessageChecker(this.serverAPI, this.userManager, this.storage);

  Future<Message?> check() async {
    if (_checked) {
      return null;
    }
    _checked = true;
    if (userManager?.currentUser == null) {
      return null;
    }
    final message = await serverAPI.getLast(userManager?.currentUser);
    if (message == null) {
      return null;
    }
    final date = await storage.getLastSeenMessageDate();
    await storage.setLastSeenMessageDate(message.date!);
    if (date != null && !message.date!.isAfter(date)) {
      return null;
    }
    return message;
  }

  factory UnreadMessageChecker.standard(
          MessageServerAPI serverAPI, UserManager userManager) =>
      UnreadMessageChecker(serverAPI, userManager, MessageStorage());

  var _checked = false;
}

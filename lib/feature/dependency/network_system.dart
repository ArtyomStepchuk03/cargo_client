import 'package:manager_mobile_client/src/logic/external/reachability.dart';
import 'package:manager_mobile_client/src/logic/external/push_notification_client.dart';

import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';
import 'package:manager_mobile_client/src/logic/user_manager/installation_manager.dart';
import 'package:manager_mobile_client/src/logic/user_manager/user_manager.dart';
import 'package:manager_mobile_client/src/logic/user_manager/configuration_loader.dart';
import 'package:manager_mobile_client/src/logic/message/unread_message_checker.dart';

import 'full_server_api.dart';

class NetworkSystem {
  final Reachability reachability;
  final PushNotificationClient pushNotificationClient;
  final ServerManager serverManager;
  final FullServerAPI serverAPI;
  final InstallationManager installationManager;
  final UserManager userManager;
  final ConfigurationLoader configurationLoader;
  final UnreadMessageChecker unreadMessageChecker;

  NetworkSystem(
    this.reachability,
    this.pushNotificationClient,
    this.serverManager,
    this.serverAPI,
    this.installationManager,
    this.userManager,
    this.configurationLoader,
    this.unreadMessageChecker,
  );

  factory NetworkSystem.standard() {
    final reachability = Reachability();
    final pushNotificationClient = PushNotificationClient();

    final serverManager = ServerManager.standard();
    final serverAPI = FullServerAPI.standard(serverManager);
    final installationManager = InstallationManager.standard(serverAPI.installations);
    final userManager = UserManager.standard(serverManager, serverAPI.users);
    final configurationLoader = ConfigurationLoader(serverAPI.configuration, userManager);
    final unreadMessageChecker = UnreadMessageChecker.standard(serverAPI.messages, userManager);

    return NetworkSystem(
      reachability,
      pushNotificationClient,
      serverManager,
      serverAPI,
      installationManager,
      userManager,
      configurationLoader,
      unreadMessageChecker,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/safe_cast.dart';
import 'package:manager_mobile_client/src/logic/external/push_notification_client.dart';
import 'package:manager_mobile_client/src/logic/external/sound_alert.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/order.dart';
import 'package:manager_mobile_client/src/logic/message/unread_message_checker.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/information_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/authorization/authorization_widget.dart';
import 'package:manager_mobile_client/src/ui/order/order_details/order_details_widget.dart';
import 'package:manager_mobile_client/src/ui/main/main_strings.dart' as strings;

class PushNotificationWidget extends StatefulWidget {
  final Widget child;

  PushNotificationWidget({this.child});

  @override
  State<StatefulWidget> createState() => PushNotificationState();
}

class PushNotificationState extends State<PushNotificationWidget> {
  PushNotificationState() : _handling = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_client == null) {
      final dependencyState = DependencyHolder.of(context);
      _client = dependencyState.network.pushNotificationClient;
      _unreadMessageChecker = dependencyState.network.unreadMessageChecker;
      _addHandler();
      _showLastMessage();
    }
  }

  @override
  void dispose() {
    _removeHandler();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  PushNotificationClient _client;
  UnreadMessageChecker _unreadMessageChecker;
  bool _handling;
  final audioPlayer = AudioPlayer();

  void _showLastMessage() async {
    final notification = await _client.popLaunchNotification();
    final message = await _unreadMessageChecker.check();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (notification != null) {
        _handleNotificationIfNotBusy(notification, false);
      } else if (message != null) {
        showInformationDialog(context, message.body);
      }
    });
  }

  Future<void> _handleOrderNotification(PushNotification notification, bool active, int orderNumber) async {
    final shouldShowDetails = await _askForOrderDetailsIfNeeded(notification, active);
    if (shouldShowDetails) {
      await _showOrderDetails(orderNumber);
    }
  }

  Future<void> _showOrderDetails(int orderNumber) async {
    showDefaultActivityDialog(context);
    final serverAPI = DependencyHolder.of(context).network.serverAPI.orders;
    try {
      final order = await serverAPI.getByNumber(orderNumber);
      Navigator.pop(context);
      if (order == null) {
        await showInformationDialog(context, strings.orderNotFound);
        return;
      }
      final authorizationState = AuthorizationWidget.of(context);
      await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => OrderDetailsWidget(
        order: order,
        user: authorizationState.user,
      )));
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  Future<bool> _askForOrderDetailsIfNeeded(PushNotification notification, bool active) async {
    if (!active) {
      return true;
    }
    _playNotificationSound();
    return await showQuestionDialog(context, strings.orderDetailsConfirmMessage(notification.alert.body));
  }

  Future<void> _handleGeneralNotification(PushNotification notification, bool active) async {
    if (active) {
      _playNotificationSound();
    }
    await _showGeneralNotificationDialog(notification.alert);
  }

  void _playNotificationSound() => playSound(audioPlayer, 'notification');
  Future<void> _showGeneralNotificationDialog(PushNotificationAlert notificationAlert) async => await showInformationDialog(context, notificationAlert.body);

  Future<void> _handleNotification(PushNotification notification, bool active) async {
    _client.clearAppBadge();
    if (notification.alert == null) {
      return;
    }
    final orderNumber = _getOrderNumber(notification.data);
    if (orderNumber != null && _shouldShowOrderDetails(notification.data)) {
      await _handleOrderNotification(notification, active, orderNumber);
      return;
    }
    await _handleGeneralNotification(notification, active);
  }

  bool _shouldShowOrderDetails(Map<String, dynamic> notificationData) {
    final type = safeCast<String>(notificationData['type']);
    if (type == 'tripStage') {
      return false;
    }
    if (type == 'newOrder') {
      final order = safeCast<Map<String, dynamic>>(notificationData['object']);
      if (order == null) {
        return false;
      }
      return safeCast<String>(order['status']) == OrderStatus.ready;
    }
    return true;
  }

  int _getOrderNumber(Map<String, dynamic> notificationData) {
    final order = safeCast<Map<String, dynamic>>(notificationData['object']);
    if (order != null) {
      return safeCast<int>(order['number']);
    }
    return safeCast<int>(notificationData['orderNumber']);
  }

  void _handleNotificationIfNotBusy(PushNotification notification, bool active) async {
    if (_handling) {
      return;
    }
    _handling = true;
    await _handleNotification(notification, active);
    _handling = false;
  }

  void _addHandler() => _client.addHandler(_handleNotificationIfNotBusy);
  void _removeHandler() => _client.removeHandler(_handleNotificationIfNotBusy);
}

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';

class PushNotificationAlert {
  final String? title;
  final String? body;
  PushNotificationAlert(this.title, this.body);
}

class PushNotification {
  final PushNotificationAlert? alert;
  final Map<String, dynamic>? data;
  PushNotification(this.alert, this.data);
}

typedef PushNotificationHandler = void Function(
    PushNotification notification, bool active);

class PushNotificationClient {
  Future<void> initialize() async {
    if (_underlying != null) {
      return;
    }

    await Firebase.initializeApp();
    _underlying = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((message) {
      print('On message: ${message.data}');
      _fireHandlers(message, true);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('On message opened app: ${message.data}');
      _fireHandlers(message, false);
    });

    print('Push notifications initialized.');
  }

  void addHandler(PushNotificationHandler handler) => _handlers.add(handler);
  void removeHandler(PushNotificationHandler handler) =>
      _handlers.remove(handler);

  Future<PushNotification?> popLaunchNotification() async {
    final message = await _underlying?.getInitialMessage();
    if (message == null) {
      return null;
    }
    print('getInitialMessage: ${message.data}');
    return _convertMessage(message);
  }

  void clearAppBadge() {
    // FlutterAppBadger.removeBadge();
  }

  Future<String?> getToken() async {
    return await _underlying!
        .getToken()
        .timeout(Duration(milliseconds: 2000), onTimeout: () async => null);
  }

  void requestPermissions() => _underlying?.requestPermission();

  FirebaseMessaging? _underlying;
  var _handlers = <PushNotificationHandler>[];

  void _fireHandlers(RemoteMessage message, bool active) {
    final notification = _convertMessage(message);
    if (notification == null) {
      return;
    }
    _handlers.forEach((handler) => handler(notification, active));
  }

  PushNotification? _convertMessage(RemoteMessage message) {
    final alert = _convertNotification(message.notification);
    final customData = _getCustomData(message.data);
    if (customData == null) {
      print('Push notification ignored. Invalid data format.');
      return null;
    }
    if (alert == null) {
      final alertData = _validateData(customData['alert']);
      if (alertData == null) {
        return PushNotification(null, customData);
      }
      final alertFromCustomData = _decodeAlert(alertData);
      return PushNotification(alertFromCustomData, customData);
    }
    return PushNotification(alert, customData);
  }

  PushNotificationAlert? _convertNotification(
      RemoteNotification? notification) {
    if (notification == null ||
        (notification.title == null && notification.body == null)) {
      return null;
    }
    if (notification.body == null) {
      return PushNotificationAlert(null, notification.title);
    }
    return PushNotificationAlert(notification.title, notification.body);
  }

  PushNotificationAlert? _decodeAlert(Map<String, dynamic> alertData) {
    final title = alertData['title'];
    final body = alertData['body'];
    if (title is! String || body is! String) {
      return null;
    }
    return PushNotificationAlert(title, body);
  }

  Map<String, dynamic>? _getCustomData(Map<String, dynamic>? data) {
    if (_containsCustomFields(data)) {
      return data;
    }
    final customData = _validateOrDecodeData(data?['data']);
    if (customData == null) {
      return null;
    }
    if (_containsCustomFields(customData)) {
      return customData;
    }
    return null;
  }

  bool _containsCustomFields(Map<String, dynamic>? data) {
    final type = data?['type'];
    return type is String;
  }

  Map<String, dynamic>? _validateOrDecodeData(dynamic data) {
    if (data == null) {
      return null;
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map<dynamic, dynamic>) {
      return data.cast<String, dynamic>();
    }
    if (data is! String) {
      return null;
    }
    final decoded = json.decode(data);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  dynamic _validateData(dynamic data) {
    if (data == null) {
      return null;
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map<dynamic, dynamic>) {
      return data.cast<String, dynamic>();
    }
    return null;
  }
}

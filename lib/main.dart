import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp();

  // Настройка уведомлений
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Разрешения для iOS
  if (Platform.isIOS) {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Разрешения на уведомления предоставлены');
    } else {
      print('Пользователь отклонил разрешения');
    }
  }

  // Получение FCM токена
  String? token = await messaging.getToken();
  print('FCM Token: $token');

  runApp(App());
}

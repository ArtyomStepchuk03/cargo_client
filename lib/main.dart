import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';

// Добавьте этот класс в main.dart
class PermissionInitializer {
  static Future<void> initializePermissions() async {
    try {
      // Инициализируем разрешения при запуске приложения
      await Permission.photos.status;
      await Permission.camera.status;

      // Это заставит iOS показать разрешения в настройках
      print('Разрешения инициализированы');
    } catch (e) {
      print('Ошибка инициализации разрешений: $e');
    }
  }

  // Вызывайте этот метод при первом использовании камеры/фото
  static Future<void> ensurePhotoPermissionsVisible() async {
    try {
      // Запрашиваем разрешения, чтобы они появились в настройках
      await [
        Permission.photos,
        Permission.camera,
      ].request();
    } catch (e) {
      print('Ошибка при запросе разрешений: $e');
    }
  }
}

// Добавьте этот виджет
class PermissionAwareApp extends StatefulWidget {
  final Widget child;

  const PermissionAwareApp({Key? key, required this.child}) : super(key: key);

  @override
  State<PermissionAwareApp> createState() => _PermissionAwareAppState();
}

class _PermissionAwareAppState extends State<PermissionAwareApp> {
  @override
  void initState() {
    super.initState();
    PermissionInitializer.initializePermissions();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Инициализируем разрешения при старте приложения
  await PermissionInitializer.initializePermissions();

  runApp(PermissionAwareApp(child: App()));
}

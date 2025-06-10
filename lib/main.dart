import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';

class PermissionInitializer {
  static Future<void> initializePermissions() async {
    try {
      await Permission.photos.status;
      await Permission.camera.status;

      print('Разрешения инициализированы');
    } catch (e) {
      print('Ошибка инициализации разрешений: $e');
    }
  }

  static Future<void> ensurePhotoPermissionsVisible() async {
    try {
      await [
        Permission.photos,
        Permission.camera,
      ].request();
    } catch (e) {
      print('Ошибка при запросе разрешений: $e');
    }
  }
}

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

  await PermissionInitializer.initializePermissions();

  runApp(PermissionAwareApp(child: App()));
}

import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

export 'package:permission_handler/permission_handler.dart';

class PhotoSaveService {
  /// Сохраняет фотографию из URL в галерею устройства
  static Future<PhotoSaveResult> savePhotoToGallery(
      String photoUrl, String fileName) async {
    try {
      // Проверяем и запрашиваем разрешения
      final permissionResult = await _requestStoragePermission();
      if (!permissionResult.granted) {
        return PhotoSaveResult.error(permissionResult.errorMessage);
      }

      // Загружаем фото с сервера
      final response = await http.get(
        Uri.parse(photoUrl),
        headers: {'User-Agent': 'Manager Mobile Client'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode != 200) {
        return PhotoSaveResult.error(
            'Не удалось загрузить фото (код: ${response.statusCode})');
      }

      final Uint8List bytes = response.bodyBytes;

      if (bytes.isEmpty) {
        return PhotoSaveResult.error('Получен пустой файл');
      }

      // Сохраняем файл
      final String? savedPath = await _saveImageToGallery(bytes, fileName);

      if (savedPath == null) {
        return PhotoSaveResult.error('Не удалось сохранить файл');
      }

      return PhotoSaveResult.success(savedPath);
    } on SocketException {
      return PhotoSaveResult.error('Нет подключения к интернету');
    } on http.ClientException {
      return PhotoSaveResult.error('Ошибка загрузки фото');
    } catch (e) {
      return PhotoSaveResult.error('Ошибка сохранения: ${e.toString()}');
    }
  }

  /// Сохраняет изображение с учетом версии Android
  static Future<String?> _saveImageToGallery(
      Uint8List bytes, String fileName) async {
    try {
      // Убеждаемся, что у файла есть расширение
      String finalFileName = fileName;
      if (!fileName.contains('.')) {
        finalFileName = '$fileName.jpg';
      }

      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        // Для Android 10+ используем scoped storage
        if (androidVersion >= 29) {
          return await _saveImageScoped(bytes, finalFileName);
        } else {
          // Для старых версий используем публичные папки
          return await _saveImageLegacy(bytes, finalFileName);
        }
      } else if (Platform.isIOS) {
        // Для iOS сохраняем в папку Documents
        final Directory documentsDir = await getApplicationDocumentsDirectory();
        final String filePath = '${documentsDir.path}/$finalFileName';
        final File file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      }

      return null;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  /// Сохранение для Android 10+ (scoped storage)
  static Future<String?> _saveImageScoped(
      Uint8List bytes, String fileName) async {
    try {
      // Сохраняем в папку Android/media/com.macsoftex.cargodeal_manager/
      final String mediaPath =
          '/storage/emulated/0/Android/media/com.macsoftex.cargodeal_manager';
      final Directory mediaDir = Directory(mediaPath);

      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      final String filePath = '$mediaPath/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      print('Saved to Android/media: $filePath');
      return filePath;
    } catch (e) {
      print('Failed to save to Android/media: $e');
    }

    // Fallback: публичная папка Pictures
    try {
      final String publicPicturesPath = '/storage/emulated/0/Pictures';
      final Directory publicPicturesDir = Directory(publicPicturesPath);

      if (!await publicPicturesDir.exists()) {
        await publicPicturesDir.create(recursive: true);
      }

      final String filePath = '$publicPicturesPath/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      print('Saved to public Pictures: $filePath');
      return filePath;
    } catch (e) {
      print('Failed to save to public Pictures: $e');
    }

    // Последний fallback: папка приложения
    try {
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final String filePath = '${externalDir.path}/$fileName';
        final File file = File(filePath);
        await file.writeAsBytes(bytes);
        print('Saved to app directory: $filePath');
        return filePath;
      }
    } catch (e) {
      print('Failed to save to app directory: $e');
    }

    return null;
  }

  /// Сохранение для старых версий Android (до API 29)
  static Future<String?> _saveImageLegacy(
      Uint8List bytes, String fileName) async {
    // Попробуем сохранить в стандартную папку Pictures
    try {
      final String publicPicturesPath = '/storage/emulated/0/Pictures';
      final Directory publicPicturesDir = Directory(publicPicturesPath);

      if (!await publicPicturesDir.exists()) {
        await publicPicturesDir.create(recursive: true);
      }

      final String filePath = '$publicPicturesPath/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      print('Saved to public Pictures: $filePath');
      return filePath;
    } catch (e) {
      print('Failed to save to public Pictures: $e');
    }

    // Fallback: сохраняем во внешнее хранилище приложения
    try {
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final String filePath = '${externalDir.path}/$fileName';
        final File file = File(filePath);
        await file.writeAsBytes(bytes);
        print('Saved to external storage: $filePath');
        return filePath;
      }
    } catch (e) {
      print('Failed to save to external storage: $e');
    }

    return null;
  }

  /// Запрашивает необходимые разрешения
  static Future<PermissionResult> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        if (androidVersion >= 33) {
          // Android 13+ - запрашиваем разрешение на медиафайлы
          final status = await Permission.photos.request();
          return _handlePermissionStatus(status, 'фото');
        } else if (androidVersion >= 29) {
          // Android 10-12 - scoped storage, специальные разрешения не нужны
          return PermissionResult.granted();
        } else {
          // Android < 10 - запрашиваем разрешение на хранилище
          final status = await Permission.storage.request();
          return _handlePermissionStatus(status, 'хранилище');
        }
      } else if (Platform.isIOS) {
        // iOS - запрашиваем разрешение на добавление фото
        final status = await Permission.photosAddOnly.request();
        return _handlePermissionStatus(status, 'библиотеку фото');
      }

      return PermissionResult.error('Неподдерживаемая платформа');
    } catch (e) {
      return PermissionResult.error(
          'Ошибка проверки разрешений: ${e.toString()}');
    }
  }

  /// Обрабатывает статус разрешения
  static PermissionResult _handlePermissionStatus(
      PermissionStatus status, String permissionType) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionResult.granted();
      case PermissionStatus.permanentlyDenied:
        return PermissionResult.error(
            'Доступ к $permissionType запрещен навсегда. Включите в настройках приложения');
      default:
        return PermissionResult.error('Отказано в доступе к $permissionType');
    }
  }

  /// Получает версию Android
  static Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.version.sdkInt;
      }
      return 0;
    } catch (e) {
      // Fallback на современную версию
      return 33;
    }
  }

  /// Открывает галерею
  static Future<bool> openGallery([String? photoPath]) async {
    try {
      if (Platform.isAndroid) {
        // Пытаемся открыть галерею разными способами
        final List<String> galleryUrls = [
          'content://media/external/images/media',
          'content://com.android.externalstorage.documents/',
        ];

        for (final galleryUrl in galleryUrls) {
          try {
            final Uri uri = Uri.parse(galleryUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return true;
            }
          } catch (e) {
            continue;
          }
        }
      } else if (Platform.isIOS) {
        // Открываем приложение Фото на iOS
        const photosUrl = 'photos-redirect://';
        final uri = Uri.parse(photosUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Показывает результат сохранения в Snackbar
  static void showSaveResultSnackbar(
    BuildContext context,
    PhotoSaveResult result,
    String successMessage,
    String openButtonText,
  ) {
    final snackBar = SnackBar(
      content: Text(
        result.isSuccess ? successMessage : result.errorMessage!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: result.isSuccess ? Colors.green : Colors.red,
      action: result.isSuccess
          ? SnackBarAction(
              label: openButtonText,
              textColor: Colors.white,
              onPressed: () async {
                final opened = await openGallery(result.savedPath);
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Не удалось открыть галерею'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            )
          : null,
      duration: Duration(seconds: result.isSuccess ? 4 : 6),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Открывает настройки приложения
  static Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }
}

/// Результат операции сохранения фото
class PhotoSaveResult {
  final bool isSuccess;
  final String? savedPath;
  final String? errorMessage;

  PhotoSaveResult.success(this.savedPath)
      : isSuccess = true,
        errorMessage = null;

  PhotoSaveResult.error(this.errorMessage)
      : isSuccess = false,
        savedPath = null;
}

/// Результат проверки разрешений
class PermissionResult {
  final bool granted;
  final String? errorMessage;

  PermissionResult.granted()
      : granted = true,
        errorMessage = null;

  PermissionResult.error(this.errorMessage) : granted = false;
}

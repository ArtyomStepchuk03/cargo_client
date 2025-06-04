import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

export 'package:gal/gal.dart';
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

      await Gal.putImageBytes(
        bytes,
        name: '$fileName.jpg',
      );

      return PhotoSaveResult.success(null); // Успешно, путь не возвращается
    } on GalException catch (e) {
      return PhotoSaveResult.error(
          'Ошибка библиотеки галереи: ${e.type.message}');
    } on SocketException {
      return PhotoSaveResult.error('Нет подключения к интернету');
    } on http.ClientException {
      return PhotoSaveResult.error('Ошибка загрузки фото');
    }
  }

  static Future<PermissionResult> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final androidVersion = await _getAndroidVersion();

        // Для Android 13+ нужно разрешение на фото
        if (androidVersion >= 33) {
          final status = await Permission.photos.request();
          if (status == PermissionStatus.granted) {
            return PermissionResult.granted();
          } else if (status == PermissionStatus.permanentlyDenied) {
            return PermissionResult.error(
                'Доступ к фото запрещен навсегда. Включите в настройках приложения');
          } else {
            return PermissionResult.error('Отказано в доступе к фото');
          }
        } else {
          // Для более старых версий Android
          final status = await Permission.storage.request();
          if (status == PermissionStatus.granted) {
            return PermissionResult.granted();
          } else if (status == PermissionStatus.permanentlyDenied) {
            return PermissionResult.error(
                'Доступ к хранилищу запрещен навсегда. Включите в настройках приложения');
          } else {
            return PermissionResult.error('Отказано в доступе к хранилищу');
          }
        }
      } else if (Platform.isIOS) {
        // Для iOS запрашиваем доступ к фото
        final status = await Permission.photosAddOnly.request();
        if (status == PermissionStatus.granted) {
          return PermissionResult.granted();
        } else if (status == PermissionStatus.permanentlyDenied) {
          return PermissionResult.error(
              'Доступ к фото запрещен. Включите в настройках iOS');
        } else {
          return PermissionResult.error('Отказано в доступе к библиотеке фото');
        }
      }
      return PermissionResult.error('Неподдерживаемая платформа');
    } catch (e) {
      return PermissionResult.error(
          'Ошибка проверки разрешений: ${e.toString()}');
    }
  }

  /// Получает версию Android используя device_info_plus
  static Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.version.sdkInt;
      }
      return 0;
    } catch (e) {
      // Fallback на современную версию если не удалось определить
      return 33;
    }
  }

  /// Пытается открыть галерею
  static Future<bool> openGallery([String? photoPath]) async {
    try {
      if (Platform.isAndroid) {
        // На Android пытаемся открыть галерею через разные варианты
        final galleryIntents = [
          'content://media/external/images/media',
          'content://media/internal/images/media',
        ];

        for (final galleryUrl in galleryIntents) {
          try {
            final uri = Uri.parse(galleryUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return true;
            }
          } catch (e) {
            // Продолжаем попытки с другими URL
          }
        }
      } else if (Platform.isIOS) {
        // На iOS пытаемся открыть приложение Фото
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

  /// Показывает Snackbar с результатом сохранения
  static void showSaveResultSnackbar(
    BuildContext context,
    PhotoSaveResult result,
    String localizationMessage,
    String localizationOpen,
  ) {
    final snackBar = SnackBar(
      content: Text(
        result.isSuccess ? localizationMessage : result.errorMessage!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: result.isSuccess ? Colors.green : Colors.red,
      action: result.isSuccess
          ? SnackBarAction(
              label: localizationOpen,
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

  /// Открывает настройки приложения для изменения разрешений
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

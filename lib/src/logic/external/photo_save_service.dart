import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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

      // Сохраняем во временную папку приложения для возможности открытия
      String? tempFilePath;
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName.jpg');
        await tempFile.writeAsBytes(bytes);
        tempFilePath = tempFile.path;
      } catch (e) {
        print('Не удалось сохранить во временную папку: $e');
      }

      // Сохраняем в галерею (Gal.putImageBytes возвращает void)
      await Gal.putImageBytes(
        bytes,
        name: '$fileName.jpg',
      );

      // Возвращаем успех с путем к временному файлу
      return PhotoSaveResult.success(tempFilePath);
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
                'Доступ к фото запрещен. Включите в настройках приложения');
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
                'Доступ к хранилищу запрещен. Включите в настройках приложения');
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

  /// Открывает фото или галерею
  static Future<bool> openPhotoOrGallery([String? tempFilePath]) async {
    // Сначала пытаемся открыть конкретное фото из временной папки
    if (tempFilePath != null && tempFilePath.isNotEmpty) {
      try {
        final file = File(tempFilePath);
        if (await file.exists()) {
          final uri = Uri.file(tempFilePath);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return true;
          }
        }
      } catch (e) {
        print('Не удалось открыть временное фото: $e');
      }
    }

    // Если не удалось открыть конкретное фото, открываем галерею
    return await _openGallery();
  }

  /// Открывает галерею
  static Future<bool> _openGallery() async {
    try {
      if (Platform.isAndroid) {
        // Пытаемся открыть галерею различными способами
        final galleryIntents = [
          'content://media/external/images/media',
          'content://media/internal/images/media',
        ];

        for (final intent in galleryIntents) {
          try {
            final uri = Uri.parse(intent);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return true;
            }
          } catch (e) {
            continue;
          }
        }

        // Последняя попытка - открыть через стандартный интент просмотра изображений
        try {
          final uri = Uri.parse('content://media/external/images/media');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        } catch (e) {
          return false;
        }
      } else if (Platform.isIOS) {
        // Для iOS пытаемся открыть приложение Фото
        final photoAppSchemes = [
          'photos-redirect://',
          'photos://',
        ];

        for (final scheme in photoAppSchemes) {
          try {
            final uri = Uri.parse(scheme);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return true;
            }
          } catch (e) {
            continue;
          }
        }
        return false;
      }
      return false;
    } catch (e) {
      print('Ошибка открытия галереи: $e');
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
                final opened = await openPhotoOrGallery(result.savedPath);
                if (!opened && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Не удалось открыть фото'),
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

class PhotoPermissionHelper {
  static Future<bool> requestPhotoPermission(BuildContext context) async {
    // Проверяем текущий статус разрешения
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      // Запрашиваем разрешение
      status = await Permission.photos.request();

      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      // Показываем диалог с предложением открыть настройки
      return await _showSettingsDialog(context);
    }

    return false;
  }

  static Future<bool> requestCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.camera.request();

      if (status.isGranted) {
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      return await _showSettingsDialog(context);
    }

    return false;
  }

  static Future<bool> _showSettingsDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Разрешение необходимо'),
              content: Text(
                'Для работы с фотографиями необходимо предоставить доступ к галерее. '
                'Перейдите в настройки приложения и включите доступ к фото.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    await openAppSettings();
                  },
                  child: Text('Настройки'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

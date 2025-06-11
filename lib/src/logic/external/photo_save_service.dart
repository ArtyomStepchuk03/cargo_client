import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

enum PhotoSaveResultType { success, error, permissionDenied }

class PhotoSaveResult {
  final PhotoSaveResultType type;
  final String message;
  final String? filePath;

  PhotoSaveResult._({
    required this.type,
    required this.message,
    this.filePath,
  });

  factory PhotoSaveResult.success(String message, {String? filePath}) {
    return PhotoSaveResult._(
      type: PhotoSaveResultType.success,
      message: message,
      filePath: filePath,
    );
  }

  factory PhotoSaveResult.error(String message) {
    return PhotoSaveResult._(
      type: PhotoSaveResultType.error,
      message: message,
    );
  }

  factory PhotoSaveResult.permissionDenied(String message) {
    return PhotoSaveResult._(
      type: PhotoSaveResultType.permissionDenied,
      message: message,
    );
  }

  bool get isSuccess => type == PhotoSaveResultType.success;
  bool get isError => type == PhotoSaveResultType.error;
  bool get isPermissionDenied => type == PhotoSaveResultType.permissionDenied;
}

class PhotoSaveService {
  /// Сохраняет фото по URL в галерею
  static Future<PhotoSaveResult> savePhotoToGallery(
    String imageUrl,
    String fileName,
  ) async {
    try {
      // Проверяем разрешения для iOS
      if (Platform.isIOS) {
        final hasPermission = await _checkIOSPhotoPermission();
        if (!hasPermission) {
          return PhotoSaveResult.permissionDenied(
            'Для сохранения фото необходимо предоставить доступ к галерее в настройках',
          );
        }
      }

      // Скачиваем изображение
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return PhotoSaveResult.error(
          'Не удалось загрузить изображение: HTTP ${response.statusCode}',
        );
      }

      final Uint8List bytes = response.bodyBytes;

      // Сохраняем с помощью Gal
      await Gal.putImageBytes(
        bytes,
        name: fileName,
      );

      return PhotoSaveResult.success(
        'Фото успешно сохранено в галерею',
        filePath: fileName,
      );
    } on GalException catch (e) {
      // Обрабатываем специфичные ошибки Gal
      return _handleGalException(e);
    } catch (e) {
      return PhotoSaveResult.error(
        'Ошибка при сохранении фото: ${e.toString()}',
      );
    }
  }

  /// Проверяет разрешения для iOS более правильным способом
  static Future<bool> _checkIOSPhotoPermission() async {
    try {
      // Сначала пробуем сохранить тестовое изображение
      // Это более надежный способ проверки для iOS 14+
      const testBytes = [
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        31,
        21,
        196,
        137,
        0,
        0,
        0,
        11,
        73,
        68,
        65,
        84,
        120,
        156,
        99,
        248,
        15,
        0,
        0,
        1,
        0,
        1,
        0,
        24,
        221,
        142,
        175,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130
      ]; // Минимальный PNG 1x1 pixel

      await Gal.putImageBytes(
        Uint8List.fromList(testBytes),
        name: 'test_permission_${DateTime.now().millisecondsSinceEpoch}',
      );

      return true;
    } on GalException catch (e) {
      // Если ошибка связана с разрешениями
      if (e.type == GalExceptionType.accessDenied) {
        return false;
      }
      // Для других ошибок Gal считаем, что разрешение есть
      return true;
    } catch (e) {
      // Fallback к старому методу проверки разрешений
      return await _fallbackPermissionCheck();
    }
  }

  /// Резервный метод проверки разрешений
  static Future<bool> _fallbackPermissionCheck() async {
    try {
      final status = await Permission.photos.status;

      // На iOS 14+ даже limited доступ позволяет сохранять новые фото
      if (Platform.isIOS) {
        return status.isGranted || status.isLimited;
      }

      return status.isGranted;
    } catch (e) {
      // Если не можем проверить разрешения, пробуем сохранить
      return true;
    }
  }

  /// Обрабатывает исключения от библиотеки Gal
  static PhotoSaveResult _handleGalException(GalException e) {
    switch (e.type) {
      case GalExceptionType.accessDenied:
        return PhotoSaveResult.permissionDenied(
          'Доступ к галерее запрещен. Предоставьте разрешение в настройках',
        );
      case GalExceptionType.notEnoughSpace:
        return PhotoSaveResult.error(
          'Недостаточно места на устройстве',
        );
      case GalExceptionType.notSupportedFormat:
        return PhotoSaveResult.error(
          'Неподдерживаемый формат изображения',
        );
      case GalExceptionType.unexpected:
      default:
        return PhotoSaveResult.error(
          'Неожиданная ошибка при сохранении: ${e.platformException?.message ?? e.toString()}',
        );
    }
  }

  /// Показывает снэкбар с результатом сохранения
  static void showSaveResultSnackbar(
    BuildContext context,
    PhotoSaveResult result,
    String successMessage,
    String actionLabel,
  ) {
    Color backgroundColor;
    IconData icon;
    String message;
    SnackBarAction? action;

    switch (result.type) {
      case PhotoSaveResultType.success:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        message = successMessage.isNotEmpty ? successMessage : result.message;
        // Добавляем кнопку "Открыть" для успешного сохранения
        if (actionLabel.isNotEmpty) {
          action = SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            onPressed: () => _openGallery(),
          );
        }
        break;
      case PhotoSaveResultType.permissionDenied:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        message = result.message;
        if (actionLabel.isNotEmpty) {
          action = SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            onPressed: () => openAppSettings(),
          );
        }
        break;
      case PhotoSaveResultType.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        message = result.message;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        action: action,
        duration: Duration(seconds: result.isSuccess ? 3 : 4),
      ),
    );
  }

  /// Открывает галерею устройства
  static Future<void> _openGallery() async {
    try {
      await Gal.open();
    } catch (e) {
      print('Не удалось открыть галерею: $e');
    }
  }
}

// Добавляем функцию для открытия настроек (если её нет)
Future<void> openAppSettings() async {
  await Permission.photos.request();
}

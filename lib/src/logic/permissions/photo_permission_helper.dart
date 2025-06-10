import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoPermissionHelper {
  static Future<bool> requestPhotoPermission(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1,
        maxHeight: 1,
      );

      if (image != null) {
        return true;
      }

      PermissionStatus status = await Permission.photos.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        status = await Permission.photos.request();
        return status.isGranted;
      }

      if (status.isPermanentlyDenied) {
        // Показываем диалог с объяснением
        return await _showPermissionDialog(context);
      }

      return false;
    } catch (e) {
      print('Ошибка при запросе разрешения на фото: $e');

      PermissionStatus status = await Permission.photos.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        status = await Permission.photos.request();
        if (status.isGranted) {
          return true;
        }
      }

      if (status.isPermanentlyDenied) {
        return await _showPermissionDialog(context);
      }

      return false;
    }
  }

  static Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Доступ к фотографиям'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Для работы с фотографиями необходимо предоставить доступ к галерее.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Пожалуйста, выполните следующие шаги:\n'
                    '1. Нажмите "Открыть настройки"\n'
                    '2. Найдите "Фото" в списке\n'
                    '3. Выберите "Все фото" или "Выбранные фото"',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    await openAppSettings();
                  },
                  child: Text('Открыть настройки'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Future<bool> forceRequestPhotoPermission(BuildContext context) async {
    try {
      PermissionStatus status = await Permission.photos.status;

      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        status = await Permission.photos.request();
        if (status.isGranted) {
          return true;
        }
      }

      if (status.isPermanentlyDenied || status.isDenied) {
        return await _showDetailedInstructionDialog(context);
      }

      return false;
    } catch (e) {
      print('Ошибка при принудительном запросе разрешения: $e');
      return await _showDetailedInstructionDialog(context);
    }
  }

  static Future<bool> _showDetailedInstructionDialog(
      BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Настройка доступа к фото'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Чтобы использовать функции работы с фотографиями, выполните следующие шаги:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    _buildInstructionStep(
                        '1', 'Нажмите "Открыть настройки" ниже'),
                    _buildInstructionStep(
                        '2', 'Найдите приложение "Каргодил Заказ" в списке'),
                    _buildInstructionStep(
                        '3', 'Нажмите на название приложения'),
                    _buildInstructionStep(
                        '4', 'Найдите раздел "Фото" и нажмите на него'),
                    _buildInstructionStep(
                        '5', 'Выберите "Все фото" для полного доступа'),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'После изменения настроек вернитесь в приложение и попробуйте снова.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    await openAppSettings();
                  },
                  child: Text('Открыть настройки'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

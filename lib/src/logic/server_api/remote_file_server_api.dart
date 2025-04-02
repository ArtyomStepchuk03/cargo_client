import 'dart:io';

import 'package:manager_mobile_client/src/logic/core/remote_file.dart';
import 'package:manager_mobile_client/src/logic/http_utility/content_type.dart';
import 'package:manager_mobile_client/src/logic/parse/requests.dart' as parse;
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';
import 'package:path/path.dart' as path;

export 'package:manager_mobile_client/src/logic/core/remote_file.dart';
export 'package:manager_mobile_client/src/logic/exceptions/exceptions.dart';

class RemoteFileServerAPI {
  final ServerManager serverManager;

  RemoteFileServerAPI(this.serverManager);

  Future<RemoteFile> createImage(File file) async {
    final fileExtension = path.extension(file.path);
    final contentType = _getImageContentType(fileExtension);
    return await parse.createFile(
        serverManager.server!, file, 'document$fileExtension', contentType);
  }

  String _getImageContentType(fileExtension) {
    if (fileExtension == '.png') {
      return contentTypePng;
    } else {
      return contentTypeJpeg;
    }
  }
}

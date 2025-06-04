import 'package:collection/collection.dart';
import 'package:manager_mobile_client/src/logic/parse/constants.dart' as parse;

import 'decoder.dart';
import 'encoder.dart';

class ChangeEncoder implements Encoder {
  final Decoder decoder;
  final Encoder encoder;

  ChangeEncoder(this.decoder, this.encoder);

  void encodeUserName(String value) => encodeString(parse.userNameKey, value);
  void encodeSessionToken(String value) =>
      encodeString(parse.sessionTokenKey, value);
  void encodeDeviceToken(String value) =>
      encodeString(parse.deviceTokenKey, value);

  void encodeBoolean(String key, bool value) {
    final oldValue = decoder.decodeBoolean(key);
    if (oldValue != value) {
      encoder.encodeBoolean(key, value);
    }
  }

  void encodeNumber(String key, num? value) {
    final oldValue = decoder.decodeNumber(key);
    if (oldValue != value) {
      encoder.encodeNumber(key, value);
    }
  }

  void encodeString(String key, String? value) {
    final oldValue = decoder.decodeString(key);
    if (oldValue != value) {
      encoder.encodeString(key, value);
    }
  }

  void encodeDate(String key, DateTime? value) {
    final oldValue = decoder.decodeDate(key);
    if (oldValue?.toUtc() != value?.toUtc()) {
      encoder.encodeDate(key, value);
    }
  }

  void encodeCoordinate(String key, LatLng? value) {
    final oldValue = decoder.decodeCoordinate(key);
    if (oldValue != value) {
      encoder.encodeCoordinate(key, value);
    }
  }

  void encodeMap(String key, Map<String, dynamic>? map) {
    final oldMap = decoder.decodeMap(key);

    if (key == 'unloadingContact') {
      print('DEBUG: Force encoding unloadingContact: $map');
      encoder.encodeMap(key, map);
      return;
    }

    if (!MapEquality().equals(oldMap, map)) {
      encoder.encodeMap(key, map);
    }
  }

  void encodeFile(String key, RemoteFile file) {
    final oldFile = decoder.decodeFile(key);
    if (oldFile != file) {
      encoder.encodeFile(key, file);
    }
  }

  void encodePointer(String key, String className, String? id) {
    final oldValueDecoder = decoder.getDecoder(key);
    final oldId = oldValueDecoder.isValid() ? oldValueDecoder.decodeId() : null;
    if (oldId != id) {
      encoder.encodePointer(key, className, id);
    }
  }

  void encodeUserPointer(String key, String? id) =>
      encodePointer(key, parse.userClassName, id);

  ListEncoder getListEncoder(String key) => encoder.getListEncoder(key);
  ListEncoder getAddOperationListEncoder(String key) =>
      encoder.getAddOperationListEncoder(key);
  ListEncoder getRemoveOperationListEncoder(String key) =>
      encoder.getRemoveOperationListEncoder(key);
}

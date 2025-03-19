import 'package:manager_mobile_client/src/logic/core/location.dart';
import 'package:manager_mobile_client/src/logic/core/remote_file.dart';
import 'package:manager_mobile_client/src/logic/core/safe_cast.dart';
import 'package:manager_mobile_client/src/logic/parse/constants.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse/objects/objects.dart'
    as parse;

export 'package:manager_mobile_client/src/logic/core/location.dart';
export 'package:manager_mobile_client/src/logic/core/remote_file.dart';

class Decoder {
  Decoder(dynamic data) : _data = safeCast<Map<String, dynamic>>(data);

  bool isValid() => _data != null && decodeId() != null;

  String? decodeId() => decodeString(parse.idKey);
  DateTime? decodeCreatedAt() =>
      parse.dateFromString(safeCast<String>(_data?[parse.createdAtKey])!);
  String? decodeUserName() => decodeString(parse.userNameKey);
  String? decodeSessionToken() => decodeString(parse.sessionTokenKey);
  String? decodeDeviceToken() => decodeString(parse.deviceTokenKey);

  bool? decodeBoolean(String? key) => safeCast<bool>(_data?[key]);
  num? decodeNumber(String? key) => safeCast<num>(_data?[key]);
  String? decodeString(String? key) => safeCast<String?>(_data?[key]);
  DateTime? decodeDate(String? key) =>
      parse.dateFromJson(safeCast<Map<String, dynamic>?>(_data?[key]));
  LatLng? decodeCoordinate(String? key) =>
      parse.coordinateFromJson(safeCast<Map<String, dynamic>?>(_data?[key]));

  Map<String, dynamic>? decodeMap(String key) =>
      safeCast<Map<String, dynamic>>(_data?[key]);
  RemoteFile? decodeFile(String key) =>
      parse.fileFromJson(safeCast<Map<String, dynamic>>(_data?[key]));

  Decoder getDecoder(String key) => Decoder(_data?[key]);
  ListDecoder getListDecoder(String key) => ListDecoder(_data?[key]);

  final Map<String, dynamic>? _data;
}

class ListDecoder {
  ListDecoder(dynamic data) : _data = safeCast<List<dynamic>>(data);

  bool isValid() => _data != null;

  int? decodeLength() => _data?.length;

  bool? decodeBoolean(int index) => safeCast<bool>(_data?[index]);
  num? decodeNumber(int index) => safeCast<num>(_data?[index]);
  String? decodeString(int index) => safeCast<String>(_data?[index]);
  DateTime? decodeDate(int index) =>
      parse.dateFromJson(safeCast<Map<String, dynamic>>(_data?[index]));
  LatLng? decodeCoordinate(int index) =>
      parse.coordinateFromJson(safeCast<Map<String, dynamic>>(_data?[index]));

  Map<String, dynamic>? decodeMap(int index) =>
      safeCast<Map<String, dynamic>>(_data?[index]);
  RemoteFile? decodeFile(int index) =>
      parse.fileFromJson(safeCast<Map<String, dynamic>>(_data?[index]));

  Decoder getDecoder(int index) => Decoder(_data?[index]);

  final List<dynamic>? _data;
}

typedef MapDecodeInitializer<T> = T Function(Map<String, dynamic> data);
typedef ObjectDecodeInitializer<T> = T Function(Decoder decoder);

typedef _DecodeFunction<T> = T Function(ListDecoder listDecoder, int index);

T? validateEnumeration<T>(int? index, List<T?> values) {
  if (index == null) {
    return null;
  }
  if (index < 0 || index >= values.length) {
    return null;
  }
  return values[index];
}

T? enumerationFromString<T>(String? stringValue, List<T> values) {
  if (stringValue == null) {
    return null;
  }
  return values.firstWhere((value) =>
      value.toString().toLowerCase().split('.').last ==
      stringValue.toLowerCase());
}

extension DecoderUtility on Decoder {
  bool decodeBooleanDefault(String key, [bool defaultValue = false]) {
    final value = decodeBoolean(key);
    if (value == null) {
      return defaultValue;
    }
    return value;
  }

  T? decodeEnumeration<T>(String key, List<T> values) {
    final index = decodeNumber(key) as int?;
    return validateEnumeration(index, values);
  }

  List<T>? decodeMapList<T>(String key, MapDecodeInitializer<T> initializer) =>
      _decodeList(key,
          (listDecoder, index) => initializer(listDecoder.decodeMap(index)!));
  List<T?>? decodeObjectList<T>(
          String key, ObjectDecodeInitializer<T?> initializer) =>
      _decodeList(key,
          (listDecoder, index) => initializer(listDecoder.getDecoder(index)));

  List<T>? _decodeList<T>(String key, _DecodeFunction<T> function) {
    final listDecoder = getListDecoder(key);
    if (!listDecoder.isValid()) {
      return null;
    }
    final count = listDecoder.decodeLength() as int;
    List<T> values = [];
    for (var counter = 0; counter < count; ++counter) {
      final value = function(listDecoder, counter);
      values.add(value);
    }
    return values;
  }
}

extension ListDecoderUtility on ListDecoder {
  bool decodeBooleanDefault(int index, [bool defaultValue = false]) {
    final value = decodeBoolean(index);
    if (value == null) {
      return defaultValue;
    }
    return value;
  }

  T? decodeEnumeration<T>(int index, List<T?> values) {
    final valueIndex = decodeNumber(index);
    return validateEnumeration(valueIndex as int?, values);
  }
}

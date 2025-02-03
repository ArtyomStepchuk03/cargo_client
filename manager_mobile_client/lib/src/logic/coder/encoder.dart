import 'package:manager_mobile_client/src/logic/core/location.dart';
import 'package:manager_mobile_client/src/logic/core/remote_file.dart';
import 'package:manager_mobile_client/src/logic/parse/constants.dart' as parse;
import 'package:manager_mobile_client/src/logic/parse/objects/objects.dart'
    as parse;
import 'package:manager_mobile_client/src/logic/parse/operation.dart' as parse;

export 'package:manager_mobile_client/src/logic/core/location.dart';
export 'package:manager_mobile_client/src/logic/core/remote_file.dart';

class Encoder {
  Encoder(Map<String, dynamic> data) : _data = data;

  void encodeUserName(String value) => encodeString(parse.userNameKey, value);
  void encodeSessionToken(String value) =>
      encodeString(parse.sessionTokenKey, value);
  void encodeDeviceToken(String value) =>
      encodeString(parse.deviceTokenKey, value);

  void encodeBoolean(String key, bool value) => _data[key] = value;
  void encodeNumber(String key, num value) => _data[key] = value;
  void encodeString(String key, String value) => _data[key] = value;
  void encodeDate(String key, DateTime value) =>
      _data[key] = parse.jsonFromDate(value);
  void encodeCoordinate(String key, LatLng value) =>
      _data[key] = parse.jsonFromCoordinate(value);

  void encodeMap(String key, Map<String, dynamic> map) => _data[key] = map;
  void encodeFile(String key, RemoteFile file) =>
      _data[key] = parse.jsonFromFile(file);
  void encodePointer(String key, String className, String id) =>
      _data[key] = parse.jsonForPointer(className, id);

  void encodeUserPointer(String key, String id) =>
      encodePointer(key, parse.userClassName, id);

  ListEncoder getListEncoder(String key) {
    final list = <dynamic>[];
    _data[key] = list;
    return ListEncoder(list);
  }

  ListEncoder getAddOperationListEncoder(String key) {
    final list = <dynamic>[];
    _data[key] = parse.jsonForOperation('Add', list);
    return ListEncoder(list);
  }

  ListEncoder getRemoveOperationListEncoder(String key) {
    final list = <dynamic>[];
    _data[key] = parse.jsonForOperation('Remove', list);
    return ListEncoder(list);
  }

  final Map<String, dynamic> _data;
}

class ListEncoder {
  ListEncoder(List<dynamic> data) : _data = data;

  void addBoolean(bool value) => _data.add(value);
  void addNumber(num value) => _data.add(value);
  void addString(String value) => _data.add(value);
  void addDate(DateTime value) => _data.add(parse.jsonFromDate(value));
  void addCoordinate(LatLng value) =>
      _data.add(parse.jsonFromCoordinate(value));

  void addMap(Map<String, dynamic> value) => _data.add(value);
  void addFile(RemoteFile file) => _data.add(parse.jsonFromFile(file));
  void addPointer(String className, String id) =>
      _data.add(parse.jsonForPointer(className, id));

  final List<dynamic> _data;
}

typedef EncodeFunction<T> = void Function(ListEncoder encoder, T value);

extension EncoderUtility on Encoder {
  void encodeList<T>(String key, List<T> values, EncodeFunction<T> function) {
    if (values == null) {
      return;
    }
    final listEncoder = getListEncoder(key);
    for (final value in values) {
      function(listEncoder, value);
    }
  }
}

import 'package:manager_mobile_client/src/logic/core/safe_cast.dart';
import 'package:manager_mobile_client/src/logic/parse/constants.dart';

DateTime dateFromJson(Map<String, dynamic> json) {
  if (json == null) {
    return null;
  }
  final string = safeCast<String>(json['iso']);
  if (string == null) {
    return null;
  }
  return dateFromString(string);
}

Map<String, dynamic> jsonFromDate(DateTime date) {
  if (date == null) {
    return null;
  }
  return {
    typeKey: 'Date',
    'iso': stringFromDate(date)
  };
}

DateTime dateFromString(String string) {
  return DateTime.parse(string);
}

String stringFromDate(DateTime date) {
  return date.toIso8601String();
}

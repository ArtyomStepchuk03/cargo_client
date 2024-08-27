import 'safe_format.dart';
import 'format_strings.dart' as strings;

String formatWithNumberSafe(String text, int number) {
  if (number == null) {
    return text;
  }
  return '$text №$number';
}

String formatSpeed(num speed) {
  return '${speed.toStringAsFixed(1)} ${strings.kilometersPerHour}';
}

String formatTonnage(num tonnage) {
  String tonnageString;
  if (tonnage.toInt() != tonnage) {
    tonnageString = tonnage.toStringAsFixed(2);
  } else {
    tonnageString = tonnage.toStringAsFixed(0);
  }
  return '$tonnageString ${strings.tons}';
}

String formatDistance(num distance) {
  return '$distance ${strings.kilometers}';
}

String formatSpeedSafe(num speed) {
  return textOrEmpty(speed != null ? formatSpeed(speed) : null);
}

int? parseHour(String string) {
  final hourNumber = int.tryParse(string);
  if (hourNumber != null) {
    return hourNumber;
  }
  final match = RegExp(r'^([0-9]{1,2})[:.-][0-9]{2}$').firstMatch(string);
  if (match == null) {
    throw FormatException();
  }
  return int.parse(match.group(1)!);
}

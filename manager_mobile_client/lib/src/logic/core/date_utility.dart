extension DateUtility on DateTime {
  DateTime get beginningOfDay {
    if (isUtc) {
      return DateTime.utc(year, month, day);
    } else {
      return DateTime(year, month, day);
    }
  }

  static DateTime fromDatePartAndTime(DateTime datePart, int hour, [int minute = 0, int second = 0]) {
    return DateTime(datePart.year, datePart.month, datePart.day, hour, minute, second);
  }
}

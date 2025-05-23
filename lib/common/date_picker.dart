import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/date_utility.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime,
  DateTime? initialValue,
  DateTime? minimumDate,
  DateTime? maximumDate,
  int minuteInterval = 1,
}) async {
  final actualInitialValue =
      _initialValueForPicker(initialValue, minimumDate, maximumDate);
  final validatedValue =
      validateDateForPicker(actualInitialValue, mode, minuteInterval);
  final actualMinimumDate = minimumDate?.beginningOfDay ?? DateTime(2000);
  final actualMaximumDate =
      maximumDate ?? DateTime.now().beginningOfDay.add(Duration(days: 30));
  if (mode == CupertinoDatePickerMode.date) {
    return await _showMaterialDatePicker(
        context: context,
        initialValue: validatedValue,
        minimumDate: actualMinimumDate,
        maximumDate: actualMaximumDate);
  }
  return await _showCupertinoDatePicker(
      context: context,
      mode: mode,
      initialValue: validatedValue,
      minimumDate: actualMinimumDate,
      maximumDate: actualMaximumDate,
      minuteInterval: minuteInterval);
}

DateTime validateDateForPicker(DateTime date, CupertinoDatePickerMode mode,
    [int minuteInterval = 1]) {
  if (mode == CupertinoDatePickerMode.date) {
    return date.beginningOfDay;
  }
  return DateTime(date.year, date.month, date.day, date.hour,
      (date.minute ~/ minuteInterval) * minuteInterval);
}

DateTime _initialValueForPicker(
    DateTime? initialValue, DateTime? minimumDate, DateTime? maximumDate) {
  if (initialValue != null) {
    return initialValue;
  }
  if (minimumDate != null && DateTime.now().isBefore(minimumDate)) {
    return minimumDate;
  }
  if (maximumDate != null && DateTime.now().isAfter(maximumDate)) {
    return maximumDate;
  }
  return DateTime.now();
}

Future<DateTime?> _showMaterialDatePicker({
  required BuildContext context,
  DateTime? initialValue,
  required DateTime minimumDate,
  required DateTime maximumDate,
}) async {
  return await showDatePicker(
      context: context,
      initialDate: initialValue,
      firstDate: minimumDate,
      lastDate: maximumDate,
      builder: (context, child) {
        final themeData = Theme.of(context);
        return Theme(
          data: themeData.copyWith(
            brightness: Brightness.light,
            textTheme: themeData.textTheme.copyWith(
              titleMedium: themeData.textTheme.titleMedium!.copyWith(
                color: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      });
}

Future<DateTime?> _showCupertinoDatePicker({
  required BuildContext context,
  required CupertinoDatePickerMode mode,
  DateTime? initialValue,
  DateTime? minimumDate,
  DateTime? maximumDate,
  required int minuteInterval,
}) async {
  final localizationUtil = LocalizationUtil.of(context);
  var value = initialValue;
  return await showModalBottomSheet<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Column(
          children: [
            Expanded(
              child: CupertinoDatePicker(
                mode: mode,
                onDateTimeChanged: (DateTime newValue) {
                  value = newValue;
                },
                initialDateTime: value,
                minimumDate: minimumDate,
                maximumDate: maximumDate,
                minuteInterval: minuteInterval,
                use24hFormat: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text(localizationUtil.cancel),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: Text(localizationUtil.ok),
                    onPressed: () => Navigator.pop(context, value),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

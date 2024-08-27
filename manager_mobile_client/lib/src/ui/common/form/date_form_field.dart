import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:manager_mobile_client/src/ui/common/date_picker.dart';
import 'package:manager_mobile_client/src/ui/format/date.dart';
import 'scrollable_form.dart';
import 'noneditable_text_field.dart';

class DateFormField extends FormField<DateTime> {
  final CupertinoDatePickerMode pickerMode;
  final DateTime minimumDate;
  final DateTime maximumDate;
  final int minuteInterval;
  final ValueChanged<DateTime> onChanged;

  DateFormField({
    Key key,
    DateTime initialValue,
    this.pickerMode = CupertinoDatePickerMode.dateAndTime,
    this.minimumDate,
    this.maximumDate,
    this.minuteInterval = 1,
    this.onChanged,
    String label,
    FormFieldValidator<DateTime> validator,
    bool enabled = true
  }) : super(
    key: key,
    initialValue: initialValue != null ? validateDateForPicker(initialValue, pickerMode, minuteInterval) : null,
    validator: validator,
    enabled: enabled,
    builder: (FormFieldState<DateTime> state) => _buildForState(state, label, enabled),
  );

  @override
  FormFieldState<DateTime> createState() => DateFormFieldState();

  static Widget _buildForState(DateFormFieldState state, String label, bool enabled) {
    final textField = buildCustomNoneditableTextField(
      context: state.context,
      text: format(state.value, state.widget.pickerMode),
      label: label,
      icon: Icon(state.widget.pickerMode == CupertinoDatePickerMode.time ? Icons.access_time : Icons.event_note),
      errorText: state.errorText,
      enabled: enabled,
    );
    if (enabled) {
      return InkWell(
        child: textField,
        onTap: () => _showPicker(state),
      );
    } else {
      return textField;
    }
  }

  static void _showPicker(DateFormFieldState state) async {
    FocusScope.of(state.context).unfocus();

    final newValue = await showCustomDatePicker(
      context: state.context,
      mode: state.widget.pickerMode,
      initialValue: state.value,
      minimumDate: state.widget.minimumDate,
      maximumDate: state.widget.maximumDate,
      minuteInterval: state.widget.minuteInterval
    );

    if (newValue != null && newValue != state.value) {
      state.value = newValue;
      if (state.widget.onChanged != null) state.widget.onChanged(newValue);
    }
  }

  static String format(DateTime date, CupertinoDatePickerMode pickerMode) {
    if (pickerMode == CupertinoDatePickerMode.time) {
      return formatTimeOnlySafe(date);
    } else if (pickerMode == CupertinoDatePickerMode.date) {
      return formatDateOnlySafe(date);
    } else {
      return formatDateSafe(date);
    }
  }
}

class DateFormFieldState extends ScrollableFormFieldState<DateTime> {
  set value(DateTime newValue) {
    didChange(newValue);
    validate();
  }

  @override
  DateFormField get widget => super.widget;
}

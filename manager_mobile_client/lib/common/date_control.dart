import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/button.dart';
import 'package:manager_mobile_client/common/date_picker.dart';
import 'package:manager_mobile_client/src/logic/core/date_utility.dart';
import 'package:manager_mobile_client/util/format/date.dart';

class DateControl extends StatefulWidget {
  final Color color;
  final DateTime initialValue;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;

  DateControl(
      {this.color, this.initialValue, this.onChanged, this.enabled = true});

  @override
  State<StatefulWidget> createState() => DateControlState();
}

class DateControlState extends State<DateControl> {
  @override
  void initState() {
    super.initState();
    _value = validateDateForPicker(
        widget.initialValue, CupertinoDatePickerMode.date);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: _iconSize,
          icon: Icon(Icons.chevron_left),
          color: widget.color,
          onPressed:
              widget.enabled && _canSetPreviousDay() ? _setPreviousDay : null,
        ),
        TextButton(
          onPressed: widget.enabled ? _showDatePicker : null,
          style: ButtonStyle(
              foregroundColor: MaterialStateColorUtility.allExceptDisabled(
                  widget.color,
                  disabledColor: Theme.of(context).disabledColor)),
          child: Text(formatDateOnly(_value), style: TextStyle(fontSize: 16)),
        ),
        IconButton(
          iconSize: _iconSize,
          icon: Icon(Icons.chevron_right),
          color: widget.color,
          onPressed: widget.enabled && _canSetNextDay() ? _setNextDay : null,
        ),
      ],
    );
  }

  static const _iconSize = 36.0;

  DateTime _value;

  void _setPreviousDay() {
    setState(() => _value = _value.subtract(Duration(days: 1)));
    if (widget.onChanged != null) widget.onChanged(_value);
  }

  void _setNextDay() {
    setState(() => _value = _value.add(Duration(days: 1)));
    if (widget.onChanged != null) widget.onChanged(_value);
  }

  bool _canSetPreviousDay() {
    return _value.subtract(Duration(days: 1)).millisecondsSinceEpoch >=
        _minimumDate.millisecondsSinceEpoch;
  }

  bool _canSetNextDay() {
    return _value.add(Duration(days: 1)).millisecondsSinceEpoch <=
        _maximumDate.millisecondsSinceEpoch;
  }

  void _showDatePicker() async {
    final newValue = await showCustomDatePicker(
        context: context,
        mode: CupertinoDatePickerMode.date,
        initialValue: _value,
        minimumDate: _minimumDate,
        maximumDate: _maximumDate);
    if (newValue != null && newValue != _value) {
      setState(() => _value = newValue);
      if (widget.onChanged != null) widget.onChanged(_value);
    }
  }

  DateTime get _minimumDate => DateTime(2000);
  DateTime get _maximumDate =>
      DateTime.now().beginningOfDay.add(Duration(days: 30));
}

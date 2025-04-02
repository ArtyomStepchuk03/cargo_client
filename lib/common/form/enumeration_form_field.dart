import 'package:flutter/material.dart';
import 'package:manager_mobile_client/util/types.dart';

import 'noneditable_text_field.dart';
import 'scrollable_form.dart';

class EnumerationFormField<T> extends FormField<T> {
  final List<T>? values;
  final Formatter<T> formatter;
  final ValueChanged<T>? onChanged;

  EnumerationFormField(BuildContext context,
      {Key? key,
      T? initialValue,
      this.values,
      required this.formatter,
      this.onChanged,
      required String label,
      FormFieldValidator<T>? validator,
      bool enabled = true})
      : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          enabled: enabled,
          builder: (FormFieldState<T> state) => _buildForState<T>(
              context, state as EnumerationFormFieldState<T>, label, enabled),
        );

  @override
  FormFieldState<T> createState() => EnumerationFormFieldState<T>();

  static Widget _buildForState<T>(BuildContext context,
      EnumerationFormFieldState<T> state, String label, bool enabled) {
    final textField = buildCustomNoneditableTextField(
      context: state.context,
      text: state.widget.formatter(context, state.value),
      label: label,
      icon: Icon(Icons.keyboard_arrow_right),
      errorText: state.errorText,
      enabled: enabled,
    );
    if (enabled) {
      return InkWell(
        child: textField,
        onTap: () => _showModalSheet<T>(state),
      );
    } else {
      return textField;
    }
  }

  static void _showModalSheet<T>(EnumerationFormFieldState<T> state) async {
    FocusScope.of(state.context).unfocus();
    T? newValue = await showModalBottomSheet<T>(
      context: state.context,
      builder: (BuildContext context) {
        final children = state.widget.values!.map((T value) {
          return ListTile(
            title: Text(state.widget.formatter(context, value)),
            onTap: () => Navigator.pop(context, value),
          );
        }).toList();
        return Column(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
    if (newValue != null && newValue != state.value) {
      state.value = newValue;
      if (state.widget.onChanged != null) {
        state.widget.onChanged!(newValue);
      }
    }
  }
}

class EnumerationFormFieldState<T> extends ScrollableFormFieldState<T> {
  set value(T? newValue) {
    didChange(newValue);
    validate();
  }

  @override
  EnumerationFormField<T> get widget => super.widget as EnumerationFormField<T>;
}

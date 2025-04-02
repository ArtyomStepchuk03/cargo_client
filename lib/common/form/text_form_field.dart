import 'package:flutter/material.dart';

import 'input_decoration.dart';
import 'noneditable_text_field.dart';
import 'scrollable_form.dart';

class CustomTextFormField extends FormField<String> {
  final bool loading;

  CustomTextFormField({
    Key? key,
    String? initialValue,
    String? label,
    this.loading = false,
    TextInputType? inputType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool autofocus = false,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          enabled: enabled,
          builder: (FormFieldState<String> state) => _buildForState(
            (state as CustomTextFormFieldState),
            label: label,
            inputType: inputType,
            textCapitalization: textCapitalization,
            autofocus: autofocus,
            enabled: enabled,
          ),
        );

  static Widget _buildForState<T>(CustomTextFormFieldState state,
      {String? label,
      TextInputType? inputType,
      required TextCapitalization textCapitalization,
      required bool autofocus,
      required bool enabled}) {
    if (state.loading) {
      return buildLoadingTextField(
          context: state.context,
          text: state.value,
          label: label,
          enabled: enabled);
    }
    return TextField(
      controller: state.controller,
      focusNode: state.focusNode,
      decoration: buildCustomInputDecoration(
          context: state.context,
          label: label,
          errorText: state.errorText,
          enabled: enabled),
      keyboardType: inputType,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      maxLines: null,
      enabled: enabled,
    );
  }

  @override
  FormFieldState<String> createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends ScrollableFormFieldState<String> {
  CustomTextFormFieldState() : _loading = false;

  TextEditingController get controller => _controller;
  FocusNode? get focusNode => _focusNode;

  set value(String? newValue) {
    _controller.text = newValue!;
    didChange(newValue);
    validate();
  }

  set loading(bool loading) => setState(() => _loading = loading);
  bool get loading => _loading;

  @override
  void reset() {
    super.reset();
    setState(() => _controller.text = widget.initialValue!);
  }

  @override
  bool validate() {
    focusNode?.unfocus();
    return super.validate();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _controller.addListener(_handleControllerChanged);
    _focusNode?.addListener(_handleFocusNodeChanged);
    _loading = widget.loading;
  }

  @override
  void didUpdateWidget(FormField<String> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loading = widget.loading;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    _focusNode?.dispose();
  }

  @override
  CustomTextFormField get widget => (super.widget as CustomTextFormField);

  late TextEditingController _controller;
  FocusNode? _focusNode;
  bool _loading;

  void _handleControllerChanged() {
    if (_controller.text != value) {
      didChange(_controller.text);
    }
  }

  void _handleFocusNodeChanged() {
    if (_focusNode?.hasFocus == false) {
      validate();
    }
  }
}

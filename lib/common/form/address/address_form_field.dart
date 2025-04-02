import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/address/address_input_body.dart';
import 'package:manager_mobile_client/common/form/noneditable_text_field.dart';
import 'package:manager_mobile_client/common/form/scrollable_form.dart';
import 'package:manager_mobile_client/common/search/search_widget.dart';
import 'package:manager_mobile_client/src/logic/external/places_service.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';

class AddressFormField extends FormField<String> {
  final PlacesService? placesService;
  final bool allowCustomAddress;
  final bool loading;
  final ValueChanged<String>? onChanged;

  AddressFormField({
    Key? key,
    String? initialValue,
    this.placesService,
    this.allowCustomAddress = true,
    this.loading = false,
    this.onChanged,
    required String label,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          enabled: enabled,
          builder: (FormFieldState<String> state) =>
              _buildForState(state as AddressFormFieldState, label, enabled),
        );

  static Widget _buildForState(
      AddressFormFieldState state, String label, bool enabled) {
    if (state.loading) {
      return buildLoadingTextField(context: state.context, label: label);
    }
    final textField = buildCustomNoneditableTextField(
      context: state.context,
      text: textOrEmpty(state.value),
      label: label,
      icon: Icon(Icons.keyboard_arrow_right),
      errorText: state.errorText,
      enabled: enabled,
    );
    if (enabled) {
      return InkWell(
        child: textField,
        onTap: () => _showInput(state),
      );
    }
    return textField;
  }

  static void _showInput(AddressFormFieldState state) async {
    final inputResult = await showCustomSearch(
      initialQuery: state.value,
      context: state.context,
      builder: (BuildContext context, String? query) {
        if (query == null) {
          return Container();
        }
        return AddressInputBody(
          placesService: state.widget.placesService!,
          query: query,
        );
      },
      actionBuilder: state.widget.allowCustomAddress
          ? (BuildContext context, String? query) {
              return IconButton(
                icon: Icon(Icons.check),
                onPressed: () =>
                    Navigator.pop(context, AddressInputResult(query)),
              );
            }
          : null,
    );

    if (inputResult != null) {
      state.setValueWithPlacesSearchResult(
          inputResult.address, inputResult.placesSearchResult);
      if (state.widget.onChanged != null) {
        state.widget.onChanged!(inputResult.address);
      }
    }
  }

  @override
  FormFieldState<String> createState() => AddressFormFieldState();
}

class AddressFormFieldState extends ScrollableFormFieldState<String> {
  AddressFormFieldState() : _loading = false;

  set value(String? newValue) => setValueWithPlacesSearchResult(newValue, null);

  void setValueWithPlacesSearchResult(
      String? newValue, PlacesSearchResult? placesSearchResult) {
    _placesSearchResult = placesSearchResult;
    didChange(newValue);
    validate();
  }

  set loading(bool loading) => setState(() => _loading = loading);
  bool get loading => _loading;

  PlacesSearchResult? get placesSearchResult => _placesSearchResult;

  @override
  void initState() {
    super.initState();
    _loading = widget.loading;
  }

  @override
  void didUpdateWidget(FormField<String> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loading = widget.loading;
  }

  @override
  AddressFormField get widget => (super.widget as AddressFormField);

  PlacesSearchResult? _placesSearchResult;
  bool _loading;
}

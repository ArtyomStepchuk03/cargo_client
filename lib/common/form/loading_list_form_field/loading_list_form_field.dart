import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/noneditable_text_field.dart';
import 'package:manager_mobile_client/common/form/scrollable_form.dart';
import 'package:manager_mobile_client/common/loading_list_view/loading_list_view.dart';
import 'package:manager_mobile_client/common/search/search_widget.dart';
import 'package:manager_mobile_client/src/logic/core/search_predicate.dart';
import 'package:manager_mobile_client/util/types.dart';

import 'loading_list_form_field_select_body.dart';

export 'package:manager_mobile_client/src/logic/core/search_predicate.dart';
export 'package:manager_mobile_client/src/logic/data_source/data_source.dart';

typedef LoadingListFormFieldAddCallback<T> = Future<T> Function(
    BuildContext context);

typedef LoadingListFormFieldDeleteCallback<T> = Future<T> Function(
    BuildContext context);

class LoadingListFormField<T> extends FormField<T> {
  final DataSource<T>? dataSource;
  final SearchPredicate<T>? searchPredicate;
  final Formatter<T>? formatter;
  final bool? fetchInitialValue;
  final LoadingListViewBuilder<T?>? listViewBuilder;
  final ValueChanged<T?>? onChanged;
  final String? noteText;
  final Color? noteColor;
  final VoidCallback? onRefresh;
  final LoadingListFormFieldSelectCallback<T>? onSelect;
  final LoadingListFormFieldAddCallback<T>? onAdd;
  final Function(T? item)? onDelete;
  final Function(T? item)? onUpdate;
  final T? selectedItem;

  LoadingListFormField(BuildContext context,
      {Key? key,
      T? initialValue,
      this.dataSource,
      this.searchPredicate,
      this.formatter,
      this.fetchInitialValue = false,
      this.listViewBuilder,
      this.onChanged,
      this.noteText,
      this.noteColor,
      this.onRefresh,
      this.onSelect,
      this.onAdd,
      this.onDelete,
      this.onUpdate,
      this.selectedItem,
      String? label,
      FormFieldValidator<T>? validator,
      bool enabled = true})
      : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          enabled: enabled,
          builder: (FormFieldState<T> state) => _buildForState<T>(
              context, state as LoadingListFormFieldState<T>?, label, enabled),
        );

  @override
  FormFieldState<T> createState() => LoadingListFormFieldState<T>();

  static Widget _buildForState<T>(BuildContext context,
      LoadingListFormFieldState<T>? state, String? label, bool enabled) {
    if (state!.fetching) {
      return buildLoadingTextField(context: state.context, label: label);
    }
    final textField = buildCustomNoneditableTextField(
      context: state.context,
      text: state.widget.formatter!(context, state.value),
      enabledBorderColor:
          state.widget.noteText != null ? state.widget.noteColor : null,
      disabledBorderColor:
          state.widget.noteText != null ? state.widget.noteColor : null,
      label: label,
      labelColor: state.widget.noteText != null ? state.widget.noteColor : null,
      icon: enabled ? Icon(Icons.keyboard_arrow_right) : null,
      helperText: state.widget.noteText,
      helperTextColor: state.widget.noteColor,
      errorText: state.errorText,
      enabled: enabled,
    );
    if (enabled) {
      return InkWell(
        child: textField,
        onTap: () => _showSelect<T>(state),
      );
    }
    return textField;
  }

  static void _showSelect<T>(LoadingListFormFieldState<T> state) async {
    FocusScope.of(state.context).unfocus();
    T? newValue = await showCustomSearch<T>(
      context: state.context,
      builder: (BuildContext context, String? query) {
        final filterPredicate = query != null
            ? SearchFilterPredicate<T>(state.widget.searchPredicate!, query)
            : null;
        return LoadingListFormFieldSelectBody<T>(
            dataSource: state.widget.dataSource,
            filterPredicate: filterPredicate,
            listViewBuilder: state.widget.listViewBuilder!,
            onRefresh: state.widget.onRefresh,
            onSelect: state.widget.onSelect,
            onDelete: state.widget.onDelete,
            selectedItem: state.widget.selectedItem,
            onUpdate: state.widget.onUpdate);
      },
      floatingActionButtonBuilder: ((BuildContext context, String? query) =>
          _buildAddButton(state)),
    );
    if (newValue != null && newValue != state.value) {
      state.value = newValue;
    }
  }

  static Widget? _buildAddButton<T>(LoadingListFormFieldState<T> state) {
    if (state.widget.onAdd == null) {
      return null;
    }
    return FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: Theme.of(state.context).primaryColor,
      onPressed: () async {
        T newValue = await state.widget.onAdd!(state.context);
        if (newValue != null) {
          Navigator.pop(state.context, newValue);
        }
      },
    );
  }
}

class LoadingListFormFieldState<T> extends ScrollableFormFieldState<T> {
  LoadingListFormFieldState() : _fetching = false;

  set value(T? newValue) {
    _fetching = false;
    didChange(newValue);
    if (widget.onChanged != null) {
      widget.onChanged!(newValue);
    }
    if (value != null) {
      validate();
    }
  }

  bool get fetching => _fetching;

  @override
  void reset() {
    _fetching = false;
    super.reset();
  }

  @override
  void initState() {
    super.initState();
    if (widget.dataSource != null) {
      _fetchIfNeeded();
    }
  }

  @override
  void didUpdateWidget(LoadingListFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dataSource != oldWidget.dataSource &&
        widget.dataSource != null) {
      _fetchIfNeeded();
    }
  }

  @override
  LoadingListFormField<T> get widget =>
      super.widget as LoadingListFormField<T>; // TODO: Костыль!

  bool _fetching;

  void _fetchIfNeeded() {
    if (!_fetching &&
        widget.enabled &&
        value == null &&
        widget.fetchInitialValue!) {
      _fetch(widget.dataSource!);
    }
  }

  void _fetch(DataSource<T> dataSource) async {
    _fetching = true;
    final portion = await dataSource.loadPortion(null, 2);
    if (mounted && _fetching) {
      if (value == null && portion.items?.length == 1) {
        value = portion.items?[0];
      } else {
        setState(() => _fetching = false);
      }
    }
  }
}

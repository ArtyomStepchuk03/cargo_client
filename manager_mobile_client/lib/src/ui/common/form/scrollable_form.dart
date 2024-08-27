import 'package:flutter/material.dart';

class ScrollableForm extends StatefulWidget {
  final EdgeInsets padding;
  final List<Widget> children;

  ScrollableForm({Key key, this.padding, this.children}) : super(key: key);

  static ScrollableFormState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ScrollableFormScopeWidget>()?.state;
  }

  @override
  State<StatefulWidget> createState() => ScrollableFormState();
}

class ScrollableFormState extends State<ScrollableForm> {
  void reset() => _formKey.currentState.reset();

  bool validate() {
    bool valid = _formKey.currentState.validate();
    if (_attentionFieldState != null) {
      _scrollController.position.ensureVisible(_attentionFieldState.context.findRenderObject());
      _attentionFieldState = null;
    }
    return valid;
  }

  void setNeedAttention(FormFieldState fieldState) {
    if (_attentionFieldState == null) {
      _attentionFieldState = fieldState;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ScrollableFormScopeWidget(
      state: this,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: widget.padding,
          child: Column(children: widget.children),
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  FormFieldState _attentionFieldState;
}

class _ScrollableFormScopeWidget extends InheritedWidget {
  final ScrollableFormState state;

  const _ScrollableFormScopeWidget({this.state, Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_ScrollableFormScopeWidget old) => true;
}

class ScrollableFormFieldState<T> extends FormFieldState<T> {
  @override
  bool validate() {
    final valid = super.validate();
    if (!valid) {
      final formState = ScrollableForm.of(context);
      if (formState != null) {
        formState.setNeedAttention(this);
      }
    }
    return valid;
  }
}

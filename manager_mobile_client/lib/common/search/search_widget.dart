import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/fullscreen_placeholder.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import '../app_bar.dart';

typedef SearchWidgetBuilder = Widget Function(
    BuildContext context, String query);

Future<T> showCustomSearch<T>({
  BuildContext context,
  String initialQuery,
  SearchWidgetBuilder builder,
  SearchWidgetBuilder actionBuilder,
  SearchWidgetBuilder floatingActionButtonBuilder,
}) async {
  return await Navigator.of(context).push<T>(
    MaterialPageRoute(
      builder: (BuildContext context) => _SearchWidget(
        initialQuery: initialQuery,
        builder: builder,
        actionBuilder: actionBuilder,
        floatingActionButtonBuilder: floatingActionButtonBuilder,
      ),
    ),
  );
}

class _SearchWidget extends StatefulWidget {
  final String initialQuery;
  final SearchWidgetBuilder builder;
  final SearchWidgetBuilder actionBuilder;
  final SearchWidgetBuilder floatingActionButtonBuilder;

  _SearchWidget(
      {this.initialQuery,
      this.builder,
      this.actionBuilder,
      this.floatingActionButtonBuilder});

  @override
  State<StatefulWidget> createState() => _SearchState();
}

class _SearchState extends State<_SearchWidget> {
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _textEditingController.addListener(_handleSearchTextChanged);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_handleSearchTextChanged);
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_focusRequested) {
      _focusRequested = true;
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _textEditingController.text;
    return Scaffold(
      appBar: buildAppBar(
        title: _buildSearchField(),
        actions: _buildActions(query),
      ),
      body: _buildBody(query),
      floatingActionButton: widget.floatingActionButtonBuilder != null
          ? widget.floatingActionButtonBuilder(context, query)
          : null,
    );
  }

  TextEditingController _textEditingController;
  FocusNode _focusNode;
  var _focusRequested = false;

  Widget _buildSearchField() {
    final localizationUtil = LocalizationUtil.of(context);
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
    );
    return TextField(
      controller: _textEditingController,
      focusNode: _focusNode,
      decoration: InputDecoration(
          hintText: localizationUtil.search,
          hintStyle: textStyle,
          border: InputBorder.none,
          suffixIcon: _textEditingController.text.isNotEmpty
              ? _buildCircleIconButton(
                  icon: Icons.clear, onPressed: _textEditingController.clear)
              : null),
      style: textStyle,
    );
  }

  Widget _buildCircleIconButton({IconData icon, VoidCallback onPressed}) {
    const size = 30.0;
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.grey[300])),
            Icon(icon, color: Theme.of(context).primaryColor, size: size * 0.6)
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(String query) {
    if (widget.actionBuilder == null) {
      return null;
    }
    final action = widget.actionBuilder(context, query);
    if (action == null) {
      return null;
    }
    return [action];
  }

  Widget _buildBody(String query) {
    final localizationUtil = LocalizationUtil.of(context);
    final children = <Widget>[_buildContent(query)];
    if (query.isNotEmpty && query.length < 3) {
      children.add(_buildPlaceholder(localizationUtil.queryTooShort));
    }
    return Stack(children: children);
  }

  Widget _buildContent(String query) {
    if (query.length < 3) {
      return widget.builder(context, null);
    }
    return widget.builder(context, query);
  }

  Widget _buildPlaceholder(String text) {
    return Container(
      color: Colors.white,
      child: FullscreenPlaceholder(
        icon: Icons.search,
        text: text,
      ),
    );
  }

  void _handleSearchTextChanged() {
    setState(() {});
  }
}

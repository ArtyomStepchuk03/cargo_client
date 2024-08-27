import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'message_write/message_write_widget.dart';
import 'message_list_body.dart';
import 'message_list_strings.dart' as strings;

class MessageListWidget extends StatefulWidget {
  final Drawer drawer;
  final TransitionBuilder containerBuilder;

  MessageListWidget(this.drawer, this.containerBuilder);

  @override
  State<StatefulWidget> createState() => MessageListState();
}

class MessageListState extends State<MessageListWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
      ),
      drawer: widget.drawer,
      body: widget.containerBuilder(context, MessageListBody(
        key: _bodyKey,
      )),
      floatingActionButton: _buildWriteButton(context),
    );
  }

  final _bodyKey = GlobalKey<MessageListBodyState>();

  Widget _buildWriteButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () => _write(context),
      child: Icon(Icons.create),
    );
  }

  void _write(BuildContext context) async {
    final sent = await Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => MessageWriteWidget(),
      fullscreenDialog: true,
    ));
    if (sent != null && sent) {
      _bodyKey.currentState.setNeedReload();
    }
  }
}

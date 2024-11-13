import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/feature/messages_page/widget/message_write/message_write_widget.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

import '../../../feature/messages_page/view/messages_page_body.dart';

class MessagesPage extends StatefulWidget {
  final Drawer drawer;
  final TransitionBuilder containerBuilder;

  MessagesPage(this.drawer, this.containerBuilder);

  @override
  State<StatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.messages),
      ),
      drawer: widget.drawer,
      body: widget.containerBuilder(
          context,
          MessageListBody(
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
    final sent = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MessageWriteWidget(),
          fullscreenDialog: true,
        ));
    if (sent != null && sent) {
      _bodyKey.currentState.setNeedReload();
    }
  }
}

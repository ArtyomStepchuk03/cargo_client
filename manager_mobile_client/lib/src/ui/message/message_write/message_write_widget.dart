import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/message.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import '../../common/app_bar.dart';
import 'message_write_strings.dart' as strings;
import 'message_write_body.dart';

class MessageWriteWidget extends StatefulWidget {
  final MessageWriteInformation information;

  MessageWriteWidget({this.information});
  factory MessageWriteWidget.clone(Message message) => MessageWriteWidget(information: cloneMesage(message));

  @override
  State<StatefulWidget> createState() => MessageWriteState();
}

class MessageWriteState extends State<MessageWriteWidget> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: MessageWriteBody(key: _bodyKey, information: widget.information),
    );
  }

  final _bodyKey = GlobalKey<MessageWriteBodyState>();

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.send), onPressed: () => _send(context)),
    ];
  }

  void _send(BuildContext context) async {
    final information = _bodyKey.currentState.validate();
    if (information == null) {
      return;
    }

    showActivityDialog(context, strings.saving);
    final serverAPI = DependencyHolder.of(context).network.serverAPI.messages;

    try {
      await serverAPI.send(information.recipients, information.title, information.body);
      Navigator.pop(context);
      Navigator.pop(context, true);
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }
}

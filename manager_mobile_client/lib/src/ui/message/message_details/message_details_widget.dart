import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/intersperse.dart';
import 'package:manager_mobile_client/src/logic/server_api/message_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/app_bar.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/src/ui/format/safe_format.dart';
import 'package:manager_mobile_client/src/ui/format/date.dart';
import 'package:manager_mobile_client/src/ui/format/role.dart';
import 'package:manager_mobile_client/src/ui/format/user.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/message/message_write/message_write_widget.dart';
import 'package:manager_mobile_client/src/ui/message/message_list_body.dart';
import 'message_details_strings.dart' as strings;

class MessageDetailsWidget extends StatelessWidget {
  final Message message;
  final MessageListBodyState listBodyState;

  MessageDetailsWidget({this.message, this.listBodyState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: Text(strings.title),
        actions: _buildActions(context),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      children: [
        _buildField(strings.recipients, _formatRecipients(message)),
        _buildField(strings.messageTitle, textOr(message.title, placeholder: strings.noTitle)),
        _buildField(strings.messageBody, textOrEmpty(message.body)),
        _buildField(strings.sent, formatDateSafe(message.date)),
      ].intersperse(SizedBox(height: 6)).toList(),
    );
  }

  String _formatRecipients(Message message) {
    if (message.user != null) {
      return formatUserSafe(message.user);
    }
    if (message.role != null) {
      return formatRole(message.role);
    }
    return strings.allUsers;
  }

  Widget _buildField(String name, String value) {
    return RichText(
      textAlign: TextAlign.start,
      softWrap: true,
      text: TextSpan(
        children: [
          TextSpan(text: '$name: ', style: TextStyle(fontSize: 16, color: Colors.grey)),
          TextSpan(text: value, style: TextStyle(fontSize: 16, color: Colors.black)),
        ]
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [_buildMoreMenuButton(context)];
  }

  PopupMenuButton _buildMoreMenuButton(BuildContext context) {
    return PopupMenuButton<GestureTapCallback>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<GestureTapCallback>(value: () => _showWriteWidget(context), child: Text(strings.clone)),
        PopupMenuItem<GestureTapCallback>(value: () => _delete(context), child: Text(strings.delete)),
      ],
      onSelected: (action) => action(),
    );
  }

  void _showWriteWidget(BuildContext context) async {
    final sent = await Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (BuildContext context) => MessageWriteWidget.clone(message),
      fullscreenDialog: true,
    ));
    if (sent != null && sent) {
      listBodyState.setNeedReload();
    }
  }

  void _delete(BuildContext context) async {
    final confirmed = await showQuestionDialog(context, strings.confirmDelete);
    if (!confirmed) {
      return;
    }
    showDefaultActivityDialog(context);
    final dependencyState = DependencyHolder.of(context);
    final serverAPI = dependencyState.network.serverAPI.messages;
    try {
      await serverAPI.delete(message);
      Navigator.pop(context);
      Navigator.pop(context);
      if (listBodyState != null) {
        listBodyState.removeMessage(message);
      }
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }
}

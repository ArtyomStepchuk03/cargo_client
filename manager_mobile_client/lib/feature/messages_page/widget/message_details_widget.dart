import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/confirm_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/messages_page/view/messages_page_body.dart';
import 'package:manager_mobile_client/feature/messages_page/widget/message_write/message_write_widget.dart';
import 'package:manager_mobile_client/src/logic/core/intersperse.dart';
import 'package:manager_mobile_client/src/logic/server_api/message_server_api.dart';
import 'package:manager_mobile_client/util/format/date.dart';
import 'package:manager_mobile_client/util/format/role.dart';
import 'package:manager_mobile_client/util/format/safe_format.dart';
import 'package:manager_mobile_client/util/format/user.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class MessageDetailsWidget extends StatelessWidget {
  final Message message;
  final MessageListBodyState listBodyState;

  MessageDetailsWidget({this.message, this.listBodyState});

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.viewMessage),
        actions: _buildActions(context),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      children: [
        _buildField(
            localizationUtil.recipients, _formatRecipients(context, message)),
        _buildField(localizationUtil.messageTitle,
            textOr(message.title, placeholder: localizationUtil.noTitle)),
        _buildField(localizationUtil.messageBody, textOrEmpty(message.body)),
        _buildField(localizationUtil.sent, formatDateSafe(message.date)),
      ].intersperse(SizedBox(height: 6)).toList(),
    );
  }

  String _formatRecipients(BuildContext context, Message message) {
    final localizationUtil = LocalizationUtil.of(context);
    if (message.user != null) {
      return formatUserSafe(context, message.user);
    }
    if (message.role != null) {
      return formatRole(context, message.role);
    }
    return localizationUtil.allUsers;
  }

  Widget _buildField(String name, String value) {
    return RichText(
      textAlign: TextAlign.start,
      softWrap: true,
      text: TextSpan(children: [
        TextSpan(
            text: '$name: ',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
        TextSpan(
            text: value, style: TextStyle(fontSize: 16, color: Colors.black)),
      ]),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [_buildMoreMenuButton(context)];
  }

  PopupMenuButton _buildMoreMenuButton(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return PopupMenuButton<GestureTapCallback>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<GestureTapCallback>(
            value: () => _showWriteWidget(context),
            child: Text(localizationUtil.clone)),
        PopupMenuItem<GestureTapCallback>(
            value: () => _delete(context),
            child: Text(localizationUtil.delete)),
      ],
      onSelected: (action) => action(),
    );
  }

  void _showWriteWidget(BuildContext context) async {
    final sent = await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MessageWriteWidget.clone(message),
          fullscreenDialog: true,
        ));
    if (sent != null && sent) {
      listBodyState.setNeedReload();
    }
  }

  void _delete(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final confirmed = await showQuestionDialog(
        context, localizationUtil.confirmDeleteMessage);
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

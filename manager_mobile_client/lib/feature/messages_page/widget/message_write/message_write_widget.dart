import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/messages_page/widget/message_write/message_write_form_fields.dart';
import 'package:manager_mobile_client/src/logic/server_api/message_server_api.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

class MessageWriteWidget extends StatefulWidget {
  final MessageWriteInformation information;

  MessageWriteWidget({this.information});
  factory MessageWriteWidget.clone(Message message) =>
      MessageWriteWidget(information: cloneMesage(message));

  @override
  State<StatefulWidget> createState() => MessageWriteState();
}

class MessageWriteState extends State<MessageWriteWidget> {
  final _formKey = GlobalKey<ScrollableFormState>();
  final _recipientsKey =
      GlobalKey<LoadingListFormFieldState<MessageRecipients>>();
  final _titleKey = GlobalKey<FormFieldState<String>>();
  final _bodyKey = GlobalKey<FormFieldState<String>>();

  Widget build(BuildContext context) {
    final dependencyState = DependencyHolder.of(context);
    final localizationUtil = LocalizationUtil.of(context);

    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.writeMessage),
        actions: _buildActions(context),
      ),
      body: buildFormGroup([
        buildFormRow(
          Icons.people,
          buildMessageRecipientsFormField(
            context,
            dependencyState: dependencyState,
            key: _recipientsKey,
            initialValue: widget.information?.recipients,
          ),
        ),
        buildFormRow(
          Icons.create,
          CustomTextFormField(
            key: _titleKey,
            initialValue: widget.information?.title,
            label: localizationUtil.messageTitle,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        buildFormRow(
          Icons.message,
          CustomTextFormField(
            key: _bodyKey,
            initialValue: widget.information?.body,
            label: localizationUtil.messageBody,
            validator: RequiredValidator(context),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ]),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.send), onPressed: () => _send(context)),
    ];
  }

  void _send(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final information = validate();
    if (information == null) {
      return;
    }

    showActivityDialog(context, localizationUtil.saving);
    final serverAPI = DependencyHolder.of(context).network.serverAPI.messages;

    try {
      await serverAPI.send(
          information.recipients, information.title, information.body);
      Navigator.pop(context);
      Navigator.pop(context, true);
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  MessageWriteInformation validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    final information = MessageWriteInformation();
    information.recipients = _recipientsKey.currentState.value;
    information.title = _titleKey.currentState.value;
    information.body = _bodyKey.currentState.value;
    return information;
  }
}

class MessageWriteInformation {
  MessageRecipients recipients;
  String title;
  String body;
}

MessageWriteInformation cloneMesage(Message message) {
  var information = MessageWriteInformation();
  if (message.user != null) {
    information.recipients = MessageRecipients.user(message.user);
  } else if (message.role != null) {
    information.recipients = MessageRecipients.role(message.role);
  } else {
    information.recipients = MessageRecipients.all();
  }
  information.title = message.title;
  information.body = message.body;
  return information;
}

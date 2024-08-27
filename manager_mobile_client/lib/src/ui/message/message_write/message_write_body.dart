import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/server_api/message_server_api.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/validators/common_validators.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'message_write_strings.dart' as strings;
import 'message_write_form_fields.dart';

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

class MessageWriteBody extends StatefulWidget {
  final MessageWriteInformation information;

  MessageWriteBody({Key key, this.information}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MessageWriteBodyState();
}

class MessageWriteBodyState extends State<MessageWriteBody> {
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

  @override
  Widget build(BuildContext context) {
    final dependencyState = DependencyHolder.of(context);
    return buildForm(key: _formKey, children: [
      _buildMainGroup(dependencyState),
    ]);
  }

  final _formKey = GlobalKey<ScrollableFormState>();

  final _recipientsKey = GlobalKey<LoadingListFormFieldState<MessageRecipients>>();
  final _titleKey = GlobalKey<FormFieldState<String>>();
  final _bodyKey = GlobalKey<FormFieldState<String>>();

  Widget _buildMainGroup(DependencyState dependencyState) {
    final dependencyState = DependencyHolder.of(context);
    return buildFormGroup([
      buildFormRow(Icons.people,
        buildMessageRecipientsFormField(
          dependencyState: dependencyState,
          key: _recipientsKey,
          initialValue: widget.information?.recipients,
        ),
      ),
      buildFormRow(Icons.create,
        CustomTextFormField(
          key: _titleKey,
          initialValue: widget.information?.title,
          label: strings.messageTitle,
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
      buildFormRow(Icons.message,
        CustomTextFormField(
          key: _bodyKey,
          initialValue: widget.information?.body,
          label: strings.messageBody,
          validator: RequiredValidator(),
          textCapitalization: TextCapitalization.sentences,
        ),
      ),
    ]);
  }
}

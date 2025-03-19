import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

Widget buildContactNameFormRow(BuildContext context,
    {Key? key,
    String? initialValue,
    FormFieldValidator<String>? validator,
    bool autofocus = false,
    bool enabled = true}) {
  final localizationUtil = LocalizationUtil.of(context);
  return buildFormRow(
    Icons.person,
    CustomTextFormField(
      key: key,
      inputType: TextInputType.text,
      initialValue: initialValue,
      label: localizationUtil.contactName,
      validator: validator,
      autofocus: autofocus,
      enabled: enabled,
    ),
  );
}

Widget buildContactPhoneNumberFormRow(BuildContext context,
    {Key? key,
    String? initialValue,
    FormFieldValidator<String>? validator,
    bool enabled = true}) {
  final localizationUtil = LocalizationUtil.of(context);
  return buildFormRow(
      Icons.phone,
      CustomTextFormField(
        key: key,
        initialValue: initialValue,
        label: localizationUtil.contactPhoneNumber,
        validator: validator,
        inputType: TextInputType.phone,
        enabled: enabled,
      ));
}

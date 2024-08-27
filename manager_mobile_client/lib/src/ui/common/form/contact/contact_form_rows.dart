import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'contact_strings.dart' as strings;

Widget buildContactNameFormRow({Key key, String initialValue, FormFieldValidator<String> validator, bool autofocus = false, bool enabled = true}) {
  return buildFormRow(Icons.person,
    CustomTextFormField(
      key: key,
      initialValue: initialValue,
      label: strings.contactName,
      validator: validator,
      autofocus: autofocus,
      enabled: enabled,
    )
  );
}

Widget buildContactPhoneNumberFormRow({Key key, String initialValue, FormFieldValidator<String> validator, bool enabled = true}) {
  return buildFormRow(Icons.phone,
    CustomTextFormField(
      key: key,
      initialValue: initialValue,
      label: strings.contactPhoneNumber,
      validator: validator,
      inputType: TextInputType.phone,
      enabled: enabled,
    )
  );
}

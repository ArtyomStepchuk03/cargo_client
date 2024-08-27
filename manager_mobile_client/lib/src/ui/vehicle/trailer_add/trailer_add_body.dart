import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/trailer.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/validators/common_validators.dart';
import 'trailer_add_strings.dart' as strings;

class TrailerAddBody extends StatefulWidget {
  final Carrier carrier;

  TrailerAddBody({Key key, this.carrier}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TrailerAddBodyState();
}

class TrailerAddBodyState extends State<TrailerAddBody> {
  Trailer validate() {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    final trailer = Trailer();
    trailer.number = _numberKey.currentState.value;
    trailer.tonnage = int.parse(_tonnageKey.currentState.value);
    trailer.carrier = widget.carrier;
    return trailer;
  }

  @override
  Widget build(BuildContext context) {
    return buildForm(key: _formKey, children: [
      _buildMainGroup(),
    ]);
  }

  final _formKey = GlobalKey<ScrollableFormState>();

  final _numberKey = GlobalKey<FormFieldState<String>>();
  final _tonnageKey = GlobalKey<FormFieldState<String>>();

  Widget _buildMainGroup() {
    return buildFormGroup([
      buildFormRow(Icons.local_shipping,
        CustomTextFormField(
          key: _numberKey,
          initialValue: '',
          label: strings.stateNumber,
          validator: TrailerNumberValidator.required(),
        )
      ),
      buildFormRow(null,
        buildCustomIntegerFormField(
          key: _tonnageKey,
          initialValue: '',
          label: strings.tonnage,
          validator: makeRequiredTonnageValidator(decimal: false),
        )
      ),
    ]);
  }
}

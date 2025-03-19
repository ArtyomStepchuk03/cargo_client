import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/app_bar.dart';
import 'package:manager_mobile_client/common/dialogs/activity_dialog.dart';
import 'package:manager_mobile_client/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/common/form/form.dart';
import 'package:manager_mobile_client/common/form/form_fields.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/trailer.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/common_validators.dart';

class AddTrailerPage extends StatefulWidget {
  final Carrier? carrier;

  AddTrailerPage({this.carrier});

  @override
  State<StatefulWidget> createState() => _AddTrailerPageState();
}

class _AddTrailerPageState extends State<AddTrailerPage> {
  final _formKey = GlobalKey<ScrollableFormState>();

  final _numberKey = GlobalKey<FormFieldState<String>>();
  final _tonnageKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return Scaffold(
      appBar: buildAppBar(
        title: Text(localizationUtil.newTrailer),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () => _save(context),
          ),
        ],
      ),
      body: buildForm(key: _formKey, children: [
        buildFormGroup([
          buildFormRow(
            Icons.local_shipping,
            CustomTextFormField(
              key: _numberKey,
              initialValue: '',
              label: localizationUtil.stateNumber,
              validator: TrailerNumberValidator.required(context),
            ),
          ),
          buildFormRow(
            null,
            buildCustomIntegerFormField(
              context,
              key: _tonnageKey,
              initialValue: '',
              label: localizationUtil.tonnage,
              validator: makeRequiredTonnageValidator(context, decimal: false),
            ),
          ),
        ]),
      ]),
    );
  }

  void _save(BuildContext context) async {
    final localizationUtil = LocalizationUtil.of(context);
    final trailer = validate();
    if (trailer == null) {
      return;
    }

    try {
      final serverAPI =
          DependencyHolder.of(context)?.network.serverAPI.trailers;
      showActivityDialog(context, localizationUtil.saving);

      final bool exist =
          await serverAPI!.exists(trailer.number, trailer.carrier);
      if (exist) {
        Navigator.pop(context);
        showErrorDialog(context, localizationUtil.trailerExists);
        return;
      }

      await serverAPI.create(trailer);
      Navigator.pop(context);
      Navigator.pop(context, trailer);
    } on Exception {
      Navigator.pop(context);
      showDefaultErrorDialog(context);
    }
  }

  Trailer? validate() {
    if (!_formKey.currentState!.validate()!) {
      return null;
    }
    final trailer = Trailer();
    trailer.number = _numberKey.currentState!.value!;
    trailer.tonnage = int.parse(_tonnageKey.currentState!.value!);
    trailer.carrier = widget.carrier;
    return trailer;
  }
}

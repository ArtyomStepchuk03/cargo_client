import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/core/number_parse.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/loading_point.dart';
import 'package:manager_mobile_client/src/logic/concrete_data/unloading_point.dart';
import 'package:manager_mobile_client/src/ui/common/button.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/error_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/dialogs/information_dialog.dart';
import 'package:manager_mobile_client/src/ui/common/form/form.dart';
import 'package:manager_mobile_client/src/ui/common/form/form_fields.dart';
import 'package:manager_mobile_client/src/ui/format/safe_format.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/validators/common_validators.dart';
import 'order_details_strings.dart' as strings;

class OrderDistanceFormRow extends StatefulWidget {
  final num initialValue;
  final LoadingPoint loadingPoint;
  final UnloadingPoint unloadingPoint;
  final FormFieldValidator<String> validator;
  final bool editing;
  final bool manualEditing;

  OrderDistanceFormRow({Key key, this.initialValue, this.loadingPoint, this.unloadingPoint, this.validator, this.editing = false, this.manualEditing = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrderDistanceFormRowState();
}

class OrderDistanceFormRowState extends State<OrderDistanceFormRow> {
  num get distance {
    if (_fieldKey.currentState.value.isEmpty) {
      return null;
    }
    return parseDecimal(_fieldKey.currentState.value);
  }

  @override
  Widget build(BuildContext context) {
    final FormFieldValidator<String> defaultValidator = NumberValidator(decimal: false, minimum: 0);
    return buildFormRow(null,
      Row(
        children: [
          Expanded(child: buildCustomIntegerFormField(
            key: _fieldKey,
            initialValue: numberOrEmpty(widget.initialValue),
            label: strings.distanceInKilometers,
            validator: widget.validator ?? defaultValidator,
            enabled: widget.editing && widget.manualEditing,
            loading: _loading,
          )),
          if (widget.editing) ...[
            SizedBox(width: 16),
            buildButton(context,
              child: Text(strings.getDistance),
              onPressed: widget.loadingPoint != null && widget.unloadingPoint != null ? _fetchDistance : null,
            ),
          ],
        ],
      ),
    );
  }

  final _fieldKey = GlobalKey<CustomTextFormFieldState>();
  var _loading = false;

  void _fetchDistance() async {
    if (_loading) {
      return;
    }
    setState(() => _loading = true);
    try {
      final serverAPI = DependencyHolder.of(context).network.serverAPI.distances;
      final distance = await serverAPI.get(widget.loadingPoint, widget.unloadingPoint);
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      if (distance == null) {
        _fieldKey.currentState.value = '';
        await showInformationDialog(context, strings.distanceMissing);
        return;
      }
      _fieldKey.currentState.value = '$distance';
    } on Exception {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      await showDefaultErrorDialog(context);
    }
  }
}

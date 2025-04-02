import 'package:flutter/material.dart';

import 'multiple_validator.dart';
import 'number_validator.dart';
import 'required_validator.dart';

export 'multiple_validator.dart';
export 'number_validator.dart';
export 'range_validator.dart';
export 'required_validator.dart';
export 'time_validator.dart';
export 'vehicle_number_validator.dart';

FormFieldValidator<String> makeTruckCountValidator(BuildContext context) =>
    NumberValidator(context, decimal: false, minimum: 1, maximum: 15);

FormFieldValidator<String?> makeRequiredTruckCountValidator(
    BuildContext context) {
  return MultipleValidator<String?>(
      [RequiredValidator(context), makeTruckCountValidator(context)]);
}

FormFieldValidator<String> makeTonnageValidator(BuildContext context,
    {bool decimal = true}) {
  return NumberValidator(context, decimal: decimal, minimum: 1, maximum: 99);
}

FormFieldValidator<String?> makeRequiredTonnageValidator(BuildContext context,
    {bool decimal = true}) {
  return MultipleValidator<String?>([
    RequiredValidator(context),
    makeTonnageValidator(context, decimal: decimal)
  ]);
}

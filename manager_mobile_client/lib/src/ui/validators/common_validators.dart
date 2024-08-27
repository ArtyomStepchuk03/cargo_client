import 'package:flutter/material.dart';
import 'multiple_validator.dart';
import 'required_validator.dart';
import 'number_validator.dart';

export 'multiple_validator.dart';
export 'required_validator.dart';
export 'number_validator.dart';
export 'time_validator.dart';
export 'range_validator.dart';
export 'vehicle_number_validator.dart';

FormFieldValidator<String> makeTruckCountValidator() {
  return NumberValidator(decimal: false, minimum: 1, maximum: 15);
}

FormFieldValidator<String> makeRequiredTruckCountValidator() {
  return MultipleValidator<String>([RequiredValidator(), makeTruckCountValidator()]);
}

FormFieldValidator<String> makeTonnageValidator({bool decimal = true}) {
  return NumberValidator(decimal: decimal, minimum: 1, maximum: 99);
}

FormFieldValidator<String> makeRequiredTonnageValidator({bool decimal = true}) {
  return MultipleValidator<String>([RequiredValidator(), makeTonnageValidator(decimal: decimal)]);
}

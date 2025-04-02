import 'package:flutter/material.dart';

class MultipleValidator<T> {
  final List<FormFieldValidator<T>> validators;

  MultipleValidator(this.validators);

  String? call(T value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}

String textOr(String? text, {required String placeholder}) {
  if (text == null) {
    return placeholder;
  }
  return text;
}

String textOrEmpty(String? text) {
  if (text == null) {
    return '';
  }
  return text;
}

String numberOrEmpty(num? number) {
  if (number == null) {
    return '';
  }
  return '$number';
}

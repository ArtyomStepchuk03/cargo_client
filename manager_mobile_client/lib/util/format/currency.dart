String formatCurrency(num value) {
  var string = value.toStringAsFixed(2);
  for (var position = string.length - (3 + 3); position > 0; position -= 3) {
    string = string.replaceRange(position, position, ' ');
  }
  return string;
}

String formatCurrencySafe(num value) {
  if (value == null) {
    return '';
  }
  return formatCurrency(value);
}

num parseDecimal(String string) {
  final invariant = _toInvariant(string);
  return num.parse(invariant);
}

num tryParseDecimal(String string) {
  final invariant = _toInvariant(string);
  return num.tryParse(invariant);
}

String _toInvariant(String string) {
  return string.replaceAll(',', '.');
}

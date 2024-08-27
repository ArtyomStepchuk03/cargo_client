T safeCast<T>(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is! T) {
    return null;
  }
  return value;
}

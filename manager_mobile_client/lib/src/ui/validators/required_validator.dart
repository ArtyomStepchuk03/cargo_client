import 'validators_strings.dart' as strings;

class RequiredValidator<T> {
  String call(T value) {
    if (value == null) {
      return strings.empty;
    }
    if (value is String && value.isEmpty) {
      return strings.empty;
    }
    return null;
  }
}

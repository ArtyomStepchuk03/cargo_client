abstract class Identifiable<T> {
  T get id;

  @override
  bool operator==(dynamic other) {
    if (other is! Identifiable<T>) {
      return false;
    }
    final Identifiable otherIdentifiable = other;
    return id == otherIdentifiable.id;
  }

  @override
  int get hashCode => id.hashCode;
}

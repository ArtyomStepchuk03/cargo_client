abstract class FilterPredicate<T> {
  bool call(T item);
}

class AndFilterPredicate<T> implements FilterPredicate<T> {
  final List<FilterPredicate<T>> predicates;

  AndFilterPredicate(this.predicates);

  bool call(T item) {
    for (final predicate in predicates) {
      if (!predicate(item)) {
        return false;
      }
    }
    return true;
  }
}

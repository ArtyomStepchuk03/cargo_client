import 'filter_predicate.dart';

abstract class SearchPredicate<T> {
  bool call(T item, String query);
}

class SearchFilterPredicate<T> implements FilterPredicate<T> {
  final SearchPredicate<T> searchPredicate;
  final String query;

  SearchFilterPredicate(this.searchPredicate, this.query);

  bool call(T item) => searchPredicate(item, query);
}

bool satisfiesQuery(String text, String query) {
  if (text == null) {
    return false;
  }
  return text.toLowerCase().contains(query.toLowerCase());
}

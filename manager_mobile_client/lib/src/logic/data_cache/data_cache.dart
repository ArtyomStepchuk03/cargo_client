import 'dart:math';

class LimitedDataCache<T> {
  void cache(List<T> items) => _items = items;
  List<T> get items => _items;

  void clear() => _items = null;

  List<T> _items;
}

class SkipPagedDataCache<T> {
  void cache(List<T> items, int skip, int limit) {
    if (skip <= _items.length) {
      _items.addAll(items.sublist(_items.length - skip));
      if (items.length < limit) {
        _finished = true;
      }
    }
  }

  List<T> getItems(int skip, int limit) {
    if (skip > _items.length) {
      return null;
    }
    if (skip + limit > _items.length && !_finished) {
      return null;
    }
    return _items.sublist(skip, min(skip + limit, _items.length));
  }

  void clear() {
    _items.clear();
    _finished = false;
  }

  final _items = <T>[];
  bool _finished = false;
}

import 'data_cache.dart';

class LimitedDataCacheMap<T, K> {
  LimitedDataCache<T> getCache(K key) {
    final existingCache = _caches[key];
    if (existingCache != null) {
      return existingCache;
    }
    final cache = LimitedDataCache<T>();
    _caches[key] = cache;
    return cache;
  }

  final _caches = <K, LimitedDataCache<T>>{};
}

class SkipPagedDataCacheMap<T, K> {
  SkipPagedDataCache<T> getCache(K key) {
    final existingCache = _caches[key];
    if (existingCache != null) {
      return existingCache;
    }
    final cache = SkipPagedDataCache<T>();
    _caches[key] = cache;
    return cache;
  }

  final _caches = <K, SkipPagedDataCache<T>>{};
}

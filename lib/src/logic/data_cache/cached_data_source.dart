import 'package:manager_mobile_client/src/logic/data_source/limited_data_source.dart';
import 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';

import 'data_cache.dart';

export 'package:manager_mobile_client/src/logic/data_source/limited_data_source.dart';
export 'package:manager_mobile_client/src/logic/data_source/paged_data_source.dart';

export 'data_cache.dart';

class CachedLimitedDataSource<T> implements LimitedDataSource<T> {
  final LimitedDataSource<T> base;
  final LimitedDataCache<T> cache;

  CachedLimitedDataSource(this.base, this.cache);

  Future<List<T?>> list() async {
    final cachedItems = cache.items;
    if (cachedItems != null) {
      return cachedItems;
    }
    final items = await base.list();
    cache.cache(items);
    return items;
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! CachedLimitedDataSource<T>) {
      return false;
    }
    final CachedLimitedDataSource<T> otherSource = other;
    return base == otherSource.base;
  }

  @override
  int get hashCode => base.hashCode;
}

class CachedSkipPagedDataSource<T> implements SkipPagedDataSource<T> {
  final SkipPagedDataSource<T> base;
  final SkipPagedDataCache<T> cache;

  CachedSkipPagedDataSource(this.base, this.cache);

  Future<List<T>> list(int skip, int limit) async {
    final cachedItems = cache.getItems(skip, limit);
    if (cachedItems != null) {
      return cachedItems;
    }
    final items = await base.list(skip, limit);
    cache.cache(items, skip, limit);
    return items;
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! CachedSkipPagedDataSource<T>) {
      return false;
    }
    final CachedSkipPagedDataSource<T> otherSource = other;
    return base == otherSource.base;
  }

  @override
  int get hashCode => base.hashCode;
}

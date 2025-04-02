import 'data_source.dart';

abstract class SkipPagedDataSource<T> {
  Future<List<T>> list(int skip, int limit);
}

class SkipPagedDataSourceAdapter<T> implements DataSource<T> {
  final SkipPagedDataSource<T> base;

  SkipPagedDataSourceAdapter(this.base);

  Future<DataPortion<T>> loadPortion(dynamic token, int suggestedLimit) async {
    int skip = token ?? 0;
    final items = await base.list(skip, suggestedLimit);
    return DataPortion(items,
        nextPortionToken: skip + items.length,
        finished: items.length < suggestedLimit);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! SkipPagedDataSourceAdapter) {
      return false;
    }
    final SkipPagedDataSourceAdapter otherSource = other;
    return base == otherSource.base;
  }

  @override
  int get hashCode => base.hashCode;
}

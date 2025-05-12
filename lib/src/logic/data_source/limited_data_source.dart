import 'data_source.dart';

abstract class LimitedDataSource<T> {
  Future<List<T?>?> list();
}

class LimitedDataSourceAdapter<T> implements DataSource<T> {
  final LimitedDataSource<T> base;

  LimitedDataSourceAdapter(this.base);

  Future<DataPortion<T>> loadPortion(dynamic token, int suggestedLimit) async {
    final items = await base.list();
    return DataPortion.finished(items);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! LimitedDataSourceAdapter) {
      return false;
    }
    final LimitedDataSourceAdapter otherSource = other;
    return base == otherSource.base;
  }

  @override
  int get hashCode => base.hashCode;
}

import 'dart:ui' show hashValues;
import 'package:manager_mobile_client/src/logic/core/filter_predicate.dart';
import 'data_source.dart';

class FilterDataSource<T> implements DataSource<T> {
  final DataSource<T> base;
  final FilterPredicate<T> predicate;

  FilterDataSource(this.base, this.predicate);

  Future<DataPortion<T>> loadPortion(dynamic token, int suggestedLimit) async {
    final portion = await base.loadPortion(token, suggestedLimit);
    return DataPortion(portion.items.where(predicate).toList(), nextPortionToken: portion.nextPortionToken, finished: portion.finished);
  }

  @override
  bool operator==(dynamic other) {
    if (other is! FilterDataSource<T>) {
      return false;
    }
    final FilterDataSource<T> otherSource = other;
    return base == otherSource.base && predicate == otherSource.predicate;
  }

  @override
  int get hashCode => hashValues(base, predicate);
}

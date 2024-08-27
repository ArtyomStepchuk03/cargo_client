import 'dart:ui' show hashValues;
import 'package:collection/collection.dart';
import 'data_source.dart';

class FixedItemsDataSource<T> implements DataSource<T> {
  final DataSource<T> base;
  final List<T> fixedItems;

  FixedItemsDataSource(this.base, this.fixedItems);

  Future<DataPortion<T>> loadPortion(dynamic token, int suggestedLimit) async {
    var portion = await base.loadPortion(token, suggestedLimit);
    if (token == null) {
      return DataPortion(fixedItems + portion.items, nextPortionToken: portion.nextPortionToken, finished: portion.finished);
    }
    return portion;
  }

  @override
  bool operator==(dynamic other) {
    if (other is! FixedItemsDataSource<T>) {
      return false;
    }
    final FixedItemsDataSource<T> otherSource = other;
    return base == otherSource.base && ListEquality().equals(fixedItems, otherSource.fixedItems);
  }

  @override
  int get hashCode => hashValues(base, fixedItems);
}

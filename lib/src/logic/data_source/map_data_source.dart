import 'package:manager_mobile_client/src/logic/core/function.dart';

import 'data_source.dart';

class MapDataSource<T, R> implements DataSource<R> {
  final DataSource<T>? base;
  final MapFunction<T, R>? mapFunction;

  MapDataSource(this.base, this.mapFunction);

  Future<DataPortion<R>> loadPortion(dynamic token, int suggestedLimit) async {
    final portion = await base?.loadPortion(token, suggestedLimit);
    return DataPortion(portion!.items!.map(mapFunction!).toList(),
        nextPortionToken: portion.nextPortionToken, finished: portion.finished);
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! MapDataSource<T, R>) {
      return false;
    }
    final MapDataSource<T, R> otherSource = other;
    return base == otherSource.base && mapFunction == otherSource.mapFunction;
  }

  @override
  int get hashCode => Object.hash(base, mapFunction);
}

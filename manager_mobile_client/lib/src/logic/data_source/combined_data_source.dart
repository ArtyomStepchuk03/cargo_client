import 'package:collection/collection.dart';
import 'data_source.dart';

class CombinedDataPortionToken {
  final int dataSourceIndex;
  final dynamic innerToken;
  CombinedDataPortionToken(this.dataSourceIndex, this.innerToken);
}

class CombinedDataSource<T> implements DataSource<T> {
  final List<DataSource<T>> dataSources;

  CombinedDataSource(this.dataSources);

  Future<DataPortion<T>> loadPortion(dynamic token, int suggestedLimit) async {
    CombinedDataPortionToken internalToken = token;
    final dataSourceIndex = internalToken?.dataSourceIndex ?? 0;
    final portion = await dataSources[dataSourceIndex].loadPortion(internalToken?.innerToken, suggestedLimit);
    if (portion.finished) {
      if (dataSourceIndex + 1 >= dataSources.length) {
        return DataPortion.finished(portion.items);
      }
      return DataPortion(portion.items, nextPortionToken: CombinedDataPortionToken(dataSourceIndex + 1, null));
    }
    return DataPortion(portion.items, nextPortionToken: CombinedDataPortionToken(dataSourceIndex, portion.nextPortionToken));
  }

  @override
  bool operator==(dynamic other) {
    if (other is! CombinedDataSource<T>) {
      return false;
    }
    final CombinedDataSource<T> otherSource = other;
    return ListEquality().equals(dataSources, otherSource.dataSources);
  }

  @override
  int get hashCode => dataSources.hashCode;
}

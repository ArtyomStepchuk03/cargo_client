class DataPortion<T> {
  List<T> items;
  dynamic nextPortionToken;
  bool finished;

  DataPortion(this.items, {this.nextPortionToken, this.finished = false});
  DataPortion.finished(List<T> items) : this(items, finished: true);
}

abstract class DataSource<T> {
  Future<DataPortion<T>> loadPortion(dynamic token, int suggestedLimit);
}

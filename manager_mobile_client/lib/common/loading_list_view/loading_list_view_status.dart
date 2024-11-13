class LoadingListViewStatus {
  LoadingListViewStatus.finished() : _type = _LoadingListViewStatusType.finished;
  LoadingListViewStatus.more(dynamic nextPortionToken) : _type = _LoadingListViewStatusType.more, _nextPortionToken = nextPortionToken;
  LoadingListViewStatus.failed(Exception exception) : _type = _LoadingListViewStatusType.failed, _exception = exception;

  bool get finished => _type == _LoadingListViewStatusType.finished;
  bool get more => _type == _LoadingListViewStatusType.more;
  bool get failed => _type == _LoadingListViewStatusType.failed;

  dynamic get nextPortionToken => _nextPortionToken;
  Exception get exception => _exception;

  _LoadingListViewStatusType _type;
  dynamic _nextPortionToken;
  Exception _exception;
}

enum _LoadingListViewStatusType {
  finished,
  more,
  failed
}

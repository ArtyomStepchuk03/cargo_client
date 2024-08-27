class RequestIdentifierGenerator {
  int getNext() {
    int requestId = _counter;
    ++_counter;
    return requestId;
  }

  int _counter = 1;
}

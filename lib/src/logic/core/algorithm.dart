extension ListAlgorithm<T> on List<T> {
  List<T> removeAndReturnWhere(bool test(T element)) {
    var result = <T>[];
    int counter = 0;
    while (counter < length) {
      if (test(this[counter])) {
        result.add(this[counter]);
        removeAt(counter);
        continue;
      }
      ++counter;
    }
    return result;
  }
}

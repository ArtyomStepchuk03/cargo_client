abstract class DeletionMarking {
  bool? get deleted;
}

extension DeleteMarkingIterableUtility<T extends DeletionMarking> on List<T?> {
  List<T?> excludeDeleted() {
    return where((object) {
      if (object?.deleted == null) {
        return false;
      }
      return object!.deleted == false;
    }).toList();
  }
}
